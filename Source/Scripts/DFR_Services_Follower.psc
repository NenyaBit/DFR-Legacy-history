Scriptname DFR_Services_Follower extends ReferenceAlias  

event OnItemAdded(Form akBaseItem, int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
    DFR_Util.Log("Services - Follower - OnitemAdded = " + akBaseItem)

    if (GetOwningQuest() as DFR_Services).IsRunning()
        (GetOwningQuest() as DFR_Services).HandleItem(akBaseItem, aiItemCount, akItemReference)
    endIf
endEvent