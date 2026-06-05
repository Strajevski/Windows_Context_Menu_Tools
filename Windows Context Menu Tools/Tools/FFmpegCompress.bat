@echo off
setlocal

echo.
echo Choose output codec:
echo 1 - HEVC quick compress
echo 2 - AV1 smaller compress
set /p MODE=Enter 1 or 2: 

if "%MODE%"=="1" (
    set "CODEC=hevc_nvenc"
    set "DEFAULTMBPS=8"
    set "LABEL=HEVC"
) else if "%MODE%"=="2" (
    set "CODEC=av1_nvenc"
    set "DEFAULTMBPS=6"
    set "LABEL=AV1"
) else (
    echo Invalid choice.
    pause
    exit /b 1
)

echo.
set /p MBPS=%LABEL% target video bitrate in Mbps (default = %DEFAULTMBPS%): 
if "%MBPS%"=="" set MBPS=%DEFAULTMBPS%

ffmpeg -i "%~1" -c:v %CODEC% -preset p7 -b:v %MBPS%M -c:a copy "%~dpn1_compressed.mp4"

pause