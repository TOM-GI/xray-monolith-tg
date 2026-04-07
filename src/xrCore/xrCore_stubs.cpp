// Stub implementations for symbols defined in xrEngine/xrServerEntities
// that xrCore references via extern. The real implementations override
// these at link time when the final executable is assembled.

#include "stdafx.h"
#include "xrCore.h"

// Defined in xrEngine/x_ray.cpp
XRCORE_API u32 build_id = 0;
XRCORE_API LPCSTR build_date = __DATE__;

// Defined in xrServerEntities/script_ini_file_script.cpp
xr_string get_modded_exes_version_string() { return "0"; }
LPCSTR get_modded_exes_name() { return "Modded Exes"; }

// Defined in xrServerEntities/script_engine.cpp
void printLuaStack() {}

// Defined in xrEngine/XR_IOConsole.cpp
enum Console_mark;
bool is_console_mark(Console_mark) { return false; }
