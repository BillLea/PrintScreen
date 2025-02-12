Scriptname PrintScreenV4_mcm_script extends Ski_configbase

PrintScreenV4_Quest_Script property Test  auto

;Set option ID's as Properties
int Property PathID auto
int Property ImageTypeID auto
int Property MenuID auto
int Property PhotoKeyID auto
int Property RemoveMenuID auto
int Property keyCodeID auto
int Property CompressionID auto  

String[] function OptionArray()
  int size= 5
  string[] OpArray = Utility.CreateStringArray(size )
  OpArray[0]= "PNG"
  OpArray[1]= "BMP"
  OpArray[2]= "TIF"
  OpArray[3] = "JPG"
  OpArray[4] ="GIF"
    return OpArray
  endFunction

  Event onConfigOpen()
    Test.bConfigOpen = true
    ;Debug.MessageBox("on ConfigOpen bConfigOpen = " + Test.bConfigOpen)
endevent

Event OnConfigInit()
    ModName ="Print Screen v4"     
    pages = New string[1] 
    pages[0] = "settings" 
    RegisterforKey(14) 
EndEvent

EVENT OnPageReset(string pagename)
 
if(pagename == "")
    SetCursorFillmode(TOP_TO_BOTTOM )
    SetCursorPosition(1)
    int ImageSelect
    ImageSelect = Utility.RandomInt(1,6)

    
    if(ImageSelect == 1)
      LoadCustomContent("PrintScreen/ScreenShot01.dds")
    Endif
     If(Imageselect == 2)
        LoadCustomContent("PrintScreen/ScreenShot02.dds")
     EndIf
    if(Imageselect == 3)
         LoadCustomContent("PrintScreen/ScreenShot03.dds")
    endif
    if(imageSelect == 4)
     LoadCustomContent("PrintScreen/ScreenShot04.dds")
     endif
    if(imageSelect == 5)
         LoadCustomContent("PrintScreen/ScreenShot05.dds")
    endif
    if(imageSelect ==6)
      LoadCustomContent("PrintScreen/ScreenShot06.dds")
    endif
else
    UnloadCustomContent()
Endif


if(pagename == "Settings")
    SetCursorFillmode(TOP_TO_BOTTOM )
    SetCursorPosition(0)
    AddheaderOption("Printscreen version 2.04")
    AddHeaderOption("Path,Image Type, Menu, Photo Key" ,0)
    addEmptyOption() 
    PathID = AddInputOption("Path",Test.Path, OPTION_FLAG_NONE)
    AddEmptyOption() 
    ImageTypeID = AddMenuOption("Select Image file type",OptionArray()[0] , 0)
   AddEmptyOption() 
   RemoveMenuID = AddToggleOption("Automatic Menu Revoval",Test.Menu, 0)
   AddEmptyOption()
   CompressionID =  AddSliderOption("Compression",50.0,"{0}", 0)

   KeyCodeID = AddKeyMapOption( "Select Take Photo Key", Test.TakePhoto, 0)
   
EndIf
EndEvent

event OnOptionHighlight(int option)
  if(option ==ImageTypeID )
      SetInfoText("Select the type of image to create ")
  elseif(option == RemoveMenuID )
    SetInfoText("Toggle Automatic Removal of HUD/Menu ")
  elseif(option== KeyCodeID )
    SetInfoText("Select an unused Key to TAKE pHOTO ")
  Elseif(option == PathID  )
setinfoText("Enter path to Image Storage")
elseif(option == CompressionID)
SetInfoText("Select QUALITY factor for jpg and Tiff files  50-LOWEST TO 100 HIGHEST quality")
  endif 
EndEvent

;path input processing

event OnOptionInputAccept(int a_option, string a_input)
	if(a_Option == PathID)  
    Test.validate=1
String Result=PrintScreenV4_formula_Script.PrintScreenV4(Test.Validate, a_input,Test.ImageType,85.0)
		if(Result== "Success") 
      Test.Path =a_input
      SetInputOptionValue(a_Option,Test.Path,false)
      Test.Validate=0
    else
        Debug.MessageBox("Path failed Validation/Creation Reenter")
    endif	
		;debug.MessageBox(Test.Path)
      Endif
endEvent

;Toggle Input processing.

Event  OnOptionSelect(int Option)
  if(Option == RemoveMenuID)
    Test.Menu = !Test.menu
    SetToggleOptionValue(Option,Test.menu, false)
  endif
endevent

; process keyCode selection

Event OnOptionKeyMapChange(int Option, int keyCode, string conflictControl, string conflictName)
;check for conflicts

if( (conflictName =="") && (conflictcontrol == "") && (input.GetMappedControl(KeyCode)==""))
    unregisterForKey(Test.TakePhoto)
    Test.TakePhoto = keyCode
    ;debug.MessageBox("No Conflict assign takephoto: " + Test.TakePhoto )
    SetKeyMapOptionValue( Option,Test.TakePhoto  , false)
Else 
Debug.messagebox("Key conflict Detected -- Please choose an unassined key")
endif 
endEvent

; Process Menu operations
event OnOptionMenuOpen(int Option)

if(Option == ImageTypeID)
  ;build optionArray
 
  ;Set menu contents here
	SetMenuDialogDefaultIndex(0)
	SetMenuDialogStartIndex(0)
	SetMenuDialogOptions(OptionArray())
endif
EndEvent

Event OnOptionMenuAccept(int Option, int  index)
  Test.ImageType= OptionArray()[index]
  SetMenuOptionValue( option, Test.Imagetype, false)
  ;Debug.MessageBox("the imagde type was" +Test.ImageType)
EndEvent

Event OnOptionSliderOpen(int a_option)
	;{Called when a slider option has been selected}
	 SetSliderOptionValue(a_option, Test.Compression,  "{0}", false)
	 SetSliderDialogStartValue(Test.Compression)
	 SetSliderDialogDefaultValue(100.0)
	 SetSliderDialogRange(50.0, 100.0)
	 SetSliderDialogInterval(5.0)
endEvent

event OnOptionSliderAccept(int a_option, float a_value)
	;{Called when a new slider value has been accepted}
	Test.Compression = a_value
SetSliderOptionValue(a_option, Test.Compression,  "{0}", false)
endEvent
 
event OnConfigClose()
  ;bConfigOpen is a flag variable which prevents activation of
  ;PrintScreenKey while the MCM is open
  Test.bConfigOpen = false 
  RegisterforKey(Test.TakePhoto )
  ;Debug.MessageBox("MCM menu closed: bConfigOpen = " + Test.bConfigOpen)
EndEvent