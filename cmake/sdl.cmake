include(ExternalProject)

# Use this version of SDL.
set(sdl_VERSION "2.24.0")

# Download `SDL` and build it using CMake.
ExternalProject_Add(sdl_EXTERNAL
    URL "https://libsdl.org/release/SDL2-${sdl_VERSION}.zip"
    #URL_MD5 "${sdl_MD5}"
    INSTALL_COMMAND ""
    CMAKE_GENERATOR "${CMAKE_GENERATOR}"
    CMAKE_ARGS
    "-DSDL_STATIC=OFF"
    "-DSDL_VIDEO_WAYLAND=OFF"
    "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE=<BINARY_DIR>"
    "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG=<BINARY_DIR>"
    "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE=<BINARY_DIR>"
    "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG=<BINARY_DIR>"
    LOG_DOWNLOAD 1
)

# Recover project paths for additional settings.
ExternalProject_Get_Property(sdl_EXTERNAL SOURCE_DIR BINARY_DIR)
set(sdl_INCLUDE_DIRS "${BINARY_DIR}/include" "${SOURCE_DIR}/include")
set(sdl_LIBRARIES_DIR "${BINARY_DIR}")
set(sdl_DIR "${SOURCE_DIR}")

# Workaround for Windows compilation being a _little_ different.
if("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    set(sdl_LIBRARY "${sdl_LIBRARIES_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}SDL2${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(sdl_IMPLIB "${sdl_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2${CMAKE_STATIC_LIBRARY_SUFFIX}")
else()
    set(sdl_LIBRARY "${sdl_LIBRARIES_DIR}/${CMAKE_SHARED_LIBRARY_PREFIX}SDL2-2.0${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set(sdl_IMPLIB "${sdl_LIBRARIES_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}SDL2-2.0${CMAKE_STATIC_LIBRARY_SUFFIX}")
endif()

# Workaround for https://cmake.org/Bug/view.php?id=15052
foreach(include_dir ${sdl_INCLUDE_DIRS})
    file(MAKE_DIRECTORY "${include_dir}")
endforeach()

# Tell CMake that the external project generated a library so we
# can add dependencies to the library here.
add_library(sdl SHARED IMPORTED)
add_dependencies(sdl sdl_EXTERNAL)
set_target_properties(sdl PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${sdl_INCLUDE_DIRS}"
    IMPORTED_LOCATION "${sdl_LIBRARY}"
    IMPORTED_IMPLIB "${sdl_IMPLIB}"
)

# Create an install command to install the shared libs.
truss_copy_libraries(sdl_EXTERNAL "${sdl_LIBRARY}")
truss_copy_libraries(sdl_EXTERNAL "${SOURCE_DIR}/../SDL2-${sdl_VERSION}.zip")
if("${CMAKE_SYSTEM_NAME}" MATCHES "Windows")
    truss_copy_libraries(sdl_EXTERNAL "${sdl_IMPLIB}")
endif()
