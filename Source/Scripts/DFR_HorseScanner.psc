Scriptname DFR_HorseScanner extends Quest

ReferenceAlias[] property HorseAliases auto

Actor[] function Scan()
    Reset()
    Start()

    Actor[] Horses = PapyrusUtil.ActorArray(HorseAliases.length)
    int numHorses = 0

    int i = 0
    while i < HorseAliases.length
        if HorseAliases[i].GetRef()
            Horses[numHorses] = HorseAliases[i].GetRef() as Actor
            numHorses += 1
        endIf
        
        i += 1
    endWhile

    return PapyrusUtil.ResizeActorArray(Horses, numHorses)
endFunction