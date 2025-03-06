cmake_minimum_required(VERSION 3.21)  # VS2022 uses CMake 3.21+
project(PrintScreen VERSION 1.5.0 LANGUAGES CXX)

# Setup output folder logic
if(DEFINED ENV{SKYRIM_FOLDER} AND IS_DIRECTORY "$ENV{SKYRIM_FOLDER}/Data")
    set(OUTPUT_FOLDER "$ENV{SKYRIM_FOLDER}/Data")
endif()

if(DEFINED ENV{SKYRIM_MODS_FOLDER} AND IS_DIRECTORY "$ENV{SKYRIM_MODS_FOLDER}")
    set(OUTPUT_FOLDER "$ENV{SKYRIM_MODS_FOLDER}/${PROJECT_NAME}")
endif()

# ========== Find Dependencies ==========
find_package(CommonLibSSE CONFIG REQUIRED)
find_package(directxtex CONFIG REQUIRED)  # Note: lowercase 'directxtex'

# ========== Create Plugin ==========
add_commonlibsse_plugin(${PROJECT_NAME} SOURCES plugin.cpp)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
target_precompile_headers(${PROJECT_NAME} PRIVATE PCH.h)

# ========== Link Libraries ==========
target_link_libraries(${PROJECT_NAME} PRIVATE 
    CommonLibSSE::CommonLibSSE
    Microsoft::DirectXTex  # Note the namespace
    d3d11
    dxgi
    windowscodecs
)

# ========== Output and Deployment ==========
if(DEFINED OUTPUT_FOLDER)
    set(DLL_FOLDER "${OUTPUT_FOLDER}/SKSE/Plugins")
    
    # VS-friendly message
    message(STATUS "SKSE plugin will be copied to: ${DLL_FOLDER}")

    add_custom_command(
        TARGET "${PROJECT_NAME}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${DLL_FOLDER}"
        COMMAND "${CMAKE_COMMAND}" -E copy_if_different "$<TARGET_FILE:${PROJECT_NAME}>" "${DLL_FOLDER}/$<TARGET_FILE_NAME:${PROJECT_NAME}>"
        VERBATIM
    )

    # PDB for debug builds
    add_custom_command(
        TARGET "${PROJECT_NAME}"
        POST_BUILD
        COMMAND "${CMAKE_COMMAND}" -E $<$<CONFIG:Debug>:copy_if_different> "$<TARGET_PDB_FILE:${PROJECT_NAME}>" "${DLL_FOLDER}/$<TARGET_PDB_FILE_NAME:${PROJECT_NAME}>"
        VERBATIM
    )
endif()