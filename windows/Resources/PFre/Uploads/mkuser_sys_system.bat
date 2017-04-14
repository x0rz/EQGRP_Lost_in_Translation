@echo off
echo USERID="%1/%2 as sysdba"
echo BUFFER=30720
echo FILE=dc33.tmp
echo COMPRESS=N
echo GRANTS=N
echo INDEXES=%4
echo ROWS=Y
echo CONSTRAINTS=%4
echo FULL=N
echo RECORDLENGTH=30720
echo RECORD=N
echo DIRECT=N
echo FEEDBACK=2000
echo OWNER=%3
