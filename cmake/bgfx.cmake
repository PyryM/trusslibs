# Download `bimg` and extract source path.
ExternalProject_Add(bimg_EXTERNAL
    GIT_REPOSITORY "https://github.com/bkaradzic/bimg.git"
    GIT_TAG "8355d36befc90c1db82fca8e54f38bfb7eeb3530"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1
)

# Recover BIMG tool paths for additional settings.
ExternalProject_Get_Property(bimg_EXTERNAL SOURCE_DIR)
set(bimg_DIR "${SOURCE_DIR}")
set(bimg_INCLUDE_DIR "${SOURCE_DIR}/include")


# Create a system name compatible with BGFX build scripts.
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(bgfx_SYSTEM_NAME "win")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
    set(bgfx_SYSTEM_NAME "osx-x64")
    set(bgfx_COMPILER "clang")
    set(bgfx_GENIE_GCC "osx-x64")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    set(bgfx_SYSTEM_NAME "linux")
    set(bgfx_COMPILER "gcc")
    set(bgfx_GENIE_GCC "linux-gcc")
else()
    message(FATAL_ERROR "BGFX does not support the system '${CMAKE_SYSTEM_NAME}'.")
endif()

# Configure platform-specific build commands.
if("${CMAKE_GENERATOR}" MATCHES "Visual Studio 16 2019")
    set(bgfx_SYSTEM_NAME "win64_vs2019")
    set(bgfx_COMPILER "vs2019")
    set(bgfx_CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "BX_DIR=${bx_DIR}" "BIMG_DIR=${bimg_DIR}" "${bx_GENIE}${CMAKE_EXECUTABLE_SUFFIX}" --with-min-tools --with-imgui --with-nanovg --with-shared-lib "${bgfx_COMPILER}")
    set(bgfx_BUILD_COMMAND "${CMAKE_VS_DEVENV_COMMAND}" "<SOURCE_DIR>/.build/projects/${bgfx_COMPILER}/bgfx.sln" /Build Release|x64)
elseif("${CMAKE_GENERATOR}" STREQUAL "Unix Makefiles")
    set(bgfx_CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "BX_DIR=${bx_DIR}" "BIMG_DIR=${bimg_DIR}" "${bx_GENIE}${CMAKE_EXECUTABLE_SUFFIX}" --with-min-tools --with-imgui --with-nanovg --with-shared-lib "--gcc=${bgfx_GENIE_GCC}" gmake)
    set(bgfx_BUILD_COMMAND "$(MAKE)" -C "<SOURCE_DIR>/.build/projects/gmake-${bgfx_SYSTEM_NAME}" config=release64)
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        set(bgfx_SYSTEM_NAME "linux64_gcc")
    endif()
else()
    message(FATAL_ERROR "BGFX does not support the generator '${CMAKE_GENERATOR}'.")
endif()

