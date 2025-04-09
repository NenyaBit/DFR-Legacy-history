Scriptname DFR_Collar extends Quest conditional

Adv_Collar property Collar auto
QF__Gift_09000D62 property Flow auto

ReferenceAlias property MasterAlias auto

Scene property LeashScene auto
Scene property LeadScene auto

bool Enabled = false
int NumViolations = 0

DFR_Collar function Get() global
    return Quest.GetQuest("DFR_Collar") as DFR_Collar
endFunction

function Maintenance()
    RegisterForModEvent("Adv_Collar_Violation", "OnCollarViolation")
endFunction

function StartMonitoring()
    Enabled = true
    NumViolations = 0
endFunction

function StopMonitoring()
    Enabled = false
endFunction

event OnCollarViolation(string asEvent, string asArg, float afArg, Form akSender)
    DFR_Util.Log("DFR_Collar - OnCollarViolation")

    if Enabled
        NumViolations += 1

        if NumViolations >= 5
            DFR_RelationshipManager.Get().DecFavour()
            NumViolations = 0
        endIf

        MasterAlias.ForceRefTo(Flow.Alias__DMaster.GetRef())

        DFR_Util.Log("DFR_Collar - Master = " + MasterAlias.GetRef() + " - " + Collar.CurrMode)

        if Collar.CurrMode == 0 
            LeashScene.Start()
        else
            LeadScene.Start()
        endif
    endIf
endEvent