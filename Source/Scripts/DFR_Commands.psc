Scriptname DFR_Commands hidden

string function Enslave() global
    if DFR_API.Enslave()
        return "successful"
    else
        return "failed"
    endIf
endFunction