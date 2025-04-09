;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname QF__DflowDealController_0A01C86D Extends Quest Hidden Conditional

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

; _DflowDealMulti
; Premature deal removal cost multiplier as a percentage. Scales up cost of deal removal before it's standard duration has elapsed.
; Set to 0 to disable.
; CostIncrease = This x DaysAheadOfSchedule x DebtCost / 100
; Ranges from 0 to 2000 => 0.0 to +20.0, 0.0 does nothing

bool property CanReject auto hidden conditional
bool property CanBuyout auto hidden conditional
bool property AskedBuyoutRecently auto hidden conditional

function Prep()
    int favour = DFR_RelationshipManager.Get().Favour
    
    int chance
    if favour > 50
        chance = 50
    elseIf favour > 0
        chance = 25
    else
        chance = 10
    endif

    CanReject = Utility.RandomInt(0, 100) < chance
    AskedBuyoutRecently = Adv_Util.BeforeTimeStamp(none, "DFR_LastBuyoutAttemptAt", Utility.RandomFloat(1, 3))
    CanBuyout = !AskedBuyoutRecently && Utility.RandomFloat(0, 1.0) < chance

    if CanBuyout
        StorageUtil.UnsetFloatValue(none, "DFR_LastBuyoutAttemptAt")
    endIf
    
    DFR_Util.Log("DealController - CanReject = " + CanReject + " CanBuyout = " + CanBuyout)
endFunction

function PersistBuyoutDecision()
    StorageUtil.SetFloatValue(none, "DFR_LastBuyoutAttemptAt", GameDaysPassed.GetValue())
endFunction

Function RecalculateDealCosts()

    DealDebtRelief    = _DflowDealBaseDebt.GetValue()
    DealBuyoutPrice   = _DflowDealBasePrice.GetValue()
    DealEarlyOutPrice = _DflowDealMulti.GetValue() * DealBuyoutPrice
   
EndFunction

Float Function SetDealBuyout(Float now, string dealName, GlobalVariable timer, GlobalVariable targetPrice)

    Int stage = DFR_DealHelpers.GetNumRules(dealName)

    _DUtil.Info("DF - SetDealBuyout - " + dealName + " stage = " + stage)

    if stage == 0
        timer.SetValue(-1)
        targetPrice.SetValue(0.0)
        return 0.0
    endIf

    Float timerValue = timer.GetValue()
    Float stageScale = stage As Float
    
    Float price = DealBuyoutPrice * stageScale
    
    If timerValue > now ; Buyout is in the future
        price += (timerValue - now) * DealEarlyOutPrice
    EndIf

    ; Add expensive debt extra after early buyout cost. It's not part of the early buyout option.
    ; _MDDeal modular = dealQuest As _MDDeal
    ; If modular
    ;     Int count = modular.ExpensiveCount
    ;     If count > 0
    ;         ExpensiveDebtCount += (count as Float)

    ;         Float deepDebtScale = 1.0

    ;         If 2 == count
    ;             deepDebtScale = 3.0
    ;         Else
    ;             deepDebtScale = 7.0
    ;         EndIf
            
    ;         Float dailyDebt = _DflowDebtPerDay.GetValue()
    ;         Float deepDebtDifficulty = _DFDeepDebtDifficulty.GetValue()
            
    ;         price += deepDebtScale * dailyDebt * deepDebtDifficulty
    ;     EndIf
    ; EndIf
    
    price = Math.Ceiling(price)
    targetPrice.SetValue(price)
    
    Return price
    
EndFunction

