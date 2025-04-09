Scriptname DFR_FailableEvent extends Adv_EventBase  

function Complete()
    DFR_Util.Log("Food Event - Complete")
    DFR_RelationshipManager.Get().CompleteEvent(GetEventId())
    Stop()
endFunction

function Fail()
    DFR_Util.Log("Food Event - Fail")
    DFR_RelationshipManager.Get().FailEvent(GetEventId())
    Stop()
endFunction