Scriptname DFR_Punish_Sex extends Adv_EventBase  

_DFtools property Tool auto
ReferenceAlias property MasterAlias auto
Scene property NoBathingScene auto

string NO_BATHING_RULE = "deviousfollowers/core/no bathing"

bool function OnStart(Actor akTarget)
    Tool.Sex(akTarget)
    Tool.WaitForSex()
    Stop()
    return true
endFunction