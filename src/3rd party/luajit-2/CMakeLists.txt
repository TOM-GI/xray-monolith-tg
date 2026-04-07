# Copyright (C) 2007-2013 LuaDist.
# Created by Peter Drahoš
# Redistribution and use of this file is allowed according to the terms of the MIT license.
# For details see the COPYRIGHT file distributed with LuaDist.
# Please note that the package source code is licensed under its own license.

cmake_minimum_required(VERSION 3.13)

project(LuaJIT C CXX ASM)

# Version
set(MAJVER 2)
set(MINVER 0)
set(RELVER 5)
set(ABIVER 5.1)
set(NODOTABIVER 51)

set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")
set(LUAJIT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src" CACHE PATH "Location of luajit sources")

option(LUAJIT_BUILD_STATIC_LIB "Build as static library" ON)
option(LUAJIT_BUILD_APP "Build application" OFF)

option(LUA_USE_RELATIVE_LOADLIB "Use modified loadlib.c with support for relative paths on posix systems (Not working)" OFF)

# Extra flags
option(LUAJIT_DISABLE_FFI "Disable the FFI extension to reduce the size of the LuaJIT executable." OFF)
option(LUAJIT_ENABLE_LUA52COMPAT "Features from Lua 5.2 that are unlikely to break existing code are enabled by default." OFF)
option(LUAJIT_DISABLE_JIT "Disable the JIT compiler, i.e. turn LuaJIT into a pure interpreter" OFF)
option(LUAJIT_DISABLE_GC64 "Disable LJ_GC64 mode for x64" OFF)
option(LUAJIT_USE_SYSMALLOC "Use the system provided memory allocator (realloc) instead of the bundled memory allocator." OFF)
option(LUAJIT_USE_VALGRIND "This option is required to run LuaJIT under Valgrind." OFF)
option(LUAJIT_USE_GDBJIT "This is the client for the GDB JIT API." OFF)

option(LUA_USE_APICHECK "Turn on assertions for the Lua/C API to debug problems with lua_* calls." OFF)
option(LUA_USE_ASSERT "Turn on assertions for the whole LuaJIT VM." OFF)

if (WIN32)
    option(LUA_BUILD_WLUA "Build wluajit interpreter for no-console applications." ON)
elseif (APPLE)
    option(LUA_USE_POSIX "Use POSIX functionality." ON)
    option(LUA_USE_DLOPEN "Use dynamic linker to load modules." ON)
else()
    option(LUA_USE_POSIX "Use POSIX functionality." ON)

    if (NOT CMAKE_SYSTEM_NAME STREQUAL "OpenBSD" AND NOT CMAKE_SYSTEM_NAME STREQUAL "NetBSD")
        option(LUA_USE_DLOPEN "Use dynamic linker to load modules." ON)
    endif()
endif()

set(LUA_PATH "LUA_PATH" CACHE STRING "Environment variable to use as package.path")
set(LUA_CPATH "LUA_CPATH" CACHE STRING "Environment variable to use as package.cpath")
set(LUA_INIT "LUA_INIT" CACHE STRING "Environment variable for initial script")

if (APPLE)
    set(ENV{SDKROOT} ${CMAKE_OSX_SYSROOT})
    set(ENV{MACOSX_DEPLOYMENT_TARGET} ${CMAKE_OSX_DEPLOYMENT_TARGET})
endif()

# Clean unnecessary files in LuaJIT source directory
execute_process(
    COMMAND make clean
    WORKING_DIRECTORY ${LUAJIT_DIR}
)

if (LUAJIT_BUILD_STATIC_LIB)
    add_library(LuaJIT STATIC)
else()
    add_library(LuaJIT SHARED)
endif()

set_target_properties(LuaJIT PROPERTIES OUTPUT_NAME lua51)
target_folder(LuaJIT ${FOLDER_LUA})

if(MSVC)
  set(CCOPT_OPT_PREFIX /)
else()
  set(CCOPT_OPT_PREFIX -)
endif()

# Compiler options
if (PROJECT_PLATFORM_E2K)
    set(CCOPT_OPT_LEVEL O3)
else()
    set(CCOPT_OPT_LEVEL O2)
endif()

set(CCOPT "${CMAKE_C_FLAGS} ${CCOPT_OPT_PREFIX}${CCOPT_OPT_LEVEL}")

if (NOT MSVC)
  if (USE_ADDRESS_SANITIZER)
      set(CCOPT "${CCOPT} -fno-stack-protector")
  else()
      set(CCOPT "${CCOPT} -fomit-frame-pointer -fno-stack-protector")
  endif()
endif()

set(CCOPT "${CCOPT} ${CCOPT_OPT_PREFIX}D_FILE_OFFSET_BITS=64 ${CCOPT_OPT_PREFIX}D_LARGEFILE_SOURCE ${CCOPT_OPT_PREFIX}U_FORTIFY_SOURCE")

string(REPLACE " " ";" CCOPT "${CCOPT}")

if (NOT MSVC)
  add_compile_options(
    -Wdeclaration-after-statement
    -Wredundant-decls
    -Wshadow
    -Wpointer-arith
  )
endif()

if (LUAJIT_DISABLE_FFI)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_DISABLE_FFI")
endif()

if (LUAJIT_ENABLE_LUA52COMPAT)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_ENABLE_LUA52COMPAT")
endif()

if (LUAJIT_DISABLE_JIT)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_DISABLE_JIT")
endif()

if (LUAJIT_DISABLE_GC64)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_DISABLE_GC64")
endif()

if (LUAJIT_USE_SYSMALLOC)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_USE_SYSMALLOC")
endif()

if (LUAJIT_USE_VALGRIND)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_USE_VALGRIND")
endif()

if (LUAJIT_USE_GDBJIT)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUAJIT_USE_GDBJIT")
endif()

if (LUA_USE_APICHECK)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUA_USE_APICHECK")
endif()

if (LUA_USE_ASSERT)
    list(APPEND XCFLAGS "${CCOPT_OPT_PREFIX}DLUA_USE_ASSERT")
endif()

set(CCOPTIONS "${CCOPT};${XCFLAGS}")

target_compile_options(LuaJIT PRIVATE ${CCOPTIONS})

# Account for disparity in platform compiler arguments
if(MSVC)
    set(TESTARCH_ARGS /Zc:preprocessor /PD /EP /E lj_arch.h)
else()
    set(TESTARCH_ARGS -dM -E lj_arch.h)
endif()

# Populate INCLUDE
set(CCINCLUDES "")
cmake_path(CONVERT "${CMAKE_C_STANDARD_INCLUDE_DIRECTORIES}" TO_NATIVE_PATH_LIST CCOPT_INCLUDES)
foreach(INC ${CCOPT_INCLUDES})
  list(APPEND CCINCLUDES ${CCOPT_OPT_PREFIX}I${INC})
  list(APPEND HOST_INCLUDES ${INC})
endforeach()

# Run luajit's architecture analyzer
execute_process(
    COMMAND ${CMAKE_C_COMPILER} ${CCOPTIONS} ${CCINCLUDES} ${TESTARCH_ARGS}
    WORKING_DIRECTORY "${LUAJIT_DIR}"
    RESULT_VARIABLE TESTARCH_RESULT
    OUTPUT_VARIABLE TESTARCH_OUTPUT
    ERROR_VARIABLE TESTARCH_ERROR
)

if(${TESTARCH_RESULT})
    message("TESTARCH_ERROR=${TESTARCH_ERROR}")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_X64")
    set(TARGET_LJARCH "x64")
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_X86")
    set(TARGET_LJARCH "x86")
    string(APPEND TARGET_XCFLAGS " -march=i686 -msse -msse2 -mfpmath=sse")
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_ARM64")
    set(TARGET_LJARCH "arm64")
    if ("${TESTARCH_OUTPUT}" MATCHES "__AARCH64EB__")
        set(TARGET_ARCH "-D__AARCH64EB__=1")
    endif()
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_ARM")
    set(TARGET_LJARCH "arm")
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_PPC")
    set(TARGET_LJARCH "ppc")
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_MIPS")
    if ("${TESTARCH_OUTPUT}" MATCHES "MIPSEL")
        set(TARGET_ARCH "-D__MIPSEL__=1")
    endif()
    if ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_MIPS64")
        set(TARGET_LJARCH "mips64")
    else()
        set(TARGET_LJARCH "mips")
    endif()
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_E2K")
    set(TARGET_LJARCH "e2k")
    string(APPEND TARGET_XCFLAGS " -fexceptions")
else()
    message("${TESTARCH_OUTPUT}")
    message(FATAL_ERROR "Unsupported luajit target architecture (see output above)")
endif()

string(APPEND TARGET_ARCH "-DLUAJIT_TARGET=LUAJIT_ARCH_${TARGET_LJARCH}")

if (WIN32)
    if (NOT MSVC)
        target_link_options(LuaJIT
            PRIVATE
            " -shared -Wl,--out-implib,libluajit-${ABIVER}.dll.a"
        )
    endif()

    if (NOT LUAJIT_BUILD_STATIC_LIB)
        string(APPEND HOST_XCFLAGS " -DLUA_BUILD_AS_DLL")
    endif()

    set(LJVM_MODE peobj)
elseif (APPLE)
    if (CMAKE_OSX_DEPLOYMENT_TARGET STREQUAL "")
        message(FATAL_ERROR "Missing export MACOSX_DEPLOYMENT_TARGET=XX.YY")
    endif()

    if (${TARGET_LJARCH} STREQUAL "x64")
        string(APPEND TARGET_XLDFLAGS " -pagezero_size 10000 -image_base 100000000 -image_base 7fff04c4a000")
    elseif (${TARGET_LJARCH} STREQUAL "arm64")
        string(APPEND TARGET_XCFLAGS " -fno-omit-frame-pointer")
    endif()

    set(LJVM_MODE machasm)
else()
    set(LJVM_MODE elfasm)
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_LE 1")
    list(APPEND DASM_FLAGS "-D ENDIAN_LE")
else()
    list(APPEND DASM_FLAGS "-D ENDIAN_BE")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_BITS 64")
    list(APPEND DASM_FLAGS "-D P64")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_HASJIT 1")
    list(APPEND DASM_FLAGS "-D JIT")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_HASFFI 1")
    list(APPEND DASM_FLAGS "-D FFI")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_DUALNUM 1")
    list(APPEND DASM_FLAGS "-D DUALNUM")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_HASFPU 1")
    list(APPEND DASM_FLAGS "-D FPU")
    list(APPEND TARGET_ARCH "-DLJ_ARCH_HASFPU=1")
else()
    list(APPEND TARGET_ARCH "-DLJ_ARCH_HASFPU=0")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ABI_SOFTFP 1")
    list(APPEND TARGET_ARCH "-DLJ_ABI_SOFTFP=1")
else()
    list(APPEND DASM_FLAGS "-D HFABI")
    list(APPEND TARGET_ARCH "-DLJ_ABI_SOFTFP=0")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_NO_UNWIND 1")
    list(APPEND DASM_FLAGS "-D NO_UNWIND")
    list(APPEND TARGET_ARCH "-DLUAJIT_NO_UNWIND")
endif()

if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_VERSION")
    string(REGEX MATCH "LJ_ARCH_VERSION ([0-9]+)$" _ "${TESTARCH_OUTPUT}")
    list(APPEND DASM_FLAGS "-D VER=${CMAKE_MATCH_1}")
else()
    list(APPEND DASM_FLAGS "-D VER=")
endif()

set(DASM_ARCH ${TARGET_LJARCH})

if (WIN32)
    list(APPEND DASM_FLAGS "-D WIN")
endif()

if (TARGET_LJARCH STREQUAL "x64")
    if (NOT "${TESTARCH_OUTPUT}" MATCHES "LJ_FR2 1")
        set(DASM_ARCH "x86")
    endif()
elseif (TARGET_LJARCH STREQUAL "arm")
    if (APPLE)
        list(APPEND DASM_FLAGS "-D IOS")
    endif()
elseif ("${TESTARCH_OUTPUT}" MATCHES "LJ_TARGET_MIPSR6")
    list(APPEND DASM_FLAGS "-D MIPSR6")
endif()

if (TARGET_LJARCH STREQUAL "ppc")
    if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_SQRT 1")
        list(APPEND DASM_FLAGS "-D SQRT")
    endif()
    if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_ROUND 1")
        list(APPEND DASM_FLAGS "-D ROUND")
    endif()
    if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_PPC32ON64 1")
        list(APPEND DASM_FLAGS "-D GPR64")
    endif()
    if ("${TESTARCH_OUTPUT}" MATCHES "LJ_ARCH_PPC64")
        set(DASM_ARCH "ppc64")
    endif()
endif()

set(HOST_ACFLAGS "${CMAKE_C_FLAGS} ${CCOPTIONS} ${TARGET_ARCH}")

string(APPEND TARGET_XCFLAGS " -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -U_FORTIFY_SOURCE")

separate_arguments(HOST_ACFLAGS)
separate_arguments(DASM_FLAGS)
separate_arguments(TARGET_XCFLAGS)

target_compile_options(LuaJIT
    PRIVATE
    ${TARGET_XCFLAGS}
)

set(DASM_DASC "${LUAJIT_DIR}/vm_${DASM_ARCH}.dasc")
set(DASM "${CMAKE_CURRENT_SOURCE_DIR}/dynasm/dynasm.lua")
set(BUILDVM_ARCH "${CMAKE_CURRENT_BINARY_DIR}/buildvm_arch.h")

add_subdirectory("HostBuildTools/minilua")

add_custom_command(OUTPUT ${BUILDVM_ARCH}
    COMMAND $<TARGET_FILE:minilua> ${DASM} ${DASM_FLAGS} -o ${BUILDVM_ARCH} ${DASM_DASC}
    VERBATIM
)

add_custom_target(buildvm_arch)
target_folder(buildvm_arch ${FOLDER_LUA_BUILD})

target_sources(buildvm_arch
  PRIVATE
  ${BUILDVM_ARCH}
)

add_subdirectory("HostBuildTools/buildvm")

list(APPEND LJLIB_C
    "${LUAJIT_DIR}/lib_base.c"
    "${LUAJIT_DIR}/lib_bit.c"
    "${LUAJIT_DIR}/lib_debug.c"
    "${LUAJIT_DIR}/lib_ffi.c"
    "${LUAJIT_DIR}/lib_io.c"
    "${LUAJIT_DIR}/lib_jit.c"
    "${LUAJIT_DIR}/lib_math.c"
    "${LUAJIT_DIR}/lib_os.c"
    "${LUAJIT_DIR}/lib_string.c"
    "${LUAJIT_DIR}/lib_table.c"
)

if (LUA_USE_RELATIVE_LOADLIB)
    list(APPEND LJLIB_C "${LUAJIT_DIR}/lib_package_rel.c")
else()
    list(APPEND LJLIB_C "${LUAJIT_DIR}/lib_package.c")
endif()

macro(add_buildvm_target target mode)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${target}
        COMMAND $<TARGET_FILE:buildvm> ARGS -m ${mode} -o ${CMAKE_CURRENT_BINARY_DIR}/${target} ${ARGN}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS buildvm ${ARGN}
    )
