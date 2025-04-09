Scriptname DFR_RelationshipManager extends Quest conditional

GlobalVariable property GameDaysPassed auto
GlobalVariable property DebugMode auto
DFR_Events property Events auto
DFR_Rules property Rules auto
_DFDealUberController property Deals auto

Quest property SlaveryIntro auto

int property Favour auto hidden conditional
GlobalVariable property FavourGlobal auto
GlobalVariable property TargetSeverity auto

bool property CanApologise auto hidden conditional
int property NumFavourLevels = 4 auto hidden

float property LastServiced auto hidden
float property RecentlyFavoured auto hidden conditional
float property LastFavoured = -1.0 auto hidden
float property ForcedEventTimer = 0.0 auto hidden conditional

float NumServicesToSeverity_Var = 0.2
float property NumServicesToSeverity hidden
    float function get()
        if !NumServicesToSeverity_Var
            NumServicesToSeverity_Var = 0.2
        endIf

        return NumServicesToSeverity_Var
    endFunction
    function set(float afValue)
        NumServicesToSeverity_Var = afValue
        SetTargetSeverity()    
    endFunction
EndProperty

Actor LastMaster
string SelectedEvent
bool property ServiceOrPunishmentActive = false auto hidden conditional
float LastCheckedFavour = 0.0
int Escalation = 0
bool InSlaverySetup = false

; user adjusable
int property FavourIncrement = 10 auto hidden
int property FavourDecrement = 10 auto hidden
int property FavourDailyDecay = 10 auto hidden
int property FavourDailyDecaySlave = 20 auto hidden
int property FavourDailyDecayDealPrevention = 2 auto hidden
float property RemembersFor = 30.0 auto hidden
float property ForcedPunishmentDelay = 0.25 auto hidden
int[] property ForcedPunishChances auto hidden
int property RecentlyFavouredDuration = 3 auto hidden
int property ServiceCooldown = 4 auto hidden

bool property AllowForcedEvents = true auto hidden conditional
float property ForcedServiceCooldown = 8.0 auto hidden
float property ForcedPunishmentCooldown = 0.25 auto hidden

int property MaxServiceRules = 10 auto hidden
int property ServiceRuleCooldownMin = 2 auto hidden
int property ServiceRuleCooldownMax = 3 auto hidden

float property ServiceRuleTimer = 0.0 auto hidden

float property ServiceLocationChangeTimer = 0.0 auto hidden conditional

DFR_RelationshipManager function Get() global
    return Quest.GetQuest("DFR_RelationshipManager") as DFR_RelationshipManager
endFunction

event OnInit()
    SetupPunishChances()
endEvent

function Maintenance()
    RegisterForMenu("Dialogue Menu")
    RefreshFavourDailyDecayTimer()
endFunction

function SetupPunishChances()
    ForcedPunishChances = CreateFavourArray()
endFunction

function SetStageRegular(Actor akMaster)
    CheckAndClearFavour(akMaster)
    Favour = StorageUtil.GetIntValue(akMaster, "DFR_Cached_Favour")
    FavourGlobal.SetValue(Favour)
    RestartPolling()
    SendModEvent("DFR_RelStage_Change", "", 1)

    ServiceRuleTimer = 0.0

    if akMaster != LastMaster
        Escalation = 0
    endIf

    if GetStage() == 50
        ; convert all service rules back to deals
        int i = 0
        while i < Rules.NumRules
            string pickedDeal = Deals.PickDeal(0)
            Deals.AddDealById(pickedDeal + "/" + Rules.ActiveRules[i])
            Rules.Remove(Rules.ActiveRules[i])
            i += 1
        endWhile
    endIf

    SetTargetSeverity()

    LastMaster = akMaster

    SetStage(10)
endFunction

