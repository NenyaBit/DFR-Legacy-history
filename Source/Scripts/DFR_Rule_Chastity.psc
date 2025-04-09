Scriptname DFR_Rule_Chastity extends Adv_EventBase  

Actor property PlayerRef auto
Armor property OpenBelt auto
_DDeal property Deal auto

bool function OnStart(Actor akTarget)
    (GetOwningQuest() as _DFlowModDealController).EquipOrLockDevice(OpenBelt)
    Deal.DelayDaysRange(2, 5)
    Deal.Triggered = false
    return true
endFunction 

function OnStop()
    (GetOwningQuest() as _DFlowModDealController).Tool.LDC.libs.UnlockDevice(PlayerRef, OpenBelt, destroyDevice = true)
endFunction