# Hackily patch BGFX to allow building with merged NanoVG
set(bgfx_PATCH_COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/overrides/bgfx" "<SOURCE_DIR>")

# Download `bgfx`
# and build it using `bx`.
ExternalProject_Add(bgfx_EXTERNAL
    DEPENDS bx_EXTERNAL bimg_EXTERNAL
    GIT_REPOSITORY "https://github.com/bkaradzic/bgfx.git"
    GIT_TAG "e0d26507dc1982b53c7f80364637a9a2098f5055"
    CONFIGURE_COMMAND ${bgfx_CONFIGURE_COMMAND}
    BUILD_COMMAND ${bgfx_BUILD_COMMAND}
    PATCH_COMMAND ${bgfx_PATCH_COMMAND}
    INSTALL_COMMAND ""
    BUILD_IN_SOURCE 1
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    #LOG_BUILD 1
)

# Add "Generate Parsers" step on Linux platforms.
# Required by BGFX (https://github.com/bkaradzic/bgfx/issues/364)
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
    ExternalProject_Add_Step(bgfx_EXTERNAL GENERATE_PARSERS
        COMMAND "./generateParsers.sh"
        WORKING_DIRECTORY "<SOURCE_DIR>/3rdparty/glsl-optimizer/"
        COMMENT "Generating parsers for GLSL optimizer."
        DEPENDEES download
        DEPENDERS build
    )
endif()

# Recover BGFX paths for additional settings.
ExternalProject_Get_Property(bgfx_EXTERNAL SOURCE_DIR)
set(bgfx_INCLUDE_DIR "${SOURCE_DIR}/include")
set(bgfx_LIBRARIES_DIR "${SOURCE_DIR}/.build/${bgfx_SYSTEM_NAME}/bin")
set(bgfx_LIBRARY "${bgfx_LIBRARIES_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}bgfx-shared-libRelease${CMAKE_SHARED_LIBRARY_SUFFIX}")
set(bgfx_IMPLIB "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bgfx-shared-libRelease${CMAKE_STATIC_LIBRARY_SUFFIX}")

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(bgfx_LIBRARIES
        "${bgfx_LIBRARY}"
        "${bgfx_IMPLIB}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bgfxRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bimgRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bimg_decodeRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bimg_encodeRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bxRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
    ) 
else()
    set(bgfx_LIBRARIES
        "${bgfx_LIBRARY}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bgfxRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bimgRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bimg_decodeRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bimg_encodeRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${bgfx_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}bxRelease${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
endif()

set(bgfx_BINARIES
    "${bgfx_LIBRARIES_DIR}/shadercRelease${CMAKE_EXECUTABLE_SUFFIX}"
    "${bgfx_LIBRARIES_DIR}/texturecRelease${CMAKE_EXECUTABLE_SUFFIX}"
)
set(bgfx_INCLUDES
    "${SOURCE_DIR}/include/bgfx/c99/bgfx.h"
    "${SOURCE_DIR}/include/bgfx/platform.h"
    "${SOURCE_DIR}/include/bgfx/defines.h"
    "${SOURCE_DIR}/examples/common/nanovg/nanovg.h"
    "${SOURCE_DIR}/examples/common/imgui/cimgui.h"
    "${SOURCE_DIR}/examples/common/imgui/imgui.h"
    "${SOURCE_DIR}/scripts/idl.lua"
    "${SOURCE_DIR}/scripts/bgfx.idl"
)

set(bgfx_SHADERINCLUDES
    "${SOURCE_DIR}/src/bgfx_compute.sh"
    "${SOURCE_DIR}/src/bgfx_shader.sh"
    "${SOURCE_DIR}/examples/common/common.sh"
    "${SOURCE_DIR}/examples/common/shaderlib.sh"
)

# Workaround for https://cmake.org/Bug/view.php?id=15052
file(MAKE_DIRECTORY "${bx_INCLUDE_DIR}")
file(MAKE_DIRECTORY "${bgfx_INCLUDE_DIR}")

# Tell CMake that the external project generated a library so we
# can add dependencies to the library here.
add_library(bgfx SHARED IMPORTED)
add_dependencies(bgfx bgfx_EXTERNAL)
set_target_properties(bgfx PROPERTIES
    IMPORTED_NO_SONAME 1
    INTERFACE_INCLUDE_DIRECTORIES "${bgfx_INCLUDE_DIR};${bx_INCLUDE_DIR}"
    IMPORTED_LOCATION "${bgfx_LIBRARY}"
    IMPORTED_IMPLIB "${bgfx_IMPLIB}"
)

# On Windows, need to include bx's 'compat' headers
if("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    file(MAKE_DIRECTORY "${bx_MSVC_COMPAT_DIR}")
    set_target_properties(bgfx PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${bgfx_INCLUDE_DIR};${bx_INCLUDE_DIR};${bx_MSVC_COMPAT_DIR}"
    )
endif()

# On Linux, BGFX needs a few other libraries.
if("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set_target_properties(bgfx PROPERTIES
        INTERFACE_LINK_LIBRARIES "dl;GL;pthread;X11"
    )
endif()

# Create install commands to install the shared libs.
truss_copy_libraries(bgfx_EXTERNAL "${bgfx_LIBRARIES}")
truss_copy_includes(bgfx_EXTERNAL "bgfx" "${bgfx_INCLUDES}")
truss_copy_includes(bgfx_EXTERNAL "bgfx/shader" "${bgfx_SHADERINCLUDES}")
truss_copy_binaries(bgfx_EXTERNAL "${bgfx_BINARIES}")
