add_library(FastDynamicCast INTERFACE)
target_folder(FastDynamicCast ${FOLDER_EXTERNAL})

target_sources(FastDynamicCast
  PRIVATE
  fast_dynamic_cast.hpp
)

target_include_directories(FastDynamicCast
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/..
)
