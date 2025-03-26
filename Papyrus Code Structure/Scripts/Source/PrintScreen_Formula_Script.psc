Scriptname PrintScreen_Formula_Script extends Quest  
;If vallidate >0 the path needs to be validated.
; The C++ function is called with validate set to 1. The c++ function
; validates and if required creats the path.  The print generation does not
; function during path vallidation. When the path is validated/created succeccfully
; A flag variable is set to 0 from its default value 0f 1. The value is set to 1
; any time the MCM opens or changes the path variable. This is because the path needs onlt ro be validated/created on initiation of the script or when canged by the MCM.
;The dcreencapture routine should never have to inspect or change the path sent to it.
;In this way a failure of the specified path will occur while the user is
;activly changing the path in the MCM. 

;Recenty I moved HUD?Menu control into the SKSE function.  I added a new control variable int nid_control. If it is 1 the HUD is switched if 0 the HUD is not Switched.

string Function PrintScreen( int Validate, String Path, String ImageType, float Compression,string ddsCompressionType) global native