Function UpdateIt()

    RecalculateDealCosts()
    Float now = GameDaysPassed.GetValue()
    
    ExpensiveDebtCount = 0.0

    int i = 0
    while i < DealNames.Length
        SetDealBuyout(now, DealNames[i], DealTimers[i], DealPrices[i])
        UpdateCurrentInstanceGlobal(DealPrices[i])
        _DUtil.Info("DF - UpdateIt - " + DealNames[i] + " " + DealTimers[i].GetValue() + " " + DealPrices[i].GetValue())
        i += 1
    endWhile

    ; SetDealBuyout(now, DealB, _DflowDealBPTimer, _DflowDealBP)
    ; SetDealBuyout(now, DealO, _DflowDealOPTimer, _DflowDealOP)
    ; SetDealBuyout(now, DealH, _DflowDealHPTimer, _DflowDealHP)
    ; SetDealBuyout(now, DealP, _DflowDealPPTimer, _DflowDealPP)
    ; SetDealBuyout(now, DealSQ, _DflowDealSPTimer, _DflowDealSP)
    ; SetDealBuyout(now, DealM1, _DflowDealM1PTimer, _DflowDealM1P)
    ; SetDealBuyout(now, DealM2, _DflowDealM2PTimer, _DflowDealM2P)
    ; SetDealBuyout(now, DealM3, _DflowDealM3PTimer, _DflowDealM3P)
    ; SetDealBuyout(now, DealM4, _DflowDealM4PTimer, _DflowDealM4P)
    ; SetDealBuyout(now, DealM5, _DflowDealM5PTimer, _DflowDealM5P)

    ; UpdateCurrentInstanceGlobal(_DflowDealBP)
    ; UpdateCurrentInstanceGlobal(_DflowDealHP)
    ; UpdateCurrentInstanceGlobal(_DflowDealOP)
    ; UpdateCurrentInstanceGlobal(_DflowDealPP)
    ; UpdateCurrentInstanceGlobal(_DflowDealSP)
    ; UpdateCurrentInstanceGlobal(_DflowDealM1P)
    ; UpdateCurrentInstanceGlobal(_DflowDealM2P)
    ; UpdateCurrentInstanceGlobal(_DflowDealM3P)
    ; UpdateCurrentInstanceGlobal(_DflowDealM4P)
    ; UpdateCurrentInstanceGlobal(_DflowDealM5P)

    _DflowExpensiveDebts.SetValue(ExpensiveDebtCount)
EndFunction


; Called by all deals, including modular deals, when a deal is added OR removed.
; The parameter is always 1 for Add
; The parameter is always -1 for Remove
Function DealAdd(Int a)
    _DUtil.Info("DF - DealAdd - " + a)

    Deals += a
    
    ; Reduce boredom and reset the debt penalty accumulator when deals added.
    If a > 0
        Tool.ReduceBoredom()
    EndIf
    
    ; Reduce fatigue when deals are removed
    If a < 0
        Float fatigueValue = _DFFatigue.GetValue()
        Float fatigueDelta = _DFFatigueRate.GetValue()
        Float dealDays = _DflowDealBaseDays.GetValue()
        ; Add fatigue when deal gained.
        fatigueValue += fatigueDelta * (dealDays + 1.0) * (a As Float)
        
        If fatigueValue < 0.0
            fatigueValue = 0.0
        EndIf
        
        _DFFatigue.SetValue(fatigueValue)
    EndIf
        
EndFunction


; Called to add or remove 'maxed out' deals.
Function DealMaxAdd(Int a)
    DealsMax += a
EndFunction

Function Res()
    DealsMax = 0
    Deals = 0 
EndFunction

Int Function SelectRandomActiveDeal()

    int numDeals = DFR_DealHelpers.GetNum()
    DFR_DealHelpers.InitDeals(DealNames)

    if numDeals > 0
        int dealIndex = Utility.RandomInt(0, numDeals - 1)
        string dealName = DFR_DealHelpers.GetDealAt(dealIndex)
        return DFR_DealHelpers.GetDealIndex(dealName)
    endIf

    ; Int[] possibleDeals = New Int[10]
    ; Int possibleCount = 0
    
    ; If DealB.GetStage() >= 1
    ;     possibleDeals[0] = 0
    ;     possibleCount += 1
    ; EndIf
    ; If DealH.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 1
    ;     possibleCount += 1
    ; EndIf
    ; If DealO.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 2
    ;     possibleCount += 1
    ; EndIf
    ; If DealP.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 3
    ;     possibleCount += 1
    ; EndIf
    ; If DealSQ.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 4
    ;     possibleCount += 1
    ; EndIf
    ; If DealM1.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 5
    ;     possibleCount += 1
    ; EndIf
    ; If DealM2.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 6
    ;     possibleCount += 1
    ; EndIf
    ; If DealM3.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 7
    ;     possibleCount += 1
    ; EndIf
    ; If DealM4.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 8
    ;     possibleCount += 1
    ; EndIf
    ; If DealM5.GetStage() >= 1
    ;     possibleDeals[possibleCount] = 9
    ;     possibleCount += 1
    ; EndIf
    
    ; If possibleCount > 0
    ;     Int selected = Utility.RandomInt(0, possibleCount - 1)
    ;     Int selectedDeal = possibleDeals[selected]
    ;     Return selectedDeal
    ; EndIf

    ; There were no active deals.
    Return -1

