Scriptname DFR_Jobs extends Quest conditional

Actor property PlayerRef auto

string[] property ActiveJobs auto hidden

float property JobTimer auto hidden conditional
int property NumJobs auto hidden conditional
bool property FoundJobs auto hidden conditional

float property LastXPos auto hidden
float property LastYPos auto hidden
float property LastZPos auto hidden

; user configurable
int property MaxJobs auto hidden
int property MinJobs auto hidden


function Maintenance()
    RegisterForSingleUpdate(10)
endFunction

event OnUpdate()
    if !PlayerRef.GetParentCell().IsInterior()
        LastXPos = PyramidUtils.GetAbsPosX(PlayerRef)
        LastYPos = PyramidUtils.GetAbsPosY(PlayerRef)
        LastZPos = PyramidUtils.GetAbsPosZ(PlayerRef)
    endIf

    RegisterForSingleUpdate(10)
endEvent

function Select()
    if NumJobs > MaxJobs
        FoundJobs = false
        return
    endIf

    ; if NumBacklog < 1 AND JobTimer < GameDaysPassed
    ; pick job geographically 

    string[] jobs = Adversity.GetContextEvents("deviousfollowers")
    jobs = Adversity.FilterEventsByTags(jobs, Utility.CreateStringArray(1, "subtype:job"))
    jobs = Adversity.FilterEventsByLocation(jobs)
    jobs = Adversity.SortEventsByClosestToPos(jobs, LastXPos, LastYPos, LastZPos)

    
endFunction


