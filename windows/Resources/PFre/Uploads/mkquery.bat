@echo off
echo set echo off
echo set pagesize 9999
echo set verify off
echo set trimspool on
echo set trimout on
echo set recsep off
echo set Numwidth 20
echo set longchunk 60000
echo set long 9999999
echo set termout on
echo set arraysize 150
echo set escape ~
echo set null ~~~
echo set linesize 80
echo -- Generic query to get list of table names for %1
echo set feedback off
echo set heading on
echo set echo on
echo select table_name from all_tables where owner = upper('%1') order by table_name;
echo set echo off
echo set linesize 1000
