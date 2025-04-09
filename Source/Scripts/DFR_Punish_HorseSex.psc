Scriptname DFR_Punish_HorseSex extends DFR_FailableEvent  

_DFtools property Tool auto
DFR_LocScanner property Scanner auto

bool function OnStart(Actor akTarget)
    Tool.Sex(Scanner.Horses[0])
    Tool.WaitForSex()
    
    Complete()

    return true
endFunction