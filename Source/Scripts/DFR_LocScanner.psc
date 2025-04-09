Scriptname DFR_LocScanner extends Quest  

Actor property PlayerRef auto

ReferenceAlias[] property DogAliases auto
ReferenceAlias[] property HorseAliases auto

Actor[] property Dogs auto hidden
Actor[] property Horses auto hidden

GlobalVariable property NumDogs auto
GlobalVariable property NumHorses auto

Cell LastCell

function Maintenance()
    PlayerRef = Game.GetPlayer()

    DogAliases = new ReferenceAlias[3]
    DogAliases[0] = GetAliasById(0) as ReferenceAlias
    DogAliases[1] = GetAliasById(2) as ReferenceAlias
    DogAliases[2] = GetAliasById(4) as ReferenceAlias

    HorseAliases = new ReferenceAlias[3]
    HorseAliases[0] = GetAliasById(1) as ReferenceAlias
    HorseAliases[1] = GetAliasById(3) as ReferenceAlias
    HorseAliases[2] = GetAliasById(5) as ReferenceAlias

    RegisterForSingleUpdate(10)
endFunction

event OnUpdate()
    Cell current = PlayerRef.GetParentCell()
    if current != LastCell
        LastCell = current
        Scan()
    endIf

    RegisterForSingleUpdate(10)
endEvent

DFR_LocScanner function Get() global
    return Quest.GetQuest("DFR_LocScanner") as DFR_LocScanner
endFunction

function Scan()
    Reset()
    Start()

    Dogs = GetActors(DogAliases)
    Horses = GetActors(HorseAliases)

    NumDogs.SetValue(Dogs.Length)
    NumHorses.SetValue(Horses.Length)
endFunction

Actor[] function GetActors(ReferenceAlias[] akAliases)
    Actor[] actors = PapyrusUtil.ActorArray(akAliases.Length)

    int i = 0
    int j = 0
    while i < akAliases.Length
        Actor ref = akAliases[i].GetRef() as Actor

        if ref
            actors[j] = ref
            j += 1
        endIf

        i += 1
    endWhile

    return PapyrusUtil.ResizeActorArray(actors, j)
endFunction