Scriptname DFR_Events_PlayerAlias extends ReferenceAlias

Cell LastCell
int INTERVAL = 10

event OnPlayerLoadGame()
    (GetOwningQuest() as DFR_Events).Maintenance()
endEvent

event OnLocationChange(Location OldLocation, Location newLocation)
    (GetOwningQuest() as DFR_Events).SelectAll(false)
endEvent