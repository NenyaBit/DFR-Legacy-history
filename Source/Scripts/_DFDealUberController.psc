Scriptname _DFDealUberController extends Quest  

; Binds classic and modular deals together into a single system.
; Now we can ask for a random deal and it will be identified by a unique ID that can be used to apply it.

; FOLDSTART - IDs
; If the ID is >= 100, then it's a deal specific modular rule, bound to a specific modular deal M1 = 100, M2 = 200, etc.
; If the ID is < 100, then it's a classic deal.
; _DflowDealB => Bondage Deal  -  01 corset,            02 boots+gloves,     03 gag,                  04 tape-gag, (103+ forcegreets occur), (104 tape-gag forcegreets occur)
; _DflowDealH => Slut Deal     -  11 speech,            12 naked in town,    13 bound-hands in town,  14 cum layers (Hellos in _DflowDealH)
; _DflowDealO => Ownership     -  21 arm+leg cuffs,     22 collar,           23 chastity belt,        24 chastity belt with once-per-day
; _DflowDealP => Piercings     -  31 nipple-piercings,  32 pussy-piercings,  33 must be naked while talking (forcegreets occur)
; _DflowDealS => Sign?         -  41 anal-plug,         42 whore-armor,      43 sign

; Add the base for the modular deal (100 bear, 200 wolf, 300 dragon, 400 skeever, 500 slaughterfish) to this ID to get the ID for a modular deal.
;  0 NoDeal                -
;  1 CuffsRule             L1+2
;  2 CollarRule            L1+2
;  3 GagRule               L1+2
;  4 NPRule                L1+2 nipple piercing
;  5 VPRule                L1+2 vaginal piercing
;  6 NakedRule             L1+2
;  7 WhoreRule             L1+2 whore armor
;  8 BlindFoldRule         L1+2
;  9 BootsRule             L1+2
; 10 GlovesRule            L1+2
; 11 PetSuitInTownRule     L3
; 12 CrawlInTownRule       L3
; 13 InnKeeperRule         L3
; 14 BoundInTownRule       L3
; 15 MerchantRule          L3
; 16 JacketRule            L3
; 17 ExpensiveRule         L1+2+3
; 18 KeyRule               L3
; 19 SkoomaRule            L3
; 20 MilkingRule           L3
; 21 SpankRule             L1+2
; 22 SexRule               L1+2
; 23 LactacidRule          L1+2
; 24 RingRule              L1+2
; 25 AmuletRule            L1+2
; 26 CircletRule           L1+2
; FOLDEND - IDs

; FOLDSTART - Properties
_DDeal Property BondageDeal Auto
_DDeal Property SlutDeal Auto ; H
_DDeal Property OwnershipDeal Auto
_DDeal Property PiercingDeal Auto
_DDeal Property WhoreDeal Auto ; SQ

_MDDeal Property M1 Auto ; 100
_MDDeal Property M2 Auto ; 200
_MDDeal Property M3 Auto ; 300
_MDDeal Property M4 Auto ; 400
_MDDeal Property M5 Auto ; 500

String Property RejectedDeal Auto 
Bool Property ShowDiagnostics Auto

_DFlowModDealController Property MDC Auto

_DFtools Property Tool Auto
QF__Gift_09000D62 Property DFlowQ Auto

_DFlowProps Property DFlowProps Auto

GlobalVariable Property _DFZero Auto
GlobalVariable property DebugMode auto 

DFR_RelationshipManager property RelManager auto
DFR_Events property Events auto

String Property Context = "deviousfollowers" Auto
; FOLDEND - Properties

Int[] existingDeals

Function StartDeals()
	MDC.StartMDC()
EndFunction

; Simple deal adding function. Picks a candidate deal, then confirms the deal.
String Function AddDeal()

    string targetDeal = GetPotentialDeal()
    _Dutil.Info("DF - adding random deal " + targetDeal)

    Bool isOpen = CheckDealOpen(targetDeal)
    _Dutil.Info("DF - adding deal " + targetDeal + " deal OPEN is " + isOpen)

    If isOpen
        ; Does nothing if targetDeal is < 0
        ; If target deal is zero, does random deal extension.
        MakeDeal(targetDeal)
        return targetDeal
    EndIf

    return ""
EndFunction

bool Function AddDealById(string targetDeal, bool reduceDebt = True)

    _Dutil.Info("DF - adding deal by ID " + targetDeal)

    Bool isOpen = CheckDealOpen(targetDeal)
    _Dutil.Info("DF - adding deal " + targetDeal + " deal OPEN is " + isOpen)

    If isOpen
        _Dutil.Info("DF - AddDealById - deal was open")
        ; Does nothing if targetDeal is < 0
        ; If target deal is zero, does random deal extension.
        MakeDeal(targetDeal, reduceDebt)
        Return true
    Else
        _Dutil.Info("DF - AddDealById - deal was blocked")
    EndIf

    Return false

