Scriptname DFR_Rule_NoBathing extends Adv_EventBase

Scene property ScoldScene auto

function OnModuleLoadGame()
    RegisterForModEvent("Bis_BatheEvent", "OnBis_BatheEvent")
endFunction

Event OnBis_BatheEvent(Form akTarget)
    if akTarget == Game.GetPlayer() && IsActive()
        ScoldScene.Start()
    endIf
EndEvent