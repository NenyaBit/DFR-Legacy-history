;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname DFR__QF_DFR_BQ01_0A433A88 Extends Quest Hidden

;BEGIN ALIAS PROPERTY BountyLocation
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_BountyLocation Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY QuestGiver
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_QuestGiver Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Innkeeper
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Innkeeper Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Steward
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Steward Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY master
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_master Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN AUTOCAST TYPE DFR_BQ01
Quest __temp = self as Quest
DFR_BQ01 kmyQuest = __temp as DFR_BQ01
;END AUTOCAST
;BEGIN CODE
kmyQuest.OnStart()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN AUTOCAST TYPE DFR_BQ01
Quest __temp = self as Quest
DFR_BQ01 kmyQuest = __temp as DFR_BQ01
;END AUTOCAST
;BEGIN CODE
kmyQuest.OnSetup()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN AUTOCAST TYPE DFR_BQ01
Quest __temp = self as Quest
DFR_BQ01 kmyQuest = __temp as DFR_BQ01
;END AUTOCAST
;BEGIN CODE
kmyQuest.OnStop()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_2
Function Fragment_2()
;BEGIN AUTOCAST TYPE DFR_BQ01
Quest __temp = self as Quest
DFR_BQ01 kmyQuest = __temp as DFR_BQ01
;END AUTOCAST
;BEGIN CODE
kmyQuest.OnComplete()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
