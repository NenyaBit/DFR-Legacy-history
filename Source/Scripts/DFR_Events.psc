Scriptname DFR_Events extends Quest conditional

ReferenceAlias property FollowerAlias auto
DFR_RelationshipManager property RelManager auto
QF__DflowDealController_0A01C86D property DealController auto
DFR_Slavery property Slavery auto
_DFtools property Tool auto

bool property Display auto hidden conditional
bool property Loop auto hidden conditional
bool property AllowWalkaway auto hidden conditional

GlobalVariable property Forced auto
GlobalVariable property EventContext auto ; 0 = deals, 1 = over debt forced deals, 2 = service, 3 = apology, 4 = enslavement setup

string[] CurrEvents
int NextEventIndex

bool IncreaseFavour

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

    string[] selectedEvents = Adversity.GetSelectedEvents("deviousfollowers")
    DFR_Util.Log("selected events = " + selectedEvents)

    int i = 0
    while i < selectedEvents.Length
        Adversity.UnselectEvent(selectedEvents[i])
        i += 1
    endWhile

    if CurrEvents.Length
        if !Adversity.SelectEvent(CurrEvents[0])
            Display = false
        endIf
    endIf

    DFR_Util.Log("Events - Setup - Display = " + Display + " - Forced = " + Forced.GetValue() + " - Loop = " + Loop + " - AllowWalkaway = " + AllowWalkaway)
endFunction

function Accept()
    ActivateEvent(CurrEvents[NextEventIndex - 1])
endFunction

function Refuse()
    if RelManager.IsSlave()
        Adv_Collar.Get().Zap()
    endIf

    if Forced.GetValue()
        ActivateEvent(CurrEvents[NextEventIndex - 1])
    else
        DeactivateEvent(CurrEvents[NextEventIndex - 1])
    endIf
endFunction

function ActivateEvent(string asId)
    DFR_Util.Log("Events - Activating Event = " + asId)
    int context = EventContext.GetValue() as int
    
    Tool.DeferPunishments()
    
    if Adversity.StartEvent(asId, FollowerAlias.GetRef() as Actor)
        StorageUtil.SetStringValue(self, "DFR_EventContext_" + asId, context)

        if IsRule(asId)
            DFR_Util.Log("ActivateEvent - " + asId + " is rule")
            if RelManager.IsSlave()
                Slavery.AcceptRule(asId)
            else
                DealController.AcceptRule(asId)
            endIf
        endIf

        if context == 2 || context == 3
            RelManager.AcceptEvent(asId, context)
        endIf
        DFR_Util.Log("Events - Activating Event = " + asId + " - Done")
    else
        Adversity.UnselectEvent(asId)

        if IsRule(asId)
            DFR_Util.Log("ActivateEvent - " + asId + " is rule")
            if RelManager.IsSlave()
                Slavery.ResetRule(asId)
            else
                DealController.ResetRule(asId)
            endIf
        endIf

        DFR_Util.Log("Events - Activating Event = " + asId + " - Failed")
    endIf
endFunction

function DeactivateEvent(string asId)
    Adversity.UnselectEvent(asId)

    if IsRule(asId)
        if RelManager.IsSlave()
            Slavery.RefuseRule(asId)
        else
            DealController.RefuseRule(asId)
        endIf
    endIf

    int context = EventContext.GetValue() as int
    if context == 2 || context == 3
        RelManager.RefuseEvent(asId, context)
    endIf

    RelManager.DecFavour()

    DFR_Util.Log("Events - Deactivating Event = " + asId)
endFunction

bool function IsRule(string asId)
    DFR_Util.Log("Tags: " + Adversity.GetEventTags(asId))
    return Adversity.EventHasTag(asId, "type:rule")
endFunction

function Walkaway()
    RelManager.DecFavour()
    if !AllowWalkaway
        ; iterate through remaining inactive and activate
        int i = NextEventIndex - 1
        while i < CurrEvents.Length
            ActivateEvent(CurrEvents[i])
            i += 1
        endWhile
    endIf
endFunction

function Next()
    NextEventIndex += 1

    if NextEventIndex < CurrEvents.Length - 1
        Adversity.SelectEvent(CurrEvents[NextEventIndex])
    endIf

    if NextEventIndex >= (CurrEvents.Length - 1)
        Loop = false        
    endIf
endFunction

string function GetContext(string asId)
    return StorageUtil.GetStringValue(self, "DFR_EventContext_" + asId, -1)
endFunction