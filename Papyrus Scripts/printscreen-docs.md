# PrintScreenV4 Mod Documentation

## Overview
PrintScreenV4 is a Skyrim mod that provides enhanced screenshot functionality with configurable options through MCM (Mod Configuration Menu). The mod allows players to take screenshots in various image formats, with customizable paths, compression settings, and hotkeys, while also providing the option to automatically hide the HUD/menu when taking screenshots.

## Core Components

### Script Architecture
The mod consists of six primary script files that work together to provide the screenshot functionality:
- PrintScreenV4_Quest_Script: Main quest script handling core functionality
- PrintScreenV4_mcm_script: MCM interface implementation
- PrintScreenV4_MAP_Script: Key mapping functionality
- PrintScreenV4_formula_Script: Native screenshot function implementation
- PrintScreenV4_ME_Script: Magic effect script for mod information display
- PSV4_PlayerRef_Script: Player reference handling

## Detailed Component Documentation

### PrintScreenV4_Quest_Script
This is the main quest script that handles the core functionality of the mod.

#### Properties
- `TakePhoto`: Integer storing the keycode for screenshot hotkey
- `ImageType`: String storing the selected image format
- `Path`: String storing the screenshot save location
- `Menu`: Boolean controlling automatic HUD/menu removal
- `bConfigOpen`: Boolean tracking MCM menu state
- `Compression`: Float controlling image compression (50.0-100.0)

#### Key Functions
- `OnInit()`: Initializes default values for all properties
- `OnKeyUp()`: Handles screenshot capture logic when hotkey is pressed

#### Screenshot Process Flow
1. Checks if MCM is open or text input is active
2. If screenshot hotkey is pressed:
   - Optionally removes HUD/menu
   - Calls PrintScreenV4 function
   - Handles success/failure notifications
   - Maintains screenshot counter

### PrintScreenV4_mcm_script
Implements the MCM interface for mod configuration.

#### Configuration Options
- Path Setting: Customizable screenshot save location
- Image Type Selection: PNG, BMP, TIF, JPG, GIF
- Menu Toggle: Enable/disable automatic HUD removal
- Compression Setting: Quality control for JPG/TIFF (50-100)
- Hotkey Configuration: Customizable screenshot key

#### Events
- `OnConfigInit()`: Sets up MCM pages and initial registration
- `OnPageReset()`: Handles MCM page layout and options
- `OnOptionSelect()`: Processes toggle options
- `OnOptionMenuAccept()`: Handles menu selection changes
- `OnOptionSliderAccept()`: Processes compression value changes

### PrintScreenV4_MAP_Script
Provides key mapping functionality with a comprehensive key code to key name mapping system.

#### Key Mapping Features
- Maps all standard keyboard keys
- Maps mouse buttons and wheel
- Maps numpad keys
- Maps function keys (F1-F12)
- Maps special keys (Ctrl, Alt, Shift)

### PrintScreenV4_formula_Script
Native implementation of the screenshot functionality.

#### Function
```papyrus
string Function PrintScreenV4(String Path, String ImageType, float Compression) global native
```

#### Parameters
- `Path`: Directory path for saving screenshots
- `ImageType`: Format of the screenshot (PNG, BMP, TIF, JPG, GIF)
- `Compression`: Quality setting for compressed formats (50.0-100.0)

#### Returns
- "Success" on successful capture
- Error message string on failure

### PrintScreenV4_ME_Script
Handles the display of mod information through magic effects.

#### Features
- Displays current mod version
- Shows current configuration settings
- Provides feedback on current key mappings

### PSV4_PlayerRef_Script
Manages player reference and item additions.

#### Functions
- Handles initial item distribution to player
- Manages player reference aliases

## Installation Requirements
- Skyrim Special Edition
- SKSE64
- SkyUI
- JContainers

## Technical Notes

### Performance Considerations
- Screenshot capture process is asynchronous
- HUD/menu removal is handled through console commands
- Key registration is managed through SKSE

### Known Limitations
- Text input must be inactive for screenshots
- MCM must be closed for hotkey to function
- Path must be valid and accessible
- Compression only affects JPG and TIFF formats

### Debugging Tips
- Check debug notifications for shot counter
- Monitor return values from PrintScreenV4 function
- Verify path accessibility if captures fail
- Check for key binding conflicts in MCM

## Version History
Current Version: 4.0.0
- Added compression control
- Enhanced format support
- Improved error handling
- Added automatic HUD removal option

## Best Practices
1. Set appropriate compression values for JPG/TIFF (85-95 recommended for quality)
2. Use absolute paths for screenshot directory
3. Avoid key bindings that conflict with common game functions
4. Test screenshot path before extended use
