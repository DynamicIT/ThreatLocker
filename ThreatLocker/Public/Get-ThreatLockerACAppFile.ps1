function Get-ThreatLockerACAppFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [Alias('OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [Alias('ApplicationId')]
        [String]
        $AppId,

        [String]
        $Search = ""
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).Id
        $query = @{
            searchText = $Search
            applicationId = $AppId
        }
        $splat = @{
            Method = 'GET'
            Endpoint = 'ApplicationFile/ApplicationFileGetByApplicationId'
            Query = $Query
            OrgId = $orgId
        }
        Invoke-ThreatLockerApiPaged @splat
    }
}
