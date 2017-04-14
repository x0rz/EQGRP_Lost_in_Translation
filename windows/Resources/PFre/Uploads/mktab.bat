@echo off
echo connect / as sysdba
echo set echo off
echo set heading off
echo set pagesize 1000
echo set trimout on
echo set trimspool on
echo set termout off
echo set feedback off
echo set verify off

echo spool dc411.tmp
echo prompt 
echo prompt NOTE:
echo prompt If you are using the SYS or SYSTEM user for logging in,
echo prompt then you need to delete the line "OWNER=%1" if you 
echo prompt use the "TABLES=(" structure below to limit the tables 
echo prompt that are part of the export.
echo prompt
echo prompt
echo prompt TABLES=(
echo select '%1.' ^|^| table_name ^|^| ','
echo from all_tables
echo where owner=upper('%1')
echo order by table_name;
echo prompt )
echo spool off
