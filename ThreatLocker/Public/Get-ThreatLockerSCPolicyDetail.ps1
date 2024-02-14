function Get-ThreatLockerSCPolicyDetail {
    [CmdletBinding(DefaultParameterSetName="AllComputers")]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [Alias('OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [String]
        $StoragePolicyId
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).Id
        $splat = @{
            Method = 'GET'
            Endpoint = 'StoragePolicy/StoragePolicyGetById'
            Query = @{ storagePolicyId = $StoragePolicyId }
            OrgId = $orgId
        }
        Invoke-ThreatLockerApi @splat
    }
}
