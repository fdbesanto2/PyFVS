
setlocal

set proj_root=%~dp0

::set PATH=C:\progs\msys64\mingw64\bin
REM set PATH=C:\progs\mingw-w64\x86_64-5.1.0-win32-seh-rt_v4-rev0\mingw64\bin
REM set PATH=C:\progs\mingw-w64\x86_64-5.3.0-posix-seh-rt_v4-rev0\mingw64\bin
REM set PATH=C:\progs\mingw-w64\x86_64-5.3.0-win32-sjlj-rt_v4-rev0\mingw64\bin
set PATH=C:\progs\mingw-w64\x86_64-6.2.0-release-win32-seh-rt_v5-rev1\mingw64\bin
set PATH=%PATH%;C:\Windows\System32;C:\Windows
set PATH=C:\progs\cmake\bin;%PATH%
set PATH=C:\Ruby22-x64\bin;%PATH%
set PATH=C:\progs\Git\bin;C:\progs\Git\usr\bin;%PATH%
set path=%path%;C:\Miniconda3\Scripts;C:\Miniconda3

::set PATH=C:\Anaconda3;C:\Anaconda3\Scripts;%PATH%

::call C:\Anaconda3\Scripts\activate.bat pyfvs_python3.5

REM start c:\progs\console2\console.exe ^
		REM -d %proj_root% ^
		REM -w "PyFVS (CMD+MinGW-w64)" ^

start C:\progs\ConEmu\ConEmu64.exe
