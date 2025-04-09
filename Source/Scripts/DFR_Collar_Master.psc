Scriptname DFR_Collar_Master extends ReferenceAlias  

event OnCombatStateChanged(Actor akTarget, int aiCombatState)
    if aiCombatState
        (GetOwningQuest() as DFR_Collar).Pause("follower-combat-state")
    else
        (GetOwningQuest() as DFR_Collar).Resume("follower-combat-state")
    endIf
endEvent