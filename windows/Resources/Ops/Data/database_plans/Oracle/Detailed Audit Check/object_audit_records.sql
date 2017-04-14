select OS_Username, Username, Terminal, 
        Owner, Obj_Name, Action_Name,
        DECODE(Returncode, '0', 'Success', Returncode),
        TO_CHAR(Timestamp, 'DD-MON-YYYY HH24:MI:SS')
from DBA_AUDIT_OBJECT
where TO_CHAR(Timestamp, 'DD-MON-YYYY') like '%&&1%' and rownum < 10;
