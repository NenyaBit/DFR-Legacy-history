Scriptname DFR_Licenses extends Quest conditional

Actor property PlayerRef auto
QF__Gift_09000D62 property Flow auto
Adv_LicenseUtils property Util auto
ReferenceAlias property MasterAlias auto
DFR_RelationshipManager property RelManager auto
_DFGoldConQScript property GoldControl auto

int property MinFavourRequired = 0 auto hidden conditional

GlobalVariable[] property LicenseStatuses auto

int STATUS_DISABLED_BOTH = -2
int STATUS_DISABLED_EXT = -1
int STATUS_DISABLED_INT = 0
int STATUS_ENABLED = 1

int LICENSE_TYPE_MAGIC = 0
int LICENSE_TYPE_WEAPON = 1
int LICENSE_TYPE_ARMOR = 2
int LICENSE_TYPE_BIKINI = 3
int LICENSE_TYPE_CLOTHES = 4
int LICENSE_TYPE_CURFEW = 5
int LICENSE_TYPE_WHORE = 6

bool property WaitingForRefresh = false auto hidden conditional

bool property HasGivenLicenses auto hidden conditional

bool property PrefersRegularArmor auto hidden conditional
bool property LicensesAvailable auto hidden conditional

bool property Enabled auto hidden conditional
bool property HandlingLicenses = false auto hidden conditional
bool property NeedsLicenses auto hidden conditional

float property BasePrice = 150.0 auto hidden
float property Markup = 10.0 auto hidden
int[] property DefaultStatus auto

FormList property LicensingLocations auto

Keyword[] property CityKeywords auto

DFR_Licenses function Get() global
    return Quest.GetQuest("DFR_Licenses") as DFR_Licenses
endFunction

function BeginLicensing()
    Reset()
    HandlingLicenses = true
    QueueRefresh()
endFunction

function Reset()
    HandlingLicenses = false
    PrefersRegularArmor = false
    HasGivenLicenses = false
    int i = 0
    while i < DefaultStatus.Length
        LicenseStatuses[i].SetValue(DefaultStatus[i])
        i += 1
    endWhile

    if !Util.IsEnabled(LICENSE_TYPE_BIKINI)
        LicenseStatuses[LICENSE_TYPE_ARMOR].SetValue(STATUS_ENABLED)
        LicenseStatuses[LICENSE_TYPE_BIKINI].SetValue(STATUS_DISABLED_EXT)
    endIf
endFunction

function CheckLicenseStatus()
    bool available = false
    bool needs = false

    if (RelManager.IsSlave() || GoldControl.Enabled) && PrefersRegularArmor
        ToggleArmorPreference()
    endIf

    if Util.LicensesAvailable() 
        int i = 0
        while i < LicenseStatuses.Length
            int status = LicenseStatuses[i].GetValue() as int
            bool licenseEnabled = Util.IsEnabled(i)
            bool has = Util.HasValid(i)

            if status > STATUS_ENABLED
                status = STATUS_ENABLED
            endIf
            
            if licenseEnabled
                if status == STATUS_DISABLED_EXT
                    status = STATUS_ENABLED
                endIf
            else
                if status == STATUS_ENABLED
                    status = STATUS_DISABLED_EXT
                elseIf status == STATUS_DISABLED_INT
                    status = STATUS_DISABLED_BOTH
                endIf
            endIf
    
            if status == STATUS_ENABLED && !has
                needs = true
            endIf
    
            if status > STATUS_DISABLED_EXT
                available = true
            endIf

            ;DFR_Util.Log("DFR_Licenses - CheckLicenseStatus - License " + i + " - Status = " + status + " - Enabled = " + enabled + " - Has = " + has)

            LicenseStatuses[i].SetValue(status)
    
            i += 1
        endWhile
    endIf

    LicensesAvailable = available
    NeedsLicenses = needs

    ;DFR_Util.Log("DFR_Licenses - CheckLicenseStatus - " + LicensesAvailable + " - " + NeedsLicenses)
endFunction

function ToggleArmorPreference()
    PrefersRegularArmor = !PrefersRegularArmor

    if PrefersRegularArmor && LicenseStatuses[LICENSE_TYPE_ARMOR].GetValue() == STATUS_DISABLED_INT
        LicenseStatuses[LICENSE_TYPE_ARMOR].SetValue(STATUS_ENABLED)
        LicenseStatuses[LICENSE_TYPE_BIKINI].SetValue(STATUS_DISABLED_INT)
    elseIf !PrefersRegularArmor && LicenseStatuses[LICENSE_TYPE_BIKINI].GetValue() == STATUS_DISABLED_INT
        LicenseStatuses[LICENSE_TYPE_BIKINI].SetValue(STATUS_ENABLED)
        LicenseStatuses[LICENSE_TYPE_ARMOR].SetValue(STATUS_DISABLED_INT)
    endIf

    QueueRefresh()
endFunction

function ToggleLicense(int aiType)
    int status = LicenseStatuses[aiType].GetValue() as int
    
    if status == STATUS_DISABLED_BOTH
        status = STATUS_DISABLED_EXT
    elseIf status == STATUS_DISABLED_INT
        status = STATUS_ENABLED
    elseIf status == STATUS_ENABLED
        status = STATUS_DISABLED_INT
    endIf

    LicenseStatuses[aiType].SetValue(status)
 
    if status == STATUS_ENABLED && aiType == LICENSE_TYPE_ARMOR && !PrefersRegularArmor
        LicenseStatuses[LICENSE_TYPE_BIKINI].SetValue(status)
    endIf

    if status
        QueueRefresh()
    endIf
endFunction

function RefreshLicenses()
    WaitingForRefresh = false

    DFR_Util.Log("Refreshing")

    int i = 0
    while i < LicenseStatuses.Length
        if LicenseStatuses[i].GetValue() == STATUS_ENABLED && !Util.HasValid(i)
            GiveLicense(i)
        endIf
        i += 1
    endWhile

    HasGivenLicenses = true
endFunction

function GiveLicense(int aiType)
    DFR_Util.Log("DFR_Licenses - GiveLicense - " + aiType)
    Flow.ChargeForSLSLicense(BasePrice, Markup)
    Util.Give(aiType, 0, MasterAlias.GetRef() as Actor, false)
endFunction

bool function CanRefresh()
    DFR_Util.Log("CanRefresh - " + Util.LicensesAvailable() + " - " + Adv_LocUtils.LocationHasKwds(PlayerRef.GetCurrentLocation(), CityKeywords) + " - " + LicensingLocations.Find(PlayerRef.GetParentCell()) >= 0)
    return Util.LicensesAvailable() && (Adv_LocUtils.LocationHasKwds(PlayerRef.GetCurrentLocation(), CityKeywords) || LicensingLocations.Find(PlayerRef.GetParentCell()) >= 0)
endFunction

function QueueRefresh()
    if CanRefresh()
        RefreshLicenses()
    else
        WaitingForRefresh = true
    endIf
endFunction

function TryRefresh()
    DFR_Util.Log("TryRefresh - " + WaitingForRefresh + " - " + CanRefresh())

    if WaitingForRefresh && CanRefresh()
        RefreshLicenses()
    endIf
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

bool function IsHandlingBikiniArmor()
    return Util.IsEnabled(LICENSE_TYPE_ARMOR) && !Util.HasValid(LICENSE_TYPE_ARMOR)
endFunction