function SetupSlavery(Actor akMaster, int aiMethod)
    DFR_Util.Log("Setup Slavery - " + akMaster + " - " + aiMethod)

    InSlaverySetup = true

    SetStage(50)
    SetTargetSeverity()
    
    ServiceRuleTimer = GameDaysPassed.GetValue() + Utility.RandomInt(ServiceRuleCooldownMin, ServiceRuleCooldownMax)
    ForcedServiceCooldown = GameDaysPassed.GetValue() + ForcedPunishmentCooldown

    CheckAndClearFavour(akMaster)
    Favour = StorageUtil.GetIntValue(akMaster, "DFR_Cached_Favour")
    FavourGlobal.SetValue(Favour)
    RestartPolling()
    CanApologise = false
    SendModEvent("DFR_RelStage_Change", "", 5)

    DFR_Util.Log("Setup Slavery - " + GetStage())

    LastMaster = akMaster
    
    ; convert existing rules to deals
    string[] existingRules = Utility.CreateStringArray(0)
    string[] existingDeals = DFR_DealHelpers.GetDeals()

    int i = 0
    int numExisting = 0
    while i < existingDeals.Length
        string[] dealRules = DFR_DealHelpers.GetRules(existingDeals[i])

        int j = 0
        while j < dealRules.Length
            if Adversity.EventHasTag(dealRules[j], "subtype:service")
                Rules.Add(dealRules[j], 3, 2)
                numExisting += 1
            else
                Adversity.StopEvent(dealRules[j])
            endIf

            j += 1
        endWhile

        DFR_DealHelpers.Remove(existingDeals[i])

        i += 1
    endWhile

    DFR_Util.Log("Setup Slavery - finished deal -> rule conversion")

    ; select and setup slavery events
    string path = Adversity.GetConfigPath("deviousfollowers")
    
    DFR_Util.Log("Setup Slavery - Path = " + path)


    DFR_Util.Log("Setup Slavery - Num Starter Rules = " + SlaveryRules)

    string[] slaveryRules = JsonUtil.StringListToArray(path, "include-slavery-rules")

    i = 0
    while i < slaveryRules.length
        slaveryRules[i] = "deviousfollowers/" + slaveryRules[i]
        i += 1
    endWhile

    DFR_Util.Log("Setup Slavery - Starter Rules = " + slaveryRules)
 
    slaveryRules = Adversity.FilterEventsByValid(slaveryRules, akMaster)
    
    DFR_Util.Log("Setup Slavery - Valid Starter Rules = " + slaveryRules)

    int numSlaveryRules = JsonUtil.GetIntValue(path, "num-starting-slavery-rules")
    numSlaveryRules -= SlaveryRules.Length
    numSlaveryRules -= numExisting

    i = 0
    while i < numSlaveryRules
        string rule = SelectEvent("service", 5, true, slaveryRules)

        if rule == ""
            i = numSlaveryRules
        else
            slaveryRules = PapyrusUtil.PushString(slaveryRules, rule)
        endIf

        i += 1
    endWhile

    DFR_Util.Log("Setup Slavery - All Starter Rules = " + slaveryRules)

    Events.Setup(slaveryRules, Events.CONTEXT_TYPE_SLAVERY_SETUP, false, true, false)

    DFR_Util.Log("Setup Slavery - finished setup - starting scene")
    
    SlaveryIntro.Start()
endFunction

function CompleteSlaverySetup()
    InSlaverySetup = false
    ForcedEventTimer = GameDaysPassed.GetValue() + (ForcedServiceCooldown as float * 0.042)
    SelectEvent("service", 5, false, Utility.CreateStringArray(0))
endFunction

