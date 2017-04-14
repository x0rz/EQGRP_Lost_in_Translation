@echo off
echo connect / as sysdba
echo spool dc121.tmp
echo @dc12.tmp %1-%2
echo spool off
