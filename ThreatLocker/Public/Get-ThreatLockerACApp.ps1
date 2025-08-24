function Get-ThreatLockerACApp {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(ParameterSetName="AppId")]
        [Alias('ApplicationId')]
        [String]
        $AppId,

        [Parameter(ParameterSetName="Search")]
        [OsType]
        $OsType = 'Windows',

        [Parameter(ParameterSetName="Search")]
        [ValidateSet('All','Custom','BuiltIn')]
        [String]
        $AppType = 'Custom',

        [Parameter(ParameterSetName="Search")]
        [Switch]
        $IncludeChildOrgs,

        [Parameter(ParameterSetName="Search")]
        [Switch]
        $IncludeHidden,

        [Parameter(ParameterSetName="Search")]
        [Switch]
        $IncludeUnused,

        [Parameter(ParameterSetName="Search")]
        [ValidateSet('AppName','FullPath','ProcessPath', 'Hash', 'Certificate')]
        [String]
        $SearchType = 'AppName',

        [Parameter(ParameterSetName="Search")]
        [String]
        $Search = ""
    )
    begin {
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
        if ($AppId) {
            $query = @{
                applicationId = $AppId
            }
            Invoke-ThreatLockerApi -Endpoint "Application/ApplicationGetById" -Query $query -OrgId $orgId
        } else {
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
                osType = [Int]$OsType
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
}
