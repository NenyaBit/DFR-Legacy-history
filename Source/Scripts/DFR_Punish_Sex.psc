Scriptname DFR_Punish_Sex extends DFR_FailableEvent  

_DFtools property Tool auto
ReferenceAlias property MasterAlias auto
Scene property NoBathingScene auto

string NO_BATHING_RULE = "deviousfollowers/core/no bathing"

function OnModuleLoad()
    EventName = "Sex Event"
endFunction

bool function OnStart(Actor akTarget)
    Actor player = Game.GetPlayer()
    DFR_Events events = DFR_Events.Get()

    PyramidUtils.SetActorCalmed(Game.GetPlayer(), true)
    PyramidUtils.SetActorCalmed(akTarget, true)

    Actor victim = none
    if events.GetContext(GetEventId()) == events.CONTEXT_TYPE_APOLOGY
        victim = player
    endIf

    SexLabUtil.QuickStart(player, akTarget, Victim = victim)

    Tool.WaitForSex()

    PyramidUtils.SetActorCalmed(Game.GetPlayer(), false)
    PyramidUtils.SetActorCalmed(akTarget, false)
    
    Complete()

    return true
endFunction