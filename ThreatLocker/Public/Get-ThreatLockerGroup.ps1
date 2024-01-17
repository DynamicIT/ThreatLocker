function Get-ThreatLockerGroup {
    [CmdletBinding(DefaultParameterSetName="AllGroups")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="LookupIdOrName", Position = 1)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).Id | FilterArguments $args[2]
        })]
        [Alias('IdOrName')]
        [String]
        $Group,

        [Switch]
        $RefreshCache
    )
    begin {
        $ctx = Get-ThreatLockerContext
        $orgId = (Get-ThreatLockerOrg $Org).Id
    }
    process {
        if ($RefreshCache -or -not (Test-Cache -Cache $ctx.Cache -Group $orgId,'Groups')) {
            Initialize-ThreatLockerComputerAndGroupCache -OrgId $orgId
        }
        if ($Group) {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Groups' -Property 'Id','Name' -Key $Group
        } else {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Groups' -All
        }
    }
}
