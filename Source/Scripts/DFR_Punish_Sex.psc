Scriptname DFR_Punish_Sex extends DFR_FailableEvent  

_DFtools property Tool auto
ReferenceAlias property MasterAlias auto
Scene property NoBathingScene auto

string NO_BATHING_RULE = "deviousfollowers/core/no bathing"

function OnModuleLoad()
    EventName = "Sex Event"
endFunction

bool function OnStart(Actor akTarget)
    Tool.Sex(akTarget)
    Tool.WaitForSex()
    
    Complete()

    return true
endFunction