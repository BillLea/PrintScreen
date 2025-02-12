std::string Check_Path(const std::string basePath,const ::string  itemType) {
    // Step 1: Ensure the base directory exists.

    try {
        // First validate the path format
        if (basePath.empty()) {
            return "Base path cannot be empty";
        }

        // Check for invalid characters in the path
        const std::string invalidChars = "<>\"|?*";  // Removed ':' from the list

        // Special handling for colon - only valid after drive letter
        size_t colonPos = basePath.find(':');
        if (colonPos != std::string::npos) {
            // Colon is only valid in the second position after a drive letter
            // e.g., "C:" is valid, but "C::" or "CC:" or ":C" are not
            if (colonPos != 1 ||                                          // Must be second character
                !std::isalpha(basePath[0]) ||                             // First char must be letter
                basePath.find(':', colonPos + 1) != std::string::npos) {  // No more colons
                return "Invalid drive specification in path";
            }
        }

        // Check other invalid characters
        if (basePath.find_first_of(invalidChars) != std::string::npos) {
            return "Invalid characters in path";
        }

        // Convert to filesystem path to check validity
        std::filesystem::path fsPath(basePath);

        // Check if path is absolute (recommended for screenshot saving)
        if (!fsPath.is_absolute()) {
            return "Path must be absolute";
        }

        // Normalize the path
        fsPath = fsPath.lexically_normal();

        // Check if parent path exists (the directory that will contain our directory)
        auto parentPath = fsPath.parent_path();
        if (!parentPath.empty() && !std::filesystem::exists(parentPath)) {
            return "Parent directory does not exist: " + parentPath.string();
        }

        // Now try to create the directory if it doesn't exist
        if (!std::filesystem::exists(fsPath)) {
            if (!std::filesystem::create_directories(fsPath)) {
                return "Failed to create directory: " + basePath;
            }
        } else if (!std::filesystem::is_directory(fsPath)) {
            return "Path exists but is not a directory: " + basePath;
        }

        // Verify we have write permissions
        std::filesystem::path testFile = fsPath / "test_write_permission";
        try {
            std::ofstream test(testFile);
            if (!test.is_open()) {
                return "Cannot write to directory: " + basePath;
            }
            test.close();
            std::filesystem::remove(testFile);
        } catch (...) {
            return "Cannot write to directory: " + basePath;
        }
    } catch (const std::filesystem::filesystem_error& e) {
        return "Filesystem error: " + std::string(e.what());
    } catch (const std::exception& e) {
        return "Exception while validating/creating directory: " + std::string(e.what());
    }
    return "Success";
}









std::string PrintScreen(RE::StaticFunctionTag*, int validate, std::string basePath, std::string imageType, float compression) {
    if (validate == 1) return Check_Path(basePath, imageType);
        //*************************************************************************************************************

// DesktopCapture.cpp

//------------------------------------------------------------------------------
// CaptureDesktopImage
//
// Parameters:
//    basePath    - A std::string that specifies the base directory. The function
//                  will check for its existence and create it if needed.
//    imageType   - A std::string containing one of the supported extensions:
//                  BMP, GIF, TIF, JPG, or PNG (case‐insensitive).
//    compression - A float (0.50f to 100f) used as the compression quality
//                  for JPEG and TIFF files. The vALUE IS DIVIDED BY 100 AND CLAMPED TO THE RANCE 0->1 BEFORRE USE.
//
// Returns:
//    An empty std::string on success or an error message if any step fails.
//------------------------------------------------------------------------------
//std::string CaptureDesktopImage(int validate, const std::string& basePath, const std::string& imageType, float compression)
// 

 // Add this after the path validation
std::string imageTypeLower = imageType;
std::transform(imageTypeLower.begin(), imageTypeLower.end(), imageTypeLower.begin(), ::tolower);
if (imageTypeLower != "bmp" && 
    imageTypeLower != "jpg" && 
    imageTypeLower != "jpeg" && 
    imageTypeLower != "png" && 
    imageTypeLower != "gif" && 
    imageTypeLower != "tif" && 
    imageTypeLower != "tiff") {
    return "Unsupported image format: " + imageType;
}
    
    // Step 2: Construct a unique filename.
    std::ostringstream oss;
    oss << basePath;
    // Ensure there is a trailing slash.
    if (basePath.back() != '\\' && basePath.back() != '/')
        oss << "\\";
    oss << "screenshot_";
    // Append current local time.
    auto now = std::chrono::system_clock::now();
    auto t = std::chrono::system_clock::to_time_t(now);
    struct tm localTime;
    if (localtime_s(&localTime, &t) != 0)
        return "Failed to get local time.";
    oss << std::put_time(&localTime, "%Y%m%d_%H%M%S");
    oss << "." << imageType;
    std::string filePathNarrow = oss.str();

    // Convert the narrow string filename to a wide string for WIC.
    int sizeNeeded = MultiByteToWideChar(CP_UTF8, 0, filePathNarrow.c_str(), -1, nullptr, 0);
    if (sizeNeeded <= 0)
        return "Failed to convert file path to wide string.";
    std::wstring filePathWide(sizeNeeded, 0);
    MultiByteToWideChar(CP_UTF8, 0, filePathNarrow.c_str(), -1, &filePathWide[0], sizeNeeded);

    // Step 3: Initialize COM and create the WIC Imaging Factory.
    HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
    bool comInitialized = SUCCEEDED(hr);
    
    Microsoft::WRL::ComPtr<IWICImagingFactory> wicFactory;
    hr = CoCreateInstance(
        CLSID_WICImagingFactory,
        nullptr,
        CLSCTX_INPROC_SERVER,
        IID_PPV_ARGS(&wicFactory)
    );
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create WIC Imaging Factory. HRESULT: " + std::to_string(hr);
    }

    // Step 4: Create a D3D11 device and immediate context.
    UINT creationFlags = 0;
