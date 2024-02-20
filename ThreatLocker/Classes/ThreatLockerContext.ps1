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
            $queryComponents = $Query.GetEnumerator() | ForEach-Object {
                "{0}={1}" -f [System.Uri]::EscapeDataString($_.Key), [System.Uri]::EscapeDataString($_.Value)
            }
            return "${joinedUri}?$( $queryComponents -join '&' )"
        }
    }
}
