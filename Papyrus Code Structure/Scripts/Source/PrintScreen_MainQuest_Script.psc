Scriptname PrintScreen_MainQuest_Script extends Quest  
  
;Define Properties
int Property TakePhoto auto  
int Property KeyMapCode auto
int Property KeyCode auto 
int Property Validate auto
int Property shots auto
bool Property UseJsonFile auto 
String Property ImageType auto 
String Property Path auto
Bool Property Menu auto 
bool property bConfigOpen auto

float property Compression auto
String Result = ""
String Property Version  auto 
bool Property Read_Write_Config auto
String Property JsonFileName auto
String Property KeyName_Path auto
String Property KeyName_TakePhoto auto
String Property Keyname_Menu auto
String Property  KeyName_Compression auto
String Property Keyname_ImageType auto
String Property KeyName_UseJsonFile auto
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
;different from list used in Ultimate Immersion Mod by Luca
;will have to explore this in more detail.
;The term HUD works to turn off the menu but Not 
;to restore it. tThis is because IsopenMenu wont return
;propper result for HUD Menu. Just turn it on and forget about
;syncronizing with other mods.
function Sanatize_ImageType()
  If(Imagetype == "png")
    return
  elseif(Imagetype == "bmp")
    return
  elseif(Imagetype == "jpeg")
    return
  elseif(ImageType == "gif")
    return
  elseif(Imagetype == "Tif")
    return
  else
    ImageType = "png"
    return
  endif 
endFunction


bool Function IsMenuOpen(string MenuName)
 ;debug.MessageBox("ISMenu Open Returned " + menuName + " open "+ UI.IsMenuOpen(menuName)  )
return  UI.IsMenuOpen(menuName)
Endfunction

function OpenMenus()

 ;Open everything
 UI.SetInt("TrueHUD", "_root._alpha", 100)
 UI.SetInt("HUD Menu", "_root._alpha", 100)
 UI.SetInt("Dialogue Menu","_root.alpha", 100)
 
  If(!IsMenuOpen("MiniMapMenu"))
    UI.SetInt("MiniMapMenu", "_root._alpha", 100)
 Endif   
Return 
EndFunction

Function CloseMenus()  
  ;Only close Open Menus 
  UI.SetInt("TrueHUD", "_root._alpha", 0)
  UI.SetInt("Dialogue Menu", "_root._alpha", 0)

 If(IsMenuOpen("HUD Menu"))
  UI.SetInt("HUD Menu", "_root._alpha", 0)
 EndIf  

 If(IsMenuOpen("MiniMapMenu"))
     UI.SetInt("MiniMapMenu", "_root._alpha", 0)
Endif 
return 
EndFunction

Event onInit()
    ;Define Default values
    Version="1.0.5"
    
    shots = 0    
    bConfigOpen = false 
    UseJsonFile=False
    JsonFilename = "Printscreen_Configure"
    KeyName_Compression = "Compression"
    Keyname_ImageType = "ImageType"
    KeyName_TakePhoto= "TakePhoto"
    KeyName_Path= "Path"
    Keyname_Menu = "Menu"
    KeyName_UseJsonFile = "UseJsonFile"

    Menu = true
    TakePhoto = 14
    Imagetype = "PNG"
    Path = "C:/Pictures" 
	  Compression = 85.0 
    RegisterForKey(TakePhoto)
;Validate initial path on startup
 Result = PrintScreen_formula_SCript.PrintScreen(1,Path,Imagetype,Compression )
if(Result != "Success")
  debug.messageBox("Printscreen - On Initialization Path failed validation \n use MCM to fix")

else
  ;Debug.MessageBox("Path validated succeccfully\n"+ Path)

endif
;json logic. How to determine if a jason file should be loaded.
; if the file exists read from it. I the useJason is 1 load defaaults
; if usejason is 0 do not load variables.
; In the MCM load any variables which are changed
;when the MCM is closedwrite out variables.

if(!jsonUtil.jsonExists(JsonFilename))
  Debug.MessageBox("Json file Not Found - create it")
;Create the jason file
JsonUtil.SetIntValue(JsonFilename,KeyName_TakePhoto,TakePhoto )
jsonUtil.SetStringValue(jsonFileName, KeyName_Path,Path)
jsonUtil.SetFloatValue(jsonFileName, KeyName_Compression,Compression)
if(menu)
  jsonUtil.SetIntValue(jsonFileName, Keyname_Menu,1)
else
  jsonUtil.SetIntValue(jsonFileName, Keyname_Menu,0)
Endif
jsonUtil.SetStringValue(jsonFilename, Keyname_ImageType, ImageType)
if(useJsonFile)
  jsonUtil.SetIntValue(jsonFileName,KeyName_UseJsonFile,1)
else
  jsonUtil.SetIntValue(jsonFileName,KeyName_UseJsonFile,0)
endif
Debug.MessageBox("Json file initially created")
jsonUtil.Save(jsonFileName, false)
else
;json file exists if good check 
if(JsonUtil.isGood(jsonFilename) && (jsonUtil.getIntValue(jsonFileName,KeyName_UseJsonFile) ==1))
  ;Read values and assign to defaults
  Compression = JsonUtil.GetFloatValue(jsonFilename, KeyName_Compression  )
  ImageType = JsonUtil.getStringValue(jsonFileName,Keyname_ImageType)
  Sanatize_ImageType()
  ;Need to sanatize user input here for Item Type
  TakePhoto = JsonUtil.getIntvalue(jsonFileName, KeyName_TakePhoto)
  if(jsonUtil.getintvalue(jsonFileName,Keyname_Menu) == 1 )
    Menu = True     
  else
    Menu = False
  endif
  If(JsonUtil.GetIntValue(JsonFilename,KeyName_UseJsonFile)==1)
    useJsonFile = True
  else
    UseJsonFile = False
  Endif

String TestPath = JsonUtil.GetStringValue(jsonFileName, KeyName_Path)
Result = PrintScreen_formula_SCript.PrintScreen(1,TestPath,Imagetype,Compression )
if(Result != "Success")
  debug.messageBox("Printscreen - Json Path failed validation \n use MCM to fix")
  
else
 ; Debug.MessageBox("Path validated succeccfully\n"+ Path)
  Path = TestPath
endif
endif 
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
