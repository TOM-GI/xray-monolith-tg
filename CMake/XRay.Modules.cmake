set(SHOW_SUBMODULES Off CACHE BOOL "Display submodules in IDEs")

# Use a single directory for build artifacts
set(COMPILE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/Binaries/$<CONFIG>)

# Add ./CMake to the module path and include NAME
macro(add_cmake_directory NAME)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMake)
  include(${NAME})
endmacro()

function(find_parent TARGET OUT_VAR)
  # Unset the output var to prevent leakage across runs
  unset(${OUT_VAR})

  # Create a segment list from our target name
  string(REPLACE "." ";" PATH ${TARGET})

  # Loop
  while(true)
    # Pop the last segment of our list
    list(POP_BACK PATH SEG)

    # If the list is empty, break
    if(NOT SEG)
      break()
    endif()

    # Join our shortened path into a name
    list(JOIN PATH "." CAND)

    # Test if it refers to a valid target
    if(TARGET "${CAND}")
      # If so, we've found our parent
      set(${OUT_VAR} ${CAND})
      return(PROPAGATE ${OUT_VAR})
    endif()
  endwhile()
endfunction()

function(add_submodule NAME SUBNAME)
  # Create our submodule's name
  set(SUBMODULE ${NAME}.${SUBNAME})

  # Add it as an interface
  add_library(${SUBMODULE} INTERFACE)

  # Copy parent's folder
  get_target_property(FOLDER ${NAME} FOLDER)
  set_target_properties(${SUBMODULE} PROPERTIES FOLDER ${FOLDER})

  if(SHOW_SUBMODULES)
    # Force IDEs to show the submodule by adding the current cmake file as a source
    target_sources(${SUBMODULE} PRIVATE ${CMAKE_CURRENT_LIST_FILE})
  endif()

  # Precompiled-header submodules must NOT be linked into the parent.
  # INTERFACE_PRECOMPILE_HEADERS propagates transitively across every
  # PUBLIC/INTERFACE link edge, which would leak this module's PCH (and the
  # macros it pulls in) into any foreign target that links the parent.
  # The PCH is instead applied PRIVATEly to the parent in add_module /
  # apply_precompiles, which keeps intra-module PCH sharing but stops leakage.
  if(SUBNAME STREQUAL Precompiles)
    return()
  endif()

  # Link our submodule to its parent
  target_link_libraries(${NAME} ${TYPE_PUBLIC} ${SUBMODULE})
endfunction()

# Apply the precompiled headers carried by a *.Precompiles interface target
# to TARGET as PRIVATE headers. PRIVATE does not populate
# INTERFACE_PRECOMPILE_HEADERS, so the headers do not propagate to consumers,
# while still being compiled into TARGET (intra-module PCH sharing preserved).
function(apply_precompiles TARGET PRECOMPILE_TARGET)
  # PRIVATE PCH is only valid on targets that compile sources; skip INTERFACE
  # libraries, which carry no sources and reject PRIVATE properties.
  get_target_property(TGT_TYPE ${TARGET} TYPE)
  if(TGT_TYPE STREQUAL INTERFACE_LIBRARY)
    return()
  endif()

  get_target_property(PCH ${PRECOMPILE_TARGET} INTERFACE_PRECOMPILE_HEADERS)
  if(PCH)
    target_precompile_headers(${TARGET} PRIVATE ${PCH})
  endif()
endfunction()

