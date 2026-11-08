@echo off
set MSYS_NO_PATHCONV=1
set MSYS2_ARG_CONV_EXCL=*

rem Check for Git Bash in common locations (e.g. C:\Program Files\Git, C:\Git) or use PATH
set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"
if not exist "%GIT_BASH%" (
    if exist "C:\Git\bin\bash.exe" (
        set "GIT_BASH=C:\Git\bin\bash.exe"
    ) else (
        where bash.exe >nul 2>&1
        if %ERRORLEVEL% equ 0 (
            set "GIT_BASH=bash.exe"
        )
    )
)

if exist "%GIT_BASH%" (
    "%GIT_BASH%" -i -c "export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'; cd ~/Documents/GitHub/Thomas-Trolls-Sacrament-Meeting-Game && exec npm start"
) else (
    cd /d "%~dp0"
    npm start
)

pause
