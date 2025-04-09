Scriptname DFR_CenterMarkerScanner extends Quest  

ReferenceAlias property CenterMarkerAlias auto

DFR_CenterMarkerScanner function Get() global
    return Quest.GetQuest("DFR_CenterMarkerScanner") as DFR_CenterMarkerScanner
endFunction

ObjectReference function Scan()
    Reset()
    Start()
    return CenterMarkerAlias.GetRef()
endFunction