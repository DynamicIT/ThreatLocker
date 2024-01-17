function Initialize-ThreatLockerOrgCache {
    param()
    begin {
        $ctx = Get-ThreatLockerContext
    }
    process {
        $top = Invoke-ThreatLockerApiPaged -Method 'POST' -Endpoint 'Organization/OrganizationGetChildOrganizationsByParameters' -PageSize 25
        $top = $top | Sort-Object -Descending computerCount
        $nav = Invoke-ThreatLockerApiPaged -Method 'GET' -Endpoint 'Organization/OrganizationGetListForNav' -Query @{ search='' }
        $flatNav = $nav | Convert-NestedToFlat -Property 'organizationHierarchyDtos'
        $seen = @{}
        $orgs = $top + $flatNav | ForEach-Object {
            if ($_ -and -not $seen.Contains($_.organizationId)) {
                $seen[$_.organizationId] = $true
                [PSCustomObject]@{
                    Name = $_.name
                    Id = $_.organizationId
                    ParentId = $_.parentId
                }
            }
        }
        Initialize-CacheGroup -Cache $ctx.Cache -Group 'Organizations' -Property 'Id','Name' -Items $orgs
    }
}
