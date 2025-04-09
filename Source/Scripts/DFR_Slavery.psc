Scriptname DFR_Slavery extends Quest conditional

_LDC property LDC auto
ReferenceAlias property MasterAlias auto
DFR_RelationshipManager property RelManager auto
Scene property EnslavementIntro auto

int property EnslavementReason = -1 auto hidden conditional

function StartSlaverySetup(Actor akMaster, int aiReason)
    RelManager.SetStageSlavery(akMaster)
    EnslavementReason = aiReason

    EnslavementIntro.Start()

    SetStage(10)
    Game.GetPlayer().SendModEvent("PlayerRefEnslaved")
    LDC.EquipCollar()
endFunction

function AcceptRule(string asId)
    
endFunction

function RefuseRule(string asId)
    
endFunction

function ResetRule(string asId)
    
endFunction