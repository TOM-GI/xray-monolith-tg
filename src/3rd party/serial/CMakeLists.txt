add_library(serial INTERFACE)

target_folder(serial ${FOLDER_EXTERNAL})

target_include_directories(serial
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}
)
