function New-ThreatLockerACApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [Alias('AppName')]
        [String]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [String]
        $Description,

        [OsType]
        $OsType = 'Windows',

        [Object[]]
        $AppFiles = @()
    )
    process {
        if ($OsType -eq [OsType]::All) {
            throw "OsType 'All' is not supported when creating an application."
        }
        $counter = -$AppFiles.Count
        $clonedAppFiles = foreach ($file in $AppFiles) {
            $hash = [Ordered]@{}
            $file.PSObject.Properties | ForEach-Object {
                $hash[$_.Name] = $_.Value
            }
            $hash.applicationFileId = $counter
            $hash.applicationId = $null
            $hash.applicationName = $null
            $hash.organizationId = $null
            $hash.updateStatus = 1
            $counter++
            [PSCustomObject]$hash
        }

        #if (-not $osTypeLookup.Contains($osType)) {
        #    throw "Invalid OsType: $osType"
        #}
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $body = [Ordered]@{
            name = $Name
            description = $Description
            osType = [Int]$OsType
            isHidden = $false
            isBuiltIn = $false
            canEditApplication = $true
            canEditKeyFile = $false
            applicationFiles = $clonedAppFiles
            applicationFileUpdates = $clonedAppFiles
            removeApplicationFileIds = @()
            applicationUpdate = @{
                automaticUpdateLinkList = @()
            }
            keyPaths = @()
            builtInApplications = @()
        }
        Invoke-ThreatLockerApi -Method 'POST' -Endpoint 'Application/ApplicationInsert' -Body $body -OrgId $orgId
    }
}
