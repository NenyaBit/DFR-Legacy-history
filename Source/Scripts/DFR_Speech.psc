Scriptname DFR_Speech extends Quest  

GlobalVariable property GameDaysPassed auto
GlobalVariable property FGDelay auto

Actor Speaker

DFR_Speech function Get() global
    return Quest.GetQuest("DFR_Speech") as DFR_Speech
endFunction

function Maintenance()
    DFR_Util.Log("Speech - Maintenance")
    RegisterForMenu("Dialogue Menu")
endFunction

event OnMenuOpen(string asMenu)
    DFR_Util.Log("Speech - OnMenuOpen")
    UnregisterForUpdate()
    FGDelay.SetValue(1)
endEvent

event OnMenuClose(string asMenu)
    DFR_Util.Log("Speech - OnMenuClose")

    Speaker = PyramidUtils.GetPlayerSpeechTarget()

    while PyramidUtils.GetPlayerSpeechTarget()
        Utility.Wait(0.1)
    endWhile

    while Speaker && Speaker.GetDialogueTarget()
        Utility.Wait(0.1)
    endWhile

    while Speaker && Speaker.IsInDialogueWithPlayer()
        Utility.Wait(0.1)
    endWhile

    RegisterForSingleUpdate(5.0)
endEvent

event OnUpdate()
    DFR_Util.Log("Speech - OnUpdate")
    FGDelay.SetValue(0)
endEvent

function WaitForTimer()
    while FGDelay.GetValue()
        Utility.Wait(1.0)
    endWhile
endFunction