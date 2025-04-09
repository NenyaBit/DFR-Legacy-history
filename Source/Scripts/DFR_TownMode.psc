;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 9
Scriptname DFR_TownMode Extends Quest Hidden

;BEGIN ALIAS PROPERTY CurrentCity
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_CurrentCity Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY master
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_master Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Player
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_Player Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY HoldTown
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_HoldTown Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY CurrentTown
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_CurrentTown Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY InnCenterMarker
;ALIAS PROPERTY TYPE ReferenceAlias
ReferenceAlias Property Alias_InnCenterMarker Auto
;END ALIAS PROPERTY

;BEGIN ALIAS PROPERTY Inn
;ALIAS PROPERTY TYPE LocationAlias
LocationAlias Property Alias_Inn Auto
;END ALIAS PROPERTY

;BEGIN FRAGMENT Fragment_1
Function Fragment_1()
;BEGIN CODE
Log("Reached")
SetObjectiveCompleted(2)
StayScene.Start()
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_6
Function Fragment_6()
;BEGIN CODE
Location inn = Alias_Inn.GetLocation()
Location holdTown = Alias_HoldTown.GetLocation()
Location city = Alias_CurrentCity.GetLocation()
Location town = Alias_CurrentTown.GetLocation()

Location leashLoc

if inn.IsSameLocation(holdTown, Keyword.GetKeyword("LocTypeInn")) || inn.IsSameLocation(holdTown, Keyword.GetKeyword("LocTypeCity"))
	leashLoc = holdTown
endIf

if inn.IsSameLocation(city, Keyword.GetKeyword("LocTypeCity"))
	leashLoc = city
endIf

if inn.IsSameLocation(city, Keyword.GetKeyword("LocTypeTown"))
	leashLoc = town
endIf

Log("In Town - Leashing = " + leashLoc)

Collar.RestrictLocation(leashLoc)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0()
;BEGIN CODE
Log("Go to town")
SetObjectiveDisplayed(2)
Collar.SetTargetRef(Alias_InnCenterMarker.GetRef())
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_7
Function Fragment_7()
;BEGIN CODE
Log("Startup -  Town/City = " +  PO3_SKSEFunctions.GetFormEditorID(Alias_HoldTown.GetLocation()) + " -  City  = " + PO3_SKSEFunctions.GetFormEditorID(Alias_CurrentCity.GetLocation()) + " -  Town = " + PO3_SKSEFunctions.GetFormEditorID(Alias_CurrentTown.GetLocation()) + " -  Inn = " + PO3_SKSEFunctions.GetFormEditorID(Alias_Inn.GetLocation()) + " - Marker = "  + PO3_SKSEFunctions.GetFormEditorID(Alias_InnCenterMarker.GetRef()))
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_5
Function Fragment_5()
;BEGIN CODE
Log("Waiting")
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3()
;BEGIN CODE
Log("Stopping")
Collar.ResetAll()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

DFR_Collar Property Collar  Auto  

function Log(string asMsg)
    DFR_Util.Log("Town Mode - " + asMsg)
endFunction

Scene Property StayScene  Auto  
