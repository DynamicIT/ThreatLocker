function Initialize-ThreatLockerOrgCache {
    param()
    begin {
        $ctx = Get-ThreatLockerContext
    }
    process {
        $top = Invoke-ThreatLockerApi -Method 'POST' -Endpoint 'Organization/OrganizationGetChildOrganizationsByParameters' -Body @{ pageSize=25; pageNumber=1 }
        $top = $top | Sort-Object -Descending computerCount
        $nav = Invoke-ThreatLockerApi -Method 'GET' -Endpoint 'Organization/OrganizationGetListForNav' -Query @{ search=''; pageSize=100; pageNumber=1 }
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
