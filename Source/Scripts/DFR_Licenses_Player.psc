Scriptname DFR_Licenses_Player extends ReferenceAlias

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    (GetOwningQuest() as DFR_Licenses).TryRefresh()
endEvent