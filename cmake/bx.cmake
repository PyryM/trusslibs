include(ExternalProject)

# Download `bx` and extract source path.
ExternalProject_Add(bx_EXTERNAL
    GIT_REPOSITORY "https://github.com/bkaradzic/bx.git"
    GIT_TAG "d6576889dd1d152d5eed8c46a2ea87e64a7c848e"
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    LOG_DOWNLOAD 1
)

# Recover BX tool paths for additional settings.
ExternalProject_Get_Property(bx_EXTERNAL SOURCE_DIR)
set(bx_DIR "${SOURCE_DIR}")
set(bx_INCLUDE_DIR "${SOURCE_DIR}/include")
set(bx_MSVC_COMPAT_DIR "${SOURCE_DIR}/include/compat/msvc")
string(TOLOWER "${CMAKE_SYSTEM_NAME}" bx_SYSTEM_NAME)
set(bx_GENIE "${SOURCE_DIR}/tools/bin/${bx_SYSTEM_NAME}/genie")