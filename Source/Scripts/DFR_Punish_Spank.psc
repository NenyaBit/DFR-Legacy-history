Scriptname DFR_Punish_Spank extends DFR_FailableEvent

_DFtools property Tool auto

bool function OnStart(Actor akTarget)
    Actor player = Game.GetPlayer()

    PyramidUtils.SetActorCalmed(player, true)
    PyramidUtils.SetActorCalmed(akTarget, true)
    
    SexlabUtil.GetAPI().TreatAsMale(akTarget)
    if SexLabUtil.QuickStart(player, akTarget, victim = player, animationTags = "IPlay_Spanking")
        DFR_Util.Log("Started SL spanking 1")
        Tool.WaitForSex()
    elseIf SexLabUtil.QuickStart(player, akTarget, victim = player, animationTags = "spanking")
        DFR_Util.Log("Started SL spanking 2")
        Tool.WaitForSex()
    else
        DFR_Util.Log("Failed to start SL spanking")
    endIf

    PyramidUtils.SetActorCalmed(Game.GetPlayer(), false)
    PyramidUtils.SetActorCalmed(akTarget, false)    
    SexLabUtil.GetAPI().ClearForcedGender(akTarget)

    DFR_Util.Log("Spanking complete")
    
    Complete()

    return true
endFunction
