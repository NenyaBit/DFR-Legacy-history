Scriptname DFR_Services extends Quest conditional

Actor property PlayerRef auto

DFR_Services_Follower property FollowerAlias auto
ReferenceAlias property ServiceEvent auto
ReferenceAlias property SharpenWeapon auto

GlobalVariable property GameDaysPassed auto

Keyword[] property TownKeywords auto
Keyword[] property StaminaPotionEffectKwds auto
Keyword[] property HealthPotionEffectKwds auto
Keyword[] property MagickaPotionEffectKwds auto

int property FOOD_SERVICE_INDEX = 0 autoreadonly hidden
int property POTION_SERVICE_INDEX = 1 autoreadonly hidden
int property SHARPEN_SERVICE_INDEX = 2 autoreadonly hidden
int property ARROW_SERVICE_INDEX = 3 autoreadonly hidden

FormList[] property InventoryFilters auto
GlobalVariable[] property DesiredCounts auto
GlobalVariable[] property CurrentCounts auto

Actor property Dummy auto

Actor LastFollower
float[] property TimeToComplete auto hidden
float TimeStarted

int property Received auto hidden conditional
bool property Overdue auto hidden conditional

GlobalVariable property Variant auto

int LastIndex = 0
int BaseDamage

event OnInit()
    Maintenance()
endEvent

function Maintenance()
    float[] deadlines = Utility.CreateFloatArray(4, 8.0)
    TimeToComplete = deadlines
    
    if IsRunning()
        StartCompletionTimer(LastIndex)
    endIf

endFunction

bool function SelectService(int aiIndex)
    DFR_Util.Log("SelectService - " + aiIndex)

    if aiIndex == FOOD_SERVICE_INDEX
        Variant.SetValue(0)
    elseIf aiIndex == POTION_SERVICE_INDEX
        ; only mages will ask for mp potions, sp/hp can always be picked
        int max = 1
        Actor follower = DFR_API.GetFollower()
        string combatStyl = Adversity.GetActorString("deviousfollowers", follower, "combatStyle")
        DFR_Util.Log("Combat Style = " + combatStyl)
        if combatStyl == "magic"
            max = 2
        endIf

        Variant.SetValue(Utility.RandomInt(0, max))
    elseIf aiIndex == SHARPEN_SERVICE_INDEX
        Variant.SetValue(0)
    elseIf aiIndex == ARROW_SERVICE_INDEX
        Variant.SetValue(0)
    endIf

    return true
endFunction

bool function StartService(Actor akMaster, int aiIndex)
    DFR_Util.Log("StartService - " + akMaster + " - " + aiIndex)
    
    LastIndex = aiIndex
    
    if SetStage(10)
        Overdue = false

        LastFollower = akMaster
        TimeStarted = GameDaysPassed.GetValue()
        StartCompletionTimer(aiIndex)

        int scaleFactor = 1

        if aiIndex == ARROW_SERVICE_INDEX
            scaleFactor = 10
        endIf

        if aiIndex < DesiredCounts.Length && DesiredCounts[aiIndex]
            DesiredCounts[aiIndex].SetValue(Utility.RandomInt(1, 3) * scaleFactor)
            CurrentCounts[aiIndex].SetValue(0)

            DFR_Util.Log("StartService - " + CurrentCounts[aiIndex].GetValue() + " - " + DesiredCounts[aiIndex].GetValue())

            UpdateCurrentInstanceGlobal(DesiredCounts[aiIndex])
            UpdateCurrentInstanceGlobal(CurrentCounts[aiIndex])
        endIf

        if aiIndex == SHARPEN_SERVICE_INDEX
            PlayerRef.AddItem(SharpenWeapon.GetRef())
        endIf
        
        SetObjectiveCompleted(GetObjectiveIndex(aiIndex), false)
        SetObjectiveDisplayed(GetObjectiveIndex(aiIndex))
        return true
    endIf 

    return false
endFunction

function StartCompletionTimer(int aiIndex)
    UnregisterForUpdateGameTime()
    float timeLeft = TimeToComplete[aiIndex] -  (GameDaysPassed.GetValue() - TimeStarted)
    DFR_Util.Log("Services - TimeLeft = " + timeLeft)
    if timeLeft > 0
        RegisterForSingleUpdateGameTime(timeLeft)
    else
        SetOverdue()
    endIf
