add_module(XRay.XMLParser
  TYPE STATIC
  
  INCLUDES
  ${CMAKE_CURRENT_SOURCE_DIR}

  DEFINES
  XRXMLPARSER_EXPORTS

  LINKS
  FastDynamicCast
  robin_hood
  TinyXML

  XRay.Core.Defines
  
  XRay.Core.Includes

  PRECOMPILES
  $<$<COMPILE_LANGUAGE:CXX>:xrCore.h>

  SOURCES
  xrXMLParser.cpp
  xrXMLParser.h
)
