# Utility functions for building truss.
# Copies every library in the given path to the `dist` lib directory.
function(truss_copy_libraries target target_libraries)
    foreach(library_path ${target_libraries})
        # Extract library name from full path.
        get_filename_component(library_file "${library_path}" NAME)

        # On Mac, we need to relocate the library RPATH.
        # This is handled manually as a post-build step because of wild
        # inconsistencies in how the Mac RPATH is handled in various libraries.
        if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
            add_custom_command(
                TARGET "${target}" POST_BUILD
                COMMAND install_name_tool
                ARGS -id "@executable_path/lib/${library_file}" "${library_path}"
                DEPENDS "${library_path}"
                COMMENT "Relocated Mac RPATH of ${target} library."
            )
        endif()

        # Create a rule to copy the library to the `lib` directory.
        add_custom_command(
            TARGET "${target}" POST_BUILD
            COMMAND "${CMAKE_COMMAND}"
            ARGS -E copy "${library_path}" "${DIST_DIR}/lib/${library_file}"
            BYPRODUCTS "${DIST_DIR}/lib/${library_file}"
            COMMENT "Installed '${library_file}' library to distribution directory."
        )
    endforeach()
endfunction()

# Copies a list of binaries to the `dist` bin directory.
function(truss_copy_binaries target target_binaries)
    foreach(binary_path ${target_binaries})
        # Extract library name from full path.
        get_filename_component(binary_file "${binary_path}" NAME)

        # Create a rule to copy the library to the `lib` directory.
        add_custom_command(
            TARGET "${target}" POST_BUILD
            COMMAND "${CMAKE_COMMAND}"
            ARGS -E copy "${binary_path}" "${DIST_DIR}/bin/${binary_file}"
            BYPRODUCTS "${DIST_DIR}/lib/${binary_file}"
            COMMENT "Installed '${binary_file}' binary to distribution directory."
        )
    endforeach()
endfunction()

# Copies a list of includes to the `dist` bin directory.
function(truss_copy_includes target target_includes)
    foreach(include_path ${target_includes})
        # Extract include name from full path.
        get_filename_component(include_file "${include_path}" NAME)

        # Create a rule to copy the library to the `lib` directory.
        add_custom_command(
            TARGET "${target}" POST_BUILD
            COMMAND "${CMAKE_COMMAND}"
            ARGS -E copy "${include_path}" "${DIST_DIR}/include/${include_file}"
            BYPRODUCTS "${DIST_DIR}/include/${include_file}"
            COMMENT "Installed '${include_file}' include to distribution directory."
        )
    endforeach()
endfunction()
