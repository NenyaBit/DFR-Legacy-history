Scriptname DFR_Skincare extends Quest conditional

QF__Gift_09000D62 property Flow auto
Actor property PlayerRef auto
SexLabFramework property SL auto
DFR_RelationshipManager property RelManager auto

Potion property RegularLotion auto
Potion property SpecialLotion auto

GlobalVariable property GameDaysPassed auto
float property LastAppliedTimer auto hidden conditional
float property LastGivenTimer auto hidden conditional

float property LotionApplyDuration = 24.0 auto hidden

bool property GaveSpecialLotion = false auto hidden conditional
bool property FakeRanOut = false auto hidden conditional
bool property WashedOff = false auto hidden conditional
bool property GaveDirect = false auto hidden conditional

; TODO: multi-NPC sources (stages 4-5)
; TODO: implement collection event - do this in DC to test inter-pack extension

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
    Log("GiveLotion - Start")
    if RelManager.GetTargetSeverity() < 3 && !GaveSpecialLotion && !abForceSpecial
        Log("GiveLotion - Regular")
        PlayerRef.AddItem(RegularLotion, Utility.RandomInt(1, 2))
    else
        Log("GiveLotion - Special")
        GaveSpecialLotion = true
        PlayerRef.AddItem(SpecialLotion, Utility.RandomInt(1, 2))
    endIf

    FakeRanOut = RelManager.GetTargetSeverity() >= 4 && Utility.RandomInt(0, 1)

    LastGivenTimer = GameDaysPassed.GetValue() + (LotionApplyDuration * 0.5 * 0.042)
    
    Log("GiveLotion - End - " + LastGivenTimer + " - " + FakeRanOut)
endFunction

function OnApplyLotion(Form akItem)
    if akItem != SpecialLotion && akItem != RegularLotion
        return
    endIf

    bool special = akItem == SpecialLotion

    Log("OnApplyLotion - " + special)

    ResetTimer()

    WashedOff = false

    if special
        Log("OnApplyLotion - special")
        SL.AddCum(PlayerRef)
    endIf
endFunction

event OnBis_BatheEvent(Form akTarget)
    Log("Detected Bathing")
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

function Log(string asMsg)
    DFR_Util.Log("Skincare - " + asMsg)
endFunction