EndFunction

Function RejectDeal(string targetDeal)

    Debug.TraceConditional("DF - RejectDeal " + targetDeal + " START", ShowDiagnostics)
    Debug.TraceConditional("DF - deal is open = " + CheckDealOpen(targetDeal), ShowDiagnostics)

    string ruleId = DFR_DealHelpers.SplitId(targetDeal)

    _Dutil.Info("DF - RejectDeal " + targetDeal + " - " + ruleId)


    If ruleId != "deviousfollowers/core/extend"
        RejectedDeal = ruleId
    EndIf

    RelManager.DeEscalate()
    
    Adversity.UnselectEvent(DFR_DealHelpers.SplitId(targetDeal)[1])

    DFlowQ.DealRejectDebt()
    _Dutil.Info("DF - RejectDeal - END")

EndFunction

string[] Function GetCandidates()
    string[] candidates = Adversity.GetContextEvents(Context)
    candidates = Adversity.FilterEventsByType(candidates, "rule")

    if !((self As Quest) As QF__DflowDealController_0A01C86D).Deals
        candidates = PapyrusUtil.RemoveString(candidates, "deviousfollowers/core/extend")
    endIf

    return Adversity.FilterEventsByValid(candidates, DFlowQ.Alias__DMaster.GetRef() as Actor)
EndFunction

string[] Function FilterBySeverity(string[] asRules, int aiMode)
    int minSeverity = 1
    int maxSeverity = 2

    if aiMode == 2
        minSeverity = 2
        maxSeverity = 3
    elseIf aiMode == 3
        minSeverity = 4
        maxSeverity = 5
    endIf

    string[] tmp = Adversity.FilterEventsBySeverity(asRules, minSeverity)
    string[] tmp2 = Adversity.FilterEventsBySeverity(tmp, maxSeverity, false)
    
    if tmp2.length
        return tmp2
    elseIf tmp.length
        return tmp
    else
        return asRules
    endIf
EndFunction

Function InitializeDeal(string asName, float afBias)
    float biasTest = Utility.RandomInt(0, 99) as float
    bool preferBaked = biasTest < afBias
    
    if !preferBaked        
        return
    endIf
EndFunction

string Function PickRule(string asDeal)
    int numRules = DFR_DealHelpers.GetNumRules(asDeal)    

    int severityMode = numRules

    string[] candidates = GetCandidates()

    DFR_Util.Log("candidates 1 = " + candidates)

    int minSeverity = numRules + 1
    candidates = FilterBySeverity(candidates, minSeverity)
  
    DFR_Util.Log("candidates 2 = " + candidates)
    
    while !candidates.length && minSeverity > 0
        candidates = FilterBySeverity(candidates, minSeverity)
        minSeverity -= 1
    endWhile
    
    DFR_Util.Log("candidates 3 = " + candidates)

    if candidates.length == 0
        _DUtil.Info("DF - GetPotentialDeal - aborting due to lack of compatible rules")
        
        RejectedDeal = ""
        
        _DUtil.Info("DF - GetPotentialDeal - END")
        return ""
    endIf

    if candidates.length > 1
        candidates = PapyrusUtil.RemoveString(candidates, RejectedDeal)
    endIf

    int[] weights = Utility.CreateIntArray(candidates.Length, 100)
    weights = Adversity.SumArrays(weights, Adversity.WeighEventsByActor("deviousfollowers", DFlowQ.Alias__DMaster.GetRef() as Actor, candidates, 100))
    
    DFR_Util.Log("DealController - Weights = " + weights)

    return candidates[Adversity.GetWeightedIndex(weights)]
endFunction

string[] function GetForcedRules()
    if !DebugMode.GetValue()
        return Utility.CreateStringArray(0)
    endIf

    string path = Adversity.GetConfigPath("deviousfollowers")
    string[] forced = JsonUtil.StringListToArray(path, "forced-rules")
   
    int i = 0
    while i < forced.length
        forced[i] = "deviousfollowers/" + forced[i]
        i += 1
    endWhile

    return forced
endFunction

