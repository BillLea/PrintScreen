Scriptname  PrintScreenV4_ME_Script extends activemagiceffect  


PrintScreenV4_Quest_Script property Test auto

event OnEffectStart(actor target, actor castor )    
    
String KeyName = PrintScreenV4_MAP_Script.GetKeyName( Test.TakePhoto)
Debug.MessageBox("Printscreen version 4.0.0\n" + \
"\nThe Image File Type is: "+ Test.ImageType + \
"\n The Compression Level is: " + Test.Compression + \
"\n The Path is: "+ Test.Path + \
"\n Automatic HUD/menu removal is: "+ Test.menu + \
"\n The Photo Key is "+ KeyName  + \
"\n" + Test.shots + " screenshots taken this session")

EndEvent 

