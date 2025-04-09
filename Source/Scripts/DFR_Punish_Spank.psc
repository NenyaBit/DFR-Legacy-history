Scriptname DFR_Punish_Spank extends Adv_EventBase

_DFtools property Tool auto

bool function OnStart(Actor akTarget)
    Actor player = Game.GetPlayer()
    SexlabUtil.GetAPI().TreatAsMale(akTarget)
    if SexLabUtil.QuickStart(player, akTarget, victim = player, animationTags = "spanking")
        DFR_Util.Log("Starting SL spanking")
        Tool.WaitForSex()
    endIf
    SexLabUtil.GetAPI().ClearForcedGender(akTarget)

    DFR_Util.Log("Spanking complete")
    Stop()
    return true
endFunction
