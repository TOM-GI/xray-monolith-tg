add_library(DxErr STATIC)

target_folder(DxErr ${FOLDER_EXTERNAL})

target_sources(DxErr PRIVATE
  dxerr.cpp
  dxerr.h
)

target_include_directories(DxErr
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
)


target_compile_options(DxErr
  PUBLIC
  $<$<CXX_COMPILER_ID:MSVC>:/wd4005>
  $<$<CXX_COMPILER_ID:Clang>:-Wno-macro-redefined>
  PRIVATE
  #$<$<CXX_COMPILER_ID:MSVC>:/permissive->
  $<$<CXX_COMPILER_ID:MSVC>:/wd4313>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4474>
  $<$<CXX_COMPILER_ID:MSVC>:/wd4477>
)
