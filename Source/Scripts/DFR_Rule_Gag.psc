Scriptname DFR_Rule_Gag extends DFR_Rule_Builtin  

_DDeal property Deal auto

function OnStart(bool abResume = false)
    Parent.OnStart(abResume)
    Deal.DelayDaysRange(2, 5)
    Deal.Triggered = false
endFunction 
