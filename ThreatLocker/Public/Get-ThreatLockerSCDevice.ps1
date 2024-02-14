function Get-ThreatLockerSCDevice {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [Alias('OrgId')]
        [String]
        $Org
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).Id
        $splat = @{
            Method = 'POST'
            Endpoint = 'StorageDevice/StorageDeviceGetByParameters'
            Body = @{}
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
