select owner ow,
       sum(decode(object_type,'TABLE',1,0)) ta ,
       sum(decode(object_type,'INDEX',1,0)) ind ,
       sum(decode(object_type,'SYNONYM',1,0)) sy ,
       sum(decode(object_type,'SEQUENCE',1,0)) se ,
       sum(decode(object_type,'VIEW',1,0)) ve
from dba_objects
group by owner
order by owner