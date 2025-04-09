Scriptname DFR_Comments extends Quest conditional

GlobalVariable property GameDaysPassed auto
float property Timer auto hidden conditional

function DelayTimer()
    Timer = GameDaysPassed.GetValue() + Utility.RandomInt(2, 3) * 0.04
endFunction