function DecFavour(int aiSeverity = 1)
    aiSeverity = PapyrusUtil.ClampInt(aiSeverity, 1, 3)
    Favour -= aiSeverity * FavourDecrement
    Favour = PapyrusUtil.ClampInt(Favour, -100, 100)
    FavourGlobal.SetValue(Favour)

    if aiSeverity == 1
        Debug.Notification(GetSubject() + " was annoyed by that")
    elseIf aiSeverity == 2
        Debug.Notification(GetSubject() + " was very annoyed by that")
    elseIf aiSeverity == 2
        Debug.Notification(GetSubject() + " was extremely annoyed by that")
    endIf

    float now = GameDaysPassed.GetValue()

    CanApologise = true
    RecentlyFavoured = - 1
    LastServiced = -1

    float before = ForcedEventTimer
    ForcedEventTimer = now + (ForcedPunishmentCooldown as float * 0.042)

    DFR_Util.Log("DecFavour - favour = " + favour + " before = " + before + " after = " + ForcedEventTimer)
endFunction

function IncFavour(int aiSeverity = 1)
    aiSeverity = PapyrusUtil.ClampInt(aiSeverity, 1, 3)
    Favour += aiSeverity * FavourIncrement
    Favour = PapyrusUtil.ClampInt(Favour, -100, 100)
    FavourGlobal.SetValue(Favour)

    if aiSeverity == 1
        Debug.Notification(GetSubject() + " was pleased by that")
    elseIf aiSeverity == 2
        Debug.Notification(GetSubject() + " was very pleased by that")
    elseIf aiSeverity == 2
        Debug.Notification(GetSubject() + " was extremely pleased by that")
    endIf

    float now = GameDaysPassed.GetValue()
    
    CanApologise = false
    LastFavoured = now
    RecentlyFavoured = now + (RecentlyFavouredDuration as float * 0.042)

    DFR_Util.Log("IncFavour - favour = " + favour)
endFunction

function SaveFavour(Actor akMaster)
    StorageUtil.SetIntValue(akMaster, "DFR_Cached_Favour", Favour)
    StorageUtil.SetFloatValue(akMaster, "DFR_Cached_Favour_Time", GameDaysPassed.GetValue())
endFunction

function CheckAndClearFavour(Actor akMaster)
    if (GameDaysPassed.GetValue() - StorageUtil.GetFloatValue(akMaster, "DFR_Cached_Favour_Time")) > RemembersFor
        StorageUtil.UnsetIntValue(akMaster, "DFR_Cached_Favour")
        StorageUtil.UnsetFloatValue(akMaster, "DFR_Cached_Favour_Time")
    endIf
endFunction

bool function IsSlave()
    return GetStage() == 50
endFunction

string function GetSubject()
    if IsSlave()
        if LastMaster.GetActorBase().GetSex()
            return "Your Mistress"
        else
            return "Your Master"
        endIf
    else
        return LastMaster.GetActorBase().GetName()
    endIf
endFunction

function RefreshFavourDailyDecayTimer()
    UnregisterForUpdateGameTime()

    float waitFor = 24.0 - (GameDaysPassed.GetValue() - LastCheckedFavour)
    if waitFor <= 0.0
        CheckFavour()
    else
        RegisterForSingleUpdateGameTime(waitFor)
    endIf
endFunction

function RestartPolling()
    LastCheckedFavour = GameDaysPassed.GetValue()
    RefreshFavourDailyDecayTimer()
endFunction

event OnUpdateGameTime()
    CheckFavour()
endEvent

function CheckFavour()
    float now = GameDaysPassed.GetValue()

    int targetFavour = 0

    if LastFavoured - now > 3
        targetFavour = -10
    endIf
    
    if Favour > targetFavour
        int decay = FavourDailyDecay - (FavourDailyDecayDealPrevention * Adversity.GetActiveEvents("deviousfollowers", "rule").Length)
        
        if decay > 0
            decay = 0
        endIf

        Favour -= decay
    endIf

    Favour = PapyrusUtil.ClampInt(Favour, -100, 100)

    FavourGlobal.SetValue(Favour)
    LastCheckedFavour = now
    RefreshFavourDailyDecayTimer()
endFunction

int function GetFavourLevel()
    if Favour > 50
        return 3
    elseIf Favour > 0
        return 2
    elseIf Favour > -50
        return 1
    else
        return 0
    endIf
endFunction

