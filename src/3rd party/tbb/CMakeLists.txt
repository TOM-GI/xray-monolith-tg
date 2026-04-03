add_library(tbb INTERFACE)

target_folder(tbb ${FOLDER_EXTERNAL})

target_include_directories(tbb
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}
)