EndFunction

GlobalVariable Function GetDealTimer(Int dealNumber)

    return DealTimers[dealNumber]

    ; If 0 == dealNumber ; B
    ;     Return _DflowDealBPTimer
    ; ElseIf 1 == dealNumber ; H
    ;     Return _DflowDealHPTimer
    ; ElseIf 2 == dealNumber ; O
    ;     Return _DflowDealOPTimer
    ; ElseIf 3 == dealNumber ; P
    ;     Return _DflowDealPPTimer
    ; ElseIf 4 == dealNumber ; S
    ;     Return _DflowDealSPTimer
    ; ElseIf 5 == dealNumber ; M1
    ;     Return _DflowDealM1PTimer
    ; ElseIf 6 == dealNumber ; M2
    ;     Return _DflowDealM2PTimer
    ; ElseIf 7 == dealNumber ; M3
    ;     Return _DflowDealM3PTimer
    ; ElseIf 8 == dealNumber ; M4
    ;     Return _DflowDealM4PTimer
    ; Else ; If 9 == dealNumber ; M5
    ;     Return _DflowDealM5PTimer
    ; EndIf
    
EndFunction

Function AddRndDay()
    Int dealNumber = SelectRandomActiveDeal()
    If dealNumber >= 0
        GlobalVariable timer = GetDealTimer(dealNumber)
        AddDayToTimer(timer)
        Debug.Notification("$DFDEALDAYINC")
    EndIf
EndFunction

Function AddDayToTimer(GlobalVariable timer)
    Float current = timer.GetValue()
    timer.SetValue(current + 1.0)
EndFunction

Function ExtendRandomDeal()
    Int dealNumber = SelectRandomActiveDeal()
    If dealNumber >= 0
        ExtendDeal(dealNumber)
    EndIf
EndFunction

; Turns a deal into an extended deal
Function ExtendDeal(Int dealNumber) ; B H O P S M1 M2 M3 M4 M5
    If dealNumber >= 0
        GlobalVariable timer = GetDealTimer(dealNumber)
        ExtendDealTimer(timer)
    EndIf
EndFunction

Function ExtendDealTimer(GlobalVariable dealTimer)

    Float baseDays = _DflowDealBaseDays.GetValue()
    
    Float current = dealTimer.GetValue()
    If current < baseDays
        current = baseDays
    EndIf
    Float newDays = current + baseDays
    
    dealTimer.SetValue(newDays)

EndFunction

Function SaveTimes()

    int i = 0
    while i < DealTimers.Length
        StorageUtil.SetFloatValue(none, "DFR_Deal_Timers_" + DealNames[i], DealTimers[i].GetValue())
        i += 1
    endWhile

    ; SPTimer = _DflowDealSPTimer.GetValue()
    ; PPTimer = _DflowDealPPTimer.GetValue()
    ; OPTimer = _DflowDealOPTimer.GetValue()
    ; HPTimer = _DflowDealHPTimer.GetValue()
    ; BPTimer = _DflowDealBPTimer.GetValue()
    ; M1Timer = _DflowDealM1PTimer.GetValue()
    ; M2Timer = _DflowDealM2PTimer.GetValue()
    ; M3Timer = _DflowDealM3PTimer.GetValue()
    ; M4Timer = _DflowDealM4PTimer.GetValue()
    ; M5Timer = _DflowDealM5PTimer.GetValue()
EndFunction

