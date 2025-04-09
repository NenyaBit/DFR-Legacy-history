;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 1
Scriptname DFR__QF_DFR_Skincare_0A41F5F3 Extends Quest Hidden

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE DFR_Skincare
Quest __temp = self as Quest
DFR_Skincare kmyQuest = __temp as DFR_Skincare
;END AUTOCAST
;BEGIN CODE
kmyQuest.Setup()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
