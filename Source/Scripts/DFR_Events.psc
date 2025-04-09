Scriptname DFR_Events extends Quest conditional

ReferenceAlias property FollowerAlias auto
DFR_RelationshipManager property RelManager auto
QF__DflowDealController_0A01C86D property DealController auto
_DFtools property Tool auto

bool property Display auto hidden conditional
bool property Loop auto hidden conditional
bool property AllowWalkaway auto hidden conditional

GlobalVariable property Forced auto
GlobalVariable property EventContext auto

int property CONTEXT_TYPE_DEALS = 0 autoreadonly hidden
int property CONTEXT_TYPE_FORCED = 1 autoreadonly hidden
int property CONTEXT_TYPE_SERVICE = 2 autoreadonly hidden
int property CONTEXT_TYPE_APOLOGY = 3 autoreadonly hidden
int property CONTEXT_TYPE_SLAVERY_SETUP = 4 autoreadonly hidden
int property CONTEXT_TYPE_CHALLENGE = 5 autoreadonly hidden

string[] CurrEvents
int NextEventIndex
bool IncreaseFavour

bool Immediate

DFR_Events function Get() global
    return Quest.GetQuest("DFR_Events") as DFR_Events
endFunction

; called from rel manager and deal controller
function Setup(string[] asEvents, int aiContext, bool abIncFavour = true, bool abForced = false, bool abAllowWalkaway = true)
    Display = asEvents.Length > 0

    EventContext.SetValue(aiContext)
    DFR_Util.Log("Events - Setup - Context = " + EventContext.GetValue() + " - Events = " + asEvents)

    CurrEvents = asEvents
    NextEventIndex = 0
    
    IncreaseFavour = abIncFavour
    Forced.SetValue(abForced as int)
    Loop = CurrEvents.Length > 1
    AllowWalkaway = abAllowWalkaway
    Immediate = false

    string[] eventTags = new string[3]
    eventTags[0] = "type:rule"
    eventTags[1] = "subtype:service"
    eventTags[2] = "subtype:punishment"

    string[] selectedEvents = Adversity.GetSelectedEvents("deviousfollowers")
    selectedEvents = Adversity.FilterEventsByTags(selectedEvents, eventTags)
    
    int i = 0
    while i < selectedEvents.Length
        Adversity.UnselectEvent(selectedEvents[i])
        i += 1
    endWhile

    if CurrEvents.Length
        if !Adversity.SelectEvent(CurrEvents[0])
            DFR_Util.Log("Events - Setup - failed to select - " + CurrEvents[0])
            Display = false
        endIf
    endIf

    DFR_Util.Log("Events - Setup - Display = " + Display + " - Forced = " + Forced.GetValue() + " - Loop = " + Loop + " - AllowWalkaway = " + AllowWalkaway)
endFunction

function Accept()
    ActivateEvent(CurrEvents[NextEventIndex - 1])
endFunction

function Refuse()
    if Immediate
        Immediate = false
        return
    endif
    
    if RelManager.IsSlave()
        Adv_Collar.Get().Zap()
    endIf

    if Forced.GetValue()
        StorageUtil.SetIntValue(self, "DFR_Forced", 1)
        ActivateEvent(CurrEvents[NextEventIndex - 1])
    else
        StorageUtil.UnsetIntValue(self, "DFR_Forced")
        DeactivateEvent(CurrEvents[NextEventIndex - 1])
    endIf
endFunction

function ActivateEvent(string asId)
    DFR_Util.Log("Events - Activating Event = " + asId + " - " + NextEventIndex)
    int context = EventContext.GetValue() as int
    
    Tool.DeferPunishments()
    
    StorageUtil.SetIntValue(self, "DFR_EventContext_" + asId, context)
    StorageUtil.SetStringValue(self, "DFR_EventFavour_" + asId, IncreaseFavour)

    if Adversity.StartEvent(asId, FollowerAlias.GetRef() as Actor)
        if context == 0
            DealController.AcceptRule(asId)
        else
            RelManager.AcceptEvent(asId, context)
        endIf

        DFR_Util.Log("Events - Activating Event = " + asId + " - Done")
    else
        StorageUtil.UnsetStringValue(self, "DFR_EventContext_" + asId)
        StorageUtil.UnsetStringValue(self, "DFR_EventFavour_" + asId)

        Adversity.UnselectEvent(asId)

        if context == 0
            DealController.ResetRule(asId)
        endIf

        DFR_Util.Log("Events - Activating Event = " + asId + " - Failed")
    endIf
endFunction

function DeactivateEvent(string asId)
    
    Adversity.UnselectEvent(asId)
    int context = EventContext.GetValue() as int

    if context == 0
        DealController.RefuseRule(asId)
    else
        RelManager.RefuseEvent(asId, context)
    endIf

    DFR_Util.Log("Events - Deactivating Event = " + asId)
endFunction

bool function IsRule(string asId)
    DFR_Util.Log("Tags: " + Adversity.GetEventTags(asId))
    return Adversity.EventHasTag(asId, "type:rule")
endFunction

function Next()
    NextEventIndex += 1
    DFR_Util.Log("Events - Next Start - " + NextEventIndex)

    if NextEventIndex < CurrEvents.Length
        DFR_Util.Log("Events - Next - selecting event - " + CurrEvents[NextEventIndex] + " - " + NextEventIndex)
        Adversity.SelectEvent(CurrEvents[NextEventIndex])
        DFR_Util.Log("Events - Next - finished selecting event - " + CurrEvents[NextEventIndex] + " - " + NextEventIndex)
    else
        DFR_Util.Log("Events - Next - disabling loop - " + NextEventIndex + " < " + CurrEvents.Length + " = " + NextEventIndex < CurrEvents.Length)

        if EventContext.GetValue() as int == CONTEXT_TYPE_SLAVERY_SETUP
            Quest.GetQuest("DFR_Slavery").SetStage(10)
        endIf

        Loop = false
    endIf
endFunction

function Gave()
    string givenEvent = CurrEvents[NextEventIndex - 1]
    DFR_Util.Log("Events - Gave = " + givenEvent)
    if Adversity.EventHasTag(givenEvent, "immediate")
        Immediate = true
        DFR_Util.Log("Events - Gave - " + givenEvent + " is immediate - closing dialogue menu")
        PO3_SKSEFunctions.HideMenu("Dialogue Menu")
        Accept()
    endIf
endFunction

int function GetContext(string asId)
    return StorageUtil.GetIntValue(self, "DFR_EventContext_" + asId, -1)
endFunction

bool function WasForced(string asId)
    return StorageUtil.GetIntValue(self, "DFR_Forced" + asId)
endFunction

string function IncreasesFavour(string asId)
    return StorageUtil.GetStringValue(self, "DFR_EventContext_" + asId, -1)
endFunction