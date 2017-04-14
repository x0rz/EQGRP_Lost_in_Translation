select OS_Username, Username, Terminal, 
        DECODE(Returncode, '0', 'Connected', 
                                 '1005', 'FailedNull', 
                                 '1017', 'Failed', Returncode),
        TO_CHAR(Timestamp, 'DD-MON-YYYY HH24:MI:SS'),
        TO_CHAR(Logoff_Time, 'DD-MON-YYYY HH24:MI:SS')
from DBA_AUDIT_SESSION 
where TO_CHAR(Timestamp, 'DD-MON-YYYY') like '%&&1%' and rownum < 10;
