Scriptname DFR_Rules extends Quest conditional

QF__Gift_09000D62 property Flow auto
DFR_RelationshipManager property RelManager auto
GlobalVariable property GameDaysPassed auto

float property RuleExtensionMin = 1.0 auto hidden
float property RuleExtensionMax = 2.0 auto hidden

int property STATUS_ACCEPT = 6 autoreadonly hidden
int property STATUS_REFUSE = 7 autoreadonly hidden

int property NumRules auto hidden conditional

string[] property ActiveRules auto hidden

DFR_Rules function Get()
    return Quest.GetQuest("DFR_Rules") as DFR_Rules
endFunction

event OnInit()
    ActiveRules = Utility.CreateStringArray(0)
endEvent

function Maintenance()
    RegisterForMenu("Dialogue Menu")
endFunction

function Setup()
    float now = GameDaysPassed.GetValue()

    bool isSlave = RelManager.IsSlave()
    bool favourRoll = !isSlave || Utility.RandomInt(0, 100) < RelManager.CreateFavourArray()[RelManager.GetFavourLevel()]

    int i = 0
    while i < ActiveRules.Length
        string rule = ActiveRules[i]
        float expiration = StorageUtil.GetFloatValue(self, rule)
        float extension = StorageUtil.GetFloatValue(self, "ExtensionDuration_" + rule)

        if expiration >= 0
            if extension < now && expiration < now && favourRoll
                ; allow removal if not slave or favour success and rule has expired
                Adversity.SetEventStatus(rule, STATUS_ACCEPT)
            else
                Adversity.SetEventStatus(rule, STATUS_REFUSE)
            endIf
        endIf

        Log("Setup - " + rule + " - " + Adversity.GetEventStatus(rule))

        i += 1
    endWhile
endFunction

event OnMenuClose(string asMenu)
    int i = 0
    while i < ActiveRules.Length
        Adversity.SetEventStatus(ActiveRules[i], 5)
        i += 1
    endWhile
endEvent

; aiTerm: 0 = hidden, 1 = 3-4 hours, 2 = 1-2 days, 3 = 3-5 days, 4 = 6-8 days
; aiContext: 0 = deals, 1 = over debt forced deals, 2 = service, 3 = apology, 4 = enslavement setup, 5 = challenge
bool function Add(string asRule, int aiTerm, int aiContext)
    if ActiveRules.Find(asRule) > -1
        return false
    endIf

    float duration = 0.0

    if aiTerm > 0
        float offset = 0.0
        if aiTerm == 1
            offset = Utility.RandomInt(3, 4) * 0.042
        elseIf aiTerm == 2
            offset = Utility.RandomInt(1, 2)
        elseIf aiTerm == 3
            offset = Utility.RandomInt(3, 5)
        elseIf aiTerm == 4
            offset = Utility.RandomInt(6, 8)
        endIf

        duration = offset + offset
    endIf

    StorageUtil.SetFloatValue(self, asRule, GameDaysPassed.GetValue() + duration)
    StorageUtil.SetIntValue(self, asRule, aiContext)
    ActiveRules = PapyrusUtil.PushString(ActiveRules, asRule)
    NumRules = ActiveRules.Length

    Log("Add - " + asRule + " - " + aiTerm + " - " + aiContext + " - " + NumRules)
endFunction

function Remove(string asRule)
    if ActiveRules.Find(asRule) == -1
        return
    endIf

    ActiveRules = PapyrusUtil.RemoveString(ActiveRules, asRule)
    StorageUtil.UnsetFloatValue(self, asRule)
    StorageUtil.UnsetIntValue(self, asRule)
    NumRules = ActiveRules.Length
    Adversity.StopEvent(asRule)

    Log("Remove - " + asRule + " - " + NumRules)
endFunction

bool function Has(string asRule)
    return ActiveRules.Find(asRule) > -1
endFunction

function Log(string asMsg)
    DFR_Util.Log("Rules - " + asMsg)
endFunction

function End(string asRule)
    if ActiveRules.Find(asRule) < 0
        return
    endIf

    float expiration = StorageUtil.GetFloatValue(self, asRule)
    int context = StorageUtil.GetIntValue(self, asRule)

    if GameDaysPassed.GetValue() < expiration
        if context == 5
            ; apply double pun debt
            Flow.ApplyPunishmentDebt()
            Flow.ApplyPunishmentDebt()
        elseIf context == 2 || context == 3
            RelManager.DecFavour(2)
        endIf
    endIf

    Remove(asRule)
endFunction

function DelayRemoval(string asRule)
    if ActiveRules.Find(asRule) < 0 || !StorageUtil.GetFloatValue(self, asRule, 0.0)
        return
    endIf

    float now = GameDaysPassed.GetValue()

    if now < StorageUtil.GetFloatValue(self, "ExtensionDuration_" + asRule)
        RelManager.DecFavour()
    endIf

    StorageUtil.SetFloatValue(self, "ExtensionDuration_" + asRule, now + Utility.RandomFloat(RuleExtensionMin, RuleExtensionMax))
endFunction


function Handle(string asRule)
    if StringUtil.Find(asRule, "deviousfollowers") == -1
        asRule = "deviousfollowers/" + asRule
    endIf

    int status = Adversity.GetEventStatus(asRule)

    Log("Handle - " + asRule + " - " + status)

    if status == 6
        End(asRule)
    elseIf status == 7
        DelayRemoval(asRule)
    endIf
endFunction