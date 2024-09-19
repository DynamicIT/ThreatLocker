function Get-ThreatLockerOrg {
    [CmdletBinding(DefaultParameterSetName="AllRecords")]
    param (
        [Parameter(Mandatory, ParameterSetName="LookupIdOrName", Position = 1, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
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
            Get-CacheItem -Cache $ctx.Cache -Group 'Organizations' -Property 'OrgId','Name' -Key $Org
        } else {
            Get-CacheItem -Cache $ctx.Cache -Group 'Organizations' -All
        }
    }
}