Function LoadTimes()

    int i = 0
    while i < DealTimers.Length
        float val = StorageUtil.GetFloatValue(none, "DFR_Deal_Timers_" + DealNames[i], DealTimers[i].GetValue())
        DealTimers[i].SetValue(val)
        i += 1
    endWhile

    ; _DflowDealSPTimer.SetValue(SPTimer)
    ; _DflowDealPPTimer.SetValue(PPTimer)
    ; _DflowDealOPTimer.SetValue(OPTimer)
    ; _DflowDealHPTimer.SetValue(HPTimer)
    ; _DflowDealBPTimer.SetValue(BPTimer)
    ; _DflowDealM1PTimer.SetValue(M1Timer)
    ; _DflowDealM2PTimer.SetValue(M2Timer)
    ; _DflowDealM3PTimer.SetValue(M3Timer)
    ; _DflowDealM4PTimer.SetValue(M4Timer)
    ; _DflowDealM5PTimer.SetValue(M5Timer)
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

    ; _DflowDealSPTimer.SetValue(0.0)
    ; _DflowDealPPTimer.SetValue(0.0)
    ; _DflowDealOPTimer.SetValue(0.0)
    ; _DflowDealHPTimer.SetValue(0.0)
    ; _DflowDealBPTimer.SetValue(0.0)
    ; _DflowDealM1PTimer.SetValue(0.0)
    ; _DflowDealM2PTimer.SetValue(0.0)
    ; _DflowDealM3PTimer.SetValue(0.0)
    ; _DflowDealM4PTimer.SetValue(0.0)
    ; _DflowDealM5PTimer.SetValue(0.0)
    ; If DealO.GetStage() == 4
    ;     libs.RemoveDevice(libs.PlayerRef, item1 , item1R, libs.zad_DeviousBelt, skipevents = false, skipmutex = true)
    ; EndIf
    ; DealB.Reset()
    ; DealO.Reset()
    ; DealP.Reset()
    ; DealSQ.Reset()
    ; DealH.Reset() 
    ; (DealM1 as _MDDeal).End()
    ; (DealM2 as _MDDeal).End()
    ; (DealM3 as _MDDeal).End()
    ; (DealM4 as _MDDeal).End()
    ; (DealM5 as _MDDeal).End()

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

Function RemoveDeviceByIndex(Int index)

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
    Adversity.ClearSelectedEvents("deviousfollowers", "rule")

    NewDeal = (UberController As _DFDealUberController).GetPotentialDeal(DealBias)
    string rule = DFR_DealHelpers.SplitId(NewDeal)[1]
    
    if NewDeal != "" && rule != ""
        Adversity.SelectEvent(rule)
    else
        Debug.Trace("DF - PickRandomDeal - failed to get valid new deal")
    endIf

    Debug.Trace("DF - PickRandomDeal - NewDeal = " + NewDeal)
EndFunction

Function PickAnyRandomDeal()
    Debug.Trace("DF - PickAnyRandomDeal")
    (UberController As _DFDealUberController).RejectedDeal = -1
    PickRandomDeal()
EndFunction

Function AcceptPendingDeal()

    Debug.Trace("DF - AcceptPendingDeal - NewDeal " + NewDeal)

    (UberController As _DFDealUberController).AddDealById(NewDeal)
    NewDeal = ""
    
    ; Select the next deal ... well in advance.
    PickRandomDeal()

    Debug.Trace("DF - AcceptPendingDeal - end")

EndFunction

Function RejectPendingDeal()

    Debug.Trace("DF - RejectPendingDeal - NewDeal " + NewDeal)
    (UberController As _DFDealUberController).RejectDeal(NewDeal)
    
    DFR_RelationshipManager RelManager = DFR_RelationshipManager.Get()
    if RelManager.IsSlave()
        RelManager.DecFavour()
    endIf
    
    ; Select the next deal ... well in advance.
    PickRandomDeal()
    
    Debug.Trace("DF - RejectPendingDeal - end")

EndFunction

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

