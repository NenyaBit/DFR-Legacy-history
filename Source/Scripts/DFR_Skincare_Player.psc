Scriptname DFR_Skincare_Player extends ReferenceAlias  

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    (GetOwningQuest() as DFR_Skincare).OnApplyLotion(akBaseObject)
endEvent