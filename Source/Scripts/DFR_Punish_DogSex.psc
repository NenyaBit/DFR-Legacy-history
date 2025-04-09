Scriptname DFR_Punish_DogSex extends DFR_FailableEvent  

_DFtools property Tool auto
DFR_LocScanner property Scanner auto

bool function OnStart(Actor akTarget)
    Tool.Sex(Scanner.Dogs[0])
    Tool.WaitForSex()
    
    Complete()

    return true
endFunction