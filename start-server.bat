@echo off
rem Start script for Thomas Trolls Sacrament Meeting Game
cd /d "%~dp0"
if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" -i -c "cd ~/Documents/GitHub/Thomas-Trolls-Sacrament-Meeting-Game && exec npm start"
) else (
    npm start
)
pause