bool function HasHighFavour()
    return Favour > 50
endFunction

bool function HasLowFavour()
    return Favour < 0
endFunction

int[] function CreateFavourArray()
    int[] arr = new int[4]
    arr[0] = 25
    arr[1] = 50
    arr[2] = 75
    arr[3] = 90
    
    return arr
endFunction

event OnMenuClose(string asMenu)
    PickAndSelectEvent()
endEvent

function PickAndSelectEvent()
    int severity = GetTargetSeverity()
    
    if CanApologise
        severity += 1
    endIf

    severity = PapyrusUtil.ClampInt(severity, 1, GetMaxSeverity())

    string type = "service"
    if CanApologise && IsSlave()
        type = "punishment"
    endIf

    SelectedEvent = SelectEvent(type, severity, false, Utility.CreateStringArray(0))

    DFR_Util.Log("Relationship - Severity = " + severity + " - SelectedEvent = " + SelectedEvent)
endFunction

string function SelectEvent(string asType, int aiSeverity, bool abRulesOnly, string[] asExclude)
    if DebugMode.GetValue()
        string path = Adversity.GetConfigPath("deviousfollowers")
        string forced = JsonUtil.GetStringValue(path, "forced-" + asType)

        DFR_Util.Log("SelectEvent - " + forced)

        if forced != ""
            return "deviousfollowers/" + forced
        endIf
    endIf

    string[] candidates = Adversity.GetContextEvents("deviousfollowers")

    if abRulesOnly
        candidates = Adversity.FilterEventsByTags(candidates, Utility.CreateStringArray(1, "type:rule"))
    elseIf asExclude || GetTargetSeverity() < 3 || Rules.NumRules >= MaxServiceRules || ServiceRuleTimer > GameDaysPassed.GetValue()
        candidates = Adversity.FilterEventsByTags(candidates, Utility.CreateStringArray(1, "type:rule"), abInvert = true)
    endIf
    DFR_Util.Log("Candidates 1 = " + candidates)

    candidates = Adversity.FilterEventsByTags(candidates, Utility.CreateStringArray(1, "subtype:" + asType))
    DFR_Util.Log("Candidates 2 = " + candidates)
    candidates = Adversity.FilterEventsByValid(candidates)
    DFR_Util.Log("Candidates 3 = " + candidates)
    candidates = Adversity.FilterEventsByCooldown(candidates)
    DFR_Util.Log("Candidates 4 = " + candidates)

    int i = 0
    int j = 0
    while i < candidates.Length
        if asExclude.Find(candidates[i]) == -1
            candidates[j] = candidates[i]
            j += 1
        endIf
        i += 1
    endWhile

    candidates = PapyrusUtil.ResizeStringArray(candidates, j)

    DFR_Util.Log("Candidates 5 = " + candidates)

    i = aiSeverity
    int maxSeverity = GetMaxSeverity()
        
    while i <= maxSeverity
        string[] tmp = Adversity.FilterEventsBySeverity(candidates, i, false)

        if tmp.Length
            int[] weights = Utility.CreateIntArray(tmp.Length, 100)
            weights = Adversity.SumArrays(weights, Adversity.WeighEventsByActor("deviousfollowers", LastMaster, tmp, 100))
            return tmp[Adversity.GetWeightedIndex(weights)]
        endIf

        i += 1
    endWhile

    return ""
endFunction

function SetupDialogue()
    if InSlaverySetup
        DFR_Util.Log("Setup Dialogue - aborting due to slavery setup")
        return
    endIf

    int num = 0
    int context = Events.CONTEXT_TYPE_SERVICE

    DFR_Util.Log("SetupDialogue - " + (GameDaysPassed.GetValue() - LastServiced) as string + " - " + (ServiceCooldown as float * 0.042) as string + " - " + SelectedEvent)

    if !ServiceOrPunishmentActive && SelectedEvent != "" && CanApologise || ((GameDaysPassed.GetValue() - LastServiced) > (ServiceCooldown as float * 0.042))
        num = 1
        if CanApologise
            context = Events.CONTEXT_TYPE_APOLOGY
        endIf
    endIf

    Events.Setup(Utility.CreateStringArray(num, SelectedEvent), context)
