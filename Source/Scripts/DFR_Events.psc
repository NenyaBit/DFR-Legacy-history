Scriptname DFR_Events extends Quest conditional

ReferenceAlias property MasterAlias auto
DFR_RelationshipManager property RelManager auto
GlobalVariable property Willpower auto

int[] property RejectFavourReqs auto hidden
bool property CanRefuse auto hidden conditional

bool property FoundNoPuns auto hidden conditional
bool property ForcedPunishment = false auto hidden
String SelectedPunishment = ""

bool property FoundNoJobs auto hidden conditional
bool property ForcedJob = false auto hidden
String SelectedJob = ""

bool property FoundNoGames auto hidden conditional
bool property ForcedGame = false auto hidden
String SelectedGame = ""

string INTERRUPT_KEY = "DFR_Sleep_Interrupt"
ObjectReference property LastBed auto hidden
bool property RegularBed auto hidden conditional
string SelectedSleepEvent = ""

event OnInit()
    Maintenance()
endEvent

function Maintenance()
    RejectFavourReqs = Utility.CreateIntArray(RelManager.NumFavourLevels)
    RejectFavourReqs[0] = 10
    RejectFavourReqs[1] = 25
    RejectFavourReqs[2] = 50
    RejectFavourReqs[3] = 75

    DFR_Util.Log("Sleep - Maintenance")
	RegisterForMenu("Sleep/Wait Menu")
	RegisterForModEvent("Adv_SleepInterrupt", "OnSleepInterrupt")
endFunction

DFR_Events function Get() global
    return Quest.GetQuest("DFR_Events") as DFR_Events
endFunction

Actor function GetMaster()
    return MasterAlias.GetRef() as Actor
endFunction

function Prep(bool abForced = false, string asType)
    int penalty = 0
    
    if abForced
        penalty = 20
    endIf

    if asType == "punish"
        ForcedPunishment = abForced
    elseIf asType == "job"
        ForcedJob = abForced
    elseIf asType == "game"
        ForcedGame = abForced
    endIf

    CanRefuse = !RelManager.IsSlave() || (Utility.RandomInt(0, 100) <= (RejectFavourReqs[RelManager.GetFavourLevel()] - penalty))
endFunction

string function SelectEventOfType(string asType, string lastSelected)
    DFR_Util.Log("SelectEventOfType - " + asType + " - " + lastSelected)
    asType = "type:" + asType

    string[] selectedEvents = Adversity.GetSelectedEvents("deviousfollowers", asType)
    selectedEvents = Adversity.FilterEventsByTags(selectedEvents, Utility.CreateStringArray(1, asType))

    int i = 0
    while i < selectedEvents.length
        Adversity.UnselectEvent(selectedEvents[i])
        i += 1
    endWhile

    if lastSelected != ""
        Adv_EventBase currSelected = Adversity.GetEvent(lastSelected)
        if currSelected.IsValid(MasterAlias.GetRef() as Actor)
            Adversity.SelectEvent(lastSelected)
            DFR_Util.Log("SelectEventOfType - using last selected - " + lastSelected)
            return lastSelected
        else
            Adversity.UnselectEvent(lastSelected)
        endIf
    endIf

    string[] events = Adversity.GetContextEvents("deviousfollowers")
    events = Adversity.FilterEventsByTags(events, Utility.CreateStringArray(1, asType))
    events = Adversity.FilterEventsByValid(events)

    if events.length
        string selected = events[Utility.RandomInt(0, events.length - 1)]
        Adversity.SelectEvent(selected)
        DFR_Util.Log("SelectEventOfType - selected new - " + selected)
        return selected
    else
        DFR_Util.Log("SelectEventOfType - none found")
        return ""
    endIf
endFunction

function SelectPunishment(bool abReset = false)
    if abReset
        Adversity.UnselectEvent(SelectedPunishment)
        SelectedPunishment = ""
    endIf

    SelectedPunishment = SelectEventOfType("punishment", SelectedPunishment)
    ;SelectedPunishment = SelectEventOfType("punishment", "deviousfollowers/core/sex")
    FoundNoPuns = SelectedPunishment == ""
endFunction

