SELECT DirName, LeafName, ID, Size, TimeLastModified, TimeCreated from Docs 
where ( (TimeLastModified between '$START_DATE' AND '$END_DATE') or (TimeCreated between '$START_DATE' AND '$END_DATE') ) 
AND (IsCurrentVersion='True') 
AND (Size>0) 
order by TimeLastModified,TimeCreated