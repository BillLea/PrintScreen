Scriptname PrintScreen_ME_Script extends activemagiceffect  
  
PrintScreen_MainQuest_Script property Test auto

event OnEffectStart(actor target, actor castor )    
    
String KeyName = PrintScreen_MAP_Script.GetKeyName( Test.TakePhoto)
Debug.MessageBox("Printscreen version 1.0.1\n" + \
"\nThe Image File Type is: "+ Test.ImageType + \
"\n The Compression Level is: " + Test.Compression + \
"\n The Path is: "+ Test.Path + \
"\n Automatic HUD/menu removal is: "+ Test.menu + \
"\n The Photo Key is "+ KeyName  + \
"\n" + Test.shots + " screenshots taken this session")

EndEvent 


