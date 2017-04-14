SELECT 
CAST(ct.IPAddress as nvarchar(20)) AS 'IP', 
CAST(ct.FullDomainName as nvarchar(128)) AS 'Computer Name', 
CAST(ct.ComputerID as nvarchar(36)) AS 'Computer ID', 
ct.LastSyncTime, 
ct.LastSyncResult, 
ctd.ClientVersion,
CAST(ctd.OSMajorVersion as varchar(2)) + '.' + 
CAST(ctd.OSMinorVersion as varchar(2)) + '.' + 
CAST(ctd.OSServicePackMajorNumber as varchar(2)) + '.' + 
CAST(ctd.OSServicePackMinorNumber as varchar(2)) AS 'OS Version', 
CAST(ctd.ProcessorArchitecture as nvarchar(5)) AS 'Arch', 
CAST(ctd.BiosName as nvarchar(32)) AS 'BIOS',
ct.LastReportedStatusTime, 
eii.Win32HResult AS 'AutoUpdateResult', 
eii.TimeAtTarget AS 'AutoUpdateTime' 
FROM dbo.tbComputerTarget AS ct 
INNER JOIN dbo.tbComputerTargetDetail as ctd ON ct.TargetID = ctd.TargetID 
LEFT JOIN ( SELECT ei.Win32HResult, ei.AppName, ei.ComputerID, ei.TimeAtTarget 
            FROM dbo.tbEventInstance as ei WHERE AppName = 'AutomaticUpdates' )
AS eii 
ON ct.ComputerID = eii.ComputerID;
