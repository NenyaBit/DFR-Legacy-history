Scriptname DFR_Rule_CumCovering extends Adv_EventBase  

DFR_Skincare property Skincare auto

function OnModuleLoadGame()
    Skincare.Maintenance()
    EventName = "Skincare"
endFunction

bool function OnStart(Actor akTarget)
    DFR_Util.Log("Skincare Start")
    return Skincare.Start()
endFunction

function OnStop()
    DFR_Util.Log("Skincare Stop")
    Skincare.Reset()
endFunction