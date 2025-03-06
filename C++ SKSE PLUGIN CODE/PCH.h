#define _SILENCE_ALL_MS_EXT_DEPRECATION_WARNINGS

#pragma once

#include "RE/Skyrim.h"
#include "SKSE/SKSE.h"

#include <Windows.h>

// DirectXTex include (ensure path is consistent with CMakeLists.txt)
#include <DirectXTex.h>  // Use angle brackets for library includes



// Required system headers
#include <d3d11.h>
#include <dxgi1_2.h>
#include <wincodec.h>
#include <wrl/client.h>

// Standard library includes
#include <string>
#include <filesystem>
#include <chrono>
#include <sstream>
#include <iomanip>
#include <algorithm>
#include <comdef.h>

// Remove lib pragma comments - these are handled in CMakeLists.txt now
// #pragma comment(lib, "d3d11.lib")
// #pragma comment(lib, "dxgi.lib")
// #pragma comment(lib, "windowscodecs.lib")
// #pragma comment(lib, "DirectXTex.lib")

namespace fs = std::filesystem;

using namespace std;
using namespace fs;
using namespace std::literals;