function SetupSlaveryDeals()
    string path = Adversity.GetConfigPath("deviousfollowers")

    SlaveryRules = JsonUtil.StringListToArray(path, "slavery-rules")
    string[] excludeRules = JsonUtil.StringListToArray(path, "exclude-slavery-rules")

    int i = 0
    while i < SlaveryRules.Length
        SlaveryRules[i] = "deviousfollowers/" + SlaveryRules[i]
        StorageUtil.SetIntValue(self, "DFR_ChosenSlave_" + SlaveryRules[i], 1)
        i += 1
    endWhile

    i = 0
    while i < excludeRules.length
        excludeRules[i] = "deviousfollowers/" + excludeRules[i]
        StorageUtil.SetIntValue(self, "DFR_SlaveExclude_" + SlaveryRules[i], 1)
        i += 1
    endWhile

    int expectedRules = JsonUtil.GetIntValue(path, "num-slavery-rules")
    int leftOver = expectedRules - SlaveryRules.Length
   
    if leftOver
        i = 0
        while i < leftOver
            string[] candidates = (UberController As _DFDealUberController).GetCandidates()

            int j = 0
            int k = 0
            while j < candidates.length
                if !StorageUtil.GetIntValue(self, "DFR_ChosenSlave_" + candidates[j])
                    candidates[k] = candidates[j]
                    k += 1
                endIf

                j += 1
            endWhile

            candidates = PapyrusUtil.ResizeStringArray(candidates, k)
            candidates = Adversity.FilterEventsBySeverity(candidates, 3)
           
            string ruleId = candidates[Utility.RandomInt(0, candidates.length - 1)]

            Adversity.ReserveEvent(ruleId)
            SlaveryRules = PapyrusUtil.PushString(SlaveryRules, ruleId)
            i += 1
        endWhile
    endIf
 
    i = 0
    while i < SlaveryRules.length
        string ruleId = SlaveryRules[i]
        StorageUtil.UnsetIntValue(self, "DFR_SlaveryRuleRejected_" + ruleId)
        StorageUtil.UnsetIntValue(self, "DFR_SlaveExclude_" + ruleId)
        i += 1
    endWhile

    i = 0
    while i < excludeRules.length
        StorageUtil.UnsetIntValue(self, "DFR_SlaveExclude_" + excludeRules[i])
        i += 1
    endWhile


    CurrSlaveryRuleIndex = -1
    DFR_DealHelpers.Remove("Slavery")
    DFR_DealHelpers.Create("Slavery")
    InEnslavementSetup = true
    Adversity.ClearSelectedEvents("deviousfollowers", "rule")
endFunction

function NextSlaveryRule()
    CurrSlaveryRuleIndex += 1
    DFR_Util.Log("NextSlaveryRule - Slavery Rules = " + SlaveryRules)
   
    if CurrSlaveryRuleIndex < SlaveryRules.Length
        string ruleId = SlaveryRules[CurrSlaveryRuleIndex]
        Adversity.SelectEvent(ruleId)
        DFR_Util.Log("NextSlaveryRule - " + ruleId)
    endIf

    FinishedSlaveryRules = (CurrSlaveryRuleIndex == SlaveryRules.Length - 1)
endFunction

function AcceptSlaveryRule(bool abAccept = true)
    string ruleId = SlaveryRules[CurrSlaveryRuleIndex]

    Adversity.StartEvent(ruleId)
    DFR_DealHelpers.AddRule("Slavery", ruleId)
    Debug.Notification(Adversity.GetEventDesc(ruleId))

    if !abAccept
        DFR_RelationshipManager.Get().DecFavour()
    endIf

    DFR_Util.Log("AcceptSlaveryRule - " + ruleId + " - " + abAccept)

    NextSlaveryRule()
endFunction

function RejectSlaveryRule()
    string ruleId = SlaveryRules[CurrSlaveryRuleIndex]

    Adversity.UnselectEvent(ruleId)
    DFR_RelationshipManager.Get().DecFavour()
    StorageUtil.SetIntValue(self, "DFR_SlaveryRuleRejected_" + ruleId, 1)
    
    DFR_Util.Log("RejectSlaveryRule - " + ruleId)

    NextSlaveryRule()
endFunction

