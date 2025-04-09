;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname QF__DflowDealController_0A01C86D Extends Quest Hidden Conditional

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

DFR_Events property Events auto

function Prep()
    Events.Setup(Utility.CreateStringArray(1, SelectedRuleId), 0, true, Willpower.GetValue() < 6)
endFunction

function PersistBuyoutDecision()
    StorageUtil.SetfloatValue(none, "DFR_LastBuyoutAttemptAt", GameDaysPassed.GetValue())
endFunction

Function RecalculateDealCosts()

    DealDebtRelief    = _DflowDealBaseDebt.GetValue()
    DealBuyoutPrice   = _DflowDealBasePrice.GetValue()
    DealEarlyOutPrice = _DflowDealMulti.GetValue() * DealBuyoutPrice
   
EndFunction

float Function SetDealBuyout(float now, string dealName, GlobalVariable timer, GlobalVariable targetPrice)

    int stage = DFR_DealHelpers.GetNumRules(dealName)

    _DUtil.Info("DF - SetDealBuyout - " + dealName + " stage = " + stage)

    if stage == 0
        timer.SetValue(-1)
        targetPrice.SetValue(0.0)
        return 0.0
    endIf

    float timerValue = timer.GetValue()
    float stageScale = stage As float
    
    float price = DealBuyoutPrice * stageScale
    
    If timerValue > now ; Buyout is in the future
        price += (timerValue - now) * DealEarlyOutPrice
    EndIf

    price = Math.Ceiling(price)
    targetPrice.SetValue(price)
    
    Return price
    
EndFunction

Function UpdateIt()

    RecalculateDealCosts()
    float now = GameDaysPassed.GetValue()
    
    ExpensiveDebtCount = 0.0

    int i = 0
    while i < DealNames.Length
        SetDealBuyout(now, DealNames[i], DealTimers[i], DealPrices[i])
        UpdateCurrentInstanceGlobal(DealPrices[i])
        _DUtil.Info("DF - UpdateIt - " + DealNames[i] + " " + DealTimers[i].GetValue() + " " + DealPrices[i].GetValue())
        i += 1
    endWhile

    _DflowExpensiveDebts.SetValue(ExpensiveDebtCount)
EndFunction


; Called by all deals, including modular deals, when a deal is added OR removed.
; The parameter is always 1 for Add
; The parameter is always -1 for Remove
Function DealAdd(int a)
    _DUtil.Info("DF - DealAdd - " + a)

    Deals += a
    
    ; Reduce boredom and reset the debt penalty accumulator when deals added.
    If a > 0
        Tool.ReduceBoredom()
    EndIf
    
    ; Reduce fatigue when deals are removed
    If a < 0
        float fatigueValue = _DFFatigue.GetValue()
        float fatigueDelta = _DFFatigueRate.GetValue()
        float dealDays = _DflowDealBaseDays.GetValue()
        ; Add fatigue when deal gained.
        fatigueValue += fatigueDelta * (dealDays + 1.0) * (a As float)
        
        If fatigueValue < 0.0
            fatigueValue = 0.0
        EndIf
        
        _DFFatigue.SetValue(fatigueValue)
    EndIf
        
EndFunction


; Called to add or remove 'maxed out' deals.
Function DealMaxAdd(int a)
    DealsMax += a
EndFunction

Function Res()
    DealsMax = 0
    Deals = 0 
EndFunction

int Function SelectRandomActiveDeal()

    int numDeals = DFR_DealHelpers.GetNum()
    DFR_DealHelpers.InitDeals(DealNames)

    if numDeals > 0
        int dealIndex = Utility.Randomint(0, numDeals - 1)
        string dealName = DFR_DealHelpers.GetDealAt(dealIndex)
        return DFR_DealHelpers.GetDealIndex(dealName)
    endIf
    Return -1

EndFunction

GlobalVariable Function GetDealTimer(int dealNumber)
    return DealTimers[dealNumber]
EndFunction

Function AddRndDay()
    int dealNumber = SelectRandomActiveDeal()
    If dealNumber >= 0
        GlobalVariable timer = GetDealTimer(dealNumber)
        AddDayToTimer(timer)
        Debug.Notification("$DFDEALDAYINC")
    EndIf
EndFunction

Function AddDayToTimer(GlobalVariable timer)
    float current = timer.GetValue()
    timer.SetValue(current + 1.0)
EndFunction

Function ExtendRandomDeal()
    int dealNumber = SelectRandomActiveDeal()
    If dealNumber >= 0
        ExtendDeal(dealNumber)
    EndIf
