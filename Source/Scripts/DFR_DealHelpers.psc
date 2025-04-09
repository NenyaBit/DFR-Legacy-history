Scriptname DFR_DealHelpers Hidden 

string function GetAllKey() global
    return "DFR_Deals"
endFunction

string function GetKey(string asName) global
    return "DFR_Deals_" + asName
endFunction

string function GetTimerKey(string asName) global
    return GetKey(asName) + "_Timer"
endFunction

string function GetCostKey(string asName) global
    return GetKey(asName) + "_Cost"
endFunction

float function GetTimer(string asName) global
    return StorageUtil.GetFloatValue(none, GetTimerKey(asName))
endFunction

function SetTimer(string asName, float afTimer) global
    StorageUtil.SetFloatValue(none, GetTimerKey(asName), afTimer)
endFunction

int function GetNum() global
    return StorageUtil.StringListCount(none, GetAllKey())
endFunction

int function GetNumRules(string asDeal) global
    return StorageUtil.StringListCount(none, GetKey(asDeal))
endFunction

string[] function GetDeals() global
    return StorageUtil.StringListToArray(none, GetAllKey())
endFunction

string function GetDealAt(int aiIndex) global
    return StorageUtil.StringListGet(none, GetAllKey(), aiIndex)
endFunction

string function GetDealByRule(string asRule) global
    return StorageUtil.GetStringValue(none, "DFR_RuleInDeal_" + asRule)
endFunction

string function GetRuleAt(string asDeal, int aiIndex) global
    return StorageUtil.StringListGet(none, GetKey(asDeal), aiIndex)
endFunction

string[] function GetRules(string asDeal) global
    return StorageUtil.StringListToArray(none, GetKey(asDeal))
endFunction

int function GetCost(string asDeal) global 
    StorageUtil.GetIntValue(none, "Deals_Cost_" + asDeal)
endFunction

int function SetCost(string asDeal, int aiCost) global 
    StorageUtil.SetIntValue(none, "Deals_Cost_" + asDeal, aiCost)
endFunction

function Create(string asDeal) global
    if !StorageUtil.StringListHas(none, GetAllKey(), asDeal)
        StorageUtil.StringListAdd(none, GetAllKey(), asDeal)
        StorageUtil.StringListClear(none, GetKey(asDeal))
    endIf
endFunction

function Remove(string asDeal) global
    StorageUtil.StringListRemove(none, GetAllKey(), asDeal)

    string[] rules = StorageUtil.StringListToArray(none, GetKey(asDeal))
    int i = 0
    while i < rules.length
        StorageUtil.UnsetStringValue(none, "DFR_RuleInDeal_" + rules[i])
        i += 1
    endWhile

    StorageUtil.StringListClear(none, GetKey(asDeal))
    ClearPath(asDeal)
endFunction

function RemoveRule(string asDeal, string asRule) global
    StorageUtil.StringListRemove(none, GetKey(asDeal), asRule, true)
    StorageUtil.UnsetStringValue(none, "DFR_RuleInDeal_" + asRule)
endFunction

bool function AddRule(string asDeal, string asRule) global
    string lastDeal = StorageUtil.GetStringValue(none, "DFR_RuleInDeal_" + asRule, "")
    if lastDeal != asDeal
        RemoveRule(lastDeal, asRule)
    endIf

    if StorageUtil.StringListAdd(none, GetKey(asDeal), asRule, false) >= 0
        StorageUtil.SetStringValue(none, "DFR_RuleInDeal_" + asRule, asDeal)
        return true
    endIf

    return false
endFunction

string[] function SplitId(string asDeal) global
    string[] ids = new string[2]
    
    string[] splits = StringUtil.Split(asDeal, "/")
    if splits.length < 4
        return ids
    endIf

    ids[0] = splits[0]
    ids[1] = splits[1] + "/" + splits[2] + "/" + splits[3]

    return ids
endFunction

function InitDeals(string[] asDeals) global
    if StorageUtil.GetIntValue(none, "DFR_DealIndex_Length") == asDeals.length
        return
    endIf

    int i = 0
    while i < asDeals.Length
        StorageUtil.SetIntValue(none, "DFR_DealIndex_" + asDeals[i], i)
        i += 1
    endWhile
endFunction

int function GetDealIndex(string asDeal) global
    return StorageUtil.GetIntValue(none, "DFR_DealIndex_" + asDeal, -1)
endFunction

string function GetDealPath(string asName) global
    return StorageUtil.GetStringValue(none, "DFR_PathUsed_" + asName)
endFunction

function SetPath(string asName, string asPath) global
    if asPath == ""
        return ClearPath(asName)
    endIf

    StorageUtil.SetStringValue(none, "DFR_PathUsed_" + asName, asPath)
    StorageUtil.SetIntValue(none, "DFR_PathUsed_" + asPath, 1)
endFunction

function ClearPath(string asName) global
    string path = StorageUtil.GetStringValue(none, "DFR_PathUsed_" + asName)
    StorageUtil.UnsetStringValue(none, "DFR_PathUsed_" + asName)
    StorageUtil.UnsetIntValue(none, "DFR_PathUsed_" + path)
endFunction

bool function IsPathUsed(string asName) global
    return StorageUtil.GetIntValue(none, "DFR_PathUsed_" + asName, 0) == 1
endFunction