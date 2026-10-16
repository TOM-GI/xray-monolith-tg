add_library(TinyXML STATIC
  tinyxml.cpp
  tinyxmlerror.cpp
  tinyxmlparser.cpp
)

target_include_directories(TinyXML
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(TinyXML
  PRIVATE
  FastDynamicCast
  robin_hood
  XRay.Core.Includes
)

set_target_properties(TinyXML
  PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY ${COMPILE_OUTPUT_DIR}
)