endmacro()

if (WIN32)
    add_buildvm_target(lj_vm.obj peobj)
    set(LJ_VM_SRC "${CMAKE_CURRENT_BINARY_DIR}/lj_vm.obj")
else()
    add_buildvm_target(lj_vm.S ${LJVM_MODE})
    set(LJ_VM_SRC "${CMAKE_CURRENT_BINARY_DIR}/lj_vm.S")
    set_source_files_properties("${LJ_VM_SRC}" PROPERTIES LANGUAGE CXX)
endif()

add_buildvm_target("lj_bcdef.h" "bcdef" ${LJLIB_C})
add_buildvm_target("lj_ffdef.h" "ffdef" ${LJLIB_C})
add_buildvm_target("lj_libdef.h" "libdef" ${LJLIB_C})
add_buildvm_target("lj_recdef.h" "recdef" ${LJLIB_C})
add_buildvm_target("lj_folddef.h" "folddef" "${LUAJIT_DIR}/lj_opt_fold.c")
add_buildvm_target("jit/vmdef.lua" "libvm" ${LJLIB_C})

target_sources(LuaJIT PRIVATE
    "${LJ_VM_SRC}"
    "${CMAKE_CURRENT_BINARY_DIR}/lj_ffdef.h"
    "${CMAKE_CURRENT_BINARY_DIR}/lj_bcdef.h"
    "${CMAKE_CURRENT_BINARY_DIR}/lj_libdef.h"
    "${CMAKE_CURRENT_BINARY_DIR}/lj_recdef.h"
    "${CMAKE_CURRENT_BINARY_DIR}/lj_folddef.h"
)

