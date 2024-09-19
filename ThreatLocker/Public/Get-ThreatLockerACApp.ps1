function Get-ThreatLockerACApp {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [ValidateSet('All','Windows','Mac')]
        [String]
        $OsType = 'Windows',

        [ValidateSet('All','Custom','BuiltIn')]
        [String]
        $AppType = 'Custom',

        [Switch]
        $IncludeChildOrgs,

        [Switch]
        $IncludeHidden,

        [Switch]
        $IncludeUnused,

        [ValidateSet('AppName','FullPath','ProcessPath', 'Hash', 'Certificate')]
        [String]
        $SearchType = 'AppName',

        [String]
        $Search = ""
    )
    begin {
        $osTypeLookup = @{
            All = 0
            Windows = 1
            Mac = 2
        }
        $appTypeLookup = @{
            All = 0
            Custom = 1
            BuiltIn = 2
        }
        $searchTypeLookup = @{
            AppName = "app"
            FullPath = "full"
            ProcessPath = "process"
            Hash = "hash"
            Certificate = "cert"
        }
    }
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $body = @{
            searchText = $Search
            searchBy = $searchTypeLookup[$SearchType]
            orderBy = "name"
            isAscending = $true
            includeMaster = $true
            permittedApplications = [Boolean](-not $IncludeUnused)
            isBuiltInApplication = $false
            isHidden = [Boolean]$IncludeHidden
            isTemporary = $false
            category = $appTypeLookup[$AppType]
            osType = $osTypeLookup[$OsType]
            includeChildOrganizations = [Boolean]$IncludeChildOrgs
            countries = @()
            categories = @()
        }
        $splat = @{
            Method = 'POST'
            Endpoint = 'Application/ApplicationGetByParameters'
            Body = $Body
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
