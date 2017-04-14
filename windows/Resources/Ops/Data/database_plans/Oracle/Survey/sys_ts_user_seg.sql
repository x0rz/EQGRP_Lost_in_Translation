select  us.name                                 ow,
        ts.name                                 ta,
        sum(seg.blocks*ts.blocksize)/1024       K
from    sys.ts$ ts,
        sys.user$ us,
        sys.seg$ seg
where   seg.user# = us.user#
and     ts.ts# = seg.ts#
group by us.name,ts.name 
order by us.name