string function PickDeal(float afBias)
    int maxDeals = MDC.MaxModDealsSetting
    int numDeals = DFR_DealHelpers.GetNum()

    int i = 0
    int numOpen = 0
    int[] openDeals = Utility.CreateIntArray(numDeals)
    while i < numDeals
        if DFR_DealHelpers.GetNumRules(DFR_DealHelpers.GetDealAt(i)) < 3
            openDeals[numOpen] = i
            numOpen += 1
        endIf
        i += 1
    endWhile
    
    int max = numOpen
    if numOpen == maxDeals
        numOpen -= 1
    endIf

    int chosenDealIndex = Utility.RandomInt(0, max)

    string dealName
    QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D
    
    if chosenDealIndex == numOpen ; new deal
        i = 0
        while i < DC.DealNames.Length
            if !DFR_DealHelpers.GetNumRules(DC.DealNames[i])
                dealName = DC.DealNames[i]
                i = DC.DealNames.Length
            endIf
            i += 1
        endWhile

        InitializeDeal(dealName, afBias)
    else ; existing deal
        int dealIndex = openDeals[chosenDealIndex]
        dealName = DC.DealNames[dealIndex]
    endIf

    return dealName
endFunction

string Function GetPotentialDeal(Float bias = 50.0)

    _DUtil.Info("DF - GetPotentialDeal - START")
    MDC.StartMDC() ; does nothing if started already

    int maxDeals = MDC.MaxModDealsSetting
    int totalRules = Adversity.GetActiveEvents(Context, "rule").Length
    int maxRules = 15
            
    If totalRules >= maxRules
        Debug.TraceConditional("DF - GetPotentialDeal - aborting due to totalDeals > maxDeals (" + totalRules + " >= " + maxRules + ")", ShowDiagnostics)
        
        RejectedDeal = ""
        
        _DUtil.Info("DF - GetPotentialDeal - END")
        Return "default/deviousfollowers/core/extend"
    EndIf

    ; choose a deal (existing or new)
    string dealName = PickDeal(bias)
    _DUtil.Info("DF - GetPotentialDeal - chosen deal = " + dealName)
    
    ; actually choose a rule

    string chosen
    string[] forced = GetForcedRules()
    _DUtil.Info("DF - GetPotentialDeal - forced = " + forced)
    forced = Adversity.FilterEventsByValid(forced)

    if forced.length > 0
        _DUtil.Info("DF - GetPotentialDeal - forced filtered = " + forced)
        chosen = forced[0]
        _DUtil.Info("DF - GetPotentialDeal - using forced rule = " + chosen)
    else
        chosen = PickRule(dealName)

        _DUtil.Info("DF - GetPotentialDeal - using random rule = " + chosen)
       
        if chosen == ""
            Debug.TraceConditional("DF - GetPotentialDeal - aborting due to totalDeals > maxDeals (" + totalRules + " >= " + maxRules + ")", ShowDiagnostics)
        
            RejectedDeal = ""
            
            _DUtil.Info("DF - GetPotentialDeal - END")
            Return "default/deviousfollowers/core/extend"
        endIf
    endIf

    _DUtil.Info("DF - GetPotentialDeal - END - " + chosen)

    return dealName + "/" + chosen
EndFunction

Function MakeDeal(string id, bool reduceDebt = True)

    Debug.TraceConditional("DF - MakeDeal " + id + " START", ShowDiagnostics)
	_Dutil.Info("DF - MakeDeal " + id)
    If id == "" ; No deal can be made
		_Dutil.Info("DF - MakeDeal - aborting id == ''")
        return
    EndIf
        
    string[] split = DFR_DealHelpers.SplitId(id)
    string deal = split[0]
    string rule = split[1]

    if deal == "" || rule == ""
        _Dutil.Info("DF - MakeDeal - aborting id == " + id + " - invalid rule + deal combo")
        return
    endIf

    If reduceDebt
        _Dutil.Info("DF - MakeDeal - reduce debt")
        DFlowQ.DealDebt()
    EndIf

    QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D
    
    DFR_DealHelpers.InitDeals(DC.DealNames)
    
    int stage = 0
    if rule == Context + "/core/extend"
        DC.ExtendRandomDeal()
        Adversity.StopEvent(rule)
    else
        if !Adversity.IsEventActive(rule)
            Adversity.StartEvent(rule)
        endIf

        DFR_DealHelpers.Create(deal)
        DFR_DealHelpers.AddRule(deal, rule)
        stage = DFR_DealHelpers.GetNumRules(deal)
        Tool.ReduceResist(stage)
       
        if Events.IncreasesFavour(rule)
            RelManager.IncFavour()
        endIf

        RelManager.Escalate(Adversity.GetEventSeverity(rule))

        GlobalVariable timer = DC.GetDealTimer(DFR_DealHelpers.GetDealIndex(deal))

        float curr = timer.GetValue()
        float now = DC.GameDaysPassed.GetValue()
        if now > timer.GetValue()
            curr = now
        endIf

        timer.SetValue(curr + DC._DflowDealBaseDays.GetValue())
    endIf

    If stage > 0
        _Dutil.Info("DF - MakeDeal - stage > 0 - update deal count globals")
        DC.DealAdd(1)
        If 3 >= stage
            _Dutil.Info("DF - MakeDeal - add a max deal")
            DC.DealMaxAdd(1)
        EndIf
    EndIf

    RejectedDeal = ""

    Debug.Notification(Adversity.GetEventDesc(rule))

    _Dutil.Info("DF - MakeDeal - END")