#ifdef _DEBUG
    creationFlags |= D3D11_CREATE_DEVICE_DEBUG;
#endif
    D3D_FEATURE_LEVEL featureLevel;
    const D3D_FEATURE_LEVEL featureLevels[] = { D3D_FEATURE_LEVEL_11_0 };
    Microsoft::WRL::ComPtr<ID3D11Device> d3dDevice;
    Microsoft::WRL::ComPtr<ID3D11DeviceContext> d3dContext;
    hr = D3D11CreateDevice(
        nullptr,                    // use default adapter
        D3D_DRIVER_TYPE_HARDWARE,
        nullptr,
        creationFlags,
        featureLevels,
        1,
        D3D11_SDK_VERSION,
        &d3dDevice,
        &featureLevel,
        &d3dContext
    );
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create D3D11 device. HRESULT: " + std::to_string(hr);
    }

    // Step 5: Get the DXGI device, adapter, and output.
    Microsoft::WRL::ComPtr<IDXGIDevice> dxgiDevice;
    hr = d3dDevice.As(&dxgiDevice);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to query IDXGIDevice from D3D11 device. HRESULT: " + std::to_string(hr);
    }

    Microsoft::WRL::ComPtr<IDXGIAdapter> dxgiAdapter;
    hr = dxgiDevice->GetAdapter(&dxgiAdapter);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to get DXGI Adapter. HRESULT: " + std::to_string(hr);
    }

    Microsoft::WRL::ComPtr<IDXGIOutput> dxgiOutput;
    hr = dxgiAdapter->EnumOutputs(0, &dxgiOutput);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to get DXGI Output. HRESULT: " + std::to_string(hr);
    }

    Microsoft::WRL::ComPtr<IDXGIOutput1> dxgiOutput1;
    hr = dxgiOutput.As(&dxgiOutput1);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to query IDXGIOutput1. HRESULT: " + std::to_string(hr);
    }

    // Step 6: Duplicate the desktop output.
    Microsoft::WRL::ComPtr<IDXGIOutputDuplication> deskDuplication;
    hr = dxgiOutput1->DuplicateOutput(d3dDevice.Get(), &deskDuplication);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to duplicate output. HRESULT: " + std::to_string(hr);
    }

    // Step 7: Acquire the next available frame.
    IDXGIResource* desktopResource = nullptr;
    DXGI_OUTDUPL_FRAME_INFO frameInfo = {};
    hr = deskDuplication->AcquireNextFrame(500, &frameInfo, &desktopResource);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to acquire next frame. HRESULT: " + std::to_string(hr);
    }

    // Obtain the desktop image as a D3D11 texture.
    Microsoft::WRL::ComPtr<ID3D11Texture2D> desktopImage;
    hr = desktopResource->QueryInterface(IID_PPV_ARGS(&desktopImage));
    desktopResource->Release();
    if (FAILED(hr)) {
        deskDuplication->ReleaseFrame();
        if (comInitialized)
            CoUninitialize();
        return "Failed to query ID3D11Texture2D from desktop resource. HRESULT: " + std::to_string(hr);
    }

    // Retrieve the texture description.
    D3D11_TEXTURE2D_DESC frameDesc = {};
    desktopImage->GetDesc(&frameDesc);

    // Ensure the image format is DXGI_FORMAT_B8G8R8A8_UNORM.
    if (frameDesc.Format != DXGI_FORMAT_B8G8R8A8_UNORM) {
        deskDuplication->ReleaseFrame();
        if (comInitialized)
            CoUninitialize();
        return "Desktop image format is not DXGI_FORMAT_B8G8R8A8_UNORM.";
    }

    // Create a staging texture to copy the frame data into CPU-accessible memory.
    D3D11_TEXTURE2D_DESC stagingDesc = frameDesc;
    stagingDesc.Usage = D3D11_USAGE_STAGING;
    stagingDesc.BindFlags = 0;
    stagingDesc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
    stagingDesc.MiscFlags = 0;

    Microsoft::WRL::ComPtr<ID3D11Texture2D> stagingTex;
    hr = d3dDevice->CreateTexture2D(&stagingDesc, nullptr, &stagingTex);
    if (FAILED(hr)) {
        deskDuplication->ReleaseFrame();
        if (comInitialized)
            CoUninitialize();
        return "Failed to create staging texture. HRESULT: " + std::to_string(hr);
    }

    // Copy the desktop image into the staging texture.
    d3dContext->CopyResource(stagingTex.Get(), desktopImage.Get());
    deskDuplication->ReleaseFrame();

    // Map the staging texture to access the pixel data.
    D3D11_MAPPED_SUBRESOURCE mapped = {};
    hr = d3dContext->Map(stagingTex.Get(), 0, D3D11_MAP_READ, 0, &mapped);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to map staging texture. HRESULT: " + std::to_string(hr);
    }

    // Step 8: Create a WIC bitmap from the mapped memory.
    const UINT width = frameDesc.Width;
    const UINT height = frameDesc.Height;
    const UINT stride = mapped.RowPitch;
    const UINT pixelSize = 4;  // 4 bytes per pixel for BGRA
    const UINT imageSize = width * height * pixelSize;

    Microsoft::WRL::ComPtr<IWICBitmap> wicBitmap;
    hr = wicFactory->CreateBitmapFromMemory(
        width,
        height,
        GUID_WICPixelFormat32bppBGRA,
        stride,
        imageSize,
        static_cast<BYTE*>(mapped.pData),
        &wicBitmap
    );
    // Unmap the staging texture now that the data has been copied.
    d3dContext->Unmap(stagingTex.Get(), 0);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create WIC bitmap from memory. HRESULT: " + std::to_string(hr);
    }

    // Step 9: Create the appropriate encoder for the desired image type.
