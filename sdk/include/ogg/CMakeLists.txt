add_library(libogg STATIC)
target_folder(libogg ${FOLDER_SDK})

target_sources(libogg
  PRIVATE
  src/bitwise.c
  src/framing.c

  ogg.h
  os_types.h
)

target_include_directories(libogg
  PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${XRAY_SDK_INCLUDE}
)
