Scriptname DFR_API Hidden 

; Convenience and proxy functions for external usage

Actor function GetFollower() global
    ObjectReference ref = QF__Gift_09000D62.Get().Alias__DMaster.GetRef()
    if ref
        return ref as Actor
    else
        return none
    endIf
endFunction

bool function IsEnslaved() global
    return DFR_RelationshipManager.Get().IsSlave()
endFunction

bool function RuleHasTag(string[] asTags, bool abAll = false) global
    string[] rules = Adversity.GetActiveEvents("deviousfollowers", "rule")
    return Adversity.FilterEventsByTags(rules, asTags, abAll).Length > 0
endFunction

float function DaysSinceStart()
    return Utility.GetCurrentGameTime() - StorageUtil.GetFloatValue(none, "DFR_RelationshipStart")
endFunction