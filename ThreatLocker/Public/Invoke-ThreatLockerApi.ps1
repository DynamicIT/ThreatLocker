function Invoke-ThreatLockerApi {
    [CmdletBinding(SupportsShouldProcess)]
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
        if ($Body -and $Body.Count) {
            $splat['Body'] = ConvertTo-Json -Compress -InputObject $body
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
