Scriptname DFR_BQ01 extends Quest conditional

Actor property PlayerRef auto

DFR_Job_BanditBounty property JobEvent auto
DFR_Collar property Collar auto
DFR_RelationshipManager property RelManager auto

ReferenceAlias property MasterAlias auto
ReferenceAlias property QuestGiverAlias auto

ReferenceAlias property JarlAlias auto
ReferenceAlias property StewardAlias auto
ReferenceAlias property InnkeeperAlias auto
ReferenceAlias property BountyTargetAlias auto
LocationAlias property BountyLocationAlias auto

Scene property IntroScene auto
Scene property ResumeScene auto

bool property PrepDelayActive = false auto hidden conditional

int STAGE_SETUP = 0
int STAGE_STARTED = 10
int STAGE_COMPLETE_STEWARD = 100
int STAGE_COMPLETE_JARL = 100
int STAGE_DONE = 200

bool property Active = false auto hidden conditional
bool property Reached = false auto hidden conditional
int property ShowedScene = -1 auto hidden conditional

bool property RanAway = false auto hidden conditional

function OnSetup()
    Log("OnSetup")
    Form[] targets = new Form[2]

    targets[0] = InnkeeperAlias.GetRef()
    targets[1] = StewardAlias.GetRef()

    ShowedScene = -1

    JobEvent.SetObjectiveTargets(targets)
endFunction

function OnStart()
    Log("OnStart")
    JobEvent.SetObjectiveTargets(Utility.CreateFormArray(1, BountyTargetAlias.GetRef()))
    Collar.ResetAll()

    PrepDelayActive = false
    RanAway = false
endFunction

function OnComplete()
    Log("OnComplete")
    Form[] targets = new Form[2]

    targets[0] = JarlAlias.GetRef()
    targets[1] = StewardAlias.GetRef()

    JobEvent.SetObjectiveTargets(targets)
    Collar.ResetAll()
endFunction

function OnStop()
    Log("OnStop")
    Active = false
    JobEvent.Complete()
    Collar.ResetAll()
    Reset()
endFunction

function Log(string asMsg)
    DFR_Util.Log("DFR_BQ01 - " + asMsg)
endFunction

function Pause()
    Active = false
    Collar.ResetAll()
endFunction

function Resume()
    Active = true

    int stage = GetStage()

    Log("Resume - stage = " + stage)

    if ShowedScene != stage && (stage == STAGE_STARTED || stage == STAGE_COMPLETE_STEWARD || stage == STAGE_COMPLETE_JARL)
        Log("Resume - starting resume scene")

        while PlayerRef.IsInCombat()
            Utility.Wait(10.0)
        endWhile

        DFR_Speech.Get().WaitForTimer()
        ResumeScene.Start()
        ShowedScene = stage
    endIf
endFunction

function OnLocationChange(Location akLocation)
    if !Active
        return
    endIf

    int stage = GetStage()
    if GetStage() == STAGE_STARTED
        Location bountyLoc = BountyLocationAlias.GetLocation()

        if bountyLoc.IsSameLocation(akLocation)
            Log("OnLocationChange - reached bandit camp - clearing target and setting location")
            Reached = true
            RanAway = false
            Collar.RestrictLocation(bountyLoc)
        endIf
    elseIf stage == STAGE_COMPLETE_STEWARD || stage == STAGE_COMPLETE_JARL
        Location bountyLoc = BountyLocationAlias.GetLocation()

        if !bountyLoc.IsSameLocation(akLocation) && PrepDelayActive
            BeginEscort()
        endIf
    endIf
endFunction

function BeginEscort()
    PrepDelayActive = false
    UnregisterForUpdateGameTime()

    int stage = GetStage()

    Log("BeginEscort - stage = " + stage)

    if stage == STAGE_STARTED
        Log("BeginEscort - setting target to bandit camp")
        Reached = PlayerRef.GetCurrentLocation() == BountyLocationAlias.GetLocation()
        if !Reached
            Collar.SetTargetRef(BountyTargetAlias.GetRef())
        endIf
        RanAway = false
    elseIf stage == STAGE_COMPLETE_STEWARD
        Collar.SetTargetRef(StewardAlias.GetRef())
    elseIf stage == STAGE_COMPLETE_JARL
        Collar.SetTargetRef(JarlAlias.GetRef())
    endIf
endFunction

function PrepDelay()
    PrepDelayActive = true
    RegisterForSingleUpdateGameTime(4 * 0.42)
endFunction

function BeginIntroScene(Actor akSpeaker)
    QuestGiverAlias.ForceRefTo(akSpeaker)
    IntroScene.Start()
endFunction

function DirectStartEvent()
    DFR_Util.Log("DirectStartEvent - " + JobEvent)
    JobEvent.Start(DFR_API.GetFollower())
endFunction

function Delay()
    RanAway = false
    DFR_Jobs.Get().Delay(JobEvent.GetEventId())
endFunction