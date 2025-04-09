Scriptname DFR_DefeatHandler_PlayerAlias extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as DFR_DefeatHandler).Maintenance()
endEvent