Scriptname DFR_Licenses extends Quest conditional

Actor property PlayerRef auto
QF__Gift_09000D62 property Flow auto
Adv_LicenseUtils property Util auto
ReferenceAlias property MasterAlias auto
DFR_RelationshipManager property RelManager auto

; Status: -2 = disabled both, -1 = disabled external, 0 = disabled internal, 1 = enabled
GlobalVariable[] property LicenseStatuses auto
bool property PrefersRegularArmor auto hidden conditional
bool property LicensesAvailable auto hidden conditional

float property BasePrice = 150.0 auto hidden
float[] property Markups auto
int[] property DefaultStatus auto

bool property HandlingLicenses = false auto hidden conditional
bool property CanGiveLicenses auto hidden conditional
bool property NeedsLicenses auto hidden conditional

FormList property LicensingLocations auto

Keyword[] property CityKeywords auto

bool Blocked = false
bool Initialized = false

DFR_Licenses function Get() global
    return Quest.GetQuest("DFR_Licenses") as DFR_Licenses
endFunction

function Maintenance()
    DFR_Util.Log("DFR_Licenses - Maintenance")
    Initialized = false
    RegisterForSingleUpdate(5.0)
endFunction

event OnUpdate()
    UpdateLicenses()
endEvent

function UpdateLicenses()
    if !Blocked && !Initialized
        Initialized = true
        LoadBarracks()
        CheckLicenseStatus()
    elseIf !Blocked && Initialized
        RefreshLicenses()
    endIf
endFunction

function BeginLicensing()
    HandlingLicenses = true
    if CanGiveLicenses
        RefreshLicenses()
    endIf
endFunction

function Reset()
    HandlingLicenses = false
    PrefersRegularArmor = false
    int i = 0
    while i < DefaultStatus.Length
        LicenseStatuses[i].SetValue(DefaultStatus[i])
        i += 1
    endWhile
    CheckLicenseStatus()
endFunction

function CheckLicenseStatus()
    CanGiveLicenses = CanRefresh()
    bool available = false
    bool needs = false

    if Util.LicensesAvailable() 
        int i = 0
        while i < LicenseStatuses.Length
            int status = LicenseStatuses[i].GetValue() as int
            bool enabled = Util.IsEnabled(i)
            bool has = Util.HasValid(i)
            
            if enabled
                if status == -1
                    status = 1
                endIf
            else
                if status == 1
                    status = -1
                elseIf status == 0
                    status = -2
                endIf
            endIf
    
            if RelManager.IsSlave()
                if i == 2 && status == 1 ; disable regular armour
                    PrefersRegularArmor = false
                    status = 0
                endIf

                if i == 3 && status == 0 ; enable bikini armour
                    status = 1
                endIf
            endIf
    
            if status == 1 && !has
                needs = true
            endIf
    
            if status > -1
                available = true
            endIf

            if has && status == 1
                status = 2
            endIf

            ;DFR_Util.Log("DFR_Licenses - CheckLicenseStatus - License " + i + " - Status = " + status + " - Enabled = " + enabled + " - Has = " + has)

            LicenseStatuses[i].SetValue(status)
    
            i += 1
        endWhile
    endIf

    LicensesAvailable = available
    NeedsLicenses = needs
   
    ;DFR_Util.Log("DFR_Licenses - CheckLicenseStatus - LicensesAvailable = " + LicensesAvailable + " NeedsLicenses = " + NeedsLicenses + " CanGiveLicenses = " + CanGiveLicenses)
endFunction

function ToggleArmorPreference()
    PrefersRegularArmor = !PrefersRegularArmor

    if PrefersRegularArmor
        LicenseStatuses[2].SetValue(1)
        LicenseStatuses[3].SetValue(0)
    elseIf !PrefersRegularArmor
        LicenseStatuses[2].SetValue(1)
        LicenseStatuses[3].SetValue(0)
    endIf
endFunction

function ToggleLicense(int aiType)
    Blocked = true

    int status = LicenseStatuses[aiType].GetValue() as int
    
    if status == -2
        status = -1
    elseIf status == 0
        status = 1
    elseIf status == 1 || status == 2
        status = 0
    endIf

    if status == 1 && aiType == 2 && !PrefersRegularArmor
        aiType = 3
    endIf

    LicenseStatuses[aiType].SetValue(status)
    
    if status == 0
        if aiType == 2
            LicenseStatuses[3].SetValue(status)
        elseIf aiType == 3
            LicenseStatuses[2].SetValue(status)
        endIf
    endIf

    Blocked = false
endFunction

function RefreshLicenses()
    if Blocked || !HandlingLicenses || !MasterAlias.GetRef() || !CanRefresh() || (RelManager.IsSlave() && RelManager.Favour < 50)
        return
    endIf

    Blocked = true
    int i = 0
    while i < LicenseStatuses.Length
        if LicenseStatuses[i].GetValue() == 1 && !Util.HasValid(i)
            GiveLicense(i)
        endIf
        i += 1
    endWhile
    CheckLicenseStatus()
    Blocked = false
endFunction

function GiveLicense(int aiType)
    DFR_Util.Log("DFR_Licenses - GiveLicense - " + aiType)
    Flow.ChargeForSLSLicense(BasePrice, Markups[aiType])
    Util.Give(aiType, 0, MasterAlias.GetRef() as Actor, false)
endFunction

bool function CanRefresh()
    return Util.LicensesAvailable() && (Adv_LocUtils.LocationHasKwds(PlayerRef.GetCurrentLocation(), CityKeywords) || LicensingLocations.Find(PlayerRef.GetParentCell()) >= 0)
endFunction

function LoadBarracks()
    LicensingLocations.Revert()

    Form[] locations = New Form[5]
    locations[0] = Game.GetForm(0x00016DF4) ; Markarth
    locations[1] = Game.GetForm(0x00045A1D) ; Riften
    locations[2] = Game.GetForm(0x000213A0) ; Solitude
    locations[3] = Game.GetForm(0x000580A2) ; Whiterun
    locations[4] = Game.GetForm(0x0001677A) ; Windhelm
    
    int i = 5
    while i
        i -= 1
        Form loc = locations[i]
        If loc
            LicensingLocations.AddForm(loc)
        EndIf
    EndWhile
endFunction