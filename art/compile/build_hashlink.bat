@echo off
color 0a
cd ..\..
echo BUILDING GAME
haxelib run lime build hl -release
echo.
echo done.
pause
pwd
explorer.exe export\release\hl\bin