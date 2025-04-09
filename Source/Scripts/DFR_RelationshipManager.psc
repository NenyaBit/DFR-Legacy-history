Scriptname DFR_RelationshipManager extends Quest conditional

GlobalVariable property GameDaysPassed auto
GlobalVariable property DebugMode auto
DFR_Events property Events auto

int property Favour auto hidden conditional
GlobalVariable property FavourGlobal auto
GlobalVariable property TargetSeverity auto

bool property CanApologise auto hidden conditional
float property ForcedPunishmentTimer auto hidden conditional
int property NumFavourLevels = 4 auto hidden
float property ForcedDealTimer auto hidden conditional
bool property ForcedPunishment = false auto hidden conditional

int Escalation = 0

float property LastServiced auto hidden

float property RecentlyFavoured auto hidden conditional
float property LastFavoured = -1.0 auto hidden

Actor LastMaster

string SelectedEvent

bool ServiceOrPunishmentActive = false

float LastCheckedFavour = 0.0

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
    DelayForcedDealTimer()
    SetStage(10)
    SendModEvent("DFR_RelStage_Change", "", 1)

    if akMaster != LastMaster
        Escalation = 0
    endIf

    SetTargetSeverity()

    LastMaster = akMaster
endFunction

function SetStageSlavery(Actor akMaster)
    CheckAndClearFavour(akMaster)
    Favour = StorageUtil.GetIntValue(akMaster, "DFR_Cached_Favour")
    FavourGlobal.SetValue(Favour)
    RestartPolling()
    CanApologise = false
    DelayForcedDealTimer()
    SetStage(50)
    SendModEvent("DFR_RelStage_Change", "", 5)

    if akMaster != LastMaster
        Escalation = 0
    endIf

    SetTargetSeverity()

    LastMaster = akMaster
endFunction

function StartApologyTimer()
    CanApologise = true

    SetupPunishChances()
    
    if !ForcedPunishment
        ForcedPunishment = Utility.RandomInt(0, 99) <= ForcedPunishChances[GetFavourLevel()]
        ForcedPunishmentTimer = GameDaysPassed.GetValue() + 0.0104
    endIf

    DFR_Util.Log("StartApologyTimer - ForcedPunishment = " + ForcedPunishment + " - Punish Chance = " + ForcedPunishChances[GetFavourLevel()] + " - ForcedPunishmentTimer = " + ForcedPunishmentTimer)
endFunction

function ResetForcedPunishment()
    ForcedPunishment = false
    CanApologise = false
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

    RecentlyFavoured = - 1
    LastServiced = -1

    StartApologyTimer()
    DFR_Util.Log("DecFavour - favour = " + favour)
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
    
    CanApologise = false
    LastFavoured = GameDaysPassed.GetValue()
    RecentlyFavoured = LastFavoured + (RecentlyFavouredDuration as float * 0.042)

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

function DelayForcedDealTimer()
    ForcedDealTimer = GameDaysPassed.GetValue() + Utility.RandomInt(1, 3)
endFunction

event OnMenuOpen(string asMenu)
    int severity = GetTargetSeverity()
    
    if CanApologise
        severity += 1
    endIf

    severity = PapyrusUtil.ClampInt(severity, 1, GetMaxSeverity())

    string type = "service"
    if CanApologise && IsSlave()
        type = "punishment"
    endIf

    SelectedEvent = SelectEvent("service", severity)

    DFR_Util.Log("Relationship - Severity = " + severity + " - SelectedEvent = " + SelectedEvent)
endEvent

string function SelectEvent(string asType, int aiSeverity)
    if DebugMode.GetValue()
        string path = Adversity.GetConfigPath("deviousfollowers")
        string forced = JsonUtil.GetStringValue(path, "forced-" + asType)

        DFR_Util.Log("SelectEvent - " + forced)

        if forced != ""
            return "deviousfollowers/" + forced
        endIf
    endIf

    string[] candidates = Adversity.GetContextEvents("deviousfollowers")
    candidates = Adversity.FilterEventsByTags(candidates, Utility.CreateStringArray(1, "subtype:" + asType))
    DFR_Util.Log("Candidates 1 = " + candidates)
    candidates = Adversity.FilterEventsByValid(candidates)
    DFR_Util.Log("Candidates 2 = " + candidates)
    candidates = Adversity.FilterEventsByCooldown(candidates)
    DFR_Util.Log("Candidates 3 = " + candidates)

    int i = aiSeverity
    int maxSeverity = GetMaxSeverity()
    
    DFR_Util.Log("Candidates i = " + i + " - max = " + maxSeverity)
    
    while i <= maxSeverity
        string[] tmp = Adversity.FilterEventsBySeverity(candidates, i, false)

        DFR_Util.Log("Candidates " + i + " = " + candidates)

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
    int num = 0
    int context = 2

    DFR_Util.Log("SetupDialogue - " + (GameDaysPassed.GetValue() - LastServiced) as string + " - " + (ServiceCooldown as float * 0.042) as string)

    if !ServiceOrPunishmentActive && (GameDaysPassed.GetValue() - LastServiced) > (ServiceCooldown as float * 0.042) && SelectedEvent != ""
        num = 1
        if CanApologise
            context = 3
        endIf
    endIf

    Events.Setup(Utility.CreateStringArray(num, SelectedEvent), context)
endFunction

function AcceptEvent(string asId, int aiContext)
    Escalate(Adversity.GetEventSeverity(asId))
    ServiceOrPunishmentActive = true
    DFR_Util.Log("Events - AcceptEvent - ServiceOrPunishmentActive = " + ServiceOrPunishmentActive)
endFunction

function RefuseEvent(string asId, int aiContext)
    DeEscalate(Adversity.GetEventSeverity(asId))
    DFR_Util.Log("Events - RefuseEvent - Escalation = " + Escalation)
    LastServiced = GameDaysPassed.GetValue()
endFunction

function CompleteEvent(string asId)
    string context = Events.GetContext(asId)
    if context == 2 || context == 3
        IncFavour()
        ServiceOrPunishmentActive = false
    endIf

    DFR_Util.Log("Events - CompleteEvent = " + asId + " - " + Escalation)

    LastServiced = GameDaysPassed.GetValue()
endFunction

function FailEvent(string asId)
    string context = Events.GetContext(asId)
    if context == 2 || context == 3
        DecFavour(2)
        ServiceOrPunishmentActive = false
    endIf
    DFR_Util.Log("Events - CompleteEvent = " + asId + " - " + Escalation)

    LastServiced = GameDaysPassed.GetValue()
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