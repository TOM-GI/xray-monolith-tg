add_library(giflib STATIC)

target_folder(giflib ${FOLDER_EXTERNAL})

target_sources(giflib PRIVATE
  dgif_lib.c
  egif_lib.c
  gif_err.c
  gif_font.c
  gif_hash.c
  gifalloc.c
  openbsd-reallocarray.c

  gif_hash.h
  gif_lib.h
  gif_lib_private.h
)

target_include_directories(giflib
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
)

target_compile_definitions(giflib
  PRIVATE
  _CRT_SECURE_NO_WARNINGS
  _CRT_NONSTDC_NO_DEPRECATE
)

target_compile_options(giflib
  PRIVATE
  $<$<C_COMPILER_ID:MSVC>:/wd4244>
  $<$<C_COMPILER_ID:MSVC>:/wd4267>
  $<$<C_COMPILER_ID:MSVC>:/wd4996>
  $<$<C_COMPILER_ID:Clang>:-Wno-deprecated-declarations>
)
