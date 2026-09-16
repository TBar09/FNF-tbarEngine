@echo off
color 0a
cd ..\..
echo BUILDING GAME
haxelib run lime build hl -debug
echo.
echo done.
pause
pwd
explorer.exe export\debug\hl\bin