# X-Ray Module Constructor
function(add_module NAME)
  # Parse keyword arguments
  cmake_parse_arguments(PARSE_ARGV 1 ARG
    "NO_LINK_PARENT"
    "TYPE"
    "SOURCES;INCLUDES;PRECOMPILES;DEFINES;LINKS"
  )

  # Determine whether we have any C or CPP sources
  set(HAS_SOURCES false)
  if(ARG_SOURCES MATCHES "\\.cpp" OR ARG_SOURCES MATCHES "\\.c")
    set(HAS_SOURCES true)
  endif()
  
  # If type has not been set explicitly, infer...
  if(NOT DEFINED ARG_TYPE)
    # If we have sources, this is a STATIC module, otherwise INTERFACE
    set(ARG_TYPE INTERFACE)
  endif()

  # If this is an interface module, override public and private semantics
  if(ARG_TYPE STREQUAL INTERFACE)
    set(TYPE_PUBLIC INTERFACE)
    set(TYPE_PRIVATE INTERFACE)
  else()
    set(TYPE_PUBLIC PUBLIC)
    set(TYPE_PRIVATE PRIVATE)
  endif()

  # Store semantics to parent scope for future reference
  set(${NAME}_TYPE_PUBLIC ${TYPE_PUBLIC} PARENT_SCOPE)
  set(${NAME}_TYPE_PRIVATE ${TYPE_PRIVATE} PARENT_SCOPE)

  # Add our module
  add_library(${NAME} ${ARG_TYPE})

  # Find our parent module
  find_parent(${NAME} PARENT)

  # Convert our module name into a folder path and apply it
  string(REPLACE "." ";" FOLDER "${NAME}")
  list(LENGTH FOLDER FOLDER_LEN)
  if(FOLDER_LEN GREATER 1)
    list(POP_BACK FOLDER)
    list(JOIN FOLDER "/" FOLDER)
  endif()

  string(REPLACE "XRay" "X-Ray" FOLDER ${FOLDER})
  set_target_properties(${NAME} PROPERTIES FOLDER ${FOLDER})

  # Set unity build mode
  set_target_properties(${NAME} PROPERTIES UNITY_BUILD_MODE GROUP)

  # Set unity group
  set_source_files_properties(
    ${ARG_SOURCES}
    PROPERTIES
    UNITY_GROUP ${NAME}
  )

  # Apply artifact output directories
  set_target_properties(${NAME}
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
    RUNTIME_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
    PDB_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
    COMPILE_PDB_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
  )

  # If we have a parent, link this module to it
  if(NOT ARG_NO_LINK_PARENT AND TARGET ${PARENT})
    target_link_libraries(${PARENT} ${${PARENT}_TYPE_PRIVATE} ${NAME})
  endif()

  # Create include directory target
  if(ARG_INCLUDES)
    add_submodule(${NAME} Includes)

    # Register includes with the submodule
    target_include_directories(${NAME}.Includes INTERFACE ${ARG_INCLUDES})

    if(SHOW_SUBMODULES)
      # Glob all headers to illustrate include scope
      set(INCLUDE_SOURCES "")
      foreach(INCLUDE ${ARG_INCLUDES})
        file(GLOB_RECURSE TEMP ${INCLUDE}/*.h)
        list(APPEND INCLUDE_SOURCES ${TEMP})
      endforeach()

      target_sources(${NAME}.Includes PRIVATE ${INCLUDE_SOURCES})
    endif()
  endif()

  # Create linkage target
  if(ARG_LINKS)
    # Pull any *.Precompiles entries out of the link list. Linking them would
    # re-export their INTERFACE_PRECOMPILE_HEADERS transitively (leaking foreign
    # PCH into anyone who links this module). Apply them PRIVATEly instead so
    # this module still shares the PCH without propagating it.
    set(LINK_LIST "")
    set(PRECOMPILE_LINKS "")
    foreach(LINK ${ARG_LINKS})
      if(LINK MATCHES "\\.Precompiles$")
        list(APPEND PRECOMPILE_LINKS ${LINK})
      else()
        list(APPEND LINK_LIST ${LINK})
      endif()
    endforeach()

    if(LINK_LIST)
      add_submodule(${NAME} Links)
      target_link_libraries(${NAME}.Links INTERFACE ${LINK_LIST})
    endif()

    foreach(PRECOMPILE_LINK ${PRECOMPILE_LINKS})
      apply_precompiles(${NAME} ${PRECOMPILE_LINK})
    endforeach()
  endif()

  # Create compile definition target
  if(ARG_DEFINES)
    add_submodule(${NAME} Defines)
    target_compile_definitions(${NAME}.Defines INTERFACE ${ARG_DEFINES})
  endif()

  # Create precompiled header target
  if(ARG_PRECOMPILES)
    # The .Precompiles interface target is the single source of truth for this
    # module's PCH and is consumed explicitly (e.g. via LINKS by submodules that
    # want to share it). add_submodule deliberately does NOT link it into the
    # parent, so apply the headers to the parent PRIVATEly here. PRIVATE keeps
    # the parent's own sources using the PCH without re-exporting it to foreign
    # targets that link this module.
    add_submodule(${NAME} Precompiles)
    target_precompile_headers(${NAME}.Precompiles INTERFACE ${ARG_PRECOMPILES})

    # INTERFACE modules carry no sources of their own, so a PRIVATE PCH is both
    # invalid and pointless for them; only real (STATIC/etc.) modules need it.
    if(NOT ARG_TYPE STREQUAL INTERFACE)
      target_precompile_headers(${NAME} PRIVATE ${ARG_PRECOMPILES})
    endif()
  endif()

  # Add current CMake file to our sources
  list(APPEND ARG_SOURCES ${CMAKE_CURRENT_LIST_FILE})

  # Add sources
  target_sources(${NAME} PRIVATE ${ARG_SOURCES})

  # If this is an interface with sources,
  # expose them separately to ensure IDEs don't elide the module
  if(ARG_TYPE STREQUAL INTERFACE AND HAS_SOURCES)  
    target_sources(${NAME} INTERFACE ${ARG_SOURCES})
  endif()
endfunction()

# Enable unique IDing for unity build robustness
if(CMAKE_UNITY_BUILD)
  set(UNITY_BUILD_UNIQUE_ID true)
endif()
