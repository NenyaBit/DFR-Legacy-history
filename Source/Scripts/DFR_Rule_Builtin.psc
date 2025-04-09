Scriptname DFR_Rule_Builtin extends Adv_EventBase

Int Property RuleIndex = -1 Auto

bool function OnStart(Actor akTarget)
    (GetOwningQuest() as _DFlowModDealController).SetRule(RuleIndex, 2)
    return true
endFunction 

function OnStop()
    (GetOwningQuest() as _DFlowModDealController).SetRule(RuleIndex, 1)
endFunction