endFunction

function OpenGiftMenu(int aiIndex)
    Received = 0
    if aiIndex == SHARPEN_SERVICE_INDEX
        if PyramidUtils.GetTemperFactor(PlayerRef, SharpenWeapon.GetRef().GetBaseObject() as Weapon)
            Received = 1
        endIf
    endIf

    LastIndex = aiIndex
    FormList filter = InventoryFilters[aiIndex]

    RegisterForMenu("GiftMenu")
    (FollowerAlias.GetRef() as Actor).ShowGiftMenu(true, filter, true, false)

    Utility.Wait(0.2)
endFunction

event OnMenuClose(string asMenu)
    UnregisterForMenu("GiftMenu")
endEvent

function HandleItem(Form akItem, int aiCount, ObjectReference akRef)
    if LastIndex == FOOD_SERVICE_INDEX
        Received = 1
    elseIf LastIndex == POTION_SERVICE_INDEX
        if IsCorrectPotionType(akItem)
            Received = 1
        endIf
    elseIf LastIndex == SHARPEN_SERVICE_INDEX
        if SharpenWeapon.GetRef() == akRef
            if Received
                Received = 1
            endIf
        else
            Received = -1
        endIf
    elseIf LastIndex == ARROW_SERVICE_INDEX
        Received = 1
    endIf

    DFR_Util.Log("Received " + akItem + " count = " + aiCount + " - " + Received)

    ObjectReference akTransferTo = PlayerRef
    if Received && LastIndex < CurrentCounts.Length && CurrentCounts[LastIndex]
        ModObjectiveGlobal(aiCount, CurrentCounts[LastIndex], GetObjectiveIndex(LastIndex), DesiredCounts[LastIndex].GetValue())
        akTransferTo = none ; if correct, we remove the items immediately to prevent player from stealing back
    else
        SetObjectiveCompleted(GetObjectiveIndex(LastIndex))
    endIf

    Form moveItem = akItem
    if akRef
        moveItem = akRef
    endIf
    FollowerAlias.GetRef().RemoveItem(moveItem, aiCount, false, akTransferTo)
endFunction

bool function IsCorrectPotionType(Form akItem)
    int potionType = Variant.GetValue() as int

    Keyword[] targetkwds = HealthPotionEffectKwds

    if potionType == 1
        targetkwds = StaminaPotionEffectKwds
    elseIf potionType == 2
        targetkwds = MagickaPotionEffectKwds
    endIf

    Potion pot = akItem as Potion
    if pot
        if StringUtil.Find(pot.GetName(), " Cum") != -1
            return false
        endIf

        MagicEffect[] effects = pot.GetMagicEffects()
        int i = 0
        while i < effects.length
            if PyramidUtils.FormHasKeyword(effects[i], targetkwds)
                return true
            endIf

            i += 1
        endWhile
    endIf

    return false
endFunction

int function GetObjectiveIndex(int aiServiceIndex)
    return ((aiServiceIndex + 1) * 10) + Variant.GetValue() as int
endFunction

function CompleteService(int aiIndex)
    SetObjectiveDisplayed(GetObjectiveIndex(aiIndex), false)
    Stop()
    Reset()
    GetEventScr(aiIndex).Complete()
endFunction

event OnUpdateGameTime()
    SetOverdue()
endEvent

function SetOverdue()
    if !IsRunning()
        return
    endIf
    
    DFR_Util.Log("Services - Overdue")

    Overdue = true
endFunction

function Fail()
    SetObjectiveDisplayed(GetObjectiveIndex(LastIndex), false)
    Stop()
    Reset()
    GetEventScr(LastIndex).Fail()
    Reset()
endFunction

DFR_FailableEvent function GetEventScr(int aiIndex)
    if (ServiceEvent as DFR_Event_Food).IsActive()
        return (ServiceEvent as DFR_Event_Food)
    endIf

    if (ServiceEvent as DFR_Event_Potions).IsActive()
        return (ServiceEvent as DFR_Event_Potions)
    endIf

    if (ServiceEvent as DFR_Event_Sharpen).IsActive()
        return (ServiceEvent as DFR_Event_Sharpen)
    endIf

    if (ServiceEvent as DFR_Event_Arrows).IsActive()
        return (ServiceEvent as DFR_Event_Arrows)
    endIf

    return none
endFunction