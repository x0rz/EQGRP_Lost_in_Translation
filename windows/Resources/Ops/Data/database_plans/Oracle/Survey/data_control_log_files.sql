select 'DATA' file_type, name from v$datafile
union
select 'CONTROL' file_type, name from v$controlfile
union 
select 'LOG' file_type, member from v$logfile