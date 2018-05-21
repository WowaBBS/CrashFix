@echo off
cls

setlocal ENABLEDELAYEDEXPANSION 

SET Version=1
SET Root=%~dp0a\..
SET SRC_DIR=%Root%\crashfix_service
SET BUILD_DIR=%Root%\Build
SET INSTALL_DIR=%Root%\Install

if not exist "%INSTALL_DIR%\.Version"                goto :DoBuild
SET /P ActualVersion=<"%INSTALL_DIR%\.Version"
if not "%Version% "=="%ActualVersion%"               goto :DoBuild
if not exist "%INSTALL_DIR%\bin\crashfixd.exe"       goto :DoBuild

goto :SkipBuild
:DoBuild

if not "%VcVars%"=="" goto SkipVcVars
::set VcVars=%ProgramFiles(x86)%\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat
set VcVars=%ProgramFiles(x86)%\Microsoft Visual Studio/2017/Community/VC\Auxiliary\Build\vcvarsamd64_x86.bat
::call SearchAtl.bat
:SkipVcVars
call "%VcVars%"

rem set PATH=C:\Programs\Dev\CMake\V2x8x9\bin;%PATH%
rem set PATH=C:\Programs\Dev\CMake\V3x11x0rc4\bin;%PATH%
if exist C:\Programs\Dev\CMake\V3x10x3\bin\cmake.exe set PATH=C:\Programs\Dev\CMake\V3x10x3\bin;%PATH%

::echo %SRC_DIR%
mkdir "%BUILD_DIR%" 2>nul
pushd "%BUILD_DIR%"
Set Param=
::Set Param=%Param% -G "Visual Studio 10 2010"
::Set Param=%Param% -T v100
Set Param=%Param% -G "Visual Studio 15 2017"
::Set CMAKE_CXX_FLAGS=-I "%AtlMfc%\include"
::Set Param=%Param% -DCMAKE_CXX_FLAGS=$(CMAKE_CXX_FLAGS)

::Set Param=%Param% -DCRASHRPT_BUILD_SHARED_LIBS=
::Set Param=%Param% -DCRASHRPT_LINK_CRT_AS_DLL=


Set Param=%Param% %SRC_DIR%
::echo %Param%
::exit /b
cmake %Param%
::>../CMake.log

Set LogFile=%BUILD_DIR%\Log\MSBuild_Release.log
Set Param=
::Set Param=%Param% /fileLoggerParameters:LogFile="%LogFile%";verbosity=normal;Encoding=UTF-8;ShowCommandLine
Set Param=%Param% /fileLoggerParameters:LogFile="%LogFile%";verbosity=normal;Encoding=cp866;ShowCommandLine

msbuild %Param% /t:Build /p:Configuration=Release ALL_BUILD.vcxproj

Set LogFile=%BUILD_DIR%\Log\MSBuild_Debug.log
Set Param=
::Set Param=%Param% /fileLoggerParameters:LogFile="%LogFile%";verbosity=normal;Encoding=UTF-8;ShowCommandLine
Set Param=%Param% /fileLoggerParameters:LogFile="%LogFile%";verbosity=normal;Encoding=cp866;ShowCommandLine

msbuild %Param% /t:Build /p:Configuration=Debug ALL_BUILD.vcxproj
popd

xcopy %BUILD_DIR%\bin\crashfixd.exe  %INSTALL_DIR%\bin\ /YDI
xcopy %BUILD_DIR%\bin\dumper.exe     %INSTALL_DIR%\bin\ /YDI

xcopy %BUILD_DIR%\lib\libdumper.lib  %INSTALL_DIR%\lib\ /YDI
xcopy %BUILD_DIR%\lib\libdumperd.lib %INSTALL_DIR%\lib\ /YDI

echo %Version% >"%INSTALL_DIR%\.Version"
:SkipBuild

endlocal
