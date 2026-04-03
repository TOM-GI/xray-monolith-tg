add_module(XRay.Collision
  TYPE STATIC

  INCLUDES
  ${CMAKE_CURRENT_SOURCE_DIR}

  DEFINES
  [[ENGINE_API=]]
  XRCDB_EXPORTS

  LINKS
  fastdelegate
  FastDynamicCast
  optick
  robin_hood

  XRay.Core.Defines
  XRay.Engine.Defines
  
  XRay.Includes
  XRay.CPUPipe.Includes
  XRay.Core.Includes
  XRay.Engine.Includes
  XRay.Physics.Includes
  XRay.Render.API.Includes
  XRay.Render.Common.Includes
  XRay.ServerEntities.Includes

  PRECOMPILES
  #[["xrCore.h"]]
  #alloc.h
  #[["opcode.h"]]
  
  SOURCES
  #cl_raypick.cpp
  Frustum.cpp
  Opcode.cpp
  OPC_AABB.cpp
  OPC_AABBCollider.cpp
  OPC_AABBTree.cpp
  OPC_Collider.cpp
  OPC_Common.cpp
  OPC_Container.cpp
  OPC_Matrix3x3.cpp
  OPC_Matrix4x4.cpp
  OPC_Model.cpp
  OPC_OBB.cpp
  OPC_OBBCollider.cpp
  OPC_OptimizedTree.cpp
  OPC_Plane.cpp
  OPC_PlanesCollider.cpp
  OPC_Point.cpp
  OPC_Ray.cpp
  OPC_RayCollider.cpp
  OPC_SphereCollider.cpp
  OPC_TreeBuilders.cpp
  OPC_TreeCollider.cpp
  OPC_Triangle.cpp
  OPC_VolumeCollider.cpp
  xrCDB.cpp
  xrCDB_box.cpp
  xrCDB_Collector.cpp
  xrCDB_frustum.cpp
  xrCDB_ray.cpp

  Frustum.h
  Opcode.h
  stdafx.h
  xrCDB.h
)

set_source_files_properties(
  ISpatial_q_frustum.cpp
  ISpatial_q_ray.cpp
  ISpatial_verify.cpp
  OPC_OBBCollider.cpp
  OPC_TreeCollider.cpp
  PROPERTIES
  SKIP_UNITY_BUILD_INCLUSION true
)

include(XRay.Collision.Engine)
