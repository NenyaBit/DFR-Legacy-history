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

    _Dutil.Info("DF - RejectDeal " + targetDeal)
    If targetDeal != "deviousfollowers/core/extend"
        RejectedDeal = targetDeal
    EndIf
    
    Adversity.StopEvent(DFR_DealHelpers.SplitId(targetDeal)[1])

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

string[] function GetPaths()
    string[] tags = Adversity.GetContextTags("deviousfollowers")
    string[] paths = Adversity.FilterTagsByKey(tags, "path")
    return Adversity.RemovePrefix(tags, "path")
endFunction

string[] Function FilterBySeverity(string[] asRules, int aiMode)
    if DFR_RelationshipManager.Get().IsSlave() && aiMode == 1
        aiMode += 1
    endIf

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

    DFR_DealHelpers.ClearPath(asName)
    
    if !preferBaked        
        return
    endIf
    
    ; pick a path
    string[] paths = GetPaths()

    ; LATER: try to use preferences to intelligently select a path

    string path = ""
    
    int numAvailable = 0

    int i = 0
    while i < paths.length
        if !DFR_DealHelpers.IsPathUsed(paths[i])
            paths[numAvailable] = paths[i]
        endIf

        i += 1
    endWhile

    if numAvailable > 0
        path = paths[Utility.RandomInt(0, numAvailable - 1)]
    endIf

    DFR_DealHelpers.SetPath(asName, path)
EndFunction

bool function AreRequirementsMet(string[] asRules, string asRule)
    string[] tags = Adversity.GetEventTags(asRule)
    string[] reqs = Adversity.FilterTagsByKey(tags, "requires")
    
    int numReqs = reqs.length
    int reqsMet = 0
    int i = 0
    while i < asRules.length
        
        int j = 0
        while j < reqs.length
            if asRules.Find(reqs[j])
                PapyrusUtil.RemoveString(reqs, reqs[j])
                reqsMet += 1
            endIf
            j += 1
        endWhile

        if numReqs == reqsMet
            i = asRules.length
        endIf

        i += 1
    endWhile
    
    return numReqs == reqsMet
endFunction

string Function PickRule(string asDeal)
    int numRules = DFR_DealHelpers.GetNumRules(asDeal)    

    int severityMode = numRules

    string[] candidates = GetCandidates()

    int minSeverity = numRules + 1
    candidates = FilterBySeverity(candidates, minSeverity)
    
    while !candidates.length && minSeverity > 0
        candidates = FilterBySeverity(candidates, minSeverity)
        minSeverity -= 1
    endWhile
    
    if candidates.length == 0
        _DUtil.Info("DF - GetPotentialDeal - aborting due to lack of compatible rules")
        
        RejectedDeal = ""
        
        _DUtil.Info("DF - GetPotentialDeal - END")
        return ""
    endIf

    string path = DFR_DealHelpers.GetDealPath(asDeal)
    if path != "" && Utility.RandomFloat(0, 1.0) <= 0.5
        ; filter by path if rules are available
        string[] tmp = Adversity.FilterEventsByTags(candidates, Utility.CreateStringArray(1, "path:" + path))
        if tmp.length > 0
            candidates = tmp
        endIf
    endIf

    if candidates.length > 0
        candidates = PapyrusUtil.RemoveString(candidates, RejectedDeal)
    endIf
    
    return candidates[Utility.RandomInt(0, candidates.length - 1)]
endFunction

