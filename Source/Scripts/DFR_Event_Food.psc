Scriptname DFR_Event_Food extends DFR_FailableEvent  

DFR_Services property Services auto

bool function OnStart(Actor akTarget)
    DFR_Util.Log("Food Event - Start")
    return Services.StartService(akTarget, Services.FOOD_SERVICE_INDEX)
endFunction

bool function OnSelect(Actor akTarget)
    return Services.SelectService(Services.FOOD_SERVICE_INDEX)
endFunction

function OnStop()
    DFR_Util.Log("Food Event - Stop")
endFunction