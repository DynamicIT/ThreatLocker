function Get-CacheItem {
    [CmdletBinding(DefaultParameterSetName="SingleItemLookup")]
    param (
        # Cache object
        [Parameter(Mandatory)]
        [Hashtable]
        $Cache,

        [Parameter(Mandatory)]
        [String[]]
        $Group,

        [Parameter(ParameterSetName="SingleItemLookup", Mandatory)]
        [String[]]
        $Property,

        # Cache item's identifier
        [Parameter(ParameterSetName="SingleItemLookup", Mandatory, ValueFromPipeline)]
        [String]
        $Key,

        # Default value to return if there's nothing cached for this key.
        [Parameter(ParameterSetName="SingleItemLookup")]
        [Object]
        $Default,

        # Return all items from the group.
        [Parameter(ParameterSetName="AllItems", Mandatory)]
        [Switch]
        $All
    )
    begin {
        $groupKey = "__$( $Group -join '_' )"
        if ($All -and -not (Test-Cache -Cache $Cache -Group $Group)) {
            Write-Error "${groupKey}: no cache available for this group."
        }
        if ($Property) {
            # Error if the group or any properties are missing.
            $null = Test-Cache -Cache $Cache -Group $Group -Property $Property -Key $null
        }
        $groupCache = $Cache[$groupKey]
    }
    process {
        if ($All) {
            return $groupCache.__all__
        } else {
            foreach ($prop in $Property) {
                if ($groupCache[$prop].Contains($Key)) {
                    $dupeCount = $groupCache["__${prop}__duplicates__"][$key]
                    if ($dupeCount) {
                        Write-Warning "$( $dupeCount + 1) records found with ${prop}: $Key. Only the first will be returned."
                    }
                    return $groupCache[$prop].$Key
                }
            }
            if ($PSBoundParameters.ContainsKey('Default')) {
                return $Default
            } else {
                throw [Management.Automation.PropertyNotFoundException]  "${groupKey}, ${Property}: No value for '$Key'"
            }
        }
    }
}