EndFunction


Int Function SetModularDeal(_MDDeal dealQuest, Int id)

		_Dutil.Info("DF - SetModularDeal " + id)
        Int stage = dealQuest.GetStage() + 1
		Float resist = 0.0
		
		MDC.SetRule(id, 2)

        If 1 == stage
            dealQuest.Rule1Code = id
			resist = 2.0
        ElseIf 2 == stage
            dealQuest.Rule2Code = id
			resist = 3.0
        ElseIf 3 == stage
            dealQuest.Rule3Code = id
			resist = 6.0
        Else
            _Dutil.Error("DF - ERROR - attempt to add to full modular deal, stage " + stage + " deal ID " + id)
        EndIf
		
        _Dutil.Info("DF - SetModularDeal - SetStage " + stage)
        dealQuest.SetStage(stage)
		
		Tool.ReduceResistFloat(resist)
		
        Return stage

EndFunction

Bool Function CheckDealOpen(string id)

    Debug.TraceConditional("DF - CheckDealOpen " + id, ShowDiagnostics)
    
    string[] ids = DFR_DealHelpers.SplitId(id)
    string deal = ids[0]
    string rule = ids[1]

    if deal == "" || rule == "" ; No deal is never open
        return false
    elseIf DFR_DealHelpers.GetNumRules(deal) == 3
        return false
    elseIf rule == "deviousfollowers/core/extend" ; Extension
        return Adversity.GetActiveEvents(Context, "rule").Length > 0
    else
        _Dutil.Info("DF - CheckDealOpen - " + Adversity.IsEventEnabled(rule))
        return Adversity.IsEventEnabled(rule)
    endIf
EndFunction


; True is the player has any deals that make them naked in town, or more broadly.
; Naked deals are: slut-deal lvl 2+, whore deal level 2+, piercing deal lvl 3+, modular naked rule (6), modular whore rule (7), modular pet-suit rule (11), modular jacket rule sort of (16)
Bool Function HaveNakedDeals()
    string[] rules = Adversity.GetActiveEvents("deviousfollowers", "rule")
    string[] tags = Utility.CreateStringArray(1, "naked")
    rules = Adversity.FilterEventsByTags(rules, tags)
    
    return rules.length > 0
EndFunction



; For device removal in return for deals.
Function DeviceRemovalDeal()

    ; DFlowProps = Quest.GetQuest("_DFlow") As _DFlowProps
    
    QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D

    bool addResult = AddDealById(DC.NewDeal, False)
    
    Int deviceIndex = DFlowProps.ItemToRemove
    _Dutil.Info("DF - DeviceRemovalDeal - dealIndex " + DC.NewDeal + ", addResult " + addResult + ", deviceIndex " + deviceIndex)
    
    If addResult
        ; Remove the device specified in _DFlow
        DC.RemoveDeviceByIndex(deviceIndex)
    EndIf
EndFunction

; Returns true if there was a deal to remove
Bool Function RemoveRandomDeal()

    Debug.TraceConditional("DF - RemoveRandomDeal - start", ShowDiagnostics)

    int numDeals = DFR_DealHelpers.GetNum()

    if numDeals
        Debug.TraceConditional("DF - RemoveRandomDeal - end - NO DEALS", ShowDiagnostics)
        return false
    endIf

    int chosenIndex = Utility.RandomInt(0, numDeals - 1)
    string chosen = DFR_DealHelpers.GetDealAt(chosenIndex)
    
    Debug.TraceConditional("DF - RemoveRandomDeal - remove " + chosen, ShowDiagnostics)

    RemoveDealById(chosen)
    
    Debug.TraceConditional("DF - RemoveRandomDeal - end", ShowDiagnostics)
    Return True

EndFunction

function RemoveDealById(string asDeal)
    int numRules = DFR_DealHelpers.GetNumRules(asDeal)

    if numRules >= 3
        ((self as Quest) as QF__DflowDealController_0A01C86D).DealMaxAdd(-1)
    Endif

    ((self as Quest) as QF__DflowDealController_0A01C86D).DealAdd(-numRules)

    int i = 0
    while i < numRules
        Adversity.StopEvent(DFR_DealHelpers.GetRuleAt(asDeal, i))
        i += 1
    endWhile

    DFR_DealHelpers.Remove(asDeal)
endFunction