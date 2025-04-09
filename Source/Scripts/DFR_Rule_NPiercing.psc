Scriptname DFR_Rule_NPiercing extends DFR_Rule_Builtin  

_DDeal property Deal Auto

bool function OnStart(Actor akTarget)
    parent.OnStart(akTarget)
    Deal.Triggered = false
    return true
endFunction