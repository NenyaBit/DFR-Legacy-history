Scriptname _DFlowFollowerEvents extends ReferenceAlias  

Event OnEnterBleedout()
	Run = True
	Utility.Wait(4)
	if Run 
		Run = False
		if (Q.Getstage() < 100 && Q.Getstage() >= 10)
			GoldCon.FollowerKnockeddown()
			If  Lives.GetValue() as int > 0
				INT a = Lives.getvalue() as INT  - 1
				Lives.SetValue(a)  
			Else
						q.PunDebt()
				int temp = Utility.RandomInt(1,10)
				if temp >=4
				MCM.noti("NoL")
				endif
			endif
		endif
	endif
endEvent

event OnCombatStateChange(Actor akTarget, int aiCombatState)
	int handle = ModEvent.Create("DFR_FollowerCombatStateChanged")
	if handle
		ModEvent.PushForm(handle, GetRef())
		ModEvent.PushInt(handle, aiCombatState)
	endIf
	ModEvent.Send(handle)
endEvent

GlobalVariable Property Lives  Auto  
QF__Gift_09000D62 Property q  Auto
_DFlowMCM Property MCM Auto
Bool Property Run auto
_DFGoldConQScript Property GoldCon Auto