if (CMAKE_UNITY_BUILD)
    target_sources(LuaJIT PRIVATE "${LUAJIT_DIR}/ljamalg.c")
else()
    target_sources(LuaJIT PRIVATE
        ${LJLIB_C}
        "${LUAJIT_DIR}/lauxlib.h"
        "${LUAJIT_DIR}/lib_aux.c"
        "${LUAJIT_DIR}/lib_init.c"
        "${LUAJIT_DIR}/lj_alloc.c"
        "${LUAJIT_DIR}/lj_alloc.h"
        "${LUAJIT_DIR}/lj_api.c"
        "${LUAJIT_DIR}/lj_asm.c"
        "${LUAJIT_DIR}/lj_asm.h"
        "${LUAJIT_DIR}/lj_bc.c"
        "${LUAJIT_DIR}/lj_bc.h"
        "${LUAJIT_DIR}/lj_bcdump.h"
        "${LUAJIT_DIR}/lj_bcread.c"
        "${LUAJIT_DIR}/lj_bcwrite.c"
        "${LUAJIT_DIR}/lj_carith.c"
        "${LUAJIT_DIR}/lj_carith.h"
        "${LUAJIT_DIR}/lj_ccall.c"
        "${LUAJIT_DIR}/lj_ccall.h"
        "${LUAJIT_DIR}/lj_ccallback.c"
        "${LUAJIT_DIR}/lj_ccallback.h"
        "${LUAJIT_DIR}/lj_cconv.c"
        "${LUAJIT_DIR}/lj_cconv.h"
        "${LUAJIT_DIR}/lj_cdata.c"
        "${LUAJIT_DIR}/lj_cdata.h"
        "${LUAJIT_DIR}/lj_char.c"
        "${LUAJIT_DIR}/lj_char.h"
        "${LUAJIT_DIR}/lj_clib.c"
        "${LUAJIT_DIR}/lj_clib.h"
        "${LUAJIT_DIR}/lj_cparse.c"
        "${LUAJIT_DIR}/lj_cparse.h"
        "${LUAJIT_DIR}/lj_crecord.c"
        "${LUAJIT_DIR}/lj_crecord.h"
        "${LUAJIT_DIR}/lj_ctype.c"
        "${LUAJIT_DIR}/lj_ctype.h"
        "${LUAJIT_DIR}/lj_debug.c"
        "${LUAJIT_DIR}/lj_debug.h"
        "${LUAJIT_DIR}/lj_def.h"
        "${LUAJIT_DIR}/lj_dispatch.c"
        "${LUAJIT_DIR}/lj_dispatch.h"
        "${LUAJIT_DIR}/lj_err.c"
        "${LUAJIT_DIR}/lj_err.h"
        "${LUAJIT_DIR}/lj_errmsg.h"
        "${LUAJIT_DIR}/lj_ff.h"
        "${LUAJIT_DIR}/lj_ffrecord.c"
        "${LUAJIT_DIR}/lj_ffrecord.h"
        "${LUAJIT_DIR}/lj_frame.h"
        "${LUAJIT_DIR}/lj_func.c"
        "${LUAJIT_DIR}/lj_func.h"
        "${LUAJIT_DIR}/lj_gc.c"
        "${LUAJIT_DIR}/lj_gc.h"
        "${LUAJIT_DIR}/lj_gdbjit.c"
        "${LUAJIT_DIR}/lj_gdbjit.h"
        "${LUAJIT_DIR}/lj_ir.c"
        "${LUAJIT_DIR}/lj_ircall.h"
        "${LUAJIT_DIR}/lj_iropt.h"
        "${LUAJIT_DIR}/lj_jit.h"
        "${LUAJIT_DIR}/lj_lex.c"
        "${LUAJIT_DIR}/lj_lex.h"
        "${LUAJIT_DIR}/lj_lib.c"
        "${LUAJIT_DIR}/lj_lib.h"
        "${LUAJIT_DIR}/lj_load.c"
        "${LUAJIT_DIR}/lj_mcode.c"
        "${LUAJIT_DIR}/lj_mcode.h"
        "${LUAJIT_DIR}/lj_meta.c"
        "${LUAJIT_DIR}/lj_meta.h"
        "${LUAJIT_DIR}/lj_obj.c"
        "${LUAJIT_DIR}/lj_obj.h"
        "${LUAJIT_DIR}/lj_opt_dce.c"
        "${LUAJIT_DIR}/lj_opt_fold.c"
        "${LUAJIT_DIR}/lj_opt_loop.c"
        "${LUAJIT_DIR}/lj_opt_mem.c"
        "${LUAJIT_DIR}/lj_opt_narrow.c"
        "${LUAJIT_DIR}/lj_opt_sink.c"
        "${LUAJIT_DIR}/lj_opt_split.c"
        "${LUAJIT_DIR}/lj_parse.c"
        "${LUAJIT_DIR}/lj_parse.h"
        "${LUAJIT_DIR}/lj_record.c"
        "${LUAJIT_DIR}/lj_record.h"
        "${LUAJIT_DIR}/lj_snap.c"
        "${LUAJIT_DIR}/lj_snap.h"
        "${LUAJIT_DIR}/lj_state.c"
        "${LUAJIT_DIR}/lj_state.h"
        "${LUAJIT_DIR}/lj_str.c"
        "${LUAJIT_DIR}/lj_str.h"
        "${LUAJIT_DIR}/lj_strscan.c"
        "${LUAJIT_DIR}/lj_strscan.h"
        "${LUAJIT_DIR}/lj_tab.c"
        "${LUAJIT_DIR}/lj_tab.h"
        "${LUAJIT_DIR}/lj_trace.c"
        "${LUAJIT_DIR}/lj_trace.h"
        "${LUAJIT_DIR}/lj_traceerr.h"
        "${LUAJIT_DIR}/lj_udata.c"
        "${LUAJIT_DIR}/lj_udata.h"
        "${LUAJIT_DIR}/lj_vm.h"
        "${LUAJIT_DIR}/lj_vmevent.c"
        "${LUAJIT_DIR}/lj_vmevent.h"
        "${LUAJIT_DIR}/lj_vmmath.c"
        "${LUAJIT_DIR}/lua.h"
        "${LUAJIT_DIR}/lua.hpp"
        "${LUAJIT_DIR}/luaconf.h"
        "${LUAJIT_DIR}/luajit.h"
        "${LUAJIT_DIR}/lualib.h"

        "${LUAJIT_DIR}/xr_alloc.c"
    )