string[] function GetForcedRules()
    string path = Adversity.GetConfigPath("deviousfollowers")
    string[] forced = JsonUtil.StringListToArray(path, "forced-rules")
   
    int i = 0
    while i < forced.length
        forced[i] = "deviousfollowers/" + forced[i]
        i += 1
    endWhile

    return forced
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

        InitializeDeal(dealName, bias)
    else ; existing deal
        int dealIndex = openDeals[chosenDealIndex]
        dealName = DC.DealNames[dealIndex]
    endIf

    _DUtil.Info("DF - GetPotentialDeal - chosen deal = " + dealName)
    
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

    ; _DUtil.Info("DF - GetPotentialDeal - START")
    ; MDC.StartMDC() ; does nothing if started already

    ; Int bondageDeals = BondageDeal.GetStage()
    ; Int slutDeals = SlutDeal.GetStage()
    ; Int ownershipDeals = OwnershipDeal.GetStage()
    ; Int piercingDeals = PiercingDeal.GetStage()
    ; Int whoreDeals = WhoreDeal.GetStage()
    
    ; ; Normalize deal stage.
    ; If bondageDeals >= 4
    ;     bondageDeals = 3
    ; EndIf
    ; If slutDeals >= 4
    ;     slutDeals = 3
    ; EndIf
    ; If ownershipDeals >= 4
    ;     ownershipDeals = 3
    ; EndIf
    
    ; Float biasTest = Utility.RandomInt(0, 99) As Float
    ; Bool preferClassic = biasTest < bias
    ; Debug.TraceConditional("DF - GetPotentialDeal - bias " + (bias As Int) + ", preferClassic " + preferClassic, ShowDiagnostics)

    ; QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D

    ; Int totalDeals = bondageDeals + slutDeals + ownershipDeals + piercingDeals + whoreDeals + m1Deals + m2Deals + m3Deals + m4Deals + m5Deals
    ; Int maxDeals = MDC.MaxModDealsSetting * 3 + DC.DealBMax + DC.DealHMax + DC.DealOMax + DC.DealPMax + DC.DealSQMax
    
    ; Debug.TraceConditional("DF - GetPotentialDeal - B " + bondageDeals + " H " + slutDeals + " O " + ownershipDeals + " P " + piercingDeals + " S " + whoreDeals + ", total " + totalDeals + ", max " + maxDeals, ShowDiagnostics)
        
    ; ; Only consider ANY deals if deal limit not met
    ; If totalDeals >= maxDeals
    ;     Debug.TraceConditional("DF - GetPotentialDeal - aborting due to totalDeals > maxDeals (" + totalDeals + " >= " + maxDeals + ")", ShowDiagnostics)
        
    ;     ; Give the basic extension deal.
    ;     RejectedDeal = 0 ; Clear the rejection state.
        
    ;     _DUtil.Info("DF - GetPotentialDeal - END")
    ;     Return 0
    ; EndIf

    ; ; Though there are 45 deal variants at time of writing, there can only be 10 candidates because they're DEAL limited, not stage or rule limited.
    ; ; i.e. At most 5 classic deals and 5 modular deals.
    ; ; The ten possible candidate slots are populated - randomly in the case of the modular deals and level 3 deals that have alternates.
    ; ; There might not be ten modular deals (or classic deals) if they have been disabled though.
    ; ; The number of candidates is dynamic.

    ; Int[] classicCandidates = New Int[5]
    ; Int[] modularCandidates = New Int[5]
    ; Int classicCount = 0
    ; Int modularCount = 0
    ; Int addDeal
    
    ; _Dutil.Info("DF - GetPotentialDeal - RejectedDeal is " + RejectedDeal)

    ; ; O, B and H deals have two level 3 variants (one of which is stage 4)

    ; ; Populate classic deals
    ; ; TO-DO handle alternate level 3 deals.
    ; If DC.DealBMax > bondageDeals
    ;     If 2 == bondageDeals
    ;         If !DC.DealB1 ; B1 not set, so it's got to be B2
    ;             bondageDeals = 3
    ;         ElseIf DC.DealB2 && Utility.RandomInt(0, 99) < 50 ; B1 and B2 set
    ;             bondageDeals = 3
    ;         EndIf
    ;     EndIf
        
    ;     addDeal = bondageDeals + 1
    ;     If addDeal != RejectedDeal && MDC.IsClassicDealNoConflict("bondage", bondageDeals+1)
    ;         Debug.TraceConditional("DF - GetPotentialDeal - adding DealB " + addDeal, ShowDiagnostics)
    ;         classicCandidates[classicCount] = addDeal
    ;         classicCount += 1
    ;     EndIf
    ; EndIf
    
    ; If DC.DealHMax > slutDeals
    ;     If 2 == slutDeals
    ;         If !DC.DealH1
    ;             slutDeals = 3
    ;         ElseIf DC.DealH2 && Utility.RandomInt(0, 99) < 50
    ;             slutDeals = 3
    ;         EndIf
    ;     EndIf
        
    ;     addDeal = slutDeals + 11
    ;     If addDeal != RejectedDeal && MDC.IsClassicDealNoConflict("slut", slutDeals+1)
    ;         Debug.TraceConditional("DF - GetPotentialDeal - adding DealH " + addDeal, ShowDiagnostics)
    ;         classicCandidates[classicCount] = addDeal
    ;         classicCount += 1
    ;     EndIf
    ; EndIf
    
    ; If DC.DealOMax > ownershipDeals
    ;     If 2 == ownershipDeals
    ;         If !DC.DealO1
    ;             ownershipDeals = 3
    ;         ElseIf DC.DealO2 && Utility.RandomInt(0, 99) < 50
    ;             ownershipDeals = 3
    ;         EndIf
    ;     EndIf
    
    ;     addDeal = ownershipDeals + 21
    ;     If addDeal != RejectedDeal && MDC.IsClassicDealNoConflict("ownership", ownershipDeals+1)
    ;         Debug.TraceConditional("DF - GetPotentialDeal - adding DealO " + addDeal, ShowDiagnostics)
    ;         classicCandidates[classicCount] = addDeal
    ;         classicCount += 1
    ;     EndIf
    ; EndIf
    
    ; If DC.DealPMax > piercingDeals
    ;     addDeal = piercingDeals + 31
    ;     If addDeal != RejectedDeal && MDC.IsClassicDealNoConflict("piercing", piercingDeals+1)
    ;         Debug.TraceConditional("DF - GetPotentialDeal - adding DealP " + addDeal, ShowDiagnostics)
    ;         classicCandidates[classicCount] = addDeal
    ;         classicCount += 1
    ;     EndIf
    ; EndIf
    ; If DC.DealSQMax > whoreDeals
    ;     addDeal = whoreDeals + 41
    ;     If addDeal != RejectedDeal && MDC.IsClassicDealNoConflict("whore", whoreDeals+1)
    ;         Debug.TraceConditional("DF - GetPotentialDeal - adding DealS " + addDeal, ShowDiagnostics)
    ;         classicCandidates[classicCount] = addDeal
    ;         classicCount += 1
    ;     EndIf
    ; EndIf
    
    ; Debug.TraceConditional("DF - GetPotentialDeal - classic deal candidates " + classicCount, ShowDiagnostics)
    
    ; Int m1Deals = M1.GetStage()
    ; Int m2Deals = M2.GetStage()
    ; Int m3Deals = M3.GetStage()
    ; Int m4Deals = M4.GetStage()
    ; Int m5Deals = M5.GetStage()

    ; ; Populate modular deals
    ; Int modDealLimit = MDC.MaxModDealsSetting

    ; ; Get the list of candidate Tier 1 and 2 rules
    ; Int[] lowRules = MDC.GetLowRules(RejectedDeal)
    ; Int lowRuleCount = MDC.CountRules(lowRules)

    ; ; Get the list of candidate Tier 3 rules
    ; Int[] hiRules = MDC.GetHiRules(RejectedDeal)
    ; Int hiRuleCount = MDC.CountRules(hiRules)
    
    ; Debug.TraceConditional("DF - GetPotentialDeal - M1 " + m1Deals + ", M2 " + m2Deals + ", M3 " + m3Deals + ", M4 " + m4Deals + ", M5 " + m5Deals, ShowDiagnostics)
    ; Debug.TraceConditional("DF - GetPotentialDeal - low rules " + lowRuleCount + ", hiRules " + hiRuleCount, ShowDiagnostics)


    ; ; Pick (up to) two candidate modular rules, which are patched into the different modular deal candidate slots.
    ; ; There's no point picking different ones for each deal, as only one deal can get assigned.
    ; Int lowPick = -1
    ; If lowRuleCount > 0
    ;     lowPick = Utility.RandomInt(0, lowRuleCount - 1)
    ;     lowPick = lowRules[lowPick]
    ;     Debug.TraceConditional("DF - GetPotentialDeal - lowPick " + lowPick, ShowDiagnostics)
    ; EndIf

    ; Int hiPick = -1
    ; If hiRuleCount > 0
    ;     hiPick = Utility.RandomInt(0, hiRuleCount - 1)
    ;     hiPick = hiRules[hiPick]
    ;     Debug.TraceConditional("DF - GetPotentialDeal - hiPick " + hiPick, ShowDiagnostics)
    ; EndIf

    ; _Dutil.Info("DF - GetPotentialDeal - lowCount " + lowRuleCount + ", lowPick " + lowPick + ", hiCount " + hiRuleCount + ", hiPick " + hiPick)

    ; ; Make picks for the enabled modular rules
    ; If modDealLimit >= 1 && m1Deals < 3
    ;     Debug.TraceConditional("DF - consider M1 at " + m1Deals, ShowDiagnostics)
    ;     If m1Deals < 2 && lowPick > 0
    ;         modularCandidates[modularCount] = lowPick + 100
    ;         modularCount += 1
    ;     ElseIf m1Deals == 2 && hiPick > 0
    ;         modularCandidates[modularCount] = hiPick + 100
    ;         modularCount += 1
    ;     EndIf
    ; EndIf

    ; If modDealLimit >= 2 && m2Deals < 3
    ;    Debug.TraceConditional("DF - consider M2 at " + m2Deals, ShowDiagnostics)
    ;     If m2Deals < 2 && lowPick > 0
    ;         modularCandidates[modularCount] = lowPick + 200
    ;         modularCount += 1
    ;     ElseIf m2Deals == 2 && hiPick > 0
    ;         modularCandidates[modularCount] = hiPick + 200
    ;         modularCount += 1
    ;     EndIf
    ; EndIf

    ; If modDealLimit >= 3 && m3Deals < 3
    ;     Debug.TraceConditional("DF - consider M3 at " + m3Deals, ShowDiagnostics)
    ;     If m3Deals < 2 && lowPick > 0
    ;         modularCandidates[modularCount] = lowPick + 300
    ;         modularCount += 1
    ;     ElseIf m3Deals == 2 && hiPick > 0
    ;         modularCandidates[modularCount] = hiPick + 300
    ;         modularCount += 1
    ;     EndIf
    ; EndIf
        
    ; If modDealLimit >= 4 && m4Deals < 3
    ;     Debug.TraceConditional("DF - consider M4 at " + m4Deals, ShowDiagnostics)
    ;     If m4Deals < 2 && lowPick > 0
    ;         modularCandidates[modularCount] = lowPick + 400
    ;         modularCount += 1
    ;     ElseIf m4Deals == 2 && hiPick > 0
    ;         modularCandidates[modularCount] = hiPick + 400
    ;         modularCount += 1
    ;     EndIf
    ; EndIf

    ; If modDealLimit >= 5 && m5Deals < 3
    ;     Debug.TraceConditional("DF - consider M5 at " + m5Deals, ShowDiagnostics)
    ;     If m5Deals < 2 && lowPick > 0
    ;         modularCandidates[modularCount] = lowPick + 500
    ;         modularCount += 1
    ;     ElseIf m5Deals == 2 && hiPick > 0
    ;         modularCandidates[modularCount] = hiPick + 500
    ;         modularCount += 1
    ;     EndIf
    ; EndIf
    
    ; Debug.TraceConditional("DF - GetPotentialDeal - modular deal candidates " + modularCount, ShowDiagnostics)
    
    ; Int pickIndex
    ; Int finalID
    ; If preferClassic && classicCount > 0
    ;     pickIndex = Utility.RandomInt(0, classicCount - 1)
    ;     finalID = classicCandidates[pickIndex]
    ;     Debug.TraceConditional("DF - GetPotentialDeal - picked preferred classic index [" + pickIndex + "], from [" + classicCount + "] candidates, got DealID " + finalID, ShowDiagnostics)
    ; ElseIf modularCount > 0
    ;     pickIndex = Utility.RandomInt(0, modularCount - 1)
    ;     finalID = modularCandidates[pickIndex]
    ;     Debug.TraceConditional("DF - GetPotentialDeal - picked modular index [" + pickIndex + "], from [" + modularCount + "] candidates, got DealID " + finalID, ShowDiagnostics)
    ; ElseIf classicCount > 0
    ;     pickIndex = Utility.RandomInt(0, classicCount - 1)
    ;     finalID = classicCandidates[pickIndex]
    ;     Debug.TraceConditional("DF - GetPotentialDeal - picked defaulted classic index [" + pickIndex + "], from [" + classicCount + "] candidates, got DealID " + finalID, ShowDiagnostics)
    ; Else
    ;     pickIndex = -1
    ;     finalID = 0
    ;     Debug.TraceConditional("DF - GetPotentialDeal - fell back to extension deal 0", ShowDiagnostics)
    ; EndIf
    
    ; ; Sometimes we may offer an extension before all deals have run out, to make things less certain.
    ; Int modularAvailable = lowRuleCount
    ; If modularAvailable < hiRuleCount
    ;     modularAvailable = hiRuleCount
    ; EndIf
    ; If modularAvailable > modularCount
    ;     modularAvailable = modularCount
    ; EndIf
    ; Int optionsAvailable = classicCount + modularAvailable
    ; Debug.TraceConditional("DF - GetPotentialDeal - optionsAvailable " + optionsAvailable, ShowDiagnostics)
    
    ; If 0 != finalId && optionsAvailable < 3
    ;     ; Never offer exceptions if successfully providing a preferred classic deal.
    ;     If !(preferClassic && finalID < 100)
    ;         ; 20%
    ;         If Utility.RandomInt(0, 1000) < 200
    ;             finalID = 0
    ;         EndIf
    ;     EndIf
    ; EndIf
    

    ; _DUtil.Info("DF - GetPotentialDeal - END")
    ; Return finalID

