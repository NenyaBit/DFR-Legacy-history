Scriptname DFR_Rule_AnalPlug extends Adv_EventBase  

bool function OnStart(Actor akTarget)
    _LDC LDC = (GetOwningQuest() as _DFlowModDealController).Tool.LDC
    if DFR_RelationshipManager.Get().IsSlave()
        LDC.EquipDeviceByKeyword(LDC.libs.zad_DeviousPlugAnal)
    else
        LDC.AddDeviceByKeyword(LDC.libs.zad_DeviousPlugAnal)
    endIf
    
    return true
endFunction 

function OnStop()
    _LDC LDC = (GetOwningQuest() as _DFlowModDealController).Tool.LDC
    LDC.RemoveDeviceByKeyword(LDC.libs.zad_DeviousPlugAnal)
endFunction

