function Get-ThreatLockerSCDevice {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrgId', 'OrgName', 'OrganizationId')]
        [String]
        $Org
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $splat = @{
            Method = 'POST'
            Endpoint = 'StorageDevice/StorageDeviceGetByParameters'
            Body = @{}
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