EndFunction

Function MakeDeal(string id, bool reduceDebt = True)

    Debug.TraceConditional("DF - MakeDeal " + id + " START", ShowDiagnostics)
	_Dutil.Info("DF - MakeDeal " + id)
    If id == "" ; No deal can be made
		_Dutil.Info("DF - MakeDeal - aborting id == ''")
        return
    EndIf
    
    DFR_RelationshipManager.Get().DelayForcedDealTimer()
    
    string[] split = DFR_DealHelpers.SplitId(id)
    string deal = split[0]
    string rule = split[1]

    if deal == "" || rule == ""
        _Dutil.Info("DF - MakeDeal - aborting id == " + id + " - invalid rule + deal combo")
        return
    endIf


    If reduceDebt && !DFR_RelationshipManager.Get().IsSlave()
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
        DFR_DealHelpers.Create(deal)
        Adversity.StartEvent(rule)
        DFR_DealHelpers.AddRule(deal, rule)
        stage = DFR_DealHelpers.GetNumRules(deal)
        Tool.ReduceResist(stage)

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

    Tool.DeferPunishments()
    RejectedDeal = ""

    Debug.Notification(Adversity.GetEventDesc(rule))

    _Dutil.Info("DF - MakeDeal - END")

    ; Int stage = 0
    
    ; If 0 == id ; Extend a random existing deal (double its duration)
    
    ;     Debug.TraceConditional("DF - MakeDeal - extend existing deal", ShowDiagnostics)
    ;     QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D
    ;     DC.ExtendRandomDeal()
    
    ; ElseIf id < 10 ; Bondage
    ;     stage = BondageDeal.GetStage() + 1
    ;     If id == 4
    ;         stage = 4
    ;     EndIf
    ;     Debug.TraceConditional("DF - MakeDeal - bondage deal " + stage, ShowDiagnostics)
    ;     BondageDeal.SetStage(stage)
    ;     Tool.ReduceResist(stage)
    ; ElseIf id < 20 ; Slut
    ;     stage = SlutDeal.GetStage() + 1
    ;     If id == 14
    ;         stage = 4
    ;     EndIf
    ;     Debug.TraceConditional("DF - MakeDeal - slut deal " + stage, ShowDiagnostics)
    ;     SlutDeal.SetStage(stage)
    ;     Tool.ReduceResist(stage)
    ; ElseIf id < 30 ; Ownership
    ;     stage = OwnershipDeal.GetStage() + 1
    ;     If id == 24
    ;         stage = 4
    ;     EndIf
    ;     Debug.TraceConditional("DF - MakeDeal - ownership deal " + stage, ShowDiagnostics)
    ;     OwnershipDeal.SetStage(stage)
    ;     Tool.ReduceResist(stage)
    ; ElseIf id < 40 ; Piercings
    ;     Debug.TraceConditional("DF - MakeDeal - piercings deal " + stage, ShowDiagnostics)
    ;     stage = PiercingDeal.GetStage() + 1
    ;     PiercingDeal.SetStage(stage)
    ;     Tool.ReduceResist(stage)
    ; ElseIf id < 50 ; WhoreDeal
    ;     Debug.TraceConditional("DF - MakeDeal - whore deal " + stage, ShowDiagnostics)
    ;     stage = WhoreDeal.GetStage() + 1
    ;     WhoreDeal.SetStage(stage)
    ;     Tool.ReduceResist(stage)
    ; ElseIf id < 200 ; M1
    ;     Debug.TraceConditional("DF - MakeDeal - M1 " + id, ShowDiagnostics)
    ;     stage = SetModularDeal(M1, id - 100)
    ; ElseIf id < 300 ; M2
    ;     Debug.TraceConditional("DF - MakeDeal - M2 " + id, ShowDiagnostics)
    ;     stage = SetModularDeal(M2, id - 200)
    ; ElseIf id < 400 ; M3
    ;     Debug.TraceConditional("DF - MakeDeal - M3 " + id, ShowDiagnostics)
    ;     stage = SetModularDeal(M3, id - 300)
    ; ElseIf id < 500 ; M4
    ;     Debug.TraceConditional("DF - MakeDeal - M4 " + id, ShowDiagnostics)
    ;     stage = SetModularDeal(M4, id - 400)
    ; ElseIf id < 600 ; M5
    ;     Debug.TraceConditional("DF - MakeDeal - M5 " + id, ShowDiagnostics)
    ;     stage = SetModularDeal(M5, id - 500)
    ; EndIf
    
    ; If stage > 0
    ;     Debug.TraceConditional("DF - MakeDeal - stage > 0 - update deal count globals", ShowDiagnostics)
    ;     QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D
    ;     DC.DealAdd(1)
    ;     If 3 >= stage
    ;         Debug.TraceConditional("DF - MakeDeal - add a max deal", ShowDiagnostics)
    ;         DC.DealMaxAdd(1)
    ;     EndIf
    ; EndIf

    ; Tool.DeferPunishments()
    ; RejectedDeal = 0
    ; _Dutil.Info("DF - MakeDeal - END")
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
        _Dutil.Info("DF - CheckDealOpen - " + Adversity.IsEventActive(rule) + " - " + Adversity.IsEventEnabled(rule))
        return !Adversity.IsEventActive(rule) && Adversity.IsEventEnabled(rule)
    endIf

    ; If id < 0 ; No deal is never open
    ;     Return False
    ; EndIf
    
    ; Int modularDeal
    ; Int stage
    
    ; QF__DflowDealController_0A01C86D DC = (self As Quest) As QF__DflowDealController_0A01C86D

    ; ; For classic deals the deal is "open" if the next stage matches the expected stage for the deal ID.
    ; ; This is easy because the IDs are matched to stages.
    ; ;
    ; If id == 0 ; Extension
    ;     ; Check if any deal has been taken at all...
    ;     Int deals = DC.DealB.GetStage() + DC.DealH.GetStage() + DC.DealO.GetStage() + DC.DealP.GetStage() + DC.DealSQ.GetStage() \
    ;         + DC.DealM1.GetStage() + DC.DealM2.GetStage() + DC.DealM3.GetStage() + DC.DealM4.GetStage() + DC.DealM5.GetStage()
    ;     Return deals > 0
    ; ElseIf id < 10 ; Bondage
    ;     Int expectedStage = id
    ;     Debug.TraceConditional("DF - CheckDealOpen B exStage " + expectedStage + ", opt1 " + DC.DealB1 + ", opt2 " + DC.DealB2, ShowDiagnostics)
    ;     If expectedStage == 3 && !DC.DealB1
    ;         Return False
    ;     ElseIf expectedStage == 4 && !DC.DealB2
    ;         Return False
    ;     EndIf
    ;     If expectedStage == 4
    ;         expectedStage = 3
    ;     EndIf
    ;     stage = BondageDeal.GetStage() + 1
    ;     Debug.TraceConditional("DF - CheckDealOpen B exStage " + expectedStage + ", stage " + stage + ", max " + DC.DealBMax, ShowDiagnostics)
    ;     Return stage == expectedStage && DC.DealBMax >= expectedStage
    ; ElseIf id < 20 ; Slut
    ;     Int expectedStage = id - 10
    ;     Debug.TraceConditional("DF - CheckDealOpen H exStage " + expectedStage + ", opt1 " + DC.DealH1 + ", opt2 " + DC.DealH2, ShowDiagnostics)
    ;     If expectedStage == 3 && !DC.DealH1
    ;         Return False
    ;     ElseIf expectedStage == 4 && !DC.DealH2
    ;         Return False
    ;     EndIf
    ;     If expectedStage == 4
    ;         expectedStage = 3
    ;     EndIf
    ;     stage = SlutDeal.GetStage() + 1
    ;     Debug.TraceConditional("DF - CheckDealOpen H exStage " + expectedStage + ", stage " + stage + ", max " + DC.DealHMax, ShowDiagnostics)
    ;     Return stage == expectedStage && DC.DealHMax >= expectedStage
    ; ElseIf id < 30 ; Ownership
    ;     Int expectedStage = id - 20
    ;     Debug.TraceConditional("DF - CheckDealOpen O exStage " + expectedStage + ", opt1 " + DC.DealO1 + ", opt2 " + DC.DealO2, ShowDiagnostics)
    ;     If expectedStage == 3 && !DC.DealO1
    ;         Return False
    ;     ElseIf expectedStage == 4 && !DC.DealO2
    ;         Return False
    ;     EndIf
    ;     If expectedStage == 4
    ;         expectedStage = 3
    ;     EndIf
    ;     stage = OwnershipDeal.GetStage() + 1
    ;     Debug.TraceConditional("DF - CheckDealOpen O exStage " + expectedStage + ", stage " + stage + ", max " + DC.DealOMax, ShowDiagnostics)
    ;     Return stage == expectedStage && DC.DealOMax >= expectedStage
    ; ElseIf id < 40 ; Piercings
    ;     Int expectedStage = id - 30
    ;     stage = PiercingDeal.GetStage() + 1
    ;     Return stage == expectedStage && DC.DealPMax >= expectedStage
    ; ElseIf id < 50 ; WhoreDeal
    ;     Int expectedStage = id - 40
    ;     stage = WhoreDeal.GetStage() + 1
    ;     Return stage == expectedStage && DC.DealSQMax >= expectedStage
        
	; ; For modular deals, the deal is "open" if we've specified a modular deal that matches the TIER TYPE of the modular ID ... AND
	; ; also the modular rule is not already allocated.
	; ; Again, should be checking the deal is enabled.
    ; ElseIf id < 200 ; M1
    ;     modularDeal = id - 100
    ;     stage = M1.GetStage() + 1
    ; ElseIf id < 300 ; M2
    ;     modularDeal = id - 200
    ;     stage = M2.GetStage() + 1
    ; ElseIf id < 400 ; M3
    ;     modularDeal = id - 300
    ;     stage = M3.GetStage() + 1
    ; ElseIf id < 500 ; M4
    ;     modularDeal = id - 400
    ;     stage = M4.GetStage() + 1
    ; ElseIf id < 600 ; M5
    ;     modularDeal = id - 500
    ;     stage = M5.GetStage() + 1
    ; Else
    ;     Debug.TraceConditional("DF - CheckDealOpen - ERROR - deal ID out of range " + id, ShowDiagnostics)
    ; EndIf
	
	; _Dutil.Info("DF - Modular deal ID is " + modularDeal)
	; _Dutil.Info("DF - Stage is " + stage)
    
	; ; Get rule status by index (0 = disabled, 1 = enabled, 2 = set, 3+ other values of set...)
    ; Int ruleState = MDC.GetRuleState(modularDeal)
	; _Dutil.Info("DF - ruleState is " + ruleState)
	
    ; If 1 != ruleState
    ;     Return False
    ; EndIf

	; ; 1 for tier 1 and 2, 2 for tier 3
    ; Int dealType = MDC.DealType[modularDeal]
	; _Dutil.Info("DF - dealType is " + dealType)
	
    ; If 1 == dealType
    ;     Return stage < 3
    ; ElseIf 2 == dealType
    ;     Return stage >= 3
    ; EndIf
    
    ; Return True

