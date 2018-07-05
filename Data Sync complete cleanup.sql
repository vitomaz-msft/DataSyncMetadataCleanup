-- Attention: Don't run this unless advised by SQL Data Sync support team
-- This will clean all objects related to data sync metadata db, hub or member this database is part of
-- Please make sure this database is not part of any sync group (even from other region or subscription)

declare @n char(1)
set @n = char(10)

declare @triggers nvarchar(max)
declare @procedures nvarchar(max)
declare @constraints nvarchar(max)
declare @views nvarchar(max)
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

-- views
select @views = isnull( @views + @n, '' ) + 'drop view [' + schema_name(schema_id) + '].[' + name + ']'
from sys.views
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
select @udt = isnull( @udt + @n, '' ) +
    'drop type [' + schema_name(schema_id) + '].[' + name + ']'
from sys.types
where is_user_defined = 1
and schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'
order by system_type_id desc

print @triggers
print @procedures 
print @constraints 
print @views 
print @FKs 
print @tables
print @udt 

exec sp_executesql @triggers
exec sp_executesql @procedures 
exec sp_executesql @constraints 
exec sp_executesql @FKs 
exec sp_executesql @views 
exec sp_executesql @tables
exec sp_executesql @udt 

GO
declare @n char(1)
set @n = char(10)
declare @functions nvarchar(max)

-- functions
select @functions = isnull( @functions + @n, '' ) + 'drop function [' + schema_name(schema_id) + '].[' + name + ']'
from sys.objects
where type in ( 'FN', 'IF', 'TF' )
and schema_name(schema_id) = 'dss' or schema_name(schema_id) = 'TaskHosting' or schema_name(schema_id) = 'DataSync'

print @functions 
exec sp_executesql @functions 
GO

DROP SCHEMA IF EXISTS [dss]
GO
DROP SCHEMA IF EXISTS [TaskHosting]
GO
DROP SCHEMA IF EXISTS [DataSync]
GO
DROP USER IF EXISTS [##MS_SyncAccount##]
GO
DROP ROLE IF EXISTS [DataSync_admin]
GO
DROP ROLE IF EXISTS [DataSync_executor]
GO
DROP ROLE IF EXISTS [DataSync_reader]
GO

declare @n char(1)
set @n = char(10)

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
GO

print 'Data Sync clean up finished' 
