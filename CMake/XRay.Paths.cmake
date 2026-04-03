include_guard()

# Define SDK paths
set(XRAY_EXTERNAL "${CMAKE_SOURCE_DIR}/src/3rd party")
set(XRAY_SDK ${CMAKE_SOURCE_DIR}/sdk)
set(XRAY_SDK_BIN ${XRAY_SDK}/bin)
set(XRAY_SDK_INCLUDE ${XRAY_SDK}/include)
set(XRAY_SDK_LIB ${XRAY_SDK}/libraries/x64)
set(XRAY_SOURCES ${CMAKE_SOURCE_DIR}/src)

# Make SDK libraries available to the linker (for #pragma comment(lib) in headers)
link_directories(${XRAY_SDK_LIB})
