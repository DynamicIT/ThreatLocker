function Invoke-ThreatLockerApiPaged {
    [CmdletBinding()]
    param(
        [String]
        $Endpoint,

        [Alias('OrganisationId')]
        [AllowEmptyString()]
        [ValidatePattern('^[a-f0-9-]{36}$')]
        [String]
        $OrgId = '00000000-0000-0000-0000-000000000000',

        # used to construct a query string. e.g. @{type="device"} would be appended to the URI as ?type=device
        [Collections.IDictionary]
        $Query = @{},

        # Body of the request. Must be a dictionary/hashtable.
        [Collections.IDictionary]
        $Body = @{},

        [ValidateSet('GET', 'POST', 'PUT')]
        [String]
        $Method = 'GET',

        [Int]
        $PageSize = 1000,

        [Int]
        $StartPage = 1
    )

    process {
        if ($Method -eq 'GET') {
            $cursor = $Query
        } else {
            $cursor = $Body
        }
        $cursor.pageSize = $PageSize
        $cursor.pageNumber = $StartPage
        $splat = @{
            Method = $Method
            Endpoint = $EndPoint
            WebRequest = $true
        }
        if ($OrgId) {
            $splat['OrgId'] = $OrgId
        }
        if ($Body.Count) {
            $splat['Body'] = $Body
        }
        if ($Query.Count) {
            $splat['Query'] = $Query
        }
        $totalPages = $StartPage
        while ($cursor.pageNumber -le $totalPages) {
            if ($totalPages -gt 1) {
                $percent = $cursor.pageNumber / $totalPages * 100
                Write-Progress -Activity $Endpoint -PercentComplete $percent -CurrentOperation "Page $( $cursor.pageNumber )"
            }
            $response = Invoke-ThreatLockerApi @splat
            $totalPages = (ConvertFrom-Json -InputObject $response.Headers.Pagination).totalPages
            ConvertFrom-Json -InputObject $response.Content | ForEach-Object { $_ }
            $cursor.pageNumber++
        }
    }
}
