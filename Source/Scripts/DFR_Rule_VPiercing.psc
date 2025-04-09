Scriptname DFR_Rule_VPiercing extends DFR_Rule_Builtin  

_DDeal property Deal Auto

bool function OnStart(Actor akTarget)
    Deal.Triggered = false
    return parent.OnStart(akTarget)
endFunction 