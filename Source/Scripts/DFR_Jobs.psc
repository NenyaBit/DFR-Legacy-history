Scriptname DFR_Jobs extends Quest conditional

Actor property PlayerRef auto
GlobalVariable property GameDaysPassed auto
GlobalVariable property GameHour auto
ReferenceAlias property MasterAlias auto

DFR_RelationshipManager property RelManager auto
QF__Gift_09000D62 property Flow auto
string[] property ActiveJobs auto hidden
_DFlowMCM property Config auto
DFR_Collar property Collar auto

Quest property TownMode auto
Scene property JobProvisionScene auto

string SelectedJob
string CurrJob

float property JobTimer auto hidden conditional
int property NumJobs = 0 auto hidden conditional
bool property FoundJob auto hidden conditional
bool property RunningJob = false auto hidden conditional

bool property ContinuingNextJob = false auto hidden conditional

int property ProvisionMode = 0 auto hidden conditional ; 0 = pause last, 1 = complete last, 2 = fail last
int property PROVISION_MODE_INTERRUPT = 0 autoreadonly hidden
int property PROVISION_MODE_COMPLETED = 1 autoreadonly hidden
int property PROVISION_MODE_FAILED = 2 autoreadonly hidden
int property PROVISION_MODE_BEGIN = 3 autoreadonly hidden
int property PROVISION_MODE_CANCELED = 4 autoreadonly hidden

; user configurable
int property MaxJobs = 1 auto hidden
int property MinJobs auto hidden
bool property MasterMode = true auto hidden conditional
bool property JobFGFlag = false auto hidden conditional
float property ForcedJobDelay = 1.0 auto hidden

bool Busy = false

string LastRejected

function Maintenance()

endFunction

DFR_Jobs function Get() global
    return Quest.GetQuest("DFR_Jobs") as DFR_Jobs
endFunction

string function Select(bool abLocation = true)
    if NumJobs > MaxJobs
        return ""
    endIf

    string[] jobs = Adversity.GetContextEvents("deviousfollowers")
        
    jobs = Adversity.FilterEventsByTags(jobs, Utility.CreateStringArray(1, "subtype:job"))
   
    Log("candidates 1 = " + jobs)

    jobs = Adversity.FilterEventsBySeverity(jobs, RelManager.GetTargetSeverity(), false)
    Log("candidates 2 = " + jobs)
    jobs = Adversity.FilterEventsByValid(jobs, Flow.Alias__DMaster.GetRef() as Actor)
    ;jobs = Adversity.SortEventsByClosestToRef(jobs, PlayerRef)
    Log("candidates 3 = " + jobs)

    if !Config._DFAnimalCont
        jobs = Adversity.FilterEventsByTags(jobs, Utility.CreateStringArray(1, "creature"), abInvert = true)
    endIf

    if jobs.Length > 1
        jobs = PapyrusUtil.RemoveString(jobs, Utility.CreateStringArray(1, LastRejected))
    endIf

    if jobs.Length
        return jobs[Utility.RandomInt(0, jobs.length - 1)]
    endIf

    return ""
endFunction

function OnLocationChange(Location akLocation)
    SetupDialogue()
endFunction

function SetupDialogue(bool abLocation = true)
    if RunningJob
        return
    endIf

    SelectedJob = Select()

    FoundJob = SelectedJob != ""

    string[] selectedJobs = Adversity.GetSelectedEvents("deviousfollowers")
    selectedJobs = Adversity.FilterEventsByTags(selectedJobs, Utility.CreateStringArray(1, "subtype:job"))

    int i = 0
    while i < selectedJobs.Length
        Adversity.UnselectEvent(selectedJobs[i])
        i += 1
    endWhile

    if FoundJob
        Adversity.SelectEvent(SelectedJob, Flow.Alias__DMaster.GetRef() as Actor)
    endIf

    Log("SetupDialogue - SelectedJob = " + SelectedJob + " - FoundJob = " + FoundJob)
endFunction

function Accept()
    Log("Accept - job = " + SelectedJob)

    ContinuingNextJob = false
    JobFGFlag = false

    Adversity.StartEvent(SelectedJob)
    SetupDialogue()
endFunction

function Refuse()
    Log("Refuse - SelectedJob = " + SelectedJob)

    ContinuingNextJob = false
    JobFGFlag = false
   
    Adversity.UnselectEvent(SelectedJob)
    RelManager.DecFavour()
    SetupDialogue()

    LastRejected = SelectedJob

    NextJob()
endFunction

function PauseCurrentJob()
    if RunningJob
        Delay(CurrJob)
    endIf
endFunction

