$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

function Initialize-BuildEnvironment {
    param (
        [IO.DirectoryInfo]
        $Path = $(if ($PSScriptRoot -eq '') { "." } else { $PSScriptRoot }),

        [IO.FileInfo]
        $Manifest,

        # Version for new build
        [Version]
        $NextVersion
    )
    begin {
        function GetModule {
            if (-not $Manifest) {
                $parentName = $Path.Name
                $Manifest = Get-Item -ErrorAction SilentlyContinue (Join-Path $Path.FullName "$parentName\$parentName.psd1")
            }
            if (-not $Manifest) {
                $manifests = Get-Item -Path (Join-Path $Path.FullName "*\*.psd1")
                $Manifest = $manifests | Where-Object { $_.Directory.Name -eq $_.BaseName } | Select-Object -First 1
            }
            if (-not $Manifest) {
                throw "Unable to find module manifest"
            }
            [PSCustomObject]@{
                Name = $manifest.BaseName
                ModuleDir = $manifest.Directory.FullName
                ManifestPath = $manifest.FullName
            }
        }
    }
    process {
        $module = GetModule
        $lastVersion = [Version](Import-PowerShellDataFile -Path $module.ManifestPath).ModuleVersion
        if (-not $NextVersion) {
            $NextVersion = [Version]::new($lastVersion.Major, $lastVersion.Minor, $lastVersion.Build + 1)
        }
        $outputDir = Join-Path $Path.FullName "Output\$( $module.Name )\$NextVersion"
        if (-not (Test-Path -PathType Container $outputDir)) {
            $null = New-Item -ItemType Directory $outputDir
        }
        [PSCustomObject]@{
            ModuleName = $module.Name
            ModuleDir = $module.ModuleDir
            ManifestPath = $module.ManifestPath
            LastVersion = $lastVersion.ToString()
            NextVersion = $NextVersion.ToString()
            OutputDir = $outputDir
        }
    }
}


function Convert-ModuleToSingleFile {
    [CmdletBinding()]
    [OutputType([String])]
    param (
        [Parameter(Mandatory)]
        [IO.FileInfo]
        $Manifest,

        # Paths to recursively import .ps1 files. Relative paths will be evaluated from the manifest's parent folder.
        [String[]]
        $ImportFrom = @("Classes", "Public", "Private")
    )
    process {
        $moduleContent = [Collections.Generic.List[String]]@()

        $manifestData = Import-PowerShellDataFile -Path $Manifest.FullName
        $rootModule = Join-Path $Manifest.Directory.FullName $manifestData.RootModule
        $header = (Get-Content $rootModule) -match '^#Require|Set-StrictMode|^\$ErrorActionPreference'
        $header | ForEach-Object { $moduleContent.Add($_) }

        foreach ($path in $ImportFrom) {
            if (-not [IO.Path]::IsPathRooted($path)) {
                $path = Join-Path $Manifest.Directory.FullName $path
            }
            Get-ChildItem -File -Recurse (Join-Path $path "*.ps1") | Sort-Object FullName | ForEach-Object {
                $moduleContent.Add((Get-Content -Raw -Path $_))
            }
        }

        $standaloneLF = '(?<!\r)\n'
        $moduleContent -join "`r`n" -replace $standaloneLF, "`r`n"
    }
}


