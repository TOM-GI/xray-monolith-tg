add_library(sm_boost INTERFACE)

target_include_directories(sm_boost
  INTERFACE
  ${CMAKE_SOURCE_DIR}/sdk/include
)

target_sources(sm_boost
  INTERFACE
  boost_legacy.h
  traits.hpp
  typelist.hpp
)
