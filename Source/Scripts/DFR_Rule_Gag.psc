Scriptname DFR_Rule_Gag extends DFR_Rule_Builtin  

_DDeal property Deal auto

bool function OnStart(Actor akTarget)
    Parent.OnStart(akTarget)
    Deal.DelayDaysRange(2, 5)
    Deal.Triggered = false
    return true
endFunction 
