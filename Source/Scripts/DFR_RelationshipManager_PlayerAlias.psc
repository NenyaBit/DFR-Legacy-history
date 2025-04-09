Scriptname DFR_RelationshipManager_PlayerAlias extends ReferenceAlias  

event OnPlayerLoadGame()
    (GetOwningQuest() as DFR_RelationshipManager).RestartPolling()
endEvent