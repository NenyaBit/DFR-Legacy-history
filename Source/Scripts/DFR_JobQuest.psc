Scriptname DFR_JobQuest extends Quest  

DFR_JobBase property JobEvent auto

function SetObjectiveTargets(Form[] akTargets)
    JobEvent.SetObjectiveTargets(akTargets)
endFunction

function ClearObjectiveTargets()
    JobEvent.ClearObjectiveTargets()
endFunction