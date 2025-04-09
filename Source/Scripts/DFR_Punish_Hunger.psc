Scriptname DFR_Punish_Hunger extends DFR_FailableEvent

Keyword[] property FoodDrinkKwds auto

bool function IsValid(Actor akTarget)
    return PyramidUtils.GetItemsByKeyword(Game.GetPlayer(), FoodDrinkKwds).Length > 0
endFunction

bool function OnStart(Actor akTarget)
    Actor player = Game.GetPlayer()
    Form[] items = PyramidUtils.GetItemsByKeyword(player, FoodDrinkKwds)
    DFR_Util.Log("Punishment Hunger - " + items)

    int maxItems = DFR_RelationshipManager.Get().GetTargetSeverity() * 3

    int removed = 0
    int i = 0
    while i < items.length
        int count = player.GetItemCount(items[i])        
       
        player.RemoveItem(items[i], count)

        removed += count

        if removed >= maxItems
            i = items.Length
        endif

        i += 1
    endWhile

    PyramidUtils.RemoveForms(player, items, _DFTools.Get().ConfiscationContainer)
    
    Complete()

    return true
endFunction