add_library(CxImage STATIC)

target_folder(CxImage ${FOLDER_EXTERNAL})

target_sources(CxImage PRIVATE
  ximacfg.cpp
  ximaenc.cpp
  ximaexif.cpp
  ximage.cpp
  ximainfo.cpp
  ximaint.cpp
  ximajpg.cpp
  ximalpha.cpp
  ximalyr.cpp
  ximapal.cpp
  ximasel.cpp
  ximath.cpp
  xmemfile.cpp

  ximacfg.h
  ximadef.h
  ximage.h
  ximaiter.h
  ximajpg.h
  ximath.h
  xiofile.h
  xfile.h
  xmemfile.h
)

target_include_directories(CxImage
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  PRIVATE
  ${CMAKE_SOURCE_DIR}/sdk/include
)

target_link_libraries(CxImage
  PRIVATE
  libjpeg
  XRay.Core
)

target_compile_options(CxImage
  PRIVATE
  #$<$<CXX_COMPILER_ID:MSVC>:/permissive->
  $<$<CXX_COMPILER_ID:MSVC>:/wd4100>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4267>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4324>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4456>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4457>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4611>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4702>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4996>
  $<$<CXX_COMPILER_ID:MSVC>:/wd5033>
  $<$<CXX_COMPILER_ID:Clang>:-Wno-switch>
)

target_compile_definitions(CxImage
  PUBLIC
  $<$<CXX_COMPILER_ID:MSVC>:JAS_WIN_MSVC_BUILD>
  _CRT_SECURE_NO_WARNINGS
)
