Scriptname DFR_JobBase extends Adv_EventBase

; utilities
bool function Start(Actor akTarget)
    DFR_Jobs jobs = DFR_Jobs.Get()
    string id = GetEventId()

    Log("Start")

    jobs.OnStartJob(id)

    if parent.Start(akTarget)
        return true
    else
        jobs.OnCancelJob(id)
    endIf
   
    Log("Failed to Start")

    return false
endFunction

bool function Pause()
    if parent.Pause()
        DFR_Jobs.Get().OnPauseJob(GetEventId())
        return true
    endIf
    return false
endFunction

bool function Resume()
    DFR_Jobs jobs = DFR_Jobs.Get()
    string id = GetEventId()
    if jobs.CanResumeJob(id) && parent.Resume()
        if Adversity.IsEventActive(id)
            jobs.OnResumeJob(id)
        endIf
        
        return true
    endIf
    return false
endFunction

function Next()
    Log("Next")
    DFR_Jobs.Get().OnStageComplete(GetEventId())
endFunction

function Complete()
    Log("completed")
    ClearObjectiveTargets()
    Stop()
    DFR_Jobs.Get().OnDone(GetEventId(), false)
    Next()
endFunction

function Fail()
    Log("failed")
    ClearObjectiveTargets()
    Stop()
    DFR_Jobs.Get().OnDone(GetEventId(), true)
    Next()
endFunction

function Log(string asMsg)
    DFR_Util.Log("[" + GetEventId() + "] " + asMsg)
endFunction