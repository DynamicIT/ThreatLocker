function Get-ThreatLockerACPolicyDetail {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [String]
        $PolicyId
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $splat = @{
            Method = 'GET'
            Endpoint = 'Policy/PolicyGetById'
            Query = @{ policyId = $PolicyId }
            OrgId = $orgId
        }
        Invoke-ThreatLockerApi @splat
    }
}
