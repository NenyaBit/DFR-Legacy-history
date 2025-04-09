Scriptname DFR_Event_RapeTime extends Adv_EventBase  

_DFtools property Tool auto

bool function OnStart(Actor akTarget)
    Tool.RapeTime()
    Stop()
    return true
endFunction