//std::string imageTypeLower = imageType;
    std::transform(imageTypeLower.begin(), imageTypeLower.end(), imageTypeLower.begin(), ::tolower);

    CLSID encoderClsid;
    if (imageTypeLower == "bmp") {
        encoderClsid = CLSID_WICBmpEncoder;
    }
    else if (imageTypeLower == "jpg" || imageTypeLower == "jpeg") {
        encoderClsid = CLSID_WICJpegEncoder;
    }
    else if (imageTypeLower == "png") {
        encoderClsid = CLSID_WICPngEncoder;
    }
    else if (imageTypeLower == "gif") {
        encoderClsid = CLSID_WICGifEncoder;
    }
    else if (imageTypeLower == "tif" || imageTypeLower == "tiff") {
        encoderClsid = CLSID_WICTiffEncoder;
    }
    else {
        if (comInitialized)
            CoUninitialize();
        return "Unsupported image format: " + imageType;
    }

 /*   Microsoft::WRL::ComPtr<IWICBitmapEncoder> encoder;
    hr = wicFactory->CreateEncoder(encoderClsid, nullptr, &encoder);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create WIC encoder. HRESULT: " + std::to_string(hr);
    }
*/
Microsoft::WRL::ComPtr<IWICBitmapEncoder> encoder;
hr = CoCreateInstance(
    encoderClsid,
    nullptr,
    CLSCTX_INPROC_SERVER,
    IID_PPV_ARGS(&encoder)
);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create WIC encoder. HRESULT: " + std::to_string(hr);
    }


    // Create an output stream for the file.
    Microsoft::WRL::ComPtr<IWICStream> stream;
    hr = wicFactory->CreateStream(&stream);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create WIC stream. HRESULT: " + std::to_string(hr);
    }

    hr = stream->InitializeFromFilename(filePathWide.c_str(), GENERIC_WRITE);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to initialize stream from filename. HRESULT: " + std::to_string(hr);
    }

    hr = encoder->Initialize(stream.Get(), WICBitmapEncoderNoCache);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to initialize encoder with stream. HRESULT: " + std::to_string(hr);
    }

    // Create a new frame for the image.
    Microsoft::WRL::ComPtr<IWICBitmapFrameEncode> frameEncode;
    Microsoft::WRL::ComPtr<IPropertyBag2> propertyBag;
    hr = encoder->CreateNewFrame(&frameEncode, &propertyBag);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to create new frame for encoder. HRESULT: " + std::to_string(hr);
    }

    hr = frameEncode->Initialize(propertyBag.Get());
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to initialize frame encoder. HRESULT: " + std::to_string(hr);
    }

    hr = frameEncode->SetSize(width, height);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to set frame size. HRESULT: " + std::to_string(hr);
    }

    // Set the pixel format (should match the WIC bitmap).
    WICPixelFormatGUID formatGUID = GUID_WICPixelFormat32bppBGRA;
    hr = frameEncode->SetPixelFormat(&formatGUID);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to set pixel format for frame. HRESULT: " + std::to_string(hr);
    }


