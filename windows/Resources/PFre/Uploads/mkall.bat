@echo off
call mkuser.bat %1 %2 %4 > exp_%1%4_user.tmp
echo Created exp_%1%4_user.tmp
call mksch.bat %1 %2 > exp_%1%4_sch.tmp
echo Created exp_%1%4_sch.tmp
call mktab.bat %1 > dc41_%1%4.tmp
echo Created dc41_%1%4.tmp
call mkscript.bat %1 %4 > %1%4_exp_script.dss
echo Created %1%4_exp_script.dss
call mkscript2.bat %1 %4 > get_%1%4_tables_script.dss
echo Created get_%1%4_tables_script.dss
echo Done.