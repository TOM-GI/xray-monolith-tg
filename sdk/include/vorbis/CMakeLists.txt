add_library(libvorbis STATIC)
target_folder(libvorbis ${FOLDER_SDK})

target_sources(libvorbis
  PRIVATE
  lib/analysis.c
  lib/bitrate.c
  lib/block.c
  lib/codebook.c
  lib/envelope.c
  lib/floor0.c
  lib/floor1.c
  lib/info.c
  lib/lookup.c
  lib/lpc.c
  lib/lsp.c
  lib/mapping0.c
  lib/mdct.c
  lib/psy.c
  lib/registry.c
  lib/res0.c
  lib/sharedbook.c
  lib/smallft.c
  lib/synthesis.c
  lib/vorbisenc.c
  lib/window.c

  codec.h
  vorbisenc.h
  vorbisfile.h
  lib/backends.h
  lib/bitrate.h
  lib/codebook.h
  lib/codec_internal.h
  lib/envelope.h
  lib/highlevel.h
  lib/lookup.h
  lib/lookup_data.h
  lib/lpc.h
  lib/lsp.h
  lib/masking.h
  lib/mdct.h
  lib/misc.h
  lib/os.h
  lib/psy.h
  lib/registry.h
  lib/scales.h
  lib/smallft.h
  lib/window.h
)

target_include_directories(libvorbis
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${XRAY_SDK_INCLUDE}
  PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib
)

target_link_libraries(libvorbis
  PUBLIC
  libogg
)

# libvorbisfile
add_library(libvorbisfile STATIC)
target_folder(libvorbisfile ${FOLDER_SDK})

target_sources(libvorbisfile
  PRIVATE
  lib/vorbisfile.c
)

target_include_directories(libvorbisfile
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${XRAY_SDK_INCLUDE}
  PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/lib
)

target_link_libraries(libvorbisfile
  PUBLIC
  libvorbis
  libogg
)
