cmake_minimum_required(VERSION 3.3)

project(trusslibs)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
set(CMAKE_CXX_STANDARD 11)
include(utils)

# Unlike most builds, we want the resulting executable to be installed into
# the root of the `dist` directory, as this entire directory comprises a
# distribution package.
set(DIST_DIR "${CMAKE_CURRENT_SOURCE_DIR}/dist")

# Install and build required dependencies.
# (BGFX, SDL)
include(bgfx)
include(sdl)

# If the user attempts to install, politely inform them that it has no effect.
install(CODE "MESSAGE(WARNING \"\nTrusslibs cannot be installed to the system. Typically, the 'dist' directory is re-distributed as a self-contained application.\")")
