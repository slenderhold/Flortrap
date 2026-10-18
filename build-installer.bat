@echo off
setlocal
rem One click: builds dist\Flortrap-Setup.exe (the installer with Flortrap inside).
rem Installs the .NET 8 SDK into a local .dotnet folder by itself if it is missing.
title Flortrap installer build
cd /d "%~dp0"

rem Find the folder with Flortrap.sln, even if this file was moved into a subfolder.
set TRIES=0
:findroot
if exist "Flortrap\Flortrap.csproj" if exist "Flortrap.Setup\Flortrap.Setup.csproj" goto :found
set /a TRIES+=1
if %TRIES% GEQ 4 goto :noroot
cd ..
goto :findroot

:noroot
echo Could not find the Flortrap project folders. Unzip the whole archive and run this file again.
goto :fail

:found
echo Project folder: %CD%

rem ---- .NET 8 SDK: use the installed one, otherwise download a private copy ----
set HAVE8=
for /f "delims=" %%v in ('dotnet --list-sdks 2^>nul ^| findstr /b "8\."') do set HAVE8=1
if defined HAVE8 goto :sdkready

if exist ".dotnet\dotnet.exe" goto :usedotnetlocal
echo [0/3] .NET 8 SDK not found, downloading it (about 250 MB, once)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -UseBasicParsing https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1; & .\dotnet-install.ps1 -Channel 8.0 -InstallDir '%CD%\.dotnet'"
if errorlevel 1 goto :fail
:usedotnetlocal
set "DOTNET_ROOT=%CD%\.dotnet"
set "PATH=%CD%\.dotnet;%PATH%"
:sdkready
set DOTNET_CLI_TELEMETRY_OPTOUT=1
set DOTNET_NOLOGO=1

echo [1/3] Publishing Flortrap...
if exist publish rmdir /s /q publish
dotnet publish Flortrap\Flortrap.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:DebugType=None -o publish\app
if errorlevel 1 goto :fail

echo [2/3] Packing the app into the installer...
if exist Flortrap.Setup\payload rmdir /s /q Flortrap.Setup\payload
mkdir Flortrap.Setup\payload
powershell -NoProfile -Command "Compress-Archive -Path 'publish\app\*' -DestinationPath 'Flortrap.Setup\payload\payload.zip' -Force"
if errorlevel 1 goto :fail

echo [3/3] Building the installer...
if exist dist rmdir /s /q dist
dotnet publish Flortrap.Setup\Flortrap.Setup.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:DebugType=None -o dist
if errorlevel 1 goto :fail

echo.
echo Done: %CD%\dist\Flortrap-Setup.exe
start "" explorer "%CD%\dist"
pause
exit /b 0

:fail
echo.
echo Build failed, see the messages above and send them to me.
pause
exit /b 1
