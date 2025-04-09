Scriptname DFR_Punish_HorseSex extends Adv_EventBase  

_DFtools property Tool auto
DFR_HorseScanner property Scanner auto

bool function IsValid(Actor akTarget)
    return _DflowMCM.Get()._DFAnimalCont && Scanner.Scan().length > 0
endFunction

bool function OnStart(Actor akTarget)
    Tool.Sex(Scanner.Scan()[0])
    Tool.WaitForSex()
    Stop()
    return true
endFunction