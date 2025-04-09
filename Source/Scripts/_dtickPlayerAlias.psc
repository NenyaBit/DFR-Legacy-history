Scriptname _dtickPlayerAlias Extends ReferenceAlias

Keyword property LocTypeDungeon auto
Keyword property LocTypeCity auto
Keyword property LocTypeTown auto
Keyword property LocTypeDwelling auto

QF__Gift_09000D62 property Flow auto
_DflowMCM property MCM auto
_DFGoldConQScript property GoldCont auto
_Dtick property Q auto
DFR_Outfits property Outfits auto
DFR_RelationshipManager property RelManager auto
DFR_Jobs property Jobs auto
ObjectReference property CrosshairTarget auto
DFR_Collar property Collar auto

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
        Elseif newLocation.HasKeyWord(LocTypeCity) || newLocation.HasKeyWord(LocTypeTown)
            newType = "LocT"
        Elseif newLocation.HasKeyWord(LocTypeDwelling)
            newType = "LocDw"
        EndIf

        int externalType = 0

        if Adv_LocUtils.LocationHasKwd(newLocation, LocTypeDungeon)
            externalType = 1
        elseIf Adv_LocUtils.LocationHasKwd(newLocation, LocTypeCity) || Adv_LocUtils.LocationHasKwd(newLocation, LocTypeTown)
            externalType = 2
        endIf

        CurrentLocationType.SetValue(externalType)

        DFR_Util.Log("External Location Type = " + externalType)
        
        If newType != Oldtype
            MCM.Noti(newType)
            Outfits.DelayValidationTimer()
        EndIf

        Outfits.CheckSwap()
        RelManager.OnLocationChange(newLocation)
        Jobs.OnLocationChange(newLocation)
        
        OldType = newType
    else
        if OldType != "LocW"
            OldType = "LocW"
            MCM.Noti(OldType)
        endIf

        CurrentLocationType.SetValue(0)
        RelManager.OnLocationChange(newLocation)
        Jobs.OnLocationChange(newLocation)
    endIf
EndEvent
