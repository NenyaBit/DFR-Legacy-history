Scriptname DFR_LocScanner_Player extends ReferenceAlias  

Location LastLocation = none

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    if akNewLocation != LastLocation
        (GetOwningQuest() as DFR_LocScanner).Scan()
        LastLocation = akNewLocation
    endIf
endEvent