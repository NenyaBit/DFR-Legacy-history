Scriptname DFR_Collar extends Quest conditional

Adv_Collar property Collar auto
QF__Gift_09000D62 property Flow auto
DFR_RelationshipManager property RelManager auto
ReferenceAlias property MasterAlias auto
Quest property TownMode auto

Scene property LeashScene auto
Scene property LeadScene auto
Scene property LocationScene auto

bool property TargetSet auto hidden conditional

bool property Enabled = false auto hidden conditional
bool property OnBreak = false auto hidden conditional

int NumViolations = 0

float property CloseDistanceThreshold = 1000.0 auto

DFR_Collar function Get() global
    return Quest.GetQuest("DFR_Collar") as DFR_Collar
endFunction

function Maintenance()
    RegisterForModEvent("Adv_Collar_Violation", "OnCollarViolation")
    RegisterForModEvent("Adv_Collar_Update", "OnCollarUpdate")
endFunction

function SetTargetRef(ObjectReference akTarget)
    if TownMode.IsRunning()
        TownMode.Stop()
    endIf

    ResetAll()
    Enabled = true
    EndBreak()
    Collar.SetTargetRef(akTarget, 500, akViolation = LeadScene)
    RelManager.DelayForcedEvent(4)
endFunction

function RestrictLocation(Location akLocation)
    ResetAll()
    Collar.SetLocation(akLocation, LocationScene)
endFunction

function ResetAll()
    Enabled = false
    EndBreak()
    Collar.StopPassive()
    NumViolations = 0
endFunction

function Pause(string asKey)
    if !Enabled
        return
    endIf
    
    Collar.Pause(asKey)
endFunction

function Resume(string asKey)
    if !Enabled
        return
    endIf

    Collar.Resume(asKey)
endFunction

event OnCollarViolation(string asEvent, string asArg, float afArg, Form akSender)
    DFR_Util.Log("DFR_Collar - OnCollarViolation")

    if Enabled
        NumViolations += 1

        if NumViolations >= 5
            DFR_RelationshipManager.Get().DecFavour()
            NumViolations = 0
        endIf
    endIf
endEvent

function OnCollarUpdate(float afLastDistance, float afCurrentDistance)
    if !Enabled
        return
    endIf

    if Collar.CurrMode == Collar.COLLAR_MODE_LEAD && (afCurrentDistance < CloseDistanceThreshold || (Collar.PlayerRef.GetParentCell() == Collar.TargetRef.GetParentCell()))
        ;DFR_Util.Log("Pausing services due to proximity to target: current = " + afCurrentDistance + " - threshold = " + CloseDistanceThreshold)
        RelManager.PauseServices("collar")
    else
        ;DFR_Util.Log("Resuming services due to distance to target")
        RelManager.ResumeServices("collar")
    endIf
endFunction

function Break()
    UnregisterForUpdateGameTime()
    RegisterForSingleUpdateGameTime(3.0)
    OnBreak = true
    Pause("break")
endFunction

event OnUpdateGameTime()
    EndBreak()
endEvent

function EndBreak()
    Resume("break")
    OnBreak = false
    UnregisterForUpdateGameTime()
endFunction
