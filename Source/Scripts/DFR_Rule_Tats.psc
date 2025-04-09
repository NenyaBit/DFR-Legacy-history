Scriptname DFR_Rule_Tats extends Adv_EventBase

bool function IsValid(Actor akTarget)
    return Game.IsPluginInstalled("RapeTattoos.esp")
endFunction

bool function OnStart(Actor akTarget)

    int handle = ModEvent.Create("RapeTattoos_addTattooV2")
    if (handle)
        ModEvent.PushForm(handle, Game.GetPlayer()) ; target should be an Actor reference
        ModEvent.PushInt(handle, 2)
        ModEvent.Send(handle)
    endIf

    DFR_RelationshipManager.Get().CompleteEvent(GetEventId())

    Stop()
    return true
endFunction
