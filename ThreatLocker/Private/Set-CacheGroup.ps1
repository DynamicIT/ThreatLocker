function Initialize-CacheGroup {
    param (
        # Cache object
        [Parameter(Mandatory)]
        [Hashtable]
        $Cache,

        [Parameter(Mandatory)]
        [String[]]
        $Group,

        # Properties to index
        [String[]]
        $Property,

        [Object[]]
        $Items
    )
    process {
        $groupKey = "__$( $Group -join '_' )"
        $Cache[$groupKey] = @{}
        $Cache[$groupKey]['__all__'] = $Items
        foreach ($prop in $property) {
            $lookup = @{}
            $duplicates = @{}
            foreach ($item in $Items) {
                $key = $item.$prop
                if ($lookup.Contains($key)) {
                    $duplicates[$key]++
                } else {
                    $lookup[$key] = $item
                }
            }
            $Cache[$groupKey][$prop] = $lookup
            $Cache[$groupKey]["__${prop}__duplicates__"] = $duplicates
        }
    }
}
