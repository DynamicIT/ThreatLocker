function Get-ThreatLockerGroup {
    [CmdletBinding(DefaultParameterSetName="AllGroups")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="LookupIdOrName", Position = 1)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).GroupId | FilterArguments $args[2]
        })]
        [Alias('GroupId', 'GroupName', 'ComputerGroupId')]
        [String]
        $Group,

        [Switch]
        $RefreshCache
    )
    begin {
        $ctx = Get-ThreatLockerContext
    }
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        if ($RefreshCache -or -not (Test-Cache -Cache $ctx.Cache -Group $orgId,'Groups')) {
            Initialize-ThreatLockerComputerAndGroupCache -OrgId $orgId
        }
        if ($Group) {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Groups' -Property 'GroupId','Name' -Key $Group
        } else {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Groups' -All
        }
    }
}
