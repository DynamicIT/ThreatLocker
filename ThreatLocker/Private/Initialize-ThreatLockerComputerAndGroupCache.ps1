function Initialize-ThreatLockerComputerAndGroupCache {
    param(
        [Parameter(Mandatory)]
        [String]
        $OrgId
    )
    begin {
        $ctx = Get-ThreatLockerContext
    }
    process {
        $endpoint = 'ComputerGroup/ComputerGroupGetGroupAndComputer'
        $query = @{
            osType=0
            includeGlobal="true"
            includeAllPolicies="false"
            includeOrganizations="false"
            includeParentGroups="false"
            includeLoggedInObjects="false"
        }
        $response = Invoke-ThreatLockerApi -Method 'GET' -Endpoint $endpoint -Query $query -OrgId $OrgId

        $groups = $response | Where-Object label -in 'Other','Computer Groups' | Select-Object -ExpandProperty items | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.label
                GroupId = $_.value
                EntityType = $_.entityType
                OrgId = $OrgId
            }
        }
        Initialize-CacheGroup -Cache $ctx.Cache -Group $orgId,'Groups' -Property 'GroupId','Name' -Items $groups

        $computers = $response | Where-Object label -eq 'Computers' | Select-Object -ExpandProperty items | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.label
                ComputerId = $_.value
                EntityType = $_.entityType
                OrgId = $OrgId
            }
        }
        Initialize-CacheGroup -Cache $ctx.Cache -Group $orgId,'Computers' -Property 'ComputerId','Name' -Items $computers

    }
}