function Delay(string asJob)
    Adversity.PauseEvent(asJob)
    StorageUtil.SetFloatValue(self, "DFR_ResumeDelay_" + asJob, Utility.GetCurrentGameTime() + 3)
endFunction

function Log(string asMsg)
    DFR_Util.Log("Jobs - " + asMsg)
endFunction

function Add(string asJob)
    ActiveJobs = PapyrusUtil.RemoveString(ActiveJobs, "")

    if ActiveJobs.Find(asJob) < 0
        ActiveJobs = PapyrusUtil.PushString(ActiveJobs, asJob)
    endIf
    
    NumJobs = ActiveJobs.Length
endFunction

function Remove(string asJob)
    ActiveJobs = PapyrusUtil.RemoveString(ActiveJobs, asJob)
    ActiveJobs = PapyrusUtil.RemoveString(ActiveJobs, "")
    NumJobs = ActiveJobs.Length
endFunction

; used in JobBase

bool function CanResumeJob(string asJob)
    return !RunningJob || CurrJob == "" || CurrJob == asJob
endFunction

; runs when job is first started
function OnStartJob(string asJob)
    Add(asJob)
    OnResumeJob(asJob)
    ProvisionMode = PROVISION_MODE_INTERRUPT
endFunction

; runs if job failed to start
function OnCancelJob(string asJob)
    Remove(asJob)
    ProvisionMode = PROVISION_MODE_CANCELED
endFunction

; runs whenever the master decides to resume the job
function OnResumeJob(string asJob)
    Log("OnResumeJob = " + asJob)

    if TownMode.IsRunning()
        TownMode.Stop()
    endIf

    RunningJob = true
    CurrJob = asJob
    ProvisionMode = PROVISION_MODE_INTERRUPT
endFunction

; runs whenever we want to pause the job
function OnPauseJob(string asJob)
    Log("OnPauseJob = " + asJob)
    if asJob == CurrJob
        RunningJob = false
        CurrJob = ""
    endIf
    ProvisionMode = PROVISION_MODE_INTERRUPT
endFunction

function OnStageComplete(string asJob)
    Log("OnStageComplete = " + asJob + " - Provision = " + ProvisionMode)

    if ActiveJobs.Find(asJob) > -1
        Adversity.PauseEvent(asJob)
    endIf

    NextJob()
endFunction

function OnDone(string asJob, bool abFailed)
    Log("OnDone = " + asJob + " - Failed = " + abFailed)

    if abFailed
        RelManager.DecFavour(2)
    else
        RelManager.IncFavour()
    endIf

    ; TODO: reduce debt
    Remove(asJob)

    if CurrJob == asJob
        RunningJob = false
        CurrJob = ""

        if abFailed
            ProvisionMode = PROVISION_MODE_FAILED
        else
            ProvisionMode = PROVISION_MODE_COMPLETED
        endIf
    endIf
endFunction

function PlayScene(Scene akScene)
    MasterAlias.ForceRefTo(Flow.Alias__DMaster.GetRef())
    akScene.Start()
endFunction

function NextJob()
    SetupDialogue()

    if !RelManager.IsSlave() || !MasterMode
        return
    endIf

    Log("OnStageComplete - MasterMode")

    float time = GameHour.GetValue()
    if time > 19 || time < 5 ; 7pm - 5am
        ; RTT to rest
        CurrJob = ""
        RunningJob = false
        if !TownMode.Start()
            Log("Failed to start town mode - going to free roam mode")
        endIf
        return
    endIf

    if FoundJob && NumJobs < MaxJobs && !Adversity.IsLocked()
        Log("OnStageComplete - Found Job = " + SelectedJob + " - starting scene")
        PlayScene(JobProvisionScene)
        return
    endIf

    if ActiveJobs.Length
        Log("OnStageComplete - Attempting to Resume Job")

        string[] potentialJobs = Utility.CreateStringArray(ActiveJobs.Length)
        float now = Utility.GetCurrentGameTime()

        int i = 0
        int j = 0
        while i < ActiveJobs.Length
            if StorageUtil.GetFloatValue(self, "DFR_ResumeDelay_" + ActiveJobs[i]) < now
                potentialJobs[j] = ActiveJobs[i]
                j += 1
            else
                Log("OnStageComplete - excluding job due to delay = " + ActiveJobs[i])
            endIf

            i += 1
        endWhile

        Log("OnStageComplete - potentialJobs = " + potentialJobs)

        if j
            ;potentialJobs = Adversity.SortEventsByClosestToRef(potentialJobs, PlayerRef)
            Log("OnStageComplete - Resuming = " + potentialJobs[0])
            Adversity.ResumeEvent(potentialJobs[0])       
            return
        endIf
    endIf

    ; TODO: hand over control to player to roam until we find jobs again
endFunction