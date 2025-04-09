Scriptname DFR_Skincare extends Quest conditional

QF__Gift_09000D62 property Flow auto
Actor property PlayerRef auto
SexLabFramework property SL auto
DFR_RelationshipManager property RelManager auto

Potion property RegularLotion auto
Potion property SpecialLotion auto
FormList property LotionList auto

GlobalVariable property GameDaysPassed auto
float property LastAppliedTimer auto hidden conditional
float property LastGivenTimer auto hidden conditional

float property LotionApplyDuration = 24.0 auto hidden

bool property GaveSpecialLotion = false auto hidden conditional
bool property FakeRanOut = false auto hidden conditional
bool property WashedOff = false auto hidden conditional
bool property GaveDirect = false auto hidden conditional

; stage 1 = regular lotion
; stage 3 = random cumtainer
; stage 4 = fake ran out

; TODO: implement collection and multi-NPC events 

function Maintenance()
    if IsRunning()
        RegisterForModEvent("Bis_BatheEvent", "OnBis_BatheEvent")
    endIf
endFunction

function Setup()    
    GaveSpecialLotion = false
    WashedOff = false
    GiveLotion()
    RegisterForModEvent("Bis_BatheEvent", "OnBis_BatheEvent")
endFunction

function GiveLotion(bool abForceSpecial = false)
    DFR_Util.Log("Skincare Quest - Giving")
    if RelManager.GetTargetSeverity() < 3 && !GaveSpecialLotion && !abForceSpecial
        PlayerRef.AddItem(RegularLotion, Utility.RandomInt(1, 2))
    else
        GaveSpecialLotion = true
        PlayerRef.AddItem(SpecialLotion, Utility.RandomInt(1, 2))
    endIf

    FakeRanOut = RelManager.GetTargetSeverity() >= 4 && Utility.RandomInt(0, 1)

    LastGivenTimer = GameDaysPassed.GetValue() + (LotionApplyDuration * 0.5 * 0.042)
endFunction

function OnApplyLotion(Form akItem)
    if !LotionList.HasForm(akItem)
        DFR_Util.Log("OnApplyLotion - not in list")
        return
    endIf

    bool special = akItem == SpecialLotion

    DFR_Util.Log("OnApplyLotion - " + special)

    ResetTimer()

    WashedOff = false

    if special
        DFR_Util.Log("Adding cum")
        SL.AddCum(PlayerRef)
    endIf
endFunction

event OnBis_BatheEvent(Form akTarget)
    DFR_Util.Log("Skincare - Detected Bathing")
    WashedOff = true
    LastAppliedTimer = 0.0
endEvent

function ResetTimer(bool abPunish = false)
    if abPunish
        if RelManager.IsSlave()
            Adv_Collar.Get().Zap()
        endIf

        Flow.PunDebt()
    endIf

    LastAppliedTimer = GameDaysPassed.GetValue() + (LotionApplyDuration / 24.0)
endFunction

function GiveDirect()
    GaveDirect = true
    SL.QuickStart(PlayerRef, Flow.Alias__DMaster.GetRef() as Actor)
    ResetTimer()
endFunction