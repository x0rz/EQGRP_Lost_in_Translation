select owner ow,
       sum(decode(object_type,'DATABASE LINK',1,0)) dbl ,
       sum(decode(object_type,'PACKAGE',1,0)) pkg ,
       sum(decode(object_type,'PACKAGE BODY',1,0)) pkb ,
       sum(decode(object_type,'PROCEDURE',1,0)) pro
from dba_objects
group by owner
order by owner