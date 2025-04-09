Scriptname DFR_DogScanner extends Quest  

ReferenceAlias[] property DogAliases auto

Actor[] function Scan()
    Reset()
    Start()

    Actor[] dogs = PapyrusUtil.ActorArray(DogAliases.length)
    int numDogs = 0

    int i = 0
    while i < DogAliases.length
        if DogAliases[i].GetRef()
            dogs[numDogs] = DogAliases[i].GetRef() as Actor
            numDogs += 1
        endIf
        
        i += 1
    endWhile


    return PapyrusUtil.ResizeActorArray(dogs, numDogs)
endFunction