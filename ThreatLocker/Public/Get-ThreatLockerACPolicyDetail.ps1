function Get-ThreatLockerACPolicyDetail {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1)]
        [String]
        $PolicyId
    )
    begin {
        $orgId = (Get-ThreatLockerOrg $Org).Id
    }
    process {
        $splat = @{
            Method = 'GET'
            Endpoint = 'Policy/PolicyGetById'
            Query = @{ policyId = $PolicyId }
            OrgId = $orgId
        }
        Invoke-ThreatLockerApi @splat
    }
}
