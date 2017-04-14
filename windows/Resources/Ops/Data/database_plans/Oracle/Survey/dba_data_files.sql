select tablespace_name, file_name, bytes
from dba_data_files
order by tablespace_name, file_name