EndFunction


; True is the player has any deals that make them naked in town, or more broadly.
; Naked deals are: slut-deal lvl 2+, whore deal level 2+, piercing deal lvl 3+, modular naked rule (6), modular whore rule (7), modular pet-suit rule (11), modular jacket rule sort of (16)
Bool Function HaveNakedDeals()
    string[] rules = Adversity.GetActiveEvents("deviousfollowers", "rule")
    string[] tags = Utility.CreateStringArray(1, "naked")
    rules = Adversity.FilterEventsByTags(rules, tags)
    
    return rules.length > 0

    ; Return SlutDeal.GetStage() >= 2 \
    ;     || WhoreDeal.GetStage() >= 2 \
    ;     || PiercingDeal.GetStage() >= 3 \
    ;     || MDC.NakedRule >= 2 \
    ;     || MDC.WhoreRule >= 2 \
    ;     || MDC.PetSuitInTownRule >= 2 \
    ;     || MDC.JacketRule >= 2
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


; Int Function BuildExistingDeals()

;     Debug.TraceConditional("DF - BuildExistingDeals - start", ShowDiagnostics)
;     Int bondageDeals = BondageDeal.GetStage()      ; 1
;     Int slutDeals = SlutDeal.GetStage()            ; 2
;     Int ownershipDeals = OwnershipDeal.GetStage()  ; 3
;     Int piercingDeals = PiercingDeal.GetStage()    ; 4
;     Int whoreDeals = WhoreDeal.GetStage()          ; 5
  
