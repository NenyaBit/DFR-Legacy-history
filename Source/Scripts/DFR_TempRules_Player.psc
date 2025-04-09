Scriptname DFR_TempRules_Player extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as DFR_TempRules).Maintenance()
endEvent