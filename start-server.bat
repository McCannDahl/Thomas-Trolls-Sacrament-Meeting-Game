@echo off
rem Start script for Thomas Trolls Sacrament Meeting Game
cd /d "%~dp0"
set MSYS_NO_PATHCONV=1
set MSYS2_ARG_CONV_EXCL=*

rem Check for Git Bash in common locations (e.g. C:\Program Files\Git, C:\Git)
set "GIT_BASH=C:\Program Files\Git\bin\bash.exe"
if not exist "%GIT_BASH%" (
    if exist "C:\Git\bin\bash.exe" (
        set "GIT_BASH=C:\Git\bin\bash.exe"
    )
)

if exist "%GIT_BASH%" (
    "%GIT_BASH%" -i -c "export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'; cd ~/Documents/GitHub/Thomas-Trolls-Sacrament-Meeting-Game && exec npm start"
) else (
    npm start
)
pause