;     Int m1Deals = M1.GetStage() ; 6
;     Int m2Deals = M2.GetStage() ; 7
;     Int m3Deals = M3.GetStage() ; 8
;     Int m4Deals = M4.GetStage() ; 9
;     Int m5Deals = M5.GetStage() ; 10
    
;     existingDeals = New Int[10]
    
;     Int count = 0
    
;     If bondageDeals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add bondage", ShowDiagnostics)
;         existingDeals[count] = 1
;         count += 1
;     EndIf
;     If slutDeals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add slut", ShowDiagnostics)
;         existingDeals[count] = 2
;         count += 1
;     EndIf
;     If ownershipDeals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add ownership", ShowDiagnostics)
;         existingDeals[count] = 3
;         count += 1
;     EndIf
;     If piercingDeals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add piercing", ShowDiagnostics)
;         existingDeals[count] = 4
;         count += 1
;     EndIf
;     If whoreDeals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add whore", ShowDiagnostics)
;         existingDeals[count] = 5
;         count += 1
;     EndIf

;     If m1Deals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add M1", ShowDiagnostics)
;         existingDeals[count] = 6
;         count += 1
;     EndIf
;     If m2Deals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add M2", ShowDiagnostics)
;         existingDeals[count] = 7
;         count += 1
;     EndIf
;     If m3Deals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add M3", ShowDiagnostics)
;         existingDeals[count] = 8
;         count += 1
;     EndIf
;     If m4Deals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add M4", ShowDiagnostics)
;         existingDeals[count] = 9
;         count += 1
;     EndIf
;     If m5Deals > 0
;         Debug.TraceConditional("DF - BuildExistingDeals - add M5", ShowDiagnostics)
;         existingDeals[count] = 10
;         count += 1
;     EndIf
;     Debug.TraceConditional("DF - BuildExistingDeals - end " + count + " deals", ShowDiagnostics)
;     Return count

