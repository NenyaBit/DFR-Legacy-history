Scriptname _dtickPlayerAlias Extends ReferenceAlias

Keyword property LocTypeDungeon auto
Keyword property LocTypeCity auto
Keyword property LocTypeTown auto
Keyword property LocTypeDwelling auto

_DflowMCM property MCM auto
_DFGoldConQScript property GoldCont auto
_Dtick property Q auto
DFR_Outfits property Outfits auto
ObjectReference property CrosshairTarget auto

; 0 = wilderness, 1 = dungeon, 2 = city/town - unlike LocType kwds this will work even while in interior locations
GlobalVariable property CurrentLocationType auto 


String OldType

Event OnPlayerLoadGame()
    ; Re-init _Dtick on game load
	Q.Init()
EndEvent

Function AddEventRegistrations()
	RegisterForCrosshairRef()
EndFunction
 
Event OnCrosshairRefChange(ObjectReference ref)
    CrosshairTarget = ref
EndEvent


Event OnLocationChange(Location OldLocation, Location newLocation)
    DFR_Util.Log("_DTickPlayerAlias - OnLocationChange - " + OldLocation + " - " + newLocation)
    If newLocation
        GoldCont.Recalc()

        String newType = "LocW"
        int type = 0
        
        If newLocation.HasKeyWord(LocTypeDungeon)
            newType = "LocD"
            type = 1
        Elseif newLocation.HasKeyWord(LocTypeCity) || newLocation.HasKeyWord(LocTypeTown)
            newType = "LocT"
            type = 2
        Elseif newLocation.HasKeyWord(LocTypeDwelling)
            newType = "LocDw"
            
             ; if it's a dwelling, we must have come from some exterior cell so use that last value
            type = CurrentLocationType.GetValue() as int
        EndIf

        CurrentLocationType.SetValue(type)

        If newType != Oldtype
            MCM.Noti(newType)
            Outfits.DelayValidationTimer()
        EndIf

        Outfits.CheckSwap()
        
        OldType = newType
    EndIf
    
EndEvent
