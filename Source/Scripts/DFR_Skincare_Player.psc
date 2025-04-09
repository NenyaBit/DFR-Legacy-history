Scriptname DFR_Skincare_Player extends ReferenceAlias  

FormList property LotionList auto

event OnLoadGame()
    RemoveAllInventoryEventFilters()
    AddInventoryEventFilter(LotionList)
endEvent

event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
    (GetOwningQuest() as DFR_Skincare).OnApplyLotion(akBaseObject)
endEvent