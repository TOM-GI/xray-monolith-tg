add_library(robin_hood INTERFACE)
target_folder(robin_hood ${FOLDER_EXTERNAL})

target_sources(robin_hood
  PRIVATE
  robin_hood.h
)

target_include_directories(robin_hood
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}
)
