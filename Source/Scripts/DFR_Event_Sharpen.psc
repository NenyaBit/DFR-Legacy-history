Scriptname DFR_Event_Sharpen extends DFR_FailableEvent  

DFR_Services property Services auto

bool function OnSelect(Actor akTarget)
    DFR_Util.Log("Sharpen Event - Select")
    return Services.SelectService(Services.SHARPEN_SERVICE_INDEX)
endFunction

bool function OnStart(Actor akTarget)
    DFR_Util.Log("Sharpen Event - Start")
    return Services.StartService(akTarget, Services.SHARPEN_SERVICE_INDEX)
endFunction

function OnStop()
    DFR_Util.Log("Sharpen Event - Stop")
endFunction