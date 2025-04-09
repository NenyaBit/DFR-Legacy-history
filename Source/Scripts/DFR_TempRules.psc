Scriptname DFR_TempRules extends Quest  

GlobalVariable property GameDaysPassed auto

int INTERVAL = 20

DFR_TempRules function Get() global
    return Quest.GetQuest("DFR_TempRules") as DFR_TempRules
endFunction

event OnInit()
    Maintenance()
endEvent

function Maintenance()
    RegisterForSingleUpdate(INTERVAL)
endFunction

function AddRule(string asRule, float aiTime = 1.0)
    Adversity.StartEvent(asRule)
    StorageUtil.StringListAdd(self, "DFR_ManagedRules", asRule)
    StorageUtil.SetFloatValue(self, "DFR_ExpirationDate_" + asRule, GameDaysPassed.GetValue() + aiTime)
endFunction

function RemoveRule(string asRule)
    Adversity.StopEvent(asRule)
    StorageUtil.StringListRemove(self, "DFR_ManagedRules", asRule)
    StorageUtil.UnsetFloatValue(self, "DFR_ExpirationDate_" + asRule)
endFunction

event OnUpdate()
    string[] managedRules = StorageUtil.StringListToArray(self, "DFR_ManagedRules")

    int i = 0
    while i < managedRules.length
        if StorageUtil.GetFloatValue(self, "DFR_ExpirationDate_" + managedRules[i], -1) < GameDaysPassed.GetValue()
            RemoveRule(managedRules[i])
        endIf

        i += 1
    endWhile

    RegisterForSingleUpdate(INTERVAL)
endEvent