@echo off
REM -------------- Variables -------------V1.0-------

set dirpath=D:\to_pp\

set host=10.0.139.12

set ftp-dir=fast

set check=0

For /F "tokens=1,2,3 delims=/" %%i in ('type c:\suite.txt') do Call :suite-set %%i

For /F "tokens=1,2,3 delims=/" %%i in ('echo %date%') do Call :set-date %%i %%j %%k

For /F "tokens=1,2,3 delims=:" %%i in ('echo %time%') do Call :set-time %%i %%j %%k


REM ------------- Variables ----------------------



REM -------------- Zip the Folders ----------------------------------------------------------

FOR /F "tokens=1,2,3 delims=<>.," %%i in ('dir %dirpath%*. /B') do Call :load-variables %%i %%j %%k 

goto :ftp-files

:load-variables

set name=%1

:zipit
c:\progra~1\winzip\wzzip -p -r %dirpath%%name% %dirpath%%name%\*.*

move /Y %dirpath%%name%.zip %dirpath%%name%-W-%suite%-%d%-%t%.zip



C:\windows\system32\md5sums -u %dirpath%%name%-W-%suite%-%d%-%t%.zip > %dirpath%%name%-W-%suite%-%d%-%t%.zip.md5

goto exit

REM -------------- Zip the Folders ----------------------------------------------------------



:suite-set
  set suite=%1
goto :exit

:set-date
  set d=%4%2%3
  rem echo %s%
goto :exit

:set-time
  set t=%1%2%4
  rem echo %t%
goto :exit






:ftp-files
REM ------------- FTP the FILES --------------------------------------------------------------
@echo off




@echo off
color 07
set i=0
echo.
echo.
echo Sending Data via ftp ...........
echo.
echo.

d:
cd %dirpath%

echo from the directory %dirpath%

> %dirpath%send.ftp echo open %host%
>> %dirpath%send.ftp echo anonymous
>> %dirpath%send.ftp echo cd %ftp-dir%
>> %dirpath%send.ftp echo mput *.zip 
>> %dirpath%send.ftp echo mput *.md5
>> %dirpath%send.ftp echo ls
>> %dirpath%send.ftp echo bye



ftp -is:%dirpath%send.ftp> %dirpath%\report.txt



REM ------------ Check the FTP status ----------------------------------------

@echo off
rem cls
color f5



for /F "usebackq tokens=1 skip=2 delims==>," %%i in (`"find "Invalid command." %dirpath%report.txt"`) do call :ftp-check %%i


if [%check%]==[0] (
for /F "usebackq tokens=1,2,3 delims==>, " %%i in (`"find "Connected" %dirpath%report.txt"`) do call :ftp-success %%i %%j %%k
)

goto :end




rem ----------------- Display Successfull FTP ---------------------------------------
:ftp-success


if [%2]==[Connected] (
echo The files:
for /F "usebackq tokens=1 delims=>," %%m in (`"find "W-%suite%" %dirpath%report.txt"`) do call :print-success %%m
	echo.
	echo.
	echo were FTP'd successfully !!!
	echo.
	echo.
	goto :cleanup
)

:print-success
        color 2f
	echo %1
	set check=1
	goto :end




rem ----------------- Display FAILED FTP --------------------------------------------
:ftp-check


if [%1]==[Invalid] (
	if /I [%1]==["Invalid command."] then
	(
	color 47
	echo.
	echo.
	echo.
	echo.
	echo.
	echo The FTP transfer FAILED !!!!
	echo.
	echo Please notify the Staff ......
	echo.
	echo.
	set check=1
	pause
	c:
	color 07
	goto :end 
 	)
)




REM ---------------- Cleanup temporary files and folders ---------------------------

:cleanup
@echo off

del /Q %dirpath%*.zip
del /Q %dirpath%*.md5
del /Q %dirpath%*.ftp
del /Q %dirpath%*.txt
del /Q %dirpath%%name%\*.*

IF EXIST %name% (rmdir %dirpath%%name%)
echo.
echo.
echo The Time is: %time% 
echo.
echo The Date is: %date%'
echo.
rem pause
color 07
c:


:end
:exit

rem ----------------- The END ----------------------------------------------------------