function Build-SingleFileModule {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory)]
        [IO.FileInfo]
        $Manifest,

        [Parameter(Mandatory)]
        [IO.DirectoryInfo]
        $OutputDir,

        # The manifests will be updated with this version number
        [Parameter(Mandatory)]
        [String]
        $NewVersion,

        # This comments out ScriptsToProcess in the built module manifest. This is desirable if the scripts are only
        # included to work around the issue with classes being used for function param types - including them  directly
        # in the module's .psm1 file seems to resolve the issue.
        [Switch]
        $RemoveScriptsToProcess,

        # Paths to recursively import .ps1 files. Relative paths will be evaluated from the manifest's parent folder.
        [String[]]
        $ImportFrom = @("Classes", "Private", "Public"),

        # If this is not set, all .ps1 files in the Public folder will used as function names (without the extension)
        [String[]]
        $FunctionsToExport
    )
    process {
        if (-not (Test-Path -PathType Container $OutputDir)) {
            $null = New-Item -ItemType Directory -Force $OutputDir
        }
        $moduleContent = Convert-ModuleToSingleFile -Manifest $Manifest -ImportFrom $ImportFrom
        # using New-Item so that the file is UTF8 without BOM. This is required for Ninja.
        $newModuleFile = join-path $outputdir "$( $manifest.basename ).psm1"
        $null = New-Item -Path $newModuleFile -value $modulecontent

        if (-not $FunctionsToExport) {
            $public = Get-ChildItem -Recurse -File (Join-Path $Manifest.Directory.FullName "Public\*.ps1")
            $FunctionsToExport = $public.BaseName
        }
        Update-ModuleManifest -Path $Manifest.FullName -ModuleVersion $NewVersion -FunctionsToExport '*'

        $newManifest = Join-Path $OutputDir $Manifest.Name
        $null = Copy-Item -Path $Manifest.FullName -Destination $newManifest
        if ($RemoveScriptsToProcess) {
            # Update-ModuleManifest can't seem to handle an emtpy array or null value for -ScriptsToProcess
            $regex = '(?m)^\s*ScriptsToProcess\s*=\s*(@\()?(["''][^"'']+["''],\s*)*["''][^"'']+["''][ \t]*\)?[ \t]*\r?$'
            Set-Content -Path $newManifest -Value ((Get-Content -Raw $newManifest) -replace $regex, '<# $0 #>')
        }
        Update-ModuleManifest -Path $newManifest -RootModule "$( $manifest.basename ).psm1" -FunctionsToExport $FunctionsToExport

        [PSCustomObject]@{
            ModuleFile = $newModuleFile
            ManifestPath = $Manifest.FullName
            Version = $NewVersion
        }
    }
}


function Merge-SingleFileModuleWithScript {
    param (
        [Parameter(Mandatory)]
        [Alias('Module')]
        [IO.FileInfo]
        $ModuleFile,

        [Parameter(Mandatory)]
        [Alias('Script')]
        [IO.FileInfo]
        $ScriptFile,

        # Defaults to
        [String]
        $OutputPath = $( Join-Path $ModuleFile.Directory.FullName $ScriptFile.Name )
    )
    process {
        $paramBlock = [Collections.Generic.List[String]]@()
        $script= [Collections.Generic.List[String]]@()
        $inParamBlock = $false
        Get-Content -Path $ScriptFile | ForEach-Object {
            if ($_ -match '^param\s*\(' -and $_ -notmatch '\)') {
                $inParamBlock = $true
                $paramBlock.Add($_)
            } elseif ($inParamBlock) {
                $paramBlock.Add($_)
                if ($_ -match '^\)') {
                    $inParamBlock = $false
                }
            } else {
                if ($_ -notmatch "\bImport-Module\b.+\b$( $ModuleFile.BaseName )\b") {
                    $script.Add($_)
                }
            }
        }
        $module = Get-Content -Encoding UTF8 $ModuleFile
        $combined = $paramBlock + $module + @('function main {') + $script + @('} main')
        New-Item -Path $OutputPath -Value ($combined -join "`r`n")
    }
}

$build = Initialize-BuildEnvironment

$buildParams = @{
    ImportFrom = "Classes", "Private", "Public"
    Manifest = $build.ManifestPath
    OutputDir = $build.OutputDir
    NewVersion = $build.NextVersion
    RemoveScriptsToProcess = $True
}
$singleFileModule = Build-SingleFileModule @buildParams
$singleFileScripts = Get-Item "Scripts\$( $build.ModuleName ).*.ps1" | ForEach-Object {
    Merge-SingleFileModuleWithScript -Module $singleFileModule.ModuleFile -Script $_.FullName
}

$cert = (Get-Item 'Cert:\CurrentUser\my\467B7FA02D65798DD1ED99E62535776CA9E86907')
Set-AuthenticodeSignature -Certificate $cert -TimestampServer 'http://timestamp.sectigo.com' -FilePath $singleFileModule.ModuleFile
$singleFileScripts | Set-AuthenticodeSignature -Certificate $cert -TimestampServer 'http://timestamp.sectigo.com'
