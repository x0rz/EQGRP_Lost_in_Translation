select o.name, i.rows from sysobjects o, sysindexes i where o.type = 'U' and o.id = i.id and i.indid in (0,1) order by o.name;
