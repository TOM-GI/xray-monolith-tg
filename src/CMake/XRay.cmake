add_module(XRay
  INCLUDES
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${XRAY_SDK_INCLUDE}

  SOURCES
  build_config_defines.h
)

include(XRay.Platform)
