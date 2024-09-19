function Get-ThreatLockerComputer {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, ParameterSetName="LookupIdOrName", Position = 1)]
        [ArgumentCompleter({
            $org = $args[4].Org
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).ComputerId | FilterArguments $args[2]
        })]
        [Alias('ComputerId', 'ComputerName')]
        [String]
        $Computer,

        [Switch]
        $RefreshCache
    )
    begin {
        $ctx = Get-ThreatLockerContext
    }
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        if ($RefreshCache -or -not (Test-Cache -Cache $ctx.Cache -Group $orgId, 'Computers')) {
            Initialize-ThreatLockerComputerAndGroupCache -OrgId $orgId
        }
        if ($Computer) {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Computers' -Property 'ComputerId','Name' -Key $Computer
        } else {
            Get-CacheItem -Cache $ctx.Cache -Group $orgId,'Computers' -All
        }
    }
}
