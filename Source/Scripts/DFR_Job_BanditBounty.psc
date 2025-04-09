Scriptname DFR_Job_BanditBounty extends DFR_JobBase  

Quest property ActualQuest auto
DFR_BQ01 property TrackerQuest auto

function OnModuleLoad()
    Log("OnModuleLoad")
    EventName = "bandit bounty"

    PO3_Events_Alias.UnregisterForAllQuestStages(self)
    PO3_Events_Alias.RegisterForQuestStage(self, ActualQuest)
endFunction

bool function OnStart(Actor akTarget)
    Log("OnStart")
    return ActualQuest.SetStage(10)
endFunction

function OnResume()
    Log("OnResume")
    TrackerQuest.Resume()
endFunction

function OnPause()
    Log("OnPause")
    TrackerQuest.Pause()
endFunction

event OnLocationChange(Location akOldLocation, Location akNewLocation)
    if IsActive()
        Log("OnLocationChange - " + akNewLocation)
        TrackerQuest.OnLocationChange(akNewLocation)
    endIf
endEvent

event OnQuestStageChange(Quest akQuest, int aiNewStage)
    Log("OnQuestStageChange - " + akQuest + " - " + aiNewStage + " - " + GetEventId() + " - " + Adversity.GetEventStatus(GetEventId()) + " - " + IsActive())
    
    if aiNewStage == 0
        RestartQuest()
    else
        if IsActive()
            TrackerQuest.SetStage(aiNewStage)
            if aiNewStage != 200 && aiNewStage != 201
                Next()
            endIf
        endIf
    endIf
endEvent

function RestartQuest()
    Log("Restarting")
    TrackerQuest.Reset()
    TrackerQuest.Start()
endFunction