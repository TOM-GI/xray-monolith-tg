include_guard()

set(XRAY_COMPILER_FLAGS
  # Compatibility flags
  -Wno-implicit-function-declaration
  -Wno-c++11-narrowing
  -Wno-invalid-token-paste
  -Wno-nonportable-include-path
  -Wno-shift-negative-value
  -Wno-address-of-temporary
  -Wno-register

  # Initialize to zero for MSVC equivalence
  -ftrivial-auto-var-init=zero
  # ...but warn about it
  -Wuninitialized
)

# Explicitly state when we're compiling for Win32
if(WIN32)
  list(APPEND XRAY_COMPILER_FLAGS -DWIN32)
endif()

set(XRAY_COMPILER_FLAGS_DEBUG
  # Disable optimizations
  -O0

  # Generate full debug info
  -g
)

set(XRAY_COMPILER_FLAGS_RELEASE
  # Enable aggressive optimizations
  -O3

  # Optimize loop execution
  -funroll-loops
  
  # Enable link-time optimization
  -flto=full

  # Disable iterator debugging
  -D_HAS_ITERATOR_DEBUGGING=0
  -D_SECURE_SCL=0
)

set(XRAY_LINKER_FLAGS_RELEASE
  # Enable aggressive optimizations
  -O3

  # Optimize loop execution
  -funroll-loops

  # Enable link-time optimization
  -flto=full
)
