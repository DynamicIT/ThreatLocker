function Get-ThreatLockerComputerDetail {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="GroupLookup", Position = 1, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).GroupId | FilterArguments $args[2]
        })]
        [Alias('GroupId', 'GroupName', 'ComputerGroupId')]
        [String]
        $Group,

        [Parameter(Mandatory, ParameterSetName="ComputerLookup", ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).ComputerId | FilterArguments $args[2]
        })]
        [Alias('ComputerId', 'ComputerName')]
        [String]
        $Computer,

        # Get computers from org & child organisations.
        [Parameter(Mandatory, ParameterSetName="IncludeChildOrgs", Position = 1)]
        [Switch]
        $Recurse,

        [String]
        $Search = "",

        [Switch]
        $RefreshCache
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $body = @{
            searchText = $Search
            computerGroup = "00000000-0000-0000-0000-000000000000"
            orderBy = "computername"
            pageSize = 25
            pageNumber = 1
            computerId = "00000000-0000-0000-0000-000000000000"
            childOrganizations = [Boolean]$Recurse
            showLastCheckIn = $true
            isAscending = $true
            kindOfAction = ""
            hasComputerPassword = $false
        }
        if ($Group) {
            $body['computerGroup'] = (Get-ThreatLockerGroup -Org $Org -Group $Group).GroupId
        } elseif ($Computer) {
            $body['computerId'] = (Get-ThreatLockerComputer -Org $Org -Computer $Computer).ComputerId
        }
        $splat = @{
            Method = 'POST'
            Endpoint = 'Computer/ComputerGetByAllParameters'
            Body = $Body
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
