Scriptname DFR_Rule_WhoreTat extends Adv_EventBase

_DDeal property Deal auto

Actor property PlayerRef auto
ReferenceAlias property MasterAlias auto

_DFtools property Tool auto

ReferenceAlias property DealPlayerDummy auto
ReferenceAlias property DealMaster auto

string[] AppliedTats

bool function OnStart(Actor akTarget)
    DealPlayerDummy.ForceRefTo(Tool.PC)
    DealMaster.ForceRefTo(akTarget)

    Deal.DelayHrs(6.0)

    if !Game.IsPluginInstalled("SlaveTats.esp")
        DFR_Util.Log("Whore Rule - ST not installed!")
        return false
    endIf

    AppliedTats = Adversity.GetRandomTattooGroup("deviousfollowers", "whore")
    DFR_Util.Log("Applying tattoos = " + AppliedTats)
    Adversity.ApplyTattooGroup(PlayerRef, AppliedTats, true)

    return true
endFunction 

function OnStop()
    Adversity.RemoveTattooGroup(PlayerRef, AppliedTats, true)
endFunction