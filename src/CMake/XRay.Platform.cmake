set(XRPLATFORM_H xrPlatform.h)

set(BENCHMARK_BUILD Off
  CACHE BOOL
  "Compile in additional performance testing machinery."
)

message(STATUS "${CMAKE_SYSTEM_NAME} Platform")
message(STATUS "    Benchmark: ${BENCHMARK_BUILD}")
message(STATUS)

# Single source of truth for global definitions
add_module(XRay.Platform
  INCLUDES
  ${CMAKE_CURRENT_SOURCE_DIR}

  DEFINES
  # Benchmark build
  $<$<BOOL:${BENCHMARK_BUILD}>:BENCHMARK_BUILD>

  # STL Exceptions
  HAS_EXCEPTIONS=1
  # X-Ray Exceptions
  $<IF:$<CONFIG:Debug>,XRAY_EXCEPTIONS=1,XRAY_EXCEPTIONS=0>
  # Luabind exception handler for non-debug builds
  $<IF:$<CONFIG:Debug>,,LUABIND_NO_EXCEPTIONS>

  LINKS
  XRay.Includes

  SOURCES
  ${XRPLATFORM_H}
)

# Force include platform header
target_compile_options(XRay.Platform
  INTERFACE
  $<$<CXX_COMPILER_ID:MSVC>:/FI${XRPLATFORM_H}>
  $<$<CXX_COMPILER_ID:Clang>:-include${XRPLATFORM_H}>
  $<$<CXX_COMPILER_ID:GNU>:-include${XRPLATFORM_H}>
)

# Platform-specific submodules
include(XRay.Platform.Windows)

# Link to all subsequent libraries, i.e. XRay.*
# Externals will need to link XRay.Platform manually
link_libraries(XRay.Platform)