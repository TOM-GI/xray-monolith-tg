include_guard()

cmake_minimum_required(VERSION 3.12)

# Shared compiler flags
set(XRAY_COMPILER_FLAGS
    # Enable rich diagnostics
    /diagnostics:column
    # Disable minimal rebuild
    /Gm-
    # Precise floating-point mode
    /fp:precise
    # Enable multi-process compilation
    /MP
    # Treat warnings as errors
    /WX
    # Use full paths in diagnostic messages
    /FC
    # Use multi-threaded DLL
    /MD
    # Suppress 'Use /EHsc' warning
    /wd4530
    # Disable #pragma deprecated warnings (malloc/free/strcmp in system headers)
    /wd4995
    # Disable redefined symbol warnings (xrDebug STATIC_CHECK)
    /wd4005
    # Disable variable shadowing warnings
    /wd4458
    # Disable 'static' ignored on type definition
    /wd4091
    # Disable narrowing conversion warnings
    /wd4838
    # Use updated __cplusplus macro
    /Zc:__cplusplus
    # Silence C++17 deprecation warnings (concurrent_unordered_map, etc.)
    /D_SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
)

# Debug flags
set(XRAY_COMPILER_FLAGS_DEBUG
    # Store debug information in object files
    /Z7
    # Don't omit frame pointers
    /Oy-
    # Warning level 4
    /W4
    # Enable security check
    /GS
    # Enable exceptions
    /EHsc
)

# Release flags
set(XRAY_COMPILER_FLAGS_RELEASE
    # Aggressive function inlining
    /Ob3
    # Omit frame pointers
    /Oy
    # Favor code speed over size
    /Ot
    # Fiber-safe optimizations
    /GT
    # Function-level linking
    /Gy
    # Intrinsic functions
    /Oi
    # String pooling
    /GF
    # Disable security check
    /GS-
    # Disable iterator debugging
    /D_HAS_ITERATOR_DEBUGGING=0
    /D_SECURE_SCL=0
)

# /Zi (separate PDB) and /GL (whole-program opt) are incompatible with CCache.
# When ccache is active, use /Z7 (debug info in obj) and omit /GL.
if(CCACHE_PROGRAM)
    list(APPEND XRAY_COMPILER_FLAGS_RELEASE /Z7)
else()
    list(APPEND XRAY_COMPILER_FLAGS_RELEASE /Zi /GL)
endif()

# Shared linker options
set(XRAY_LINKER_FLAGS
    # Mark verified with data execution prevention
    /NXCOMPAT
    # Enable large-address awareness
    /LARGEADDRESSAWARE
    # Enable error reporting prompt
    /ERRORREPORT:PROMPT
    # Don't use a dynamic base address
    /DYNAMICBASE:NO
    # Allow larger PDBs
    /PDBPAGESIZE:16384
    # Compress PDBs during build
    /PDBCOMPRESS
    # Treat warnings as errors
    /WX
    # Generate debug information
    /DEBUG
    # Disable multiply-defined symbol warnings (libjpeg / cximage)
    /ignore:4006
    /ignore:4099
)

# Debug linker options
set(XRAY_LINKER_FLAGS_DEBUG
    # Disable COMDAT folding
    /OPT:NOICF
    # Don't eliminate unreferenced functions and data
    /OPT:NOREF
    # Don't use a fixed address space
    /FIXED:NO
)

# Release linker options (/LTCG omitted when CCache is active — requires /GL)
set(XRAY_LINKER_FLAGS_RELEASE
    # Enable COMDAT folding
    /OPT:ICF
    # Eliminate unreferenced functions and data
    /OPT:REF
)
if(NOT CCACHE_PROGRAM)
    list(APPEND XRAY_LINKER_FLAGS_RELEASE /LTCG)
endif()
