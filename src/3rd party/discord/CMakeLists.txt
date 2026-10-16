add_library(discord INTERFACE)

target_folder(discord ${FOLDER_EXTERNAL})

target_sources(discord
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}/achievement_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/achievement_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/activity_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/activity_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/application_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/application_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/core.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/core.h
  ${CMAKE_CURRENT_SOURCE_DIR}/discord.h
  ${CMAKE_CURRENT_SOURCE_DIR}/event.h
  ${CMAKE_CURRENT_SOURCE_DIR}/ffi.h
  ${CMAKE_CURRENT_SOURCE_DIR}/image_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/image_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/lobby_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/lobby_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/network_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/network_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/overlay_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/overlay_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/relationship_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/relationship_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/storage_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/storage_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/store_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/store_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/types.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/types.h
  ${CMAKE_CURRENT_SOURCE_DIR}/user_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/user_manager.h
  ${CMAKE_CURRENT_SOURCE_DIR}/voice_manager.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/voice_manager.h
)

target_include_directories(discord
  INTERFACE
  ${CMAKE_CURRENT_SOURCE_DIR}
)

add_library(discord_game_sdk SHARED IMPORTED)
set_property(
  TARGET discord_game_sdk
  PROPERTY IMPORTED_LOCATION
  ${CMAKE_SOURCE_DIR}/sdk/binaries/discord_game_sdk.dll
)
set_property(
  TARGET discord_game_sdk
  PROPERTY
  IMPORTED_IMPLIB
  ${CMAKE_SOURCE_DIR}/sdk/libraries/x64.old/discord_game_sdk.lib
)

target_link_libraries(discord
  INTERFACE
  discord_game_sdk
)
