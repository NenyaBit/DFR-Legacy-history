Scriptname DFR_Punish_Hunger extends Adv_EventBase

Keyword[] property FoodDrinkKwds auto

bool function IsValid(Actor akTarget)
    return PyramidUtils.GetItemsByKeyword(Game.GetPlayer(), FoodDrinkKwds).Length > 0
endFunction

bool function OnStart(Actor akTarget)
    Actor player = Game.GetPlayer()
    Form[] items = PyramidUtils.GetItemsByKeyword(player, FoodDrinkKwds)
    DFR_Util.Log("Punishment Hunger - " + items)
    PyramidUtils.RemoveForms(player, items, _DFTools.Get().ConfiscationContainer)
    Stop()
    return true
endFunction