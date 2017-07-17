# Logging test cases
## Test cases
- Without logging
- Log is part of transaction
-- when log was fault then transaction should been terminated and rollbacked.
- Log is out side of transaction
-- when log was fault then transaction should been commited

## Performance test
Test should measure performance with, without logging, and diffrent strategy of management of transactions (autonomous transactions)

## Structures to test script
```sql
if exists (select 1 where objectproperty( object_id('[dbo].[test_child]'), 'IsTable') = 1)
begin
	drop table [dbo].[test_child]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Table [dbo].[test_child] has been dropped.'
end
go

if exists (select 1 where objectproperty( object_id('[dbo].[test_parent]'), 'IsTable') = 1)
begin
	drop table [dbo].[test_parent]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Table [dbo].[test_parent] has been dropped.'
end
go
if exists (select 1 where objectproperty( object_id('[dbo].[test_log]'), 'IsTable') = 1)
begin
	drop table [dbo].[test_log]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Table [dbo].[test_log] has been dropped.'
end
go
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table [dbo].[test_parent] 
(
	[parent_id] int identity(1,1) not null
,	[parent_uid] uniqueidentifier not null
,	[child_qty] smallint not null
,	[create_date] datetime  not null
,	[modify_date] datetime  not null
)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Table [dbo].[test_parent] has been created.'
go
alter table [dbo].[test_parent]
	add constraint [pk_test_parent_parent_id]
	primary key (parent_id)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'PrimaryKey [pk_test_parent_parent_id] has been added to [dbo].[test_parent].'
go
alter table [dbo].[test_parent]
	add constraint [uq_test_parent_parent_uid]
	unique(parent_uid)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Unique [uq_test_parent_parent_uid] has been added to [dbo].[test_parent].'
go
alter table [dbo].[test_parent]
	add constraint [df_test_parent_parent_uid]
	default(newid())
	for [parent_uid]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_parent_parent_create_child_qty] has been added to [dbo].[test_parent].'
go
alter table [dbo].[test_parent]
	add constraint [df_test_parent_child_qty]
	default(0)
	for [child_qty]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_parent_child_qty] has been added to [dbo].[test_parent].'
go
alter table [dbo].[test_parent]
	add constraint [df_test_parent_parent_create_date]
	default(getdate())
	for [create_date]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_parent_parent_create_date] has been added to [dbo].[test_parent].'
go
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table [dbo].[test_child] 
(
	[child_id] int identity(1,1) not null
,	[child_uid] uniqueidentifier not null
,	[parent_id] int not null
,	[create_date] datetime  not null
,	[modify_date] datetime  not null
)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Table [dbo].[test_child] has been created.'
go
alter table [dbo].[test_child]
	add constraint [pk_test_child_child_id]
	primary key (child_id)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'PrimaryKey [pk_test_child_child_id] has been added to [dbo].[test_child].'
go
alter table [dbo].[test_child]
	add constraint [uq_test_child_child_uid]
	unique(child_uid)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Unique [uq_test_child_child_uid] has been added to [dbo].[test_child].'
go
alter table [dbo].[test_child]
	add constraint [fk_test_child_test_parent]
	foreign key (parent_id)
	references [dbo].[test_parent]([parent_id])
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'ForeignKey [fk_test_child_test_parent] has been added to [dbo].[test_child].'
go
create nonclustered index ix_test_child_parent_id
	on [dbo].[test_child]([parent_id])
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Index [ix_test_child_parent_id] has been added to [dbo].[test_child].'
go
alter table [dbo].[test_child]
	add constraint [df_test_child_child_uid]
	default(newid())
	for [child_uid]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_child_child_uid] has been added to [dbo].[test_child].'
go
alter table [dbo].[test_child]
	add constraint [df_test_child_child_create_date]
	default(getdate())
	for [create_date]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_child_child_create_date] has been added to [dbo].[test_child].'
go
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create table [dbo].[test_log] 
(
	[log_id] int identity(1,1) not null
,	[log_uid] uniqueidentifier not null
,	[parent_id] int not null
,	[child_id] int null
,	[procedure_name] varchar(1000) not null
,	[log_value] varchar(max) null
,	[create_date] datetime  not null
)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Table [dbo].[test_log] has been created.'
go
alter table [dbo].[test_log]
	add constraint [pk_test_log_log_id]
	primary key (log_id)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'PrimaryKey [pk_test_log_log_id] has been added to [dbo].[test_log].'
go
alter table [dbo].[test_log]
	add constraint [uq_test_log_log_uid]
	unique(log_uid)
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Unique [uq_test_log_log_uid] has been added to [dbo].[test_log].'
go
create nonclustered index ix_test_log_parent_id
	on [dbo].[test_log]([parent_id])
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Index [ix_test_log_parent_id] has been added to [dbo].[test_log].'
go
create nonclustered index ix_test_log_child_id
	on [dbo].[test_log]([child_id])
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Index [ix_test_log_child_id] has been added to [dbo].[test_log].'
go
alter table [dbo].[test_log]
	add constraint [df_test_log_log_uid]
	default(newid())
	for [log_uid]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_log_log_uid] has been added to [dbo].[test_log].'
go
alter table [dbo].[test_log]
	add constraint [df_test_log_log_create_date]
	default(getdate())
	for [create_date]
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Default [df_test_log_log_create_date] has been added to [dbo].[test_log].'
go
```
