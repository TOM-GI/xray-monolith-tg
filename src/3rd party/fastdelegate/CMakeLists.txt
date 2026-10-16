add_library(fastdelegate INTERFACE)
target_folder(fastdelegate ${FOLDER_EXTERNAL})

target_sources(fastdelegate
  PRIVATE
  fastdelegate.h
)

target_include_directories(fastdelegate
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}
)
