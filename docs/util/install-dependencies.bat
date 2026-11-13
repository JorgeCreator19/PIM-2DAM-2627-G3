@echo off
setlocal EnableExtensions
REM ===========================================================================
REM  Vapor - Windows development environment installer
REM
REM  Run as Administrator (right click > "Run as administrator").
REM  Safe to run more than once: anything already installed is skipped.
REM
REM  Installs (only if missing):
REM    General : Chocolatey, Git, VS Code, Python 3.11, Node.js LTS, Docker Desktop (+ WSL 2)
REM    Server  : VS 2022 Build Tools (C++ workload + Windows SDK), CMake, Ninja, vcpkg (+ VCPKG_ROOT)
REM    Core    : Rust (rustup, stable, clippy, rustfmt), flutter_rust_bridge_codegen 2.13.0
REM    App     : Flutter SDK, Java 17 (Temurin), Android Studio
REM ===========================================================================

set "FAILED="
set "REBOOT_NEEDED="
set "FRB_VERSION=2.13.0"

echo.
echo ===========================================================================
echo  Vapor - installing development dependencies
echo  Make sure you have an internet connection. This can take a long time.
echo ===========================================================================
echo.

REM --- Administrator check
net session >nul 2>&1
if errorlevel 1 (
    echo [ERROR] This script needs administrator privileges.
    echo         Right click the file and choose "Run as administrator".
    echo.
    pause
    exit /b 1
)
echo [OK] Administrator privileges confirmed.

REM --- Chocolatey
call :section "Chocolatey"
if not defined ChocolateyInstall set "ChocolateyInstall=%ALLUSERSPROFILE%\chocolatey"
where choco >nul 2>nul
if not errorlevel 1 (
    echo [OK] Chocolatey is already installed.
    goto :choco_ready
)
echo Installing Chocolatey...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
set "PATH=%PATH%;%ChocolateyInstall%\bin"
where choco >nul 2>nul
if errorlevel 1 (
    echo [ERROR] Chocolatey could not be installed. Nothing else can be installed without it.
    echo         Check that you have an internet connection and try again.
    echo.
    pause
    exit /b 1
)
:choco_ready
choco --version

REM --- General tools
call :ensure "where git"          "Git"                 "git"
call :ensure "where code"         "Visual Studio Code"  "vscode"
call :ensure "py -3.11 --version" "Python 3.11"         "python311"
call :ensure "where node"         "Node.js LTS"         "nodejs-lts"

REM --- Git identity (only asked if not configured yet)
call :section "Git configuration"
where git >nul 2>nul
if errorlevel 1 (
    echo [SKIP] Git is not available, skipping configuration.
    goto :git_config_done
)
set "GIT_NAME="
set "GIT_EMAIL="
for /f "delims=" %%i in ('git config --global user.name 2^>nul') do set "GIT_NAME=%%i"
for /f "delims=" %%i in ('git config --global user.email 2^>nul') do set "GIT_EMAIL=%%i"
if not defined GIT_NAME set /p "GIT_NAME=Enter your Git user name: "
if not defined GIT_EMAIL set /p "GIT_EMAIL=Enter your Git user email: "
if defined GIT_NAME git config --global user.name "%GIT_NAME%"
if defined GIT_EMAIL git config --global user.email "%GIT_EMAIL%"
echo [OK] Git user: %GIT_NAME% ^<%GIT_EMAIL%^>
:git_config_done

REM --- Visual Studio 2022 Build Tools (C++)
REM  Must go before Rust: Rust on Windows uses the MSVC linker.
call :section "Visual Studio 2022 C++ Build Tools"
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "VS_PATH="
if exist "%VSWHERE%" for /f "usebackq delims=" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "VS_PATH=%%i"
REM (the VS path contains "(x86)", so it must not be echoed inside a parenthesized block)
if not defined VS_PATH goto :vs_install
echo [OK] C++ build tools found in: %VS_PATH%
goto :vs_done
:vs_install
echo Installing Visual Studio 2022 Build Tools with the C++ workload. This takes a while...
call choco install visualstudio2022buildtools -y --no-progress
call :check_rc "VS 2022 Build Tools"
call choco install visualstudio2022-workload-vctools -y --no-progress --package-parameters "--includeRecommended"
call :check_rc "VS 2022 C++ workload"
call :refresh
:vs_done

REM --- CMake and Ninja
call :ensure "where cmake" "CMake" "cmake --installargs ADD_CMAKE_TO_PATH=System"
call :ensure "where ninja" "Ninja" "ninja"

