Scriptname DFR_Rule_CumCovering extends Adv_EventBase  

_DDeal property Deal auto

function OnModuleLoadGame()
    RegisterForModEvent("Bis_BatheEvent", "OnBis_BatheEvent")
endFunction

bool function OnStart(Actor akTarget)
    Deal.Triggered = false
    Deal.Said1 = 0
    Deal.DelayHrs(4.0)
endFunction

event OnBis_BatheEvent(Form akTarget)
    if akTarget == Game.GetPlayer() && IsActive()
	    Deal.Said1 = 1
    endIf
endEvent