Scriptname DFR_TownMode_Player extends ReferenceAlias  

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    DFR_TownMode TownMode = GetOwningQuest() as DFR_TownMode

    int stage = TownMode.GetStage()

    TownMode.Log("Stage = " + stage + " - Location = " + akNewLocation + " - Inn = " + TownMode.Alias_Inn.GetLocation())
    
    if stage == 2 && TownMode.Alias_Inn.GetLocation().IsSameLocation(akNewLocation)
        TownMode.SetStage(3)
    endIf
endEvent