function CheckSlaveryDeals()
    int i = CurrSlaveryRuleIndex
    while i < SlaveryRules.length
        string ruleId = SlaveryRules[i]
        
        if !Adversity.IsEventActive(ruleId) && !StorageUtil.GetIntValue(self, "DFR_SlaveryRuleRejected_" + ruleId)
            Adversity.StartEvent(ruleId)
            DFR_DealHelpers.AddRule("Slavery", ruleId)
            Debug.Notification(Adversity.GetEventDesc(ruleId))
        endIf

        StorageUtil.UnsetIntValue(self, "DFR_SlaveryRuleRejected_" + ruleId)

        i += 1
    endWhile
    Tool.ReduceResist(DFR_DealHelpers.GetNumRules("Slavery"))
    FinishedSlaveryRules = true
    InEnslavementSetup = false
    PickRandomDeal()
endFunction

function RemoveSlaveDeal()
    int numRules = DFR_DealHelpers.GetNumRules("Slavery")
    
    int i = 0
    while i < numRules
        Adversity.StopEvent(DFR_DealHelpers.GetRuleAt("Slavery", i))
        i += 1
    endWhile

    DFR_DealHelpers.Remove("Slavery")
endFunction

_LDC property LDC auto
GlobalVariable Property _DflowDealBasePrice Auto ; The buyout cost
GlobalVariable Property _DflowDealBaseDebt Auto ; The relief amount
GlobalVariable Property _DflowDealMulti Auto
GlobalVariable Property _DflowDealBaseDays Auto

String[] Property DealNames Auto
GlobalVariable[] Property DealPrices Auto
GlobalVariable[] Property DealTimers Auto

string[] SlaveryRules
int CurrSlaveryRuleIndex
bool property FinishedSlaveryRules auto hidden conditional
bool property InEnslavementSetup auto hidden conditional
float property RejectRuleChance auto hidden

GlobalVariable Property GameDaysPassed Auto
GlobalVariable Property _DFCostScale Auto
GlobalVariable Property _DFFatigue Auto
GlobalVariable Property _DFFatigueRate Auto
GlobalVariable Property _DflowDebtPerDay Auto
GlobalVariable Property _DflowExpensiveDebts Auto
GlobalVariable Property _DFDeepDebtDifficulty Auto

Quest Property UberController Auto
Quest Property DealO  Auto 
Quest Property DealB  Auto 
Quest Property DealH  Auto 
Quest Property DealP  Auto 
Quest Property DealSQ Auto 
Quest Property DealM1 Auto 
Quest Property DealM2 Auto 
Quest Property DealM3 Auto 
Quest Property DealM4 Auto 
Quest Property DealM5 Auto 
Message Property msg  Auto  
_DFTools Property Tool Auto

Int Property Deals = 0 Auto  Conditional
Int Property DealsMax = 0 Auto  Conditional ; Number of maxed out deals.

Int Property DealOMax  Auto Conditional
Bool Property DealO1 Auto	Conditional
Bool Property DealO2 Auto	Conditional

Int Property DealBMax  Auto Conditional
Bool Property DealB1 Auto	Conditional
Bool Property DealB2 Auto	Conditional

Int Property DealHMax  Auto Conditional
Bool Property DealH1 Auto	Conditional
Bool Property DealH2 Auto	Conditional

Int Property DealPMax  Auto Conditional
Int Property DealSQMax  Auto Conditional

; The full ID of the new deal (e.g. each modular deal+rule combination is unique)
String Property NewDeal Auto Conditional
; The de-duplicated ID of the new deal (e.g. modular deals have 1XX values matching the shared rule)
;Int Property DealOffering Auto Conditional

Actor Property PlayerRef Auto
Armor Property Item1 Auto
Armor Property Item1r Auto
ZadLibs Property libs Auto

Float Property DealBias = 50.0 Auto
Float Property DealDebtRelief Auto
Float Property DealBuyoutPrice Auto
Float Property DealEarlyOutPrice Auto

Float Property ExpensiveDebtCount Auto

Float SPTimer = 0.0
Float PPTimer = 0.0
Float OPTimer = 0.0
Float HPTimer = 0.0
Float BPTimer = 0.0
Float M1Timer = 0.0
Float M2Timer = 0.0
Float M3Timer = 0.0
Float M4Timer = 0.0
Float M5Timer = 0.0

MiscObject Property Gold Auto 