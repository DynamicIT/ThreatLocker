function Copy-ThreatLockerACApp {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('OrganizationId')]
        [String]
        $Org,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('ApplicationId')]
        [String]
        $AppId,

        [Parameter(Mandatory)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).OrgId | FilterArguments $args[2] })]
        [Alias('NewOrganizationId')]
        [String]
        $NewOrg,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('NewAppName', 'Name')]
        [String]
        $NewName
    )
    process {
        $orgId = (Get-ThreatLockerOrg $Org).OrgId
        $newOrgId = (Get-ThreatLockerOrg $NewOrg).OrgId

        $app = Get-ThreatLockerACApp -Org $orgId -AppId $AppId
        $appFiles = Get-ThreatLockerACAppFile -Org $orgId -AppId $AppId

        if (-not $NewName) {
            $NewName = $app.Name
        }
        $desc = "Copied from $orgId/$AppId`n`n$( $app.Description )"

        New-ThreatLockerACApp -Org $newOrgId -Name $NewName -Description $desc -OsType $app.OsType -AppFiles $appFiles
    }
}