; EndFunction


; Function RemoveDealByIndex(Int index)

;     If 1 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - bondage", ShowDiagnostics)
;         (BondageDeal As _DDeal).BuyOut(_DFZero)
;     ElseIf 2 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - slut", ShowDiagnostics)
;         (SlutDeal As _DDeal).BuyOut(_DFZero)
;     ElseIf 3 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - ownership", ShowDiagnostics)
;         (OwnershipDeal As _DDeal).BuyOut(_DFZero)
;     ElseIf 4 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - piercing", ShowDiagnostics)
;         (PiercingDeal As _DDeal).BuyOut(_DFZero)
;     ElseIf 5 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - whore", ShowDiagnostics)
;         (WhoreDeal As _DDeal).BuyOut(_DFZero)
;     ElseIf 6 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - M1", ShowDiagnostics)
;         (M1 As _MDDeal).BuyOut(_DFZero)
;     ElseIf 7 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - M2", ShowDiagnostics)
;         (M2 As _MDDeal).BuyOut(_DFZero)
;     ElseIf 8 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - M3", ShowDiagnostics)
;         (M3 As _MDDeal).BuyOut(_DFZero)
;     ElseIf 9 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - M4", ShowDiagnostics)
;         (M4 As _MDDeal).BuyOut(_DFZero)
;     ElseIf 10 == index
;         Debug.TraceConditional("DF - RemoveDealByIndex - M5", ShowDiagnostics)
;         (M5 As _MDDeal).BuyOut(_DFZero)
;     EndIf
    
; EndFunction

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

    ; Int count = BuildExistingDeals()
    ; If count <= 0
    ;     Debug.TraceConditional("DF - RemoveRandomDeal - end - NO DEALS", ShowDiagnostics)
    ;     Return False
    ; EndIf
    ; count -= 1
    
    ; Int remove = Utility.RandomInt(0, count)
    ; Int id = existingDeals[remove]
    
    ; Debug.TraceConditional("DF - RemoveRandomDeal - remove " + id, ShowDiagnostics)
    
    ; RemoveDealByIndex(id)
    
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