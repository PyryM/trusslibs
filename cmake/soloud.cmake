# Create a system name compatible with BGFX build scripts.
if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(soloud_COMPILER "vs2022")
else()
    set(soloud_COMPILER "gmake")
endif()

# Configure platform-specific build commands.
if("${CMAKE_GENERATOR}" MATCHES "Visual Studio 17 2022")
    #SDL backend on windows doesn't seem as good so just don't compile it!
    #set(soloud_CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "SDL2_DIR=${sdl_DIR}" "${bx_GENIE}${CMAKE_EXECUTABLE_SUFFIX}" --file=build/genie.lua --platform=x64 --with-sdl2 "${soloud_COMPILER}")
    set(soloud_CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "SDL2_DIR=${sdl_DIR}" "${bx_GENIE}${CMAKE_EXECUTABLE_SUFFIX}" --file=build/genie.lua --platform=x64 "${soloud_COMPILER}")
    set(soloud_BUILD_COMMAND "${CMAKE_VS_DEVENV_COMMAND}" "<SOURCE_DIR>/build/${soloud_COMPILER}/SoLoud.sln" /Build Release|x64)
elseif("${CMAKE_GENERATOR}" STREQUAL "Unix Makefiles")
    set(soloud_CONFIGURE_COMMAND "${CMAKE_COMMAND}" -E env "SDL2_DIR=${sdl_DIR}" "${bx_GENIE}${CMAKE_EXECUTABLE_SUFFIX}" --file=build/genie.lua --with-sdl2 "${soloud_COMPILER}")
    set(soloud_BUILD_COMMAND "$(MAKE)" -C "<SOURCE_DIR>/build/${soloud_COMPILER}" config=release)
else()
    message(FATAL_ERROR "Soloud does not support the generator '${CMAKE_GENERATOR}'.")
endif()

# Patch soloud?
set(soloud_PATCH_COMMAND "${CMAKE_COMMAND}" -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/overrides/soloud" "<SOURCE_DIR>")

# Download `soloud`
# and build it using `genie`.
ExternalProject_Add(soloud_EXTERNAL
    DEPENDS bx_EXTERNAL sdl_EXTERNAL
    GIT_REPOSITORY "https://github.com/jarikomppa/soloud.git"
    GIT_TAG "1157475881da0d7f76102578255b937c7d4e8f57"
    CONFIGURE_COMMAND ${soloud_CONFIGURE_COMMAND}
    BUILD_COMMAND ${soloud_BUILD_COMMAND}
    PATCH_COMMAND ${soloud_PATCH_COMMAND}
    INSTALL_COMMAND ""
    BUILD_IN_SOURCE 1
    LOG_DOWNLOAD 1
    LOG_CONFIGURE 1
    #LOG_BUILD 1
)

# Recover BGFX paths for additional settings.
ExternalProject_Get_Property(soloud_EXTERNAL SOURCE_DIR)
set(soloud_INCLUDE_DIR "${SOURCE_DIR}/include")
set(soloud_LIBRARIES_DIR "${SOURCE_DIR}/lib")

if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
    set(soloud_LIBRARIES
        "${soloud_LIBRARIES_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}soloud_x64${CMAKE_SHARED_LIBRARY_SUFFIX}"
        "${soloud_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}soloud_x64${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${soloud_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}soloud_static_x64${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${soloud_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}soloud_c_static_x64${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
else()
    set(soloud_LIBRARIES
        "${soloud_LIBRARIES_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}soloud${CMAKE_SHARED_LIBRARY_SUFFIX}"
        "${soloud_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}soloud_static${CMAKE_STATIC_LIBRARY_SUFFIX}"
        "${soloud_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}soloud_c_static${CMAKE_STATIC_LIBRARY_SUFFIX}"
    )
endif()

set(soloud_INCLUDES
    "${SOURCE_DIR}/include/soloud_c.h"
)

# Create install commands to install the shared libs.
truss_copy_libraries(soloud_EXTERNAL "${soloud_LIBRARIES}")
truss_copy_includes(soloud_EXTERNAL "soloud" "${soloud_INCLUDES}")