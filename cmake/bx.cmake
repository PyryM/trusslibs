include(ExternalProject)

# Download `bx` and extract source path.
ExternalProject_Add(bx_EXTERNAL
    GIT_REPOSITORY "https://github.com/bkaradzic/bx.git"
    GIT_TAG "51f25ba638b9cb35eb2ac078f842a4bed0746d56"
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