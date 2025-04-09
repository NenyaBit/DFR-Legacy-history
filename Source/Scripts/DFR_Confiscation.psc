Scriptname DFR_Confiscation extends Quest conditional

Actor property PlayerRef auto
GlobalVariable property GameDaysPassed auto

; used for temporary confiscation i.e. for rule enforcement
ObjectReference property TempConfiscationContainer auto
int property NumTempConfiscated = 0 auto hidden conditional

; configuration
bool Enabled_var = true
bool property Enabled
    bool function Get()
        return Enabled_var
    endFunction

    function Set(bool abValue)
        Enabled_var = abValue
        if !abValue && NumTempConfiscated
            ReturnItems()
        endIf
    endFunction
endProperty
float property ReturnDelayMin = 1.0 auto hidden
float property ReturnDelayMax = 3.0 auto hidden
float property ReturnTimer = 0.0 auto hidden conditional
int property MinFavourRequired = 0 auto hidden conditional

DFR_Confiscation function Get() global
    return Quest.GetQuest("DFR_Confiscation") as DFR_Confiscation
endFunction

function TakeClothing(ObjectReference akContainer = none, bool abExcludeFootwear = true)
    if !akContainer
        akContainer = TempConfiscationContainer
    endIf

    DFR_Util.Log("ConfiscateClothing - START")

    Keyword[] clothingKwds = new Keyword[4]
    clothingKwds[0] = Keyword.GetKeyword("ArmorClothing")
    clothingKwds[1] = Keyword.GetKeyword("ArmorLight")
    clothingKwds[2] = Keyword.GetKeyword("ArmorHeavy")
    clothingKwds[4] = Keyword.GetKeyword("VendorItemArmor")

    Keyword[] excludeKwds = new Keyword[8]
    excludeKwds[0] = Keyword.GetKeyword("Adv_RuleItemKwd")
    excludeKwds[1] = Keyword.GetKeyword("Adv_OutfitItemKwd")
    excludeKwds[2] = Keyword.GetKeyword("SexlabNoStrip")
    excludeKwds[3] = Keyword.GetKeyword("zad_Lockable")
    excludeKwds[4] = Keyword.GetKeyword("zad_InventoryDevice")
    excludeKwds[5] = Keyword.GetKeyword("zad_DeviousPlug")

    if abExcludeFootwear
        excludeKwds[6] = Keyword.GetKeyword("ClothingFeet")
        excludeKwds[7] = Keyword.GetKeyword("ArmorBoots")
    endIf

    Form[] clothing = PyramidUtils.GetItemsByKeyword(PlayerRef, clothingKwds)
    DFR_Util.Log("ConfiscateClothing - 1 - " + clothing)
    clothing = PyramidUtils.FilterFormsByKeyword(clothing, excludeKwds, abInvert = true)
    DFR_Util.Log("ConfiscateClothing - 2 - " + clothing)

    DFR_Util.Log("ConfiscateClothing - END - " + clothing)
    int count = PyramidUtils.RemoveForms(PlayerRef, clothing, akContainer)
    NumTempConfiscated += count
    
    if count
        ReturnTimer = GameDaysPassed.GetValue() + Utility.RandomFloat(ReturnDelayMin, ReturnDelayMax)
    endIf
endFunction

function ReturnItems()
    TempConfiscationContainer.RemoveAllItems(PlayerRef)
    NumTempConfiscated = 0
    ReturnTimer = 0.0
endFunction
