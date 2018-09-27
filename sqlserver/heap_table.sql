use test
go
 
if exists ( select 1 where objectproperty(object_id('dbo.HeapWithoutIndex'),'IsUserTable') = 1 ) drop table dbo.HeapWithoutIndex
if exists ( select 1 where objectproperty(object_id('dbo.HeapWithIndex'),'IsUserTable') = 1 ) drop table dbo.HeapWithIndex

create table dbo.HeapWithoutIndex
(
	id int identity(1,1) not null
,	value_01 varchar(100) not null
,	uuid uniqueidentifier not null
)

insert into dbo.HeapWithoutIndex (value_01, uuid)
select	top(10000)
		RIGHT( convert(varchar(100), hashbytes('SHA2_512', c1.name + c2.name), 2), len(c1.name + c2.name))
	,	newid()
from	sys.all_columns c1
		join sys.all_columns c2 on 1 = 1

select	* 
from	dbo.HeapWithoutIndex 

select	* 
into	dbo.HeapWithIndex
from	dbo.HeapWithoutIndex

create nonclustered index IX_HeapWithIndex_id on dbo.HeapWithIndex(id)

select	* 
from	dbo.HeapWithoutIndex 
select	* 
from	dbo.HeapWithIndex

select	top(100) *
from	dbo.HeapWithoutIndex 
select	top(100) * 
from	dbo.HeapWithIndex

select	* 
from	dbo.HeapWithoutIndex 
where	id = 100
select	* 
from	dbo.HeapWithIndex
where	id = 100

select	* 
from	dbo.HeapWithoutIndex 
where	id between 100 and 200
select	* 
from	dbo.HeapWithIndex
where	id between 100 and 200

select	* 
from	dbo.HeapWithoutIndex 
where	id > 100
select	* 
from	dbo.HeapWithIndex
where	id > 100
select	id
from	dbo.HeapWithIndex
where	id > 100
