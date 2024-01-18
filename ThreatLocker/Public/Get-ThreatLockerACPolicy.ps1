function Get-ThreatLockerACPolicy {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [Alias('OrgId')]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="GroupPolicy", Position = 1)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).Id | FilterArguments $args[2]
        })]
        [String]
        $Group,

        [Parameter(Mandatory, ParameterSetName="ComputerPolicy")]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).Id | FilterArguments $args[2]
        })]
        [String]
        $Computer,

        [String]
        $Search = ""
    )
    begin {
        $orgId = (Get-ThreatLockerOrg $Org).Id
    }
    process {
        $body = @{
            activeOnly = $true
            filter = ""
            isEnabled = $true
            searchText = $Search
            status = 0
            utcOffset = 0
        }
        if ($Group) {
            $body['computerGroupId'] = (Get-ThreatLockerGroup -Org $Org -Group $Group).Id
        } elseif ($Computer) {
            $body['computerGroupId'] = (Get-ThreatLockerComputer -Org $Org -Group $Computer).Id
        } else {
            Write-Error "Computer or Group need to be specified."
        }
        $splat = @{
            Method = 'POST'
            Endpoint = 'Policy/PolicyGetByParameters'
            Body = $Body
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
