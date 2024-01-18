function Invoke-ThreatLockerApi {
    [CmdletBinding(SupportsShouldProcess)]
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

        # Body of the request. Strings are passed through as-is, any other object will be converted to JSON.
        [Object]
        $Body,

        [ValidateSet('GET', 'POST', 'PUT')]
        [String]
        $Method = 'GET',

        # Returns the a web request object, rather than JSON.
        [Switch]
        $WebRequest
    )

    begin {
        $context = Get-ThreatLockerContext
    }

    process {
        $headers = @{
            authorization = $context.AccessTokenPlain()
        }
        if ($OrgId) {
            $headers.managedorganizationid = $OrgId
        }
        $uri = $context.FullUri($Endpoint, $Query)
        $splat = @{
            WebSession = $context.Session
            Method = $Method
            Uri = $Uri
            Headers = $headers
            ContentType = "application/json"
        }
        if ($null -ne $Body) {
            if ($Body -is [String]) {
                $splat['Body'] = $Body
            } else {
                $splat['Body'] = ConvertTo-Json -Depth 10 -Compress -InputObject $body
            }
        }
        if ($PSCmdlet.ShouldProcess($uri, "$Method $Body")) {
            if ($WebRequest) {
                Invoke-WebRequest -UseBasicParsing @splat
            } else {
                Invoke-RestMethod @splat
            }
        }
    }
}
