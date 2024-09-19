function New-ThreatLockerOrg {
    [CmdletBinding(DefaultParameterSetName="AllRecords")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('ParentOrgId', 'ParentOrgName')]
        [String]
        $ParentOrg,

        # This is used for matching with deployment scripts
        [Parameter(Mandatory, Position = 1)]
        [Alias('Identifier')]
        [String]
        $Name,

        # This is displayed in the UI
        [String]
        $DisplayName = $Name
    )
    begin {
        $parentOrgId = (Get-ThreatLockerOrg -Org $ParentOrg).OrgId
        $template = Invoke-ThreatLockerApi -Method 'GET' -OrgId $parentOrgId -Endpoint 'Organization/OrganizationGetForInsertByParentId'
    }
    process {
        $template.name = $Name
        $template.displayName = $DisplayName
        $newOrg = Invoke-ThreatLockerApi -Method 'POST' -OrgId $parentOrgId -Endpoint 'Organization/OrganizationCreateChild' -Body $template
        Get-ThreatLockerOrg -Org $newOrg.organizationId -RefreshCache
    }
}
