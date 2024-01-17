function Invoke-ThreatLockerApiPaged {
    [CmdletBinding()]
    param(
        [String]
        $Endpoint,

        [Alias('OrganisationId')]
        [AllowEmptyString()]
        [ValidatePattern('^[a-f0-9-]{36}$')]
        [String]
        $OrgId,

        # used to construct a query string. e.g. @{type="device"} would be appended to the URI as ?type=device
        [Hashtable]
        $Query = @{},

        # body of the request
        [Hashtable]
        $Body = @{},

        [ValidateSet('GET', 'POST', 'PUT')]
        [String]
        $Method = 'GET',

        [Int]
        $PageSize = 100,

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
