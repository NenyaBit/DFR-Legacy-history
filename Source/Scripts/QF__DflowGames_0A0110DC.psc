;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 0
Scriptname QF__DflowGames_0A0110DC Extends Quest Hidden

;BEGIN ALIAS PROPERTY SceneYOU
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_SceneYOU Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Follower
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Follower Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Jarl
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Jarl Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_12
Function Fragment_12()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_16
Function Fragment_16()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_8
Function Fragment_8()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_20
Function Fragment_20()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_11
Function Fragment_11()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_10
Function Fragment_10()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_15
Function Fragment_15()
;BEGIN CODE
;CODE NOT LOADED
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Function AdvanceCommentTimer(Float seconds)

    seconds /= (86400.0/20.0) ; Convert seconds to game time in days... at 20x normal time-rate ... would be better if I got the time rate properly ... but even then player can change before timer is used.
    Float current = _DFGameCommentTimer.GetValue()
    Float now = Utility.GetCurrentGameTime()
    Float offset = now - current
    Float adjustBy = seconds + offset
    
    ; While the Get above defeats atomicity, I'm hoping this call will ensure that other code gets the updated value and doesn't hold onto the old one.
    _DFGameCommentTimer.Mod(adjustBy)

EndFunction

Armor Property HI  Auto  

Armor Property HR  Auto  

Armor Property HGI  Auto  

Armor Property HGR  Auto  

Armor Property HTI  Auto  

Armor Property HTR  Auto  
  

Armor Property HarnR  Auto  

Armor Property HarnI  Auto  

Armor Property CollarR  Auto  

Armor Property CollarI  Auto  
Armor Property BinderR  Auto  

Armor Property BinderI  Auto  
Armor Property HOOFR  Auto  

Armor Property HOOFI  Auto  

zadlibs Property  libs Auto  

actor Property Playerref auto

keyword Property zad_lockable auto

Quest Property Q  Auto  
QF__Gift_09000D62 Property QQ auto
  

zadxlibs2 Property xlibs2  Auto  

; this simply didn't work... tests seemed to use old stale values. Possibly caused by script missing Conditional tag.
; Wrote global replacement before noticing the likely error/cause.
Float Property CommentTimer  Auto  Conditional

GlobalVariable Property _DFGameCommentTimer Auto

