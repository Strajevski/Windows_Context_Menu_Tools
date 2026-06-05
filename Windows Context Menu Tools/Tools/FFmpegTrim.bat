@echo off
setlocal

if "%~1"=="" (
    echo Usage: drag a video file onto this script, or launch it from the context menu.
    pause
    exit /b 1
)

echo Input file:
echo %~1
echo.

set /p START=Start time (HH:MM:SS or MM:SS):
set /p END=End time   (HH:MM:SS or MM:SS):

ffmpeg -ss %START% -to %END% -i "%~1" -c copy "%~dpn1_trimmed.mp4"

echo.
echo Done.
pause