EndFunction

Function ExtendDeal(int dealNumber) 
    If dealNumber >= 0
        GlobalVariable timer = GetDealTimer(dealNumber)
        ExtendDealTimer(timer)
    EndIf
EndFunction

Function ExtendDealTimer(GlobalVariable dealTimer)

    float baseDays = _DflowDealBaseDays.GetValue()
    
    float current = dealTimer.GetValue()
    If current < baseDays
        current = baseDays
    EndIf
    float newDays = current + baseDays
    
    dealTimer.SetValue(newDays)

EndFunction

Function SaveTimes()
    int i = 0
    while i < DealTimers.Length
        StorageUtil.SetfloatValue(none, "DFR_Deal_Timers_" + DealNames[i], DealTimers[i].GetValue())
        i += 1
    endWhile
EndFunction

Function LoadTimes()
    int i = 0
    while i < DealTimers.Length
        float val = StorageUtil.GetfloatValue(none, "DFR_Deal_Timers_" + DealNames[i], DealTimers[i].GetValue())
        DealTimers[i].SetValue(val)
        i += 1
    endWhile
EndFunction

Function ResetAllDeals()
    int i = 0
    while i < DealTimers.Length
        DealTimers[i].SetValue(0)
        DFR_DealHelpers.Remove(DealNames[i])
        i += 1
    endWhile

    string[] activeRules = Adversity.GetActiveEvents("deviousfollowers", "rule")

    i = 0
    while i < activeRules.length
        Adversity.StopEvent(activeRules[i])
        i += 1
    endWhile

    Deals = 0
    DealsMax = 0 ; Not the max deals but the number of maxed-out deals.
EndFunction


Function AddRandomDeal()

	string added = (UberController As _DFDealUberController).AddDeal()

	If added == "deviousfollowers/core/extend" && Deals > 0
        AddRndDay()
        AddRndDay()
        AddRndDay()
    EndIf

EndFunction

Function RemoveDeviceByIndex(int index)

    _DUtil.Notify("Remove Device Index " + index)

    Actor who = libs.playerref
    Keyword kw
    
    If 1 == index
        Debug.Notification("$DF_REMOVE_MSG_BLINDFOLD")
        kw = libs.zad_DeviousBlindfold
    ElseIf 2 == index
        Debug.Notification("$DF_REMOVE_MSG_BOOTS")
        kw = libs.zad_DeviousBoots
    ElseIf 3 == index
        Debug.Notification("$DF_REMOVE_MSG_GAG")
        kw = libs.zad_DeviousGag
    ElseIf 4 == index
        Debug.Notification("$DF_REMOVE_MSG_HEAVY")
        kw = libs.zad_DeviousHeavyBondage
    ElseIf 5 == index
        Debug.Notification("$DF_REMOVE_MSG_MITTENS")
        kw = libs.zad_DeviousBondageMittens
    ElseIf 6 == index
        Debug.Notification("$DF_REMOVE_MSG_COLLAR")
        kw = libs.zad_DeviousCollar
    ElseIf 7 == index
        Debug.Notification("$DF_REMOVE_MSG_GLOVES")
        kw = libs.zad_DeviousGloves
    EndIf
        
    If kw
        Armor deviceI = StorageUtil.GetFormValue(who, "zad_Equipped" + libs.LookupDeviceType(kw) + "_Inventory") As Armor
        
        If deviceI && !deviceI.HasKeyword(Libs.zad_QuestItem)
            libs.UnlockDevice(who, deviceI)
            who.Removeitem(deviceI, 1, True)
        EndIf
    EndIf
    
EndFunction

Function PickRandomDeal()
    Debug.Trace("DF - PickRandomDeal - start")

    NewDeal = (UberController As _DFDealUberController).GetPotentialDeal(DealBias)
    SelectedRuleId = DFR_DealHelpers.SplitId(NewDeal)[1]
    
    if NewDeal == "" || SelectedRuleId == ""
        Debug.Trace("DF - PickRandomDeal - failed to get valid new deal")
    endIf

    Debug.Trace("DF - PickRandomDeal - NewDeal = " + NewDeal + " - SelectedRuleId = " + SelectedRuleId)
EndFunction

Function PickAnyRandomDeal()
    Debug.Trace("DF - PickAnyRandomDeal")
    (UberController As _DFDealUberController).RejectedDeal = ""
    PickRandomDeal()
EndFunction

