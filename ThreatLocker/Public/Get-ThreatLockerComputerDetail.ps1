function Get-ThreatLockerComputerDetail {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [Alias('OrgId')]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="GroupLookup", Position = 1)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).Id | FilterArguments $args[2]
        })]
        [String]
        $Group,

        [Parameter(Mandatory, ParameterSetName="ComputerLookup")]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).Id | FilterArguments $args[2]
        })]
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
    begin {
        $ctx = Get-ThreatLockerContext
        $orgId = (Get-ThreatLockerOrg $Org).Id
    }
    process {
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
            $body['computerGroup'] = (Get-ThreatLockerGroup -Org $Org -Group $Group).Id
        } elseif ($Computer) {
            $body['computerId'] = (Get-ThreatLockerComputer -Org $Org -Computer $Computer).Id
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
