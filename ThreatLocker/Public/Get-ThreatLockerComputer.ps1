function Get-ThreatLockerComputer {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="LookupIdOrName", Position = 1)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).Id | FilterArguments $args[2]
        })]
        [Alias('IdOrName')]
        [String]
        $Computer,

        [Switch]
        $RefreshCache
    )
    begin {
        $ctx = Get-ThreatLockerContext
        $orgId = (Get-ThreatLockerOrg $Org).Id
    }
    process {
        if ($RefreshCache -or -not (Test-Cache -Cache $ctx.Cache -Group $orgId, 'Computers')) {
            Initialize-ThreatLockerComputerAndGroupCache -OrgId $orgId
        }
        if ($Computer) {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Computers' -Property 'Id','Name' -Key $Computer
        } else {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Computers' -All
        }
    }
}