REM --- vcpkg
call :section "vcpkg"
where git >nul 2>nul
if errorlevel 1 (
    echo [SKIP] Git is required to install vcpkg.
    set "FAILED=%FAILED%, vcpkg"
    goto :vcpkg_done
)
REM Ignore a VCPKG_ROOT that is not a git clone (for example the copy bundled with Visual Studio)
if defined VCPKG_ROOT if not exist "%VCPKG_ROOT%\.git" set "VCPKG_ROOT="
if not defined VCPKG_ROOT set "VCPKG_ROOT=%USERPROFILE%\vcpkg"
if exist "%VCPKG_ROOT%\.git" (
    echo Updating existing vcpkg in %VCPKG_ROOT%...
    git -C "%VCPKG_ROOT%" pull --ff-only
) else (
    echo Cloning vcpkg into %VCPKG_ROOT%...
    git clone https://github.com/microsoft/vcpkg.git "%VCPKG_ROOT%"
)
if errorlevel 1 (
    echo [ERROR] Could not clone or update vcpkg.
    set "FAILED=%FAILED%, vcpkg"
    goto :vcpkg_done
)
if not exist "%VCPKG_ROOT%\vcpkg.exe" call "%VCPKG_ROOT%\bootstrap-vcpkg.bat" -disableMetrics
if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo [ERROR] vcpkg bootstrap failed.
    set "FAILED=%FAILED%, vcpkg"
    goto :vcpkg_done
)
REM CMakePresets.json uses $env{VCPKG_ROOT} to find the vcpkg toolchain
setx VCPKG_ROOT "%VCPKG_ROOT%" >nul
"%VCPKG_ROOT%\vcpkg.exe" version
echo [OK] VCPKG_ROOT set to %VCPKG_ROOT%
:vcpkg_done

REM --- Rust
call :ensure "where rustup" "Rust - rustup" "rustup.install"
call :section "Rust toolchain"
where rustup >nul 2>nul
if errorlevel 1 (
    echo [SKIP] rustup is not available.
    goto :rust_done
)
rustup default stable
rustup component add clippy rustfmt
rustc --version
cargo --version

call :section "flutter_rust_bridge_codegen %FRB_VERSION%"
flutter_rust_bridge_codegen --version 2>nul | find "%FRB_VERSION%" >nul
if not errorlevel 1 (
    echo [OK] flutter_rust_bridge_codegen %FRB_VERSION% is already installed.
    goto :rust_done
)
echo Compiling flutter_rust_bridge_codegen. This takes several minutes...
cargo install flutter_rust_bridge_codegen --version %FRB_VERSION% --locked --force
if errorlevel 1 (
    echo [ERROR] flutter_rust_bridge_codegen could not be installed.
    set "FAILED=%FAILED%, flutter_rust_bridge_codegen"
)
:rust_done

REM --- Flutter and Android
call :ensure "where flutter" "Flutter SDK"   "flutter"
call :ensure "where java"    "Java 17"       "temurin17"
call :section "Android Studio"
if exist "%ProgramFiles%\Android\Android Studio\bin\studio64.exe" (
    echo [OK] Android Studio is already installed.
) else (
    call choco install androidstudio -y --no-progress
    call :check_rc "Android Studio"
    call :refresh
)

REM --- Docker Desktop (needs WSL 2)
call :section "Docker Desktop"
where docker >nul 2>nul
if not errorlevel 1 (
    echo [OK] Docker Desktop is already installed.
    goto :docker_done
)
echo Enabling WSL 2...
wsl --install --no-distribution
if errorlevel 1 echo [WARN] WSL could not be enabled. Check that virtualization is enabled in the BIOS.
call choco install docker-desktop -y --no-progress
call :check_rc "Docker Desktop"
set "REBOOT_NEEDED=1"
:docker_done

REM --- Summary
call :refresh
call :section "Summary"
if defined FAILED (
    echo [ERROR] These items failed:%FAILED:~1%
    echo         Scroll up to see the errors, fix them and run this script again.
) else (
    echo [OK] All dependencies are installed.
)
echo.
if defined REBOOT_NEEDED (
    echo [!] RESTART WINDOWS before using Docker or the new tools.
    echo.
)
echo Next steps, in a NEW terminal:
echo   1. Open Android Studio once to download the Android SDK, then run:
echo        flutter doctor --android-licenses
echo        flutter doctor
echo   2. Build the server from the "x64 Native Tools Command Prompt for VS 2022":
echo        cd server
echo        cmake --preset debug
echo        cmake --build --preset debug
echo   3. Start the development services, from the repo root in PowerShell:
echo        .\infra\scripts\dev-up.ps1
echo.
pause
endlocal
exit /b 0


REM ===========================================================================
REM  Subroutines
REM ===========================================================================

REM call :ensure "<check command>" "<display name>" "<choco package [args]>"
REM Installs the package only when the check command fails.
REM Display names must not contain parentheses (they are echoed inside a block).
:ensure
call :section "%~2"
call %~1 >nul 2>nul
if not errorlevel 1 (
    echo [OK] %~2 is already installed.
    exit /b 0
)
echo Installing %~2...
call choco install %~3 -y --no-progress
call :check_rc "%~2"
call :refresh
exit /b 0

REM Checks the exit code of the last choco install. 3010 and 1641 mean "OK, reboot needed".
:check_rc
set "RC=%errorlevel%"
if "%RC%"=="0" exit /b 0
if "%RC%"=="3010" goto :check_rc_reboot
if "%RC%"=="1641" goto :check_rc_reboot
echo [ERROR] %~1 failed to install, exit code %RC%.
set "FAILED=%FAILED%, %~1"
exit /b 1
:check_rc_reboot
set "REBOOT_NEEDED=1"
exit /b 0

REM Reloads PATH and other environment variables so newly installed tools work in this window
:refresh
if exist "%ChocolateyInstall%\bin\RefreshEnv.cmd" call "%ChocolateyInstall%\bin\RefreshEnv.cmd" >nul
exit /b 0

REM Echoes a section header, for readability
:section
echo.
echo ---------------------------------------------------------------------------
echo  %~1
echo ---------------------------------------------------------------------------
exit /b 0
