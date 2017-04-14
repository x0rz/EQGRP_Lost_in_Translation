set pages 0
set lines 1024
set feedback off
set trimspool on
set verify off
accept output_file_name prompt 'Enter Output File Name: '
accept begin_date prompt 'Enter BEGINNING date in the format "yyyymmdd": '
accept end_date prompt 'Enter ENDING date in the format "yyyymmdd": '
prompt
prompt
prompt
set termout off
spool d41af8c_a.tmp
select 'set long 4096' from dual;
select 'set lines 1024' from dual;
select 'set longc 4096' from dual;
select 'set wrap on' from dual;
select 'set recsep off' from dual;
select 'set pages 0' from dual;
select 'set feedback off' from dual;
select 'set verify off' from dual;
select 'set trimspool on' from dual;
select 'spool &&output_file_name append' from dual;
select 'select ''"SENDER_CC","RECEIVER_CC","MESG_S_UMID","SWIFT_MESSAGE"'' from dual;' from dual;
select 'select ''"''||substr(mesg_sender_swift_address,5,2)||''","''||substr(mesg_receiver_swift_address,5,2)||''","''||mesg_s_umid||''","{1:F01''||decode(substr(m.mesg_uumid,1,1),''O'',mesg_receiver_swift_address,''I'',mesg_sender_swift_address,''OTHER'')||
          ltrim((select to_char(appe_session_nbr,''0000'')||ltrim(to_char(appe_sequence_nbr,''000000'')) 
           from saaowner.appe_'||substr(table_name,6,20)||' a 
           where a.appe_s_umid = m.mesg_s_umid and a.appe_iapp_name = ''SWIFT'' and rownum = 1)) ||
       ''}''||''{2:''||decode(substr(m.mesg_uumid,1,1),''O'',''O''||mesg_type||
       ltrim((select to_char(TO_DATE (((TO_NUMBER (TO_CHAR (TO_DATE (''1970-01-01 00:00:00'', ''yyyy-mm-dd hh24:mi:ss''), ''J''), ''9999999'')) + 
                                       ((appe_remote_input_time - (MOD (appe_remote_input_time, 86400))) / 86400)), ''J'') + 
                                       ((MOD (appe_remote_input_time, 86400)) / 86400),''hh24mi'')||appe_remote_input_reference||
       to_char(TO_DATE (((TO_NUMBER (TO_CHAR (TO_DATE (''1970-01-01 00:00:00'', ''yyyy-mm-dd hh24:mi:ss''), ''J''), ''9999999'')) + 
                         ((appe_local_output_time - (MOD (appe_local_output_time, 86400))) / 86400)), ''J'') + 
                         ((MOD (appe_local_output_time, 86400)) / 86400),''yymmddhh24mi'')
           from saaowner.appe_'||substr(table_name,6,20)||' a  
           where a.appe_s_umid = m.mesg_s_umid and a.appe_iapp_name = ''SWIFT'' and rownum = 1))
       ||decode(m.mesg_network_priority,1,''S'',2,''U'',3,''N'',''N''),''I'',''I''||mesg_type||
       mesg_receiver_swift_address||decode(m.mesg_network_priority,1,''S'',2,''U'',3,''N'',''N'')
       ,''OTHER'')||''}{3:''||text_swift_block_3||
       ''}{4:''||text_data_block||''
-}{5:''||utl_raw.cast_to_varchar2(dbms_lob.substr(text_swift_block_5))||''}"'' SWIFT_MESSAGE
from saaowner.text_'||substr(table_name,6,20)||' t ,saaowner.mesg_'||substr(table_name,6,20)||' m
where
m.mesg_s_umid = t.text_s_umid and
text_swift_block_5 is not null;'||'
spool off
set termout on
prompt date '||substr(table_name,6,8)||' completed.
set termout off
spool ''&&output_file_name'' append'
from all_tables
where owner = 'SAAOWNER'
and table_name like 'MESG%' escape '\'
and table_name not like '%YYYYMMDD%'
and substr(table_name,6,8) >= '&&begin_date'
and substr(table_name,6,8) <= '&&end_date'
order by table_name
/
select 'spool off' from dual;
spool off
@d41af8c_a.tmp
undefine begin_date
undefine end_date
undefine cc
set termout on
host del d41af8c_a.tmp
prompt 
prompt 
prompt Done!
prompt 
prompt 
prompt 
exit

