Scriptname DFR_Outfits extends Quest conditional

QF__Gift_09000D62 property Flow auto
Actor property PlayerRef auto
Adv_OutfitManager property Manager auto
DFR_Licenses property Licenses auto
DFR_RelationshipManager property Relationship auto

GlobalVariable property GameDaysPassed auto
GlobalVariable property LocTransitionCooldown auto
GlobalVariable property TargetSeverity auto
GlobalVariable property WhoreArmorValidStatus auto

int CurrentOutfitSeverity
float property LostArmorEscalationChance = 0.5 auto hidden
bool property LostArmorEscalate = false auto hidden conditional

string WhoreArmorRule = "deviousfollowers/core/whore armor"

int property CurrArmorType auto hidden conditional
int property NumOutfitRulesActive = 0 auto hidden conditional

bool property SwapOutfit = false auto hidden conditional
bool property ProgressToNextSet auto hidden conditional
bool property BikiniArmor = false auto hidden conditional

int property SwapCooldownMin = 1 auto hidden
int property SwapCooldownMax = 3 auto hidden

float property SwapCooldown auto hidden conditional

string LastOutfit = ""
string SelectedOutfitSwap = ""
bool property OutfitSequence = false auto hidden conditional

string[] ActiveOutfitRules

DFR_Outfits function Get() global
    return Quest.GetQuest("DFR_Outfits") as DFR_Outfits
endFunction

function Maintenance()
    RegisterForModEvent("DFR_TargetSeverity_Change", "OnSeverityChange")
    Log("Maintenance")
    TargetSeverity = PyramidUtils.GetGlobal("DFR_Target_Severity")
endFunction

function Prep()
    ; random chance we try to escalate the outfit
    LostArmorEscalate = !BikiniArmor && SwapCooldown < Utility.GetCurrentGameTime() && Utility.RandomInt(0, 100) < (LostArmorEscalationChance * 100)
    Log("Prep - Escalate = " + LostArmorEscalate)
    PickArmor()

    int i = 0
    while i < ActiveOutfitRules.Length
        Adv_EventBase rule = Adversity.GetEvent(ActiveOutfitRules[i])
        DFR_OutfitRuleBase outfitRule = rule as DFR_OutfitRuleBase
        
        if outfitRule
            outfitRule.Prep()
        endIf

        i += 1
    endWhile
endFunction

string function GetCurrentOutfit()
    string[] outfits = Manager.GetOutfits(WhoreArmorRule)

    if outfits.length
        return outfits[0]
    endIf

    return ""
endFunction

event OnSeverityChange(int aiSeverity)
    SwapOutfit = false
    CheckSwap()
endEvent

function ResetChange()
    ProgressToNextSet = false
endFunction

function GiveWhoreArmor(bool abPay = true, string asId = "")
    DelayValidationTimer()
    
    string current = GetCurrentOutfit()

    Log("Current = " + current)

    if asId == ""
        asId = PickArmor()
    endIf

    CurrentOutfitSeverity = Adversity.GetOutfitSeverity(asId)

    float cost = 0.0
    if Manager.GetOutfits(WhoreArmorRule).Length
        cost = Adversity.SwapOutfitPieces(PlayerRef, current, asId, true) as float
        Manager.Swap(WhoreArmorRule, Utility.CreateStringArray(1, asId))
    else
        cost = Adversity.GiveOutfitPieces(PlayerRef, asId) as float
        Manager.Add(WhoreArmorRule, Utility.CreateStringArray(1, asId), WhoreArmorValidStatus)
    endIf

    if abPay
        cost *= 1.2
        Log("Charging " + cost)
        Flow.AddDebt(cost)
    endIf

    SwapCooldown = GameDaysPassed.GetValue() + Utility.RandomInt(SwapCooldownMin, SwapCooldownMax)
endFunction

string function PickArmor()
    ProgressToNextSet = false
    
    int minSeverity = Adversity.GetOutfitSeverity(current)
    int maxSeverity = PapyrusUtil.ClampInt(TargetSeverity.GetValue() as int+ (LostArmorEscalate as int), 1, 5)
    string current = GetCurrentOutfit()

    if minSeverity == maxSeverity
        return current
    endIf
  
    Log("PickArmor - " + " current = " + current + " - min = " + minSeverity + " - max = " + maxSeverity)

    if current != "" && StringUtil.Find(current, GetArmorType()) > -1
        string chosen = Adversity.GetNextOutfit(current, maxSeverity)
        if chosen != ""
            int chosenSeverity = Adversity.GetOutfitSeverity(chosen)
            if chosenSeverity >= minSeverity && chosenSeverity <= maxSeverity && (!BikiniArmor || Adversity.OutfitHasTag(chosen, "bikini") || !Adversity.OutfitHasTag(current, "bikini"))
                Log("Sequenced outfit is within range - choosing = " + chosen)
                ProgressToNextSet = true
                return chosen
            else
                Log("Sequenced outfit is not within range " + chosenSeverity + " - not choosing = " + chosen)
            endIf
        endIf
    endIf

    string chosen = ""

    string armorType = GetArmorType()
    Log("type " + armorType)
    string[] outfits = Adversity.GetOutfits("deviousfollowers", armorType)
    Log("outfits 1 " + outfits)

    if BikiniArmor && armorType != "mage"
        string[] tmp = Adversity.FilterOutfitsByTags(outfits, Utility.CreateStringArray(1, "bikini"))
        if tmp.Length
            outfits = tmp
        endIf
    endIf
    Log("outfits 2 " + outfits)

    string[] tmp = Adversity.FilterOutfitsBySeverity(outfits, minSeverity)
    Log("outfits 3 " + tmp)

    if tmp.length
        outfits = tmp
    endIf

    tmp = Adversity.FilterOutfitsBySeverity(outfits, maxSeverity, false)
    Log("outfits 4 " + outfits)

    if tmp.length
        outfits = tmp
    endIf

    tmp = Adversity.FilterOutfitsBySeverity(outfits, maxSeverity)
    Log("outfits 5 " + outfits)

    if tmp.length
        outfits = tmp
    endIf

    if outfits.length
        chosen = outfits[Utility.RandomInt(0, outfits.length - 1)]
    endIf

    Log("PickArmor - type = " + armorType + " - chosen = " + chosen)

    return chosen
