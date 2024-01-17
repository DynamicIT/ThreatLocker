class ThreatLockerContext {
    [Uri] $BaseUri
    [Security.SecureString] $AccessToken
    [Microsoft.PowerShell.Commands.WebRequestSession] $Session
    [Hashtable] $Cache = @{}
    [String] AccessTokenPlain() {
        return [pscredential]::New("n/a", $this.AccessToken).GetNetworkCredential().Password
    }
    [String] FullUri([String]$Endpoint) {
        return $this.FullUri($Endpoint, @{})
    }
    [String] FullUri([String]$Endpoint, [Hashtable]$Query) {
        $joinedUri = "{0}/{1}" -f $this.BaseUri.AbsoluteUri.TrimEnd('/'), $Endpoint.TrimStart('/')
        if ($null -eq $Query -or $Query.Keys.Count -eq 0) {
            return $joinedUri
        } else {
            $queryBuilder = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
            foreach ($key in $Query.Keys) {
                $queryBuilder.Add($key, $Query[$key])
            }
            $uriBuilder = [System.UriBuilder]$joinedUri
            $uriBuilder.Query = $QueryBuilder.ToString()
            return $uriBuilder.ToString()
        }
    }
}
