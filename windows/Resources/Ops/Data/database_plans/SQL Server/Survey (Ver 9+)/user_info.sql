SELECT TOP 1000 loginname, language, isntname, isntgroup, isntuser, sysadmin, dbname FROM sys.syslogins where hasaccess = 1;
