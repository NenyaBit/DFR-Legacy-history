Scriptname DFR_DefeatHandler extends Quest conditional

Actor property PlayerRef auto
ReferenceAlias property MasterAlias auto
GlobalVariable property Lives auto
QF__Gift_09000D62 property Q auto
_DflowMCM property MCM auto
_DFGoldConQScript property GoldCon auto

bool property RescueValid = false auto hidden
bool property BothDowned = false auto hidden conditional
bool property WasDefeated = false auto hidden conditional
bool property FollowerSavedPlayer auto hidden conditional

; TODO: if a slave goes down, the master decides to relegate them to town and favour decreases
; 

function Maintenance()
    DFR_Util.Log("DFR_DefeatHandler - Maintenance - Acheron = " + Game.IsPluginInstalled("Acheron.esm"))
    if Game.IsPluginInstalled("Acheron.esm")
        Acheron.RegisterForActorDefeated(self)
        Acheron.RegisterForActorRescued(self)
        RegisterForModEvent("DF_StartNewAgreement", "OnNewAgreement")
    endIf

    if Game.IsPluginInstalled("Practical Defeat.esp")
        PO3_Events_Form.RegisterForQuest(self, Quest.GetQuest("PD_DefeatHandler"))
    endIf
endFunction

event OnQuestStart(Quest akQuest)
    if akQuest == Quest.GetQuest("PD_DefeatHandler")
        WasDefeated = true
    endIf
endEvent

event OnNewAgreement(Form akMaster)
    RescueValid = true
    FollowerSavedPlayer = false
endEvent

function ResetTaunts()
    BothDowned = false
    WasDefeated = false
endFunction

event OnActorDefeated(Actor akVictim)
    Actor Master = MasterAlias.GetActorRef()

    if akVictim != Master && akVictim != PlayerRef
        return
    endIf

    if Acheron.IsDefeated(PlayerRef) && Acheron.IsDefeated(Master)
        DFR_Util.Log("DFR_DefeatHandler - both are down - invalidating rescue")
        BothDowned = true
        RescueValid = false
    endIf

    if akVictim == Master
        DFR_Util.Log("DFR_DefeatHandler - Follower went down - reducing lives")
        if (Q.Getstage() < 100 && Q.Getstage() >= 10)
            GoldCon.FollowerKnockeddown()
            if Lives.GetValue() as int > 0
                int a = (Lives.getvalue() as int) - 1
                Lives.SetValue(a)  
            else
                q.PunDebt()
                int temp = Utility.RandomInt(1,10)
                if temp >=4
                    MCM.noti("NoL")
                endif
             endif
        endif
    elseIf akVictim == PlayerRef
        DFR_Util.Log("DFR_DefeatHandler - Player went down")
    endIf
endEvent

event OnActorRescued(Actor akVictim)
    Actor Master = MasterAlias.GetActorRef()

    if akVictim != Master && akVictim != PlayerRef
        return
    endIf

    DFR_Util.Log("DFR_DefeatHandler - defeated = " + akVictim)

    if akVictim == PlayerRef
        if RescueValid && Master && !Acheron.IsDefeated(Master)
            FollowerSavedPlayer = true
            DFR_Util.Log("DFR_DefeatHandler - Follower kept enemies at bay while player got up")
        else
            DFR_Util.Log("DFR_DefeatHandler - Player got up - doing nothing")
        endIf
    endIf

    if !Acheron.IsDefeated(PlayerRef) && !Acheron.IsDefeated(Master)
        DFR_Util.Log("DFR_DefeatHandler - both are up - revalidating rescue")
        RescueValid = true
    endIf
endEvent

function RescueDebt()
    Debug.Notification("Your follower added some debt for rescuing you")
    FollowerSavedPlayer = false
    Q.AddDebt(200)
endFunction