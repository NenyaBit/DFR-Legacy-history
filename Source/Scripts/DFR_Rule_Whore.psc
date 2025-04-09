Scriptname DFR_Rule_Whore extends Adv_EventBase  

_DDeal property Deal auto

Actor property PlayerRef auto
ReferenceAlias property MasterAlias auto

_DFtools property Tool auto

ReferenceAlias property DealPlayerDummy auto
ReferenceAlias property DealMaster auto

Armor property SignPlug auto

zadLibs property Libs auto

bool function OnStart(Actor akTarget)
    DealPlayerDummy.ForceRefTo(Tool.PC)
    DealMaster.ForceRefTo(MasterAlias.GetRef())

    Deal.DelayHrs(6.0)
    
    if DFR_RelationshipManager.Get().IsSlave()
        Libs.LockDevice(PlayerRef, SignPlug)
    else
        PlayerRef.AddItem(SignPlug)
    endIf

    return true
endFunction 

function OnStop()
    Libs.UnlockDevice(PlayerRef, SignPlug, destroyDevice = true)
endFunction