endFunction

function DelayLocationTimer()
    ServiceLocationChangeTimer = GameDaysPassed.GetValue() + (0.042 * 0.5)
endFunction

function AcceptEvent(string asId, int aiContext)
    CanApologise = false

    ForcedEventTimer = GameDaysPassed.GetValue() + (ForcedServiceCooldown as float * 0.042)

    Escalate(Adversity.GetEventSeverity(asId))
    if Adversity.EventHasTag(asId, "type:rule")
        Rules.Add(asId, StorageUtil.GetIntValue(self, "Term_" + asId), aiContext)
        ServiceRuleTimer = GameDaysPassed.GetValue() + Utility.RandomInt(ServiceRuleCooldownMin, ServiceRuleCooldownMax)
    else
        if Adversity.IsEventActive(asId)
            ServiceOrPunishmentActive = true
        endIf
    endIf
    
    DFR_Util.Log("Events - AcceptEvent - ServiceOrPunishmentActive = " + ServiceOrPunishmentActive)
endFunction

function RefuseEvent(string asId, int aiContext)
    CanApologise = false
    DeEscalate(Adversity.GetEventSeverity(asId))
    DFR_Util.Log("Events - RefuseEvent - Escalation = " + Escalation)
    LastServiced = GameDaysPassed.GetValue()
    ServiceOrPunishmentActive = false
endFunction

function CompleteEvent(string asId)
    DFR_Util.Log("Events - CompleteEvent = " + asId + " - " + Escalation)
    
    string context = Events.GetContext(asId)
    
    if Events.IncreasesFavour(asId)
        IncFavour()
    endIf
    
    ServiceOrPunishmentActive = false
    LastServiced = GameDaysPassed.GetValue()
endFunction

function FailEvent(string asId)    
    DFR_Util.Log("Events - CompleteEvent = " + asId + " - " + Escalation)
  
    string context = Events.GetContext(asId)

    DecFavour(2)
    ServiceOrPunishmentActive = false
    LastServiced = GameDaysPassed.GetValue()
endFunction

function Escalate(int aiAmount = 1)
    float multiplier = Adversity.GetActorFloat("deviousfollowers", LastMaster, "escalation-increase-multiplier", 1.0)
    Escalation += Math.Floor(aiAmount * multiplier)
    DFR_Util.Log("Escalate - amt = " + aiAmount + " - multiplier = " + multiplier + " - escalation = " + Escalation)
    SetTargetSeverity()
endFunction

function DeEscalate(int aiAmount = 1)
    float multiplier = Adversity.GetActorFloat("deviousfollowers", LastMaster, "escalation-decrease-multiplier", 1.0)
    Escalation -= Math.Ceiling(aiAmount)
    DFR_Util.Log("Escalate - amt = " + aiAmount + " - multiplier = " + multiplier + " - escalation = " + Escalation)
    SetTargetSeverity()
endFunction

function SetTargetSeverity()
    float lastTarget = TargetSeverity.GetValue()
    float newTarget = GetTargetSeverity()
    TargetSeverity.SetValue(newTarget)
    if newTarget != lastTarget
        int handle = ModEvent.Create("DFR_TargetSeverity_Change")
        if handle
            ModEvent.PushFloat(handle, newTarget)
            ModEvent.Send(handle)
        endIf
    endIf
endFunction

int function GetMaxSeverity()
    if IsSlave()
        return 5
    endIf

    return 4
endFunction

int function GetTargetSeverity()
    if IsSlave()
        return 5
    endIf

    return PapyrusUtil.ClampInt(1 + Math.Floor(Escalation * NumServicesToSeverity), 1, GetMaxSeverity())
endFunction