Scriptname DFR_RelationshipManager extends Quest conditional

GlobalVariable property GameDaysPassed auto
QF__DflowDealController_0A01C86D property DealController auto

int property Favour auto hidden conditional
GlobalVariable property FavourGlobal auto
int property FavourIncrement = 20 auto hidden
int property FavourDecay = -20 auto hidden
int property FavourDecayDealPrevention = 5 auto hidden

float property RemembersFor = 30.0 auto hidden

bool property CanApologise auto hidden conditional
float property ForcedPunishmentDelay = 0.25 auto hidden
float property ForcedPunishmentTimer auto hidden conditional
int[] property ForcedPunishChances auto hidden
bool property ForcedPunishment = false auto hidden conditional

int property NumFavourLevels = 4 auto hidden

float property ForcedDealTimer auto hidden conditional

DFR_RelationshipManager function Get() global
    return Quest.GetQuest("DFR_RelationshipManager") as DFR_RelationshipManager
endFunction

event OnInit()
    SetupPunishChances()
endEvent

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
    Favour -= aiSeverity * FavourIncrement
    Favour = PapyrusUtil.ClampInt(Favour, -100, 100)
    FavourGlobal.SetValue(Favour)

    if aiSeverity == 1
        Debug.Notification("Your " + GetSubject() + " was annoyed by that")
    elseIf aiSeverity == 2
        Debug.Notification("Your " + GetSubject() + " was very annoyed by that")
    elseIf aiSeverity == 2
        Debug.Notification("Your " + GetSubject() + " was extremely annoyed by that")
    endIf

    StartApologyTimer()
    DFR_Util.Log("DecFavour - favour = " + favour)
endFunction

function IncFavour(int aiSeverity = 1)
    aiSeverity = PapyrusUtil.ClampInt(aiSeverity, 1, 3)
    Favour += aiSeverity * FavourIncrement
    Favour = PapyrusUtil.ClampInt(Favour, -100, 100)
    FavourGlobal.SetValue(Favour)

    if aiSeverity == 1
        Debug.Notification("Your " + GetSubject() + " was pleased by that")
    elseIf aiSeverity == 2
        Debug.Notification("Your " + GetSubject() + " was very pleased by that")
    elseIf aiSeverity == 2
        Debug.Notification("Your " + GetSubject() + " was extremely pleased by that")
    endIf
    
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
        return "Master"
    else
        return "Follower"
    endIf
endFunction

function RestartPolling()
    UnregisterForUpdateGameTime()
    RegisterForSingleUpdateGameTime(10.0)
endFunction

event OnUpdateGameTime()
    if IsSlave() && Favour > 0
        int decay = FavourDecay + (FavourDecayDealPrevention * DealController.Deals)
        
        if decay > 0
            decay = 0
        endIf

        Favour += decay
    endIf

    FavourGlobal.SetValue(Favour)
    RegisterForSingleUpdateGameTime(10.0)
endEvent

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