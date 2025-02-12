Scriptname PrintScreen_MainQuest_Script extends Quest  
  
;Define Properties
int Property TakePhoto auto  
int Property KeyMapCode auto
int Property KeyCode auto 
int Property Validate auto
int Property shots auto
String Property ImageType auto 
String Property Path auto
Bool Property Menu auto 
bool property bConfigOpen auto
float property Compression auto
String Result = "Sucess"

; Common menu names for IsMenuOpen()
;"BarterMenu"
;"BookMenu"
;"ConsoleMenu"
;"ContainerMenu"
;"CraftingMenu"
;"DialogueMenu"
;"FavoritesMenu"
;"GiftMenu"
;"InventoryMenu"
;"JournalMenu"
;"LevelUpMenu"
;"LoadingMenu"
;"LockpickingMenu"
;"MagicMenu"
;"MapMenu"
;"MessageBoxMenu"
;"StatsMenu"
;"TutorialMenu"
;"TweenMenu"
;"RaceSexMenu"
;"SleepWaitMenu"
;"MainMenu"
;"Training Menu"
;"Cursor Menu"
; Output from Claude Desktop May be an incomplete list appears
;different from list used in Hltimate Immersion Mod by Luca
;will have to explore this in more detail.
;The term HUD works to turn off the menu but Not 
;to restore it. tThis is because IsopenMenu wont return
;propper result for HUD Menu. Just turn it on and forget about
;syncronizing with other mods.

bool Function IsMenuOpen(string MenuName)
;  debug.MessageBox("ISMenu Open was " + menuName + " open "+UI.IsMenuOpen(menuName)  )
return  UI.IsMenuOpen(menuName)
Endfunction

function OpenMenus()
 ;Only open closed menusInt
 If(!IsMenuOpen( "DialogueMenu"))
  ;Debug.MessageBox("Dialogue Menu is not Open")
  UI.SetInt("DialogueMenu","_root.alpha", 100)
 Endif


  UI.SetInt("HUD Menu", "_root._alpha", 100)

  If(!IsMenuOpen("MiniMapMenu"))
    UI.SetInt("MiniMapMenu", "_root._alpha", 100)
 Endif
 If(!IsMenuOpen("TrueHUD"))
   UI.SetInt("TrueHUD", "_root._alpha", 100)
 Endif
Return 
EndFunction

Function CloseMenus()  
  ;Only close Open Menus 
 if(IsMenuOpen("Dialogue Menu")) 
  ;Debug.MessageBox("The Dialog Menu was Open")
  ;this cancells the ("Dialogue Menu ") display
    UI.SetInt("DialogueMenu", "_root._alpha", 0)
 Endif 
 If(IsMenuOpen("HUD Menu"))
  ;Debug.MessageBox("On close HUD the HUD was found open")
  ;This cancells the HUD Display
  UI.SetInt("HUD Menu", "_root._alpha", 0)
 EndIf  
 If(IsMenuOpen("MiniMapMenu"))
     UI.SetInt("MiniMapMenu", "_root._alpha", 0)
Endif 
 If(IsMenuOpen("TrueNUD"))
     UI.SetInt("TrueHUD", "_root._alpha", 0)
 EndIf

return 
EndFunction

Event onInit()
    ;Define Default values
    Validate =1
    shots = 0    
    bConfigOpen = false 
    Menu = true
    TakePhoto = 14
    Imagetype = "PNG"
    Path = "C:/Pictures" 
	  Compression = 85.0 

    RegisterForKey(TakePhoto)
;Validate initial path on startup
 Result = PrintScreen_formula_SCript.PrintScreen(Validate,Path,Imagetype,Compression )
if(Result != "Success")
  debug.messageBox("Printscreen - On Initialization Path failed validation \n use MCM to fix")
  Validate = 1 ;Inital validation failed
else
  validate = 0 ;Inital Path validated
endif
EndEvent

Event OnKeyUP(int theKey, float holdtime)
  If( (theKey != TakePhoto) || \
      (bConfigOpen) || \
      (ui.IsTextInputEnabled()) )
      ;Debug.MessageBox("Printscreen Returning faild entry tests")
  return
  Endif
  
  if(menu) 
    ;Debug.MessageBox("Closing Menues")   
    CloseMenus() 
  endif
  ;Debug.MessageBox("Calling PrintScreen function")
  Result = PrintScreen_Formula_SCript.PrintScreen(0,Path,ImageType, Compression)
    if(Result == "Success")
       Shots = shots + 1
    Endif
    ;regardless of rresult restore menues
  if(menu)
    ;Debug.MessageBox("Open Menues")
    OpenMenus()
  endif
EndEvent
  
  ;The problem here is in keeping the menu open/closure in sync with the actual state
  ;of the menu system. 
  ;We may actually need to test each menu we fiddle with 
  ; individually on both open and close.




