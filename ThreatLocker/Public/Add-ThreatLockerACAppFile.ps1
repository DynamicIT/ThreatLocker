function Add-ThreatLockerACAppFile {
    [CmdletBinding(DefaultParameterSetName="HashOnly")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [Alias('ApplicationId')]
        [String]
        $AppId,

        [Parameter(Mandatory)]
        [OsType]
        $OsType,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="HashOnly")]
        [String]
        $Hash,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="NonHash")]
        [Alias('Certificate')]
        [String]
        $Cert,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="NonHash")]
        [Alias('Path')]
        [String]
        $FullPath,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="NonHash")]
        [Alias('Process')]
        [String]
        $ProcessPath,

        # Created By in the UI.
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="NonHash")]
        [String]
        $InstalledBy
    )
    begin {
        $notes = [DateTime]::Now.ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss'Z'") + " added from PowerShell"
    }
    process {
        if ($OsType -eq [OsType]::All) {
            throw "OsType 'All' is not supported when adding an application file."
        }
        if (-not ($Hash -or $Cert -or $FullPath)) {
            throw "At least one of Hash, Cert or FullPath must be specified."
        }
        if ($FullPath -and -not ($Cert -or $ProcessPath -or $InstalledBy)) {
            Write-Warning "Path only rules are risky. Consider adding Cert, ProcessPath or InstalledBy:  $FullPath"
        }
        $body = [Ordered]@{
            applicationFileId = 0
            applicationId = $AppId
            osType = [Int]$OsType
            hash = $Hash
            isHashOnly = [Boolean]$Hash
            cert = $Cert
            fullPath = $FullPath
            processPath = $ProcessPath
            installedBy = $InstalledBy
            notes = $notes

            applicationName = $null
            applicationFileDetails = $null
            createdBy = $null
            keyFile = $false
            maxSize = $null
            minSize = $null
            name = $null
            organizationId = $null
            originalCert = $null
            originalFullPath = $null
            originalHash = $null
            originalInstalledBy = $null
            originalKeyFile = $false
            originalNotes = $null
            originalProcessPath = $null
            updateStatus = 0
        }
        Invoke-ThreatLockerApi -Method 'POST' -Endpoint 'ApplicationFile/ApplicationFileInsert' -Body $body
    }
}
