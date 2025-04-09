Scriptname DFR_Event_Potions extends DFR_FailableEvent  

DFR_Services property Services auto

bool function OnSelect(Actor akTarget)
    DFR_Util.Log("Potion Event - Select")
    return Services.SelectService(Services.POTION_SERVICE_INDEX)
endFunction

bool function OnStart(Actor akTarget)
    DFR_Util.Log("Potion Event - Start")
    return Services.StartService(akTarget, Services.POTION_SERVICE_INDEX)
endFunction

function OnStop()
    DFR_Util.Log("Potion Event - Stop")
endFunction