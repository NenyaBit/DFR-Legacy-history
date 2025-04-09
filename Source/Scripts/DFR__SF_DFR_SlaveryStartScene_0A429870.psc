;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 2
Scriptname DFR__SF_DFR_SlaveryStartScene_0A429870 Extends Scene Hidden

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
DFR_Util.Log("Slavery Intro Start")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
DFR_Util.Log("Slavery Intro End")
DFR_RelationshipManager.Get().CompleteSlaverySetup()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
