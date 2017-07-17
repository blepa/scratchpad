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

## Functions
```sql
if exists (select 1 where objectproperty( object_id('[dbo].[test_parent_get_parent_id]'), 'IsScalarFunction') = 1)
begin
	drop function [dbo].[test_parent_get_parent_id]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Scalar Function [dbo].[test_parent_get_parent_id] has been dropped.'
end
go

create function [dbo].[test_parent_get_parent_id]
(
	@parent_uid uniqueidentifier 
)
returns int
as 
begin
	return 
	(	select	tc.parent_id
		from	[dbo].[test_parent] tc
		where	tc.parent_uid = @parent_uid
	)
end
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Scalar Function [dbo].[test_parent_get_parent_id] has been created.'
go

if exists (select 1 where objectproperty( object_id('[dbo].[test_child_get_child_id]'), 'IsScalarFunction') = 1)
begin
	drop function [dbo].[test_child_get_child_id]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Scalar Function [dbo].[test_child_get_child_id] has been dropped.'
end
go

create function [dbo].[test_child_get_child_id]
(
	@child_uid uniqueidentifier 
)
returns int
as 
begin
	return 
	(	select	tc.child_id
		from	[dbo].[test_child] tc
		where	tc.child_uid = @child_uid
	)
end
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Scalar Function [dbo].[test_child_get_child_id] has been created.'
go

if exists (select 1 where objectproperty( object_id('[dbo].[test_parent_get_child_qty]'), 'IsScalarFunction') = 1)
begin
	drop function [dbo].[test_parent_get_child_qty]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Scalar Function [dbo].[test_parent_get_child_qty] has been dropped.'
end
go

create function [dbo].[test_parent_get_child_qty]
(
	@parent_uid uniqueidentifier 
)
returns int
as 
begin
	return 
	(	select	count(1)
		from	[dbo].[test_child] tc
				join [dbo].[test_parent] tp on tc.parent_id = tp.parent_id
		where	tp.parent_uid = @parent_uid
	)
end
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Scalar Function [dbo].[test_parent_get_child_qty] has been created.'
go
```
## Log procedure simple
``` sql
if exists (select 1 where objectproperty( object_id('[dbo].[test_log_create_simple]'), 'IsProcedure') = 1)
begin
	drop procedure [dbo].[test_log_create_simple]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_log_create_simple] has been dropped.'
end
go

create procedure  [dbo].[test_log_create_simple]
(
	@log_uid uniqueidentifier 
,	@parent_id int 
,	@child_id int 
,	@procedure_name varchar(1000)
,	@log_value varchar(max)
,	@create_date datetime
,	@error_strategy varchar(100) = 'no_error'
)
as 
begin
	set nocount on; 

	insert into [dbo].[test_log]
	(
		[log_uid]
	,	[parent_id]
	,	[child_id]
	,	[procedure_name]
	,	[log_value]
	,	[create_date]
	)
	select	@log_uid
		,	@parent_id
		,	@child_id
		,	@procedure_name
		,	@log_value
		,	@create_date
	;

	return 0;
end
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_log_create_simple] has been created.'
go
```
## Test case - without logging - simple
```sql

if exists (select 1 where objectproperty( object_id('[dbo].[test_parent_create_simple]'), 'IsProcedure') = 1)
begin
	drop procedure [dbo].[test_parent_create_simple]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_parent_create_simple] has been dropped.'
end
go

create procedure  [dbo].[test_parent_create_simple]
(
	@parent_uid uniqueidentifier
,	@error_strategy varchar(100) = 'no_error'
)
as 
begin
	set nocount on;

	insert into [dbo].[test_parent]
	(
		[parent_uid]
	,	[child_qty]
	,	[create_date]
	,	[modify_date]
	)
	select	@parent_uid
		,	0
		,	getdate()
		,	getdate()
	;

	return 0;
end
go

print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_parent_create_simple] has been created.'
go


if exists (select 1 where objectproperty( object_id('[dbo].[test_child_create_simple]'), 'IsProcedure') = 1)
begin
	drop procedure [dbo].[test_child_create_simple]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_child_create_simple] has been dropped.'
end
go

create procedure  [dbo].[test_child_create_simple]
(
	@parent_uid uniqueidentifier
,	@child_uid uniqueidentifier 
,	@error_strategy varchar(100) = 'no_error'
)
as 
begin
	set nocount on;

	insert into [dbo].[test_child]
	(
		[child_uid]
	,	[parent_id]
	,	[create_date]
	,	[modify_date]
	)
	select	@child_uid
		,	[dbo].[test_parent_get_parent_id](@parent_uid)
		,	getdate()
		,	getdate()
	;

	return 0;
end
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_child_create_simple] has been created.'
go


if exists (select 1 where objectproperty( object_id('[dbo].[test_parent_set_child_qty]'), 'IsProcedure') = 1)
begin
	drop procedure [dbo].[test_parent_set_child_qty]
	print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_parent_set_child_qty] has been dropped.'
end
go

create procedure  [dbo].[test_parent_set_child_qty]
(
	@parent_uid uniqueidentifier
,	@error_strategy varchar(100) = 'no_error'
)
as 
begin
	set nocount on;

	update	tp
	set		tp.child_qty = [dbo].[test_parent_get_child_qty](@parent_uid)
		,	tp.modify_date = getdate()
	from	[dbo].[test_parent] tp 
	where	tp.parent_uid = @parent_uid
	;

	return 0;
end
go
print convert(varchar(23), getdate(), 121) + ' - ' + '[' + @@servername + '].[' + db_name() + ']' + ' - ' + 'Procedure [dbo].[test_parent_set_child_qty] has been created.'
go
```
