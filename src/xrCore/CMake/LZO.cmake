add_library(LZO STATIC
  rt_lzo_init.cpp
  rt_lzo1x_1.cpp
  rt_lzo1x_9x.cpp
  rt_lzo1x_d1.cpp
  rt_lzo1x_d2.cpp
  rt_lzo1x_d3.cpp
)

target_include_directories(LZO
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(LZO
  PRIVATE
  FastDynamicCast
  robin_hood
)

target_compile_options(LZO
  PRIVATE
  $<$<CXX_COMPILER_ID:MSVC>:/wd5033>
)

set_target_properties(LZO
  PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
)
