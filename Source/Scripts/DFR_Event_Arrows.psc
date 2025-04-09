Scriptname DFR_Event_Arrows extends DFR_FailableEvent  

DFR_Services property Services auto

bool function OnStart(Actor akTarget)
    DFR_Util.Log("Arrows Event - Start")
    return Services.StartService(akTarget, Services.ARROW_SERVICE_INDEX)
endFunction

bool function OnSelect(Actor akTarget)
    return Services.SelectService(Services.ARROW_SERVICE_INDEX)
endFunction

function OnStop()
    DFR_Util.Log("Arrows Event - Stop")
endFunction