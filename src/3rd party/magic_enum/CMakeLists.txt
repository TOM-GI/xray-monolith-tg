add_library(magic_enum INTERFACE)
target_folder(magic_enum ${FOLDER_EXTERNAL})

target_sources(magic_enum
  PRIVATE
  magic_enum.hpp
  magic_enum_all.hpp
  magic_enum_containers.hpp
  magic_enum_flags.hpp
  magic_enum_format.hpp
  magic_enum_fuse.hpp
  magic_enum_iostream.hpp
  magic_enum_switch.hpp
  magic_enum_utility.hpp
)

target_include_directories(magic_enum
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}      # enables #include "magic_enum.hpp"
  ${CMAKE_CURRENT_SOURCE_DIR}/..   # enables #include <magic_enum/magic_enum.hpp>
)
