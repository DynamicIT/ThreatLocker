function Get-ThreatLockerSCPolicyDetail {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [String]
        $StoragePolicyId
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $splat = @{
            Method = 'GET'
            Endpoint = 'StoragePolicy/StoragePolicyGetById'
            Query = @{ storagePolicyId = $StoragePolicyId }
            OrgId = $orgId
        }
        Invoke-ThreatLockerApi @splat
    }
}
