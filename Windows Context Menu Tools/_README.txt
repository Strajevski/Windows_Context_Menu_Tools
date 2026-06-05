This folder contains scripts on how to remove some clutter from the right-click menus in Windows file explorer, and include two scripts using ffmpeg to trim and compress .mp4 .mkv and .mov file formats
NOTE: the compression uses NVIDIA NVENC hardware encoding and therefore requires a supported NVIDIA GPU. Trim should work regardless since it does not re-encode.


Instructions:

1)removing "edit with clipchamp" and "ask Copilot" right click options from both the w11 main right click and the w10 "show more options" menu

* double click to open "disable-clipchamp.reg" and "disable-ask-copilot.reg" respectively
* when prompted for admin permissions, and given a warning about registry editing, just click yes. Everything will be fine, you can open both in notepad to see exactly what they do if you like.
* for other right click options: there are right click options that come with PowerToys if you have it (I would recommend, lots of useful tools there). Open PowerToys settings > File Management > each of the items either disable them entirely or disable their shell integrations
* to undo this later, I have included "enable-*.reg" files as well that will put them back in.

2)adding custom batch files to right click extended context menus (unfortunately I do not know how to add them to the main w11 right click. ): very complicated.) (right click > show more options, or shift+right click)
* requires FFmpeg to be installed. Go to https://ffmpeg.org/download.html for download and instructions if you do not have it. Useful anyways for all sorts of quick and precise editing in the command line
* requires FFmpeg to be added to PATH for the Windows command line.
  *  Locate the folder containing ffmpeg.exe (usually something like C:\ffmpeg\bin or C:\Tools\ffmpeg\bin).
  * Copy the full path of that folder.
  * Press Win + R, type: `sysdm.cpl`and hit enter.
  * Go to the Advanced tab → Environment Variables.
  * Under "System variables", select "Path" and click Edit.
  * Click New and paste the folder path copied in step 2.
  * Click OK on all windows.
  * Close and reopen Command Prompt.
* Check: open Command Prompt and run: `ffmpeg -version` (copy&paste without the `` and hit enter), if installed and the path is configured correctly, it should show version info etc. otherwise it will give an error "'ffmpeg' is not recognised as an internal or external command"
* After adding FFmpeg to PATH, you may need to close and reopen File Explorer, Command Prompt, or sign out and back in before the change takes effect. Try this if it doesn't work, but it should be fine.

* Copy the "Tools" folder and its contents (two .bat files) to C: such that you have C:\\Tools\FFmpegCompress.bat and C:\\Tools\FFmpegTrim.bat
* If your OS drive is for some bizarre reason not C:, you will need to edit the respective .reg files in notepad or notepad++ to reflect their location
* optionally test (it does work tho lol): drag and drop a video onto the respective .bat in file explorer (or a desktop shortcut, if you don't want to/no admin perms to do right click option)
* double click to open "enable-FFmpeg-compress.reg" and "enable-FFmpeg-trim.reg", and click yes when prompted for admin perms and registry editing warning
* to undo this later, I have included "disable-*.reg" files as well that will put them back in.

* upon running the scripts: a cmd console will open and prompt you with input instructions
  * Trim: write start time and hit enter, write stop time and hit enter, wait for it to finish, it will prompt you to press any key to continue and it will close the console and you will see "{original}_trimmed.mp4" in the same folder
    * this operation is lossless and does not compress/re-encode the video at all.
    * ideally trim and then compress, to save time so it doesn't have to compress the whole longer video
  * Compress:
    * First choose an output codec:
      * HEVC (H.265) - good balance of speed, quality and file size. Recommended for first pass.
      * AV1 - newer codec which can produce a similar visual quality, but takes longer to encode.
    * Then enter a target video bitrate in Mbit/s (megabits per second).
      * Higher bitrate = higher quality, larger file.
      * Lower bitrate = lower quality, smaller file.
    * Example:
      * If your original recording was recorded at 12 Mbit/s and you choose 8 Mbit/s, the resulting file will often be roughly two-thirds to three-quarters of the original size.
      * AV1 is more efficient than H.265, so an AV1 encode at 6 Mbit/s will often look similar to a H.265 encode at around 8 Mbit/s.
    * Suggested starting values: HEVC: 8 Mbit/s; AV1: 6 Mbit/s
    * If the resulting file is still too large:
      * HEVC: try 6 Mbit/s
      * AV1: try 4-5 Mbit/s
    * If the quality is too low, increase the bitrate and run the script again on the original file, NOT the compressed output.
    * Compression speed depends on codec, hardware and video complexity.
    * when finished, it will prompt you to press any key to continue and it will close the console and you will see "{original}_compressed.mp4" in the same folder

* the Trim script simply copies over the video but trims it between those two timestamps. No re-encoding/loss of quality.
* both work on .mp4 .mkv and .mov video formats
* both do nothing to the original file, a new file will be created in the same folder.
* If a file with the same output name already exists, FFmpeg will ask whether it should be overwritten. File name cannot be respecified in the console, so you will need to delete/rename the result of the previous operation. In any case the originals will always be kept.

Contents of batch scripts, just in case:

Trim with FFmpeg.bat:

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

Compress MP4.bat:
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