endFunction

function CheckSwap()
    if Adversity.IsEventActive(WhoreArmorRule)
        string current = GetCurrentOutfit()

        if Adversity.GetOutfitSeverity(current) < TargetSeverity.GetValue()
            SwapCooldown = 0
            SwapOutfit = true
        endIf
    endIf
    Log("OnSeverityChange = " + TargetSeverity.GetValue() + " - Swap = " + SwapOutfit)
endFunction

function SetupSwap()
    SelectedOutfitSwap = PickArmor()
endFunction

function CompleteSwap()
    LastOutfit = Manager.GetOutfits(WhoreArmorRule)
    GiveWhoreArmor(false, SelectedOutfitSwap)
endFunction

function UndoSwap()
    GiveWhoreArmor(true, LastOutfit)
    Flow.PunDebt()
    Relationship.DecFavour()
    Relationship.DeEscalate()
endFunction

function SwapWalkaway()
    Flow.PunDebt()
    Relationship.DecFavour()
    Relationship.DeEscalate()
endFunction

string function GetArmorType()
    string armorType = "light"
    if CurrArmorType == 1
        armorType = "heavy"
    elseIf CurrArmorType == 2
        armorType = "mage"
    endIf

    return armorType
endFunction

bool function IsWearingWhoreArmor()
    return Manager.IsValid(WhoreArmorRule)
endFunction

function StartWhoreArmorRule()
    string playerCombatPref = Adversity.GetActorString("deviousfollowers", Flow.Alias__DMaster.GetRef() as Actor, "playerCombatPref")

    if playerCombatPref == "magic"
        CurrArmorType = 2
    elseIf playerCombatPref == "heavy"
       CurrArmorType = 1
    else
        CurrArmorType = 0
    endIf

    BikiniArmor = Licenses.IsHandlingBikiniArmor()

    NumOutfitRulesActive += 1
    
    GiveWhoreArmor(false)
endFunction

function ChangeArmorType(int aiType)
    CurrArmorType = aiType
    GiveWhoreArmor(true)
endFunction

function ToggleBikiniArmor()
    BikiniArmor = !BikiniArmor
    GiveWhoreArmor(!BikiniArmor)
endFunction

function StopWhoreArmorRule()
    string[] ids = Manager.GetOutfits(WhoreArmorRule)

    int i = 0
    while i < ids.length
        float missingCost = Adversity.RemoveOutfitPieces(PlayerRef, ids[i]) as float
        missingCost *= 1.2
        Flow.AddDebt(missingCost)
    endWhile

    RemoveRule(WhoreArmorRule)
endFunction

function DelayValidationTimer()
    LocTransitionCooldown.SetValue(GameDaysPassed.GetValue() + 0.04)
endFunction

function Log(string asMsg)
    DFR_Util.Log("Outfits - " + asMsg)
endFunction

bool function AddRule(string asRule, string asOutfit, GlobalVariable akStatus)
    if Manager.Has(asRule)
        return false
    endIf

    ActiveOutfitRules = PapyrusUtil.PushString(ActiveOutfitRules, asRule)

    Manager.Add(asRule, Utility.CreateStringArray(1, asOutfit), akStatus)
    NumOutfitRulesActive = ActiveOutfitRules.Length
endFunction

function SetRule(string asRule, string asOutfit)
    Manager.Swap(asRule, Utility.CreateStringArray(1, asOutfit))
endFunction

bool function RemoveRule(string asRule)
    if !Manager.Has(asRule)
        return false
    endIf

    ActiveOutfitRules = PapyrusUtil.RemoveString(ActiveOutfitRules, asRule)

    Manager.Remove(WhoreArmorRule)
    NumOutfitRulesActive = ActiveOutfitRules.Length
endFunction

string[] function GetOutfits(string asRule)
    if !Manager.Has(asRule)
        return Utility.CreateStringArray(0)
    endIf

    return Manager.GetOutfits(asRule)
endFunction