Function AcceptPendingDeal()

    Debug.Trace("DF - AcceptPendingDeal - NewDeal " + NewDeal)

    (UberController As _DFDealUberController).AddDealById(NewDeal)
    NewDeal = ""
    SelectedRuleId = ""
    
    ; Select the next deal ... well in advance.
    PickRandomDeal()

    Debug.Trace("DF - AcceptPendingDeal - end")

EndFunction

Function RejectPendingDeal()
    Debug.Trace("DF - RejectPendingDeal - NewDeal " + NewDeal)
    (UberController As _DFDealUberController).RejectDeal(NewDeal)
    
    ; Select the next deal ... well in advance.
    PickRandomDeal()
    
    Debug.Trace("DF - RejectPendingDeal - end")
EndFunction

Function AcceptRule(string asId)
    DFR_Util.Log("AcceptRule - " + asId + " - " + SelectedRuleId)
    if asId == SelectedRuleId
        AcceptPendingDeal()
    elseIf !Adversity.FilterEventsByValid(Utility.CreateStringArray(1, SelectedRuleId)).Length
        PickRandomDeal()
    endIf
EndFunction

Function RefuseRule(string asId)
    if asId == SelectedRuleId
        RejectPendingDeal()
    endIf
EndFunction

function ResetRule(string asId)
    if asId == SelectedRuleId
        PickRandomDeal()
    endIf
endFunction

Function Buyout(int aiIndex)
    string deal = DealNames[aiIndex]
    _DUtil.Info("DF - Buyout - START - " + deal)
    
    (UberController As _DFDealUberController).RemoveDealById(deal)

    if !Gold
        Gold = Game.GetFormFromFile(0xF, "Skyrim.esm") as MiscObject
    endIf

    PlayerRef.RemoveItem(Gold, DealPrices[aiIndex].GetValue() as int)

    _DUtil.Info("DF - Buyout - END - " + deal)
EndFunction

_LDC property LDC auto
GlobalVariable property _DflowDealBasePrice auto ; The buyout cost
GlobalVariable property _DflowDealBaseDebt auto ; The relief amount
GlobalVariable property _DflowDealMulti auto
GlobalVariable property _DflowDealBaseDays auto

string[] property DealNames auto
GlobalVariable[] property DealPrices auto
GlobalVariable[] property DealTimers auto

string[] SlaveryRules
int CurrSlaveryRuleIndex
bool property FinishedSlaveryRules auto hidden conditional
bool property InEnslavementSetup auto hidden conditional
float property RejectRuleChance auto hidden

GlobalVariable property GameDaysPassed auto
GlobalVariable property _DFCostScale auto
GlobalVariable property _DFFatigue auto
GlobalVariable property _DFFatigueRate auto
GlobalVariable property _DflowDebtPerDay auto
GlobalVariable property _DflowExpensiveDebts auto
GlobalVariable property _DFDeepDebtDifficulty auto

Quest property UberController auto
Quest property DealO  auto 
Quest property DealB  auto 
Quest property DealH  auto 
Quest property DealP  auto 
Quest property DealSQ auto 
Quest property DealM1 auto 
Quest property DealM2 auto 
Quest property DealM3 auto 
Quest property DealM4 auto 
Quest property DealM5 auto 
Message property msg  auto  
_DFTools property Tool auto

int property Deals = 0 auto  Conditional
int property DealsMax = 0 auto  Conditional ; Number of maxed out deals.

int property DealOMax  auto Conditional
bool property DealO1 auto	Conditional
bool property DealO2 auto	Conditional

int property DealBMax  auto Conditional
bool property DealB1 auto	Conditional
bool property DealB2 auto	Conditional

int property DealHMax  auto Conditional
bool property DealH1 auto	Conditional
bool property DealH2 auto	Conditional

int property DealPMax  auto Conditional
int property DealSQMax  auto Conditional

; The full ID of the new deal (e.g. each modular deal+rule combination is unique)
string property NewDeal auto Conditional
string property SelectedRuleId auto Conditional
; The de-duplicated ID of the new deal (e.g. modular deals have 1XX values matching the shared rule)
;int property DealOffering auto Conditional

Actor property PlayerRef auto
Armor property Item1 auto
Armor property Item1r auto
ZadLibs property libs auto

float property DealBias = 50.0 auto
float property DealDebtRelief auto
float property DealBuyoutPrice auto
float property DealEarlyOutPrice auto

float property ExpensiveDebtCount auto

MiscObject property Gold auto

GlobalVariable property Willpower auto