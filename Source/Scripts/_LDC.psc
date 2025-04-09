Scriptname _LDC extends Quest

;/
Note for Future Readers:

This was originally a script created by lozeak for generalised DD usage. Since DF is basically the only mod that actually
leverages this script, I've rewritten and specialised it. For the most part, you should just use the new native functions 
present in DD NG rather than trying to model your approach after this script or the original. 

- ponzi
/;

zadlibs Property libs auto

function Init()
	if !libs
		libs = Quest.GetQuest("zadQuest") as zadLibs
	endIf
endFunction

_LDC function Get() global
	return Quest.GetQuest("DFR_DeviceController") as _LDC
endFunction

Armor function GetGenericDeviceByKeyword(Actor akActor, Keyword kw)
	if akActor.WornHasKeyword(kw)
		return none
	endIf

	Keyword[] kwds = new Keyword[1]
	kwds[0] = kw

	Form[] items = PyramidUtils.GetItemsByKeyword(akActor, kwds)
	DFR_Util.Log("Found - " + items + " - " + kwds)

	if items.length
		Armor existing = items[0] as Armor
		DFR_Util.Log("Existing - " + existing)
		if existing
			Armor inventory = zadNativeFunctions.GetInventoryDevice(items[0] as Armor)
			DFR_Util.Log("Inventory - " + inventory)
			if inventory
				DFR_Util.Log("Found existing " + inventory)
				return inventory
			endIf
		endIf
	endIf

	Armor[] options = Adversity.GetDevicesByKeyword("deviousfollowers", Game.GetPlayer(), kw)

	Armor chosen = none
	if options.length > 0
		chosen = options[Utility.RandomInt(0, options.length - 1)]
	endIf

	_DUtil.Info("DF - GetGenericDeviceByKeyword - chosen = " + chosen)

	return chosen
endFunction

function EquipDeviceByKeyword(Keyword kw, Actor akActor = none)
	If akActor == none
		akActor = libs.playerref
	Endif

	Armor device = GetGenericDeviceByKeyword(akActor, kw)
	_DUtil.Info("DF - EquipDeviceByKeyword - " + device)

	if device
		libs.LockDevice(akActor, device)
	endIf
endFunction

function ForceEquipDeviceByKeyword(Keyword kw,Actor akActor = none)
	If akActor == none
		akActor = libs.playerref
	Endif

	Armor device = GetGenericDeviceByKeyword(akActor, kw)
	_DUtil.Info("DF - ForceEquipDeviceByKeyword - " + device)

	if device
		libs.LockDevice(akActor, device, true)
	endIf
endFunction

function AddDeviceByKeyword(Keyword kw,Actor akActor = none)
	If akActor == none
		akActor = libs.playerref
	Endif

	Armor device = GetGenericDeviceByKeyword(akActor, kw)
	_DUtil.Info("DF - AddDeviceByKeyword - " + device)

	if device
		akActor.AddItem(device)
	endIf
endFunction

bool function RemoveDeviceByKeyword(Keyword kw, Actor akActor= none)
	return RemoveDevice(kw, akActor, false)
endFunction

bool function RemoveAndDestroyDeviceByKeyword(Keyword kw, Actor akActor = none)
	return RemoveDevice(kw, akActor, true)
endFunction

bool function RemoveDevice(Keyword kw, Actor akActor = none, bool abDestroy)
	If akActor == none
		akActor = libs.playerref
	Endif

	Armor device = libs.GetWornDeviceFuzzyMatch(akActor, kw)
	_DUtil.Info("DF - RemoveDevice - " + device)

	if device
		return libs.UnlockDevice(akActor, device, destroyDevice = abDestroy)
	endIf
endFunction

function EquipCuffs()
	EquipDeviceByKeyword(libs.zad_DeviousArmCuffs)
	EquipDeviceByKeyword(libs.zad_DeviousLegCuffs)
endFunction

function EquipBlindfold()
	EquipDeviceByKeyword(libs.zad_DeviousBlindfold)
endFunction

function EquipCollar()
	DFR_Util.Log("EquipCollar")
	EquipDeviceByKeyword(libs.zad_DeviousCollar)
endFunction

function EquipGag()
	EquipDeviceByKeyword(libs.zad_DeviousGag)
endFunction

function EquipNPiercings()
	EquipDeviceByKeyword(libs.zad_DeviousPiercingsNipple)
endFunction

function EquipVPiercings()
	EquipDeviceByKeyword(libs.zad_DeviousPiercingsVaginal)
endFunction

function EquipGloves()
	EquipDeviceByKeyword(libs.zad_DeviousGloves)
endFunction

function EquipBoots()
	EquipDeviceByKeyword(libs.zad_DeviousBoots)
endFunction