if (imageTypeLower == "tif" || imageTypeLower == "tiff") {
    // Set up compression method first
    PROPBAG2 option[2] = {};
    VARIANT value[2];

    // Setup compression method property
    option[0].pstrName = const_cast<LPOLESTR>(L"TiffCompressionMethod");
    VariantInit(&value[0]);
    value[0].vt = VT_UI1;
    value[0].bVal = WICTiffCompressionZIP;  // Try ZIP compression

    // Setup quality property
    option[1].pstrName = const_cast<LPOLESTR>(L"CompressionQuality");  // Note: different property name for TIFF
    VariantInit(&value[1]);
    value[1].vt = VT_R4;
    value[1].fltVal = std::clamp(compression / 100.0f, 0.0f, 1.0f);

    // Write both properties at once
    hr = propertyBag->Write(2, option, value);
    
    // Clean up variants
    VariantClear(&value[0]);
    VariantClear(&value[1]);

    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to set TIFF compression properties. HRESULT: " + std::to_string(hr);
    }

    } else if (imageTypeLower == "jpg" || imageTypeLower == "jpeg") {
        // JPEG only needs quality setting
        PROPBAG2 optionProp = {0};
        optionProp.pstrName = const_cast<LPOLESTR>(L"ImageQuality");
        VARIANT varValue;
        VariantInit(&varValue);
        varValue.vt = VT_R4;
        varValue.fltVal = std::clamp(compression / 100.0f, 0.0f, 1.0f);
        hr = propertyBag->Write(1, &optionProp, &varValue);
        VariantClear(&varValue);
        if (FAILED(hr)) {
            if (comInitialized) CoUninitialize();
            return "Failed to set compression quality property. HRESULT: " + std::to_string(hr);
        }
    }
    // Write the WIC bitmap to the frame.
    hr = frameEncode->WriteSource(wicBitmap.Get(), nullptr);
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to write bitmap to frame. HRESULT: " + std::to_string(hr);
    }

    hr = frameEncode->Commit();
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to commit frame. HRESULT: " + std::to_string(hr);
    }

    hr = encoder->Commit();
    if (FAILED(hr)) {
        if (comInitialized)
            CoUninitialize();
        return "Failed to commit encoder. HRESULT: " + std::to_string(hr);
    }

    if (comInitialized)
        CoUninitialize();

    // Success!
    return "Success";
}




//*************************************************************************************************************

 

bool BindPapyrusFunctions(RE::BSScript::IVirtualMachine* vm) {
    vm->RegisterFunction( "PrintScreen","PrintScreen_Formula_Script", PrintScreen);
    return true ;
}


SKSEPluginLoad(const SKSE::LoadInterface *skse) {
    SKSE::Init(skse);
    SKSE::GetPapyrusInterface()->Register(BindPapyrusFunctions);
    return true;
}
