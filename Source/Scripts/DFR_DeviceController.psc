Scriptname DFR_DeviceController extends Quest  

Actor property PlayerRef auto
zadLibs property Libs auto
QF__Gift_09000D62 property Flow auto
GlobalVariable property Lives auto
GlobalVariable property RemovalPrice auto
MiscObject property Gold auto

GlobalVariable[] property RemovalBlocked auto ; 0 = allowed, 1 = blocked (generic), 2 = blocked (deal)

DFR_DeviceController function Get() global
    return Quest.GetQuest("DFR_DeviceController") as DFR_DeviceController
endFunction

Function PriceUpdate()
    Flow.PriceUpdate()
EndFunction

function BlockRemoval(int aiCode, string asSource, int aiType = 0)
    if StorageUtil.StringListAdd(self, "DeviceBlockers" + aiCode, asSource, false) >= 0
        StorageUtil.SetIntValue(self, "DeviceBlockers" + aiCode, StorageUtil.GetIntValue(self, "DeviceBlockers" + aiCode) + aiType)
        StorageUtil.IntListAdd(self, "DeviceBlockers" + aiCode, aiType)
        int status = RemovalBlocked[aiCode].GetValue() as int
        if aiCode
            status = 2
        elseIf status < 2
            status = 1
        endIf
        RemovalBlocked[aiCode].SetValue(status)
    endIf
endFunction

function AllowRemoval(int aiCode, string asSource)
    int index = StorageUtil.StringListFind(self, "DeviceBlockers" + aiCode, asSource)

    if index >= 0 && StorageUtil.StringListRemove(self, "DeviceBlockers" + aiCode, asSource, true)
        StorageUtil.SetIntValue(self, "DeviceBlockers" + aiCode, StorageUtil.GetIntValue(self, "DeviceBlockers" + aiCode) - StorageUtil.IntListGet(self, "DeviceBlockers" + aiCode, index))
        StorageUtil.IntListRemoveAt(self, "DeviceBlockers" + aiCode, index)

        int status
        if StorageUtil.StringListCount(self, "DeviceBlockers" + aiCode)
            if StorageUtil.GetIntValue(self, "DeviceBlockers" + aiCode)
                status = 2
            else
                status = 1
            endIf
        else
            status = 0
        endIf

        RemovalBlocked[aiCode].SetValue(status)
    endIf
endFunction

function PrepDealRemoval(int aiCode)
    ((Flow as Quest) as _DFlowProps).ItemToRemove = aiCode + 1
endFunction

function Remove(int aiCode)
    Keyword kwd = DeviceCodeToKeyword(aiCode)
    if kwd && Libs.UnlockDeviceByKeyword(PlayerRef, kwd)
        if PlayerRef.GetItemCount(Gold) >= RemovalPrice.GetValue()
            Flow.DeviceRemovalGold()
        else
            Flow.DeviceRemovalDebt()
        endIf
        if Lives.GetValue() > 0
            Lives.Mod(-1)
        endIf
    else
        Debug.Notification("$DFNOTREMOVED")
    endIf
endFunction

Keyword function DeviceCodeToKeyword(int aiCode)
    if aiCode == 0
        return Libs.zad_DeviousBlindfold
    elseIf aiCode == 1
        return Libs.zad_DeviousBoots
    elseIf aiCode == 2
        return Libs.zad_DeviousCollar
    elseIf aiCode == 3
        return Libs.zad_DeviousGag
    elseIf aiCode == 4
        return Libs.zad_DeviousGloves
    elseIf aiCode == 5
        return Libs.zad_DeviousHeavyBondage
    endIf

    return none
endFunction