add_library(icu INTERFACE)

target_folder(icu ${FOLDER_EXTERNAL})

target_include_directories(icu
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)
