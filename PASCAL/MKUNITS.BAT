@echo off

if not "%1" == "" goto %1

set OLD_TPC=
if not "%TPC%" == "" goto TPCset
set OLD_TPC=%TPC%
set TPC=TPC
if exist %DOSDIR%\LINKS\%TPC%.BAT set TPC=call %TPC%
:TPCset

set OLD_TPV=
if not "%TPV%" == "" goto TPVset
set OLD_TPV=%TPV%
set TPV=TP70
:TPVset

set OLD_ASM=
if not "%ASM%" == "" goto ASMset
set OLD_ASM=%ASM%
set ASM=NASM
if exist %DOSDIR%\LINKS\%ASM%.BAT set ASM=call %ASM%
:ASMset

deltree /y *.obj *.tpu >NUL

call %0 make QCRT
call %0 make QSTRINGS
call %0 make QDOS

goto DONE
:MAKE
set AOPT=
set TOPT=
if "%OPTIONS%" == "" goto NoOptions

echo %OPTIONS% | vstr /n /s '/' '-' | set /p AOPT=
echo %OPTIONS% | vstr /n /s '-' '/' | set /p TOPT=
set TOPT=%OPTIONS%

:NoOptions
echo %ASM% ..\%2.ASM -I.. -fobj -D%TPV% %AOPT% -O9 -o %2.OBJ
%ASM% ..\%2.ASM -I.. -fobj -D%TPV% %AOPT% -O9 -o %2.OBJ
if not exist %2.OBJ goto ErrorExit
echo %TPC% /B %TOPT% %2.PAS
%TPC% /B %TOPT% %2.PAS
if not exist %2.TPU goto ErrorExit

set EXIT_CODE=
verrlvl 0
goto END

:ErrorExit
set EXIT_CODE=1

:DONE
if not "%OLD_TPC%" == "" set TPC=%OLD_TPC%
if not "%OLD_TPV%" == "" set TPV=%OLD_TPV%
if not "%OLD_ASM%" == "" set TPV=%OLD_ASM%
set OLD_ASM=
set OLD_TPC=
set OLD_TPV=

:END
if not "%EXIT_CODE%" == "" verrlvl %EXIT_CODE%
