Scriptname DFR_Punish_DogSex extends DFR_FailableEvent  

_DFtools property Tool auto
DFR_LocScanner property Scanner auto

bool function OnStart(Actor akTarget)
    Actor player = Game.GetPlayer()
    DFR_Events events = DFR_Events.Get()

    PyramidUtils.SetActorCalmed(player, true)
    PyramidUtils.SetActorCalmed(akTarget, true)

    Actor victim = none
    if events.GetContext(GetEventId()) == events.CONTEXT_TYPE_APOLOGY
        victim = player
    endIf

    SexLabUtil.QuickStart(player, Scanner.Dogs[0], Victim = victim)

    Tool.WaitForSex()

    PyramidUtils.SetActorCalmed(Game.GetPlayer(), false)
    PyramidUtils.SetActorCalmed(akTarget, false)

    Complete()

    return true
endFunction