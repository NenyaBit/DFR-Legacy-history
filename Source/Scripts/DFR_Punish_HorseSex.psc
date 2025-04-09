Scriptname DFR_Punish_HorseSex extends Adv_EventBase  

_DFtools property Tool auto
DFR_HorseScanner property Scanner auto

bool function OnStart(Actor akTarget)
    Tool.Sex(Scanner.Scan()[0])
    Tool.WaitForSex()
    Stop()
    DFR_RelationshipManager.Get().CompleteEvent(GetEventId())

    return true
endFunction