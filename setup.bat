@echo off
rem Set up the DIV -> Godot remakes on Windows.
rem   setup.bat                   check prerequisites, then import every Godot project (headless)
rem   setup.bat check             only check prerequisites
rem   setup.bat import [Game ...] check, then import all projects (or only the listed ones)
rem   setup.bat build  [Game ...] check, import, then build the web exports and public/index.html
rem                               via "_web/build_and_deploy.sh --no-deploy" (never deploys)
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "MODE=%~1"
if "%MODE%"=="" set "MODE=import"
if /i not "%MODE%"=="check" if /i not "%MODE%"=="import" if /i not "%MODE%"=="build" (
  echo Usage: setup.bat [check ^| import [Game ...] ^| build [Game ...]]
  exit /b 2
)
shift
set "GAMES="
:collect
if not "%~1"=="" (
  set "GAMES=!GAMES! %~1"
  shift
  goto collect
)
if "%GAMES%"=="" for /d %%D in (*) do if exist "%%D\project.godot" set "GAMES=!GAMES! %%D"

set "MISSING=0"
echo === Checking prerequisites ===

rem Godot 4.7.2 (+ web export templates)
set "GODOT_VER="
for /f "delims=" %%V in ('godot --version 2^>nul') do if not defined GODOT_VER set "GODOT_VER=%%V"
if not defined GODOT_VER (
  echo [MISSING] godot - install Godot 4.7.2 and put it on PATH as "godot"
  set "MISSING=1"
) else (
  echo [ok] godot !GODOT_VER!
  if not "!GODOT_VER:~0,6!"=="4.7.2." echo [warn] the projects are made for Godot 4.7.2
)
set "TPL=%APPDATA%\Godot\export_templates\4.7.2.stable\web_nothreads_release.zip"
if exist "%TPL%" (
  echo [ok] Godot 4.7.2 web export templates
) else (
  echo [MISSING] Godot 4.7.2 web export templates ^(%TPL%^) - Godot editor: Editor ^> Manage Export Templates ^> Download
  set "MISSING=1"
)

rem Python 3.12+
set "PY_VER="
for /f "tokens=2" %%V in ('python --version 2^>nul') do set "PY_VER=%%V"
if not defined PY_VER (
  echo [MISSING] python - install Python 3.12 and put it on PATH as "python"
  set "MISSING=1"
) else (
  echo [ok] python !PY_VER!
)

rem Git Bash (runs _web/build_and_deploy.sh); its own brotli is used by the script
set "BASH="
for %%B in ("%ProgramFiles%\Git\bin\bash.exe" "%ProgramFiles(x86)%\Git\bin\bash.exe" "%LocalAppData%\Programs\Git\bin\bash.exe") do if not defined BASH if exist %%B set "BASH=%%~B"
if not defined BASH (
  echo [MISSING] Git Bash - install Git for Windows ^(https://git-scm.com^)
  set "MISSING=1"
) else (
  echo [ok] bash !BASH!
  "!BASH!" -c "command -v brotli" >nul 2>nul && (echo [ok] brotli) || (
    echo [MISSING] brotli CLI ^(not found in Git Bash^) - e.g. "winget install Google.Brotli" or MSYS2 "pacman -S brotli"
    set "MISSING=1"
  )
)

rem Node.js (npx wrangler, only needed to deploy)
set "NODE_VER="
for /f "delims=" %%V in ('node --version 2^>nul') do set "NODE_VER=%%V"
if not defined NODE_VER (
  echo [MISSING] node / npx - install Node.js ^(only needed to deploy with "npx wrangler"^)
  set "MISSING=1"
) else (
  echo [ok] node !NODE_VER! - to deploy, log in once with: npx wrangler login
)

if "%MISSING%"=="1" (
  echo.
  echo Some prerequisites are missing ^(see above^).
  if /i "%MODE%"=="check" exit /b 1
  if not defined GODOT_VER exit /b 1
)
if /i "%MODE%"=="check" exit /b 0

echo.
echo === Importing Godot projects ===
set "FAILED="
for %%G in (%GAMES%) do (
  echo --- %%G
  godot --headless --path "%%G" --import >"%TEMP%\divremake_import.log" 2>&1
  if errorlevel 1 (
    set "FAILED=!FAILED! %%G"
    type "%TEMP%\divremake_import.log"
  )
)
if defined FAILED (
  echo Import failed for:%FAILED%
  exit /b 1
)
echo All projects imported.
if /i not "%MODE%"=="build" exit /b 0

echo.
echo === Building web exports (no deploy) ===
if not defined BASH exit /b 1
"%BASH%" _web/build_and_deploy.sh --no-deploy %GAMES%
exit /b %ERRORLEVEL%
