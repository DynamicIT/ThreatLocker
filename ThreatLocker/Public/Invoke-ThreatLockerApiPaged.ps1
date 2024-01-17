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
        $Query,

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
        $splat = @{
            Method = $Method
            Endpoint = $EndPoint
            Body = $Body
            OrgId = $OrgId
            WebRequest = $true
        }
        $Body.pageSize = $PageSize
        $Body.pageNumber = $StartPage
        $totalPages = $StartPage
        while ($Body.pageNumber -le $totalPages) {
            if ($totalPages -gt 1) {
                $percent = $Body.pageNumber / $totalPages * 100
                Write-Progress -Activity $Endpoint -PercentComplete $percent -CurrentOperation "Page $( $Body.pageNumber )"
            }
            $response = Invoke-ThreatLockerApi @splat
            $totalPages = (ConvertFrom-Json -InputObject $response.Headers.Pagination).totalPages
            ConvertFrom-Json -InputObject $response.Content | ForEach-Object { $_ }
            $Body.pageNumber++
        }
    }
}
