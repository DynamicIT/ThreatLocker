function Get-ThreatLockerSCPolicy {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="GroupPolicy", Position = 1, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).GroupId | FilterArguments $args[2]
        })]
        [Alias('GroupId', 'GroupName', 'ComputerGroupId')]
        [String]
        $Group,

        [Parameter(Mandatory, ParameterSetName="ComputerPolicy", ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).ComputerId | FilterArguments $args[2]
        })]
        [Alias('ComputerId', 'ComputerName')]
        [String]
        $Computer,

        [String]
        $Search = ""
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $body = @{
            activeOnly = $true
            filter = ""
            isEnabled = $true
            searchText = $Search
            status = 0
        }
        if ($Group) {
            $body['computerGroupId'] = (Get-ThreatLockerGroup -Org $Org -Group $Group).GroupId
        } elseif ($Computer) {
            $body['computerGroupId'] = (Get-ThreatLockerComputer -Org $Org -Group $Computer).ComputerId
        } else {
            Write-Error "Computer or Group need to be specified."
        }
        $splat = @{
            Method = 'POST'
            Endpoint = 'StoragePolicy/StoragePolicyGetByParameters'
            Body = $Body
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