function SelectJob(bool abReset = false)
    if abReset
        Adversity.UnselectEvent(SelectedJob)
        SelectedJob = ""
    endIf

    SelectedJob = SelectEventOfType("job", SelectedJob)
    FoundNoJobs = SelectedJob == ""
endFunction

function SelectGame(bool abReset = false)
    if abReset
        Adversity.UnselectEvent(SelectedGame)
        SelectedGame = ""
    endIf

    SelectedGame = SelectEventOfType("game", SelectedGame)
    FoundNoGames = SelectedGame == ""
endFunction

function SelectAll(bool abReset = false)
    DFR_Util.Log("DFR_Events - SelectAll - " + abReset)
    SelectPunishment(abReset)
    SelectJob(abReset)
    SelectGame(abReset)
endFunction

function AcceptPun(bool abForced = false)
    DFR_Util.Log("DFR_Events - AcceptPun - " + SelectedPunishment)
    if Adversity.StartEvent(SelectedPunishment, MasterAlias.GetActorRef())

        if abForced
            RelManager.DecFavour()
        elseIf !ForcedPunishment
            RelManager.IncFavour()
        endIf

        StorageUtil.SetIntValue(none, "DFR_Events_Type", 0)

        RelManager.ResetForcedPunishment()
    else
        Adversity.UnselectEvent(SelectedPunishment)
    endIf
SelectPunishment(true)
endFunction

function RejectPun()
    Adversity.UnselectEvent(SelectedPunishment)
    SelectedPunishment = ""
    RelManager.DecFavour()
    RelManager.ResetForcedPunishment()

    SelectPunishment(true)
endFunction

function AcceptJob(bool abForced = false)
    DFR_Util.Log("DFR_Events - AcceptJob - " + SelectedJob)
    if Adversity.StartEvent(SelectedJob, MasterAlias.GetActorRef())
        if abForced
            RelManager.DecFavour()
        elseIf !ForcedJob
            RelManager.IncFavour()
        endIf

        StorageUtil.SetIntValue(none, "DFR_Events_Type", 1)
    else
        Adversity.UnselectEvent(SelectedJob)
    endIf

    SelectJob(true)
endFunction

function RejectJob()
    Adversity.UnselectEvent(SelectedJob)
    SelectedJob = ""
    RelManager.DecFavour()
    SelectJob(true)
endFunction

function Delay()
    RelManager.ResetForcedPunishment()
endFunction

event OnMenuOpen(string asMenu)
	DFR_Util.Log("Sleep - OnMenuOpen")
    
    SelectedSleepEvent = ""
    RegularBed = false
    bool interrupt = false

	if RelManager.IsSlave()
		ObjectReference bed = Game.GetCurrentCrosshairRef()
		LastBed = bed

        Keyword bedrollKwd = Keyword.GetKeyword("FurnitureBedRoll")

        if bed && !bed.HasKeyword(bedrollKwd)
            RegularBed = true
            interrupt = true
		endIf
	endIf

    if interrupt
        string[] events = Adversity.GetContextEvents("deviousfollowers")
        
        DFR_Util.Log("Sleep - Events 1 = " + events)
        
        events = Adversity.FilterEventsByTags(events, Utility.CreateStringArray(1, "type:sleep"))
        DFR_Util.Log("Sleep - Events 2 = " + events)
        
        events = Adversity.FilterEventsByValid(events, master)

        DFR_Util.Log("Sleep - Events 3 = " + events)

        Actor master = MasterAlias.GetActorRef()

        if events.length
            SelectedSleepEvent = events[Utility.RandomInt(0, events.length - 1)]
            DFR_Util.Log("Sleep - Registering an interrupt")
            Adv_SleepUtils.Get().RegisterInterrupt(INTERRUPT_KEY, 0)
        endIf
    endIf
endEvent

event OnMenuClose(string asMenu)
	Adv_SleepUtils.Get().RemoveInterrupt(INTERRUPT_KEY)
endEvent

event OnSleepInterrupt(string asEvent, string asArg, float afArg, Form akSender)
	if asArg != INTERRUPT_KEY
		return
	endIf
    
    DFR_Util.Log("Sleep - OnSleepInterrupt")
    Adversity.StartEvent(SelectedSleepEvent)
endEvent