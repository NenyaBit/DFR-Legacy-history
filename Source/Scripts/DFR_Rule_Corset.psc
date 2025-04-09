Scriptname DFR_Rule_Corset extends Adv_EventBase  

bool function OnStart(Actor akTarget)
    _LDC LDC = (GetOwningQuest() as _DFlowModDealController).Tool.LDC
    if DFR_RelationshipManager.Get().IsSlave()
        LDC.EquipDeviceByKeyword(LDC.libs.zad_DeviousCorset)
    else
        LDC.AddDeviceByKeyword(LDC.libs.zad_DeviousCorset)
    endIf

    return true
endFunction

function OnStop()
    _LDC LDC = (GetOwningQuest() as _DFlowModDealController).Tool.LDC
    LDC.RemoveDeviceByKeyword(LDC.libs.zad_DeviousCorset)
endFunction