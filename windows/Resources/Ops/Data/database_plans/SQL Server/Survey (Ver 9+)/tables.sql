select o.name 
from sysobjects o, sysindexes i
where o.type = 'U' 
and o.id = i.id 
and i.indid in (0,1) 
and i.rowcnt > 0 
and o.name <> 'ads_org_unit'
order by o.name