endif()

target_include_directories(LuaJIT
    PUBLIC
    "${LUAJIT_DIR}"

    PRIVATE
    "${CMAKE_CURRENT_BINARY_DIR}"
)

target_link_libraries(LuaJIT
    PRIVATE
    $<$<BOOL:${LUA_USE_POSIX}>:m>
    $<$<BOOL:${LUA_USE_DLOPEN}>:dl>
)

if (MSVC)
  target_compile_options(LuaJIT
      PRIVATE
      /wd5287
  )
else()
  target_compile_options(LuaJIT
      PRIVATE
      -Wno-comment
  )
endif()

set_target_properties(LuaJIT PROPERTIES
    PREFIX ""
    UNITY_BUILD OFF
)

install(
    TARGETS LuaJIT LIBRARY
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

if (LUAJIT_BUILD_APP)
    add_executable(luajit
        ${LUAJIT_DIR}/luajit.c
    )

    target_link_libraries(luajit
        PRIVATE
        LuaJIT
    )

    target_link_options(luajit
        PRIVATE
        ${TARGET_XLDFLAGS}
    )

    if (LUA_BUILD_WLUA)
        add_executable(wluajit WIN32
            "${LUAJIT_DIR}/wmain.c"
            "${LUAJIT_DIR}/luajit.c"
            "${LUAJIT_DIR}/luajit.rc"
        )
        target_link_libraries(wluajit
            PRIVATE
            LuaJIT
        )
    endif()
endif()
