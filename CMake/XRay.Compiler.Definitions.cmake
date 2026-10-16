include_guard()

# Configure compile definitions
add_compile_definitions(
  # Suppress deprecation errors
  _SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS
)

# Activate interprocedural optimization for release builds
# Profiled stays off to match vcxproj (WholeProgramOptimization=false, no /LTCG)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_PROFILED Off)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE On)
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION_RELWITHDEBINFO On)
