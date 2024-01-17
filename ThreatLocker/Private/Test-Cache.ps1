function Test-Cache {
    [CmdletBinding(DefaultParameterSetName="GroupTest")]
    param (
        # Cache object
        [Parameter(Mandatory)]
        [Hashtable]
        $Cache,

        [Parameter(ParameterSetName="GroupTest", Mandatory)]
        [Parameter(ParameterSetName="PropertyTest", Mandatory)]
        [Parameter(ParameterSetName="KeyTest", Mandatory)]
        [String[]]
        $Group,

        [Parameter(ParameterSetName="PropertyTest", Mandatory)]
        [Parameter(ParameterSetName="KeyTest", Mandatory)]
        [String[]]
        $Property,

        # Cache item's identifier
        [Parameter(ParameterSetName="KeyTest", Mandatory)]
        [AllowEmptyString()]
        [String]
        $Key
    )
    process {
        $groupKey = "__$( $Group -join '_' )"
        if ($PsCmdlet.ParameterSetName -eq 'GroupTest') {
            return $Cache.Contains($groupKey)
        }
        if ($Cache.Contains($groupKey)) {
            $groupCache = $Cache[$groupKey]
        } else {
            Write-Error "${groupKey}: no cache available for this group."
        }
        if ($PsCmdlet.ParameterSetName -eq 'PropertyTest') {
            # true if all properties are present
            foreach ($prop in $Property) {
                if (-not $groupCache.Contains($prop)) {
                    return $false
                }
            }
            return $true
        }

        if ($PsCmdlet.ParameterSetName -eq 'KeyTest') {
            # True if any of the properties contain a matching key
            foreach ($prop in $Property) {
                if (-not $groupCache.Contains($prop)) {
                    Write-Error "${groupKey}: no index available for '$prop'"
                }
                if ($groupCache.$prop.Contains($Key)) {
                    return $true
                }
            }
            return $false
        }

        Write-Error "Unexpected ParameterSet: '$( $PsCmdlet.ParameterSetName )'"
    }
}
