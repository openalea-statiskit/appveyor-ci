:: EXPECTED ENV VARS: PLATFORM (either x86 or x64)
::                    PYTHON_VERSION (either 27, 33, 35 etc. - only major version is extracted)
::
::
:: To build extensions for 64 bit Python 3, we need to configure environment
:: variables to use the MSVC 2010 C++ compilers from GRMSDKX_EN_DVD.iso of:
:: MS Windows SDK for Windows 7 and .NET Framework 4 (SDK v7.1)
::
:: To build extensions for 64 bit Python 2, we need to configure environment
:: variables to use the MSVC 2008 C++ compilers from GRMSDKX_EN_DVD.iso of:
:: MS Windows SDK for Windows 7 and .NET Framework 3.5 (SDK v7.0)
::
:: 32 bit builds, and 64-bit builds for 3.5 and beyond, do not require specific
:: environment configurations.
::
:: Note: this script needs to be run with the /E:ON and /V:ON flags for the
:: cmd interpreter, at least for (SDK v7.0)
::
:: More details at:
:: https://github.com/cython/cython/wiki/64BitCythonExtensionsOnWindows
:: http://stackoverflow.com/a/13751649/163740
::
:: Author: Phil Elson
:: Original Author: Olivier Grisel (https://github.com/ogrisel/python-appveyor-demo)
:: License: CC0 1.0 Universal: http://creativecommons.org/publicdomain/zero/1.0/
::
:: Notes about batch files for Python people:
::
:: Quotes in values are literally part of the values:
::      SET FOO="bar"
:: FOO is now five characters long: " b a r "
:: If you don't want quotes, don't include them on the right-hand side.
::
:: The CALL lines at the end of this file look redundant, but if you move them
:: outside of the IF clauses, they do not run properly in the SET_SDK_64==Y
:: case, I don't know why.
@ECHO OFF

SET COMMAND_TO_RUN=%*
SET WIN_SDK_ROOT=C:\Program Files\Microsoft SDKs\Windows

:: Based on the Python version, determine what SDK version to use, and whether
:: to set the SDK for 64-bit.
IF %CONDA_VERSION% == 2 (
    SET WINDOWS_SDK_VERSION="v7.0"
    SET SET_SDK_64=Y
) ELSE (
    IF %CONDA_VERSION% == 3 (
        SET WINDOWS_SDK_VERSION="v7.1"
        SET SET_SDK_64=N
    ) ELSE (
        ECHO Unsupported Python version: "%CONDA_VERSION%"
        EXIT /B 1
    )
)

IF "%PLATFORM%"=="x64" (
    IF %SET_SDK_64% == Y (
        ECHO Configuring Windows SDK %WINDOWS_SDK_VERSION% for Python %CONDA_VERSION% on a 64 bit architecture
        SET DISTUTILS_USE_SDK=1
        SET MSSdk=1
        "%WIN_SDK_ROOT%\%WINDOWS_SDK_VERSION%\Setup\WindowsSdkVer.exe" -q -version:%WINDOWS_SDK_VERSION%
        "%WIN_SDK_ROOT%\%WINDOWS_SDK_VERSION%\Bin\SetEnv.cmd" /x64 /release
        ECHO Executing: %COMMAND_TO_RUN%
        call %COMMAND_TO_RUN% || EXIT /B 1
    ) ELSE (
        ECHO Using default MSVC build environment for 64 bit architecture
        ECHO Executing: %COMMAND_TO_RUN%
        call %COMMAND_TO_RUN% || EXIT /B 1
    )
) ELSE (
    ECHO Using default MSVC build environment for 32 bit architecture
    ECHO Executing: %COMMAND_TO_RUN%
    call %COMMAND_TO_RUN% || EXIT /B 1
)