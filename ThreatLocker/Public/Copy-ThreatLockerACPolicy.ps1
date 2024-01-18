function Copy-ThreatLockerACPolicy {
    [CmdletBinding(DefaultParameterSetName = "SameOrg")]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [String]
        $Org,

        [Parameter(Mandatory, Position = 1)]
        [String]
        $PolicyId,

        # Target organisation. Defaults to match the source policy. If an org is specified, but no group or computer,
        # the target of the source policy is looked up, and the destination target will be set to a matching group
        # in the destination org. e.g. Org1:Workstations -> Org2:Workstations
        [ArgumentCompleter({ (Get-ThreatLockerOrg).Name + (Get-ThreatLockerOrg).Id | FilterArguments $args[2] })]
        [String]
        $NewOrg = $Org,

        # Target group to copy the policy into. If target not specified it defaults to the the source policy target.
        [Parameter(ParameterSetName = "TargetGroup")]
        [ArgumentCompleter({
                $org = $args[4].NewOrg
            (Get-ThreatLockerGroup $org).Name + (Get-ThreatLockerGroup $org).Id | FilterArguments $args[2]
            })]
        [String]
        $NewGroup,

        # Target group to copy the policy into. If target not specified it defaults to the the source policy target.
        [Parameter(ParameterSetName = "TargetComputer")]
        [ArgumentCompleter({
                $org = $args[4].NewOrg
            (Get-ThreatLockerComputer $org).Name + (Get-ThreatLockerComputer $org).Id | FilterArguments $args[2]
            })]
        [String]
        $NewComputer,

        # Defaults to source policy name + date time
        [String]
        $NewName,

        [Switch]
        $TopOfList,

        [Switch]
        $Enable
    )
    begin {
        $orgId = (Get-ThreatLockerOrg $Org).Id
        $newOrgId = (Get-ThreatLockerOrg $NewOrg).Id
    }
    process {
        $sourcePolicy = Get-ThreatLockerACPolicyDetail -Org $orgId -PolicyId $PolicyId
        if ($NewGroup) {
            $target = (Get-ThreatLockerGroup -Org $newOrgId -Group $NewGroup).Id
        } elseif ($NewComputer) {
            $target = (Get-ThreatLockerComputer -Org $newOrgId -Computer $NewComputer).Id
        } elseif ($orgId -ne $newOrgId) {
            $currentGroupName = (Get-ThreatLockerGroup -Org $orgId -Group $sourcePolicy.computerGroupId).Name
            try {
                $target = (Get-ThreatLockerGroup -Org $newOrgId -Group $currentGroupName).Id
            } catch [Management.Automation.PropertyNotFoundException] {
                Write-Error -Message "Unable to find group named $currentGroupName on target org." -Exception $_.Exception
            }
        } else {
            $target = $sourcePolicy.computerGroupId
        }
        if (-not $NewName) {
            $NewName = "$( $sourcePolicy.name ) $( Get-Date -Format FileDateTime )"
        }

        $clone = [Ordered]@{}
        $sourcePolicy.PSObject.Properties | ForEach-Object {
            $clone[$_.Name] = $_.Value
        }
        $clone.Remove('policyId')
        $clone.Remove('appliesToId')
        $clone.isEnabled = [Boolean]$Enable
        $clone.orderBefore = [Boolean]$TopOfList
        $clone.organizationId = $newOrgId
        $clone.computerGroupId = $target
        $clone.name = $NewName
        $splat = @{
            Method = 'POST'
            Endpoint = 'Policy/PolicyInsert'
            OrgId = $newOrgId
            Body = $clone
        }
        Invoke-ThreatLockerApi @splat
    }
}
