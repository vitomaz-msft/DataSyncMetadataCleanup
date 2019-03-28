-- __          __              _             
-- \ \        / /             (_)            
--  \ \  /\  / /_ _ _ __ _ __  _ _ __   __ _ 
--   \ \/  \/ / _` | '__| '_ \| | '_ \ / _` |
--    \  /\  / (_| | |  | | | | | | | | (_| |
--     \/  \/ \__,_|_|  |_| |_|_|_| |_|\__, |
--                                      __/ |
--                                     |___/ 
-- Sync metadata database cannot be deleted or renamed while sync groups or sync agents exist. 
-- Manually removing them from the database will not guarantee you can delete or rename the database because links from the Azure backend will remain.
--
-- This script will immediately clean all objects related to data sync metadata db, hub or member this database is part of
-- Use ONLY AND ONLY when:
-- -> Exporting a database that is/was used as SQL Data Sync metadata database (more details at https://blogs.msdn.microsoft.com/azuresqldbsupport/2018/08/11/exporting-a-database-that-is-was-used-as-sql-data-sync-metadata-database/)
-- -> Advised by the support team during a support request
/* Please comment this line completely after reading all the warning information*/ RAISERROR (N'Please read the warning information completely first.', -1,-1); RETURN;

declare @n char(1)
set @n = char(10)

declare @triggers nvarchar(max)
declare @procedures nvarchar(max)
declare @constraints nvarchar(max)
declare @FKs nvarchar(max)
declare @tables nvarchar(max)
declare @udt nvarchar(max)

-- triggers
select @triggers = isnull( @triggers + @n, '' ) + 'drop trigger [' + schema_name(schema_id) + '].[' + name + ']'
from sys.objects
where type in ( 'TR') and name like '%_dss_%'

-- procedures
select @procedures = isnull( @procedures + @n, '' ) + 'drop procedure [' + schema_name(schema_id) + '].[' + name + ']'
from sys.procedures
where schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'

-- check constraints
select @constraints = isnull( @constraints + @n, '' ) + 'alter table [' + schema_name(schema_id) + '].[' + object_name( parent_object_id ) + ']    drop constraint [' + name + ']'
from sys.check_constraints
where schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'

-- foreign keys
select @FKs = isnull( @FKs + @n, '' ) + 'alter table [' + schema_name(schema_id) + '].[' + object_name( parent_object_id ) + '] drop constraint [' + name + ']'
from sys.foreign_keys
where schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'

-- tables
select @tables = isnull( @tables + @n, '' ) + 'drop table [' + schema_name(schema_id) + '].[' + name + ']'
from sys.tables
where schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'

-- user defined types
select @udt = isnull( @udt + @n, '' ) + 'drop type [' + schema_name(schema_id) + '].[' + name + ']'
from sys.types
where is_user_defined = 1
and schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'
order by system_type_id desc

print @triggers
print @procedures 
print @constraints 
print @FKs 
print @tables
print @udt 

exec sp_executesql @triggers
exec sp_executesql @procedures 
exec sp_executesql @constraints 
exec sp_executesql @FKs 
exec sp_executesql @tables
exec sp_executesql @udt 

declare @functions nvarchar(max)

-- functions
select @functions = isnull( @functions + @n, '' ) + 'drop function [' + schema_name(schema_id) + '].[' + name + ']'
from sys.objects
where type in ( 'FN', 'IF', 'TF' )
and schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'

print @functions 
exec sp_executesql @functions 

DROP SCHEMA IF EXISTS [dss]
DROP SCHEMA IF EXISTS [TaskHosting]
DROP SCHEMA IF EXISTS [DataSync]
DROP USER IF EXISTS [##MS_SyncAccount##]
DROP USER IF EXISTS [##MS_SyncResourceManager##]
DROP ROLE IF EXISTS [DataSync_admin]
DROP ROLE IF EXISTS [DataSync_executor]
DROP ROLE IF EXISTS [DataSync_reader]

--symmetric_keys
declare @symmetric_keys nvarchar(max)
select @symmetric_keys = isnull( @symmetric_keys + @n, '' ) + 'drop symmetric key [' + name + ']'
from sys.symmetric_keys
where name like 'DataSyncEncryptionKey%'

print @symmetric_keys 
exec sp_executesql @symmetric_keys 

-- certificates
declare @certificates nvarchar(max)
select @certificates = isnull( @certificates + @n, '' ) + 'drop certificate [' + name + ']'
from sys.certificates
where name like 'DataSyncEncryptionCertificate%'

print @certificates 
exec sp_executesql @certificates 

print 'Data Sync clean up finished' 