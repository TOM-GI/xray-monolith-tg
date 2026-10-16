add_module(ReShadeCompat
  TYPE STATIC

  LINKS
  reshade
  FastDynamicCast
  robin_hood

  XRay.Core.Includes

  SOURCES
  addon.cpp
  stdafx.h
)
