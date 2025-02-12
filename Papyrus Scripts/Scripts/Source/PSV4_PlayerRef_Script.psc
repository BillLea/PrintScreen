Scriptname PSV4_PlayerRef_Script extends referenceAlias
armor property arm auto
MiscObject property Lp auto

event OnEffectStart(actor target, actor caster)

game.getplayer().additem(arm,1)
game.Getplayer().AddItem(Lp,1)

EndEvent  


