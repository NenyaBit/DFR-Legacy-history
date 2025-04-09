Scriptname DFR_Licenses_Player extends ReferenceAlias

event OnPlayerLoadGame()
    (GetOwningQuest() as DFR_Licenses).Maintenance()
endEvent

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    (GetOwningQuest() as DFR_Licenses).UpdateLicenses()
endEvent