function Get-ThreatLockerOrg {
    [CmdletBinding(DefaultParameterSetName="AllRecords")]
    param (
        [Parameter(Mandatory, ParameterSetName="LookupIdOrName", Position = 1)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [Alias('IdOrName')]
        [String]
        $Org,

        [Switch]
        $RefreshCache
    )
    begin {
        $ctx = Get-ThreatLockerContext
    }
    process {
        if ($RefreshCache -or -not (Test-Cache -Cache $ctx.Cache -Group 'Organizations')) {
            Initialize-ThreatLockerOrgCache
        }
        if ($Org) {
            Get-CacheItem -Cache $ctx.Cache -Group 'Organizations' -Property 'Id','Name' -Key $Org
        } else {
            Get-CacheItem -Cache $ctx.Cache -Group 'Organizations' -All
        }
    }
}
