Scriptname DFR_Event_Masturbation extends Adv_EventBase  

bool function OnStart(Actor akTarget)
    SexLabUtil.GetAPI().QuickStart(Game.GetPlayer())
    _DFtools.Get().WaitForSex()
    Stop()
    DFR_RelationshipManager.Get().CompleteEvent(GetEventId())
    return true
endFunction