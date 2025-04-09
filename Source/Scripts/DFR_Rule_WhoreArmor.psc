Scriptname DFR_Rule_WhoreArmor extends DFR_Rule_Builtin  

function OnStart(bool abResume = false)
    Adv_OutfitManager.Get().StartValidation()
    parent.OnStart(abResume)
endFunction 

function OnStop(bool abPause = true)
    Adv_OutfitManager.Get().StopValidation()
    parent.OnStart(abPause)
endFunction