add_module(XRay.Render.API
  TYPE STATIC
  
  INCLUDES
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/../../Include/xrApi

  LINKS
  XRay.Render.Common.Includes

  DEFINES
  $<$<PLATFORM_ID:Windows>:_WIN32_WINDOWS=0x0410>
  $<$<PLATFORM_ID:Windows>:WIN32_LEAN_AND_MEAN>
  
  SOURCES
  xrAPI.cpp
  ../../Include/xrApi/xrAPI.h
)

set_target_properties(XRay.Render.API PROPERTIES OUTPUT_NAME xrAPI)
