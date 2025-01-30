ALTER DATABASE moviedb SET OFFLINE WITH ROLLBACK IMMEDIATE;
GO

-- Drop the Database
DROP DATABASE moviedb;
GO

/*
--Reattach the Database (Optional)
USE master;
GO
EXEC sp_attach_db @dbname = 'moviedb', 
    @filename1 = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\moviedb.mdf',
    @filename2 = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\moviedb_log.ldf';
GO



--Delete the Physical MDF and LDF Files
--go to cmd 
del "C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\moviedb.mdf"
del "C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\moviedb_log.ldf"
*/