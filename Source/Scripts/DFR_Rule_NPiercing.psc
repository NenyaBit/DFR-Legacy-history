Scriptname DFR_Rule_NPiercing extends DFR_Rule_Builtin  

_DDeal property Deal Auto

function OnStart(bool abResume = false)
    parent.OnStart(abResume)
    Deal.Triggered = false
endFunction