@echo off
setlocal

set CONFIG=Release
set PRESET=MSVS.MSVC.MSBuild
set PRESET_AVX=%PRESET%.AVX
set OUTPUT_DIR=%~dp0_release

echo === Configuring non-AVX build ===
cmake --preset %PRESET% -DUSE_CCACHE=Off
if %errorlevel% neq 0 goto :error

echo === Configuring AVX build ===
cmake --preset %PRESET_AVX% -DUSE_CCACHE=Off
if %errorlevel% neq 0 goto :error

echo === Building non-AVX (%CONFIG%) ===
cmake --build --preset %PRESET%.%CONFIG%
if %errorlevel% neq 0 goto :error

echo === Building AVX (%CONFIG%) ===
cmake --build --preset %PRESET_AVX%.%CONFIG%
if %errorlevel% neq 0 goto :error

echo === Collecting binaries ===
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

set SRC=%~dp0_build\%PRESET%\Binaries\%CONFIG%
set SRC_AVX=%~dp0_build\%PRESET_AVX%\Binaries\%CONFIG%

echo Copying non-AVX from %SRC%
copy /Y "%SRC%\*.exe" "%OUTPUT_DIR%\"
copy /Y "%SRC%\*.pdb" "%OUTPUT_DIR%\"

echo Copying AVX from %SRC_AVX%
copy /Y "%SRC_AVX%\*.exe" "%OUTPUT_DIR%\"
copy /Y "%SRC_AVX%\*.pdb" "%OUTPUT_DIR%\"

echo === Done! Binaries in %OUTPUT_DIR% ===
goto :eof

:error
echo === Build failed with error %errorlevel% ===
exit /b %errorlevel%
