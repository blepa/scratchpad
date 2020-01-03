# Allocation Unit #

[pic01]: https://github.com/blepa/scratchpad/blob/master/sqlserver/sql_internal/pic/allocate_unit_diagram.png

[sqlity.net: The Allocation Unit](https://sqlity.net/en/2287/allocation-unit/)  
[docs.microsoft: Table and Index Organization](https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms189051(v=sql.105)?redirectedfrom=MSDN)  
[medium.com/@idanmashi: SQL Server — Part 1 Files and Basics of Data Structure](https://medium.com/@idanmashi/sql-server-part-1-5811daebdeba)  
[docs.microsoft: Pages and Extents Architecture Guide](https://docs.microsoft.com/en-us/sql/relational-databases/pages-and-extents-architecture-guide?view=sql-server-ver15)  
[sqlservercentral.com: SQL Server : Understanding the IAM Page](https://www.sqlservercentral.com/blogs/sql-server-understanding-the-iam-page)  

Allocation units are used for grouping all pages into logical units belong to a single partition of a single table. Information about the data page belonging to the table is not store in this data page. 

Demo:
```sql
-- in_row_data: a row fits on single page, row is not bigger than 8kb.
if exists (select 1 where objectproperty(object_id('dbo.allocation_unit_demo_in_row_data'), 'IsTable') = 1) 
drop table dbo.allocation_unit_demo_in_row_data;
go
create table dbo.allocation_unit_demo_in_row_data 
(
	col_varchar_1000 varchar(1000)
,	col_varchar_5000 varchar(5000)
);
go

;with 
n1(c) as ( select 0 union all select 0),
n2(c) as ( select 0 from n1 as t1 cross join n1 as t2),
n3(c) as ( select 0 from n2 as t1 cross join n2 as t2)
insert into dbo.allocation_unit_demo_in_row_data(col_varchar_1000,col_varchar_5000) 
select 
convert(varchar(1000),crypt_gen_random(abs(cast(cast(newid() as varbinary(36)) as int)) % 1000, null),2),
convert(varchar(5000),crypt_gen_random(abs(cast(cast(newid() as varbinary(36)) as int)) % 5000, null),2)
from n3;

select	au.* 
from	sys.allocation_units au
join 	sys.partitions p on au.container_id = p.partition_id
where	p.object_id = object_id('dbo.allocation_unit_demo_in_row_data'); 

select	au.* 
from	sys.system_internals_allocation_units au
join 	sys.partitions p on au.container_id = p.partition_id
where	p.object_id = object_id('dbo.allocation_unit_demo_in_row_data'); 

-- select len(col_varchar_1000) len_col_varchar_1000, len(col_varchar_5000) col_varchar_5000, * from dbo.allocation_unit_demo_in_row_data 
```  
  
```sql
-- all types of allocation unit
-- in_row_data:		a row fits on single page, row is not bigger than 8kb.
-- row_overflow_data:	the rows in total pass the 8kb size, but the size of every individual column is less than 8kb.
-- lob_data:		a individual column size is more than 8kb.
if exists (select 1 where objectproperty(object_id('dbo.allocation_unit_demo_all_types'), 'IsTable') = 1) 
drop table dbo.allocation_unit_demo_all_types;
go
create table dbo.allocation_unit_demo_all_types 
(
	col_in_row_data varchar(3000)
,	col_row_overflow_data varchar(7000)
,	col_lob_data varbinary(max)
);
go
-- in_row_data
;with 
n1(c) as ( select 0 union all select 0),
n2(c) as ( select 0 from n1 as t1 cross join n1 as t2)
insert into dbo.allocation_unit_demo_all_types(col_in_row_data) 
select 
convert(varchar(3000),crypt_gen_random(abs(cast(cast(newid() as varbinary(36)) as int)) % 3000, null),2)
from n2;
-- row_overflow_data
;with 
n1(c) as ( select 0 union all select 0),
n2(c) as ( select 0 from n1 as t1 cross join n1 as t2)
insert into dbo.allocation_unit_demo_all_types(col_in_row_data, col_row_overflow_data) 
select 
convert(varchar(3000),crypt_gen_random(3000, null),2),
convert(varchar(7000),crypt_gen_random(7000, null),2)
from n2;
-- lob_data
;with 
n1(c) as ( select 0 union all select 0),
n2(c) as ( select 0 from n1 as t1 cross join n1 as t2)
insert into dbo.allocation_unit_demo_all_types(col_lob_data) 
select 
convert(varbinary(max),crypt_gen_random(8000, null),2) + convert(varbinary(max),crypt_gen_random(5000, null),2) 
from n2;

select	au.* 
from	sys.allocation_units au
join 	sys.partitions p on au.container_id = p.partition_id
where	p.object_id = object_id('dbo.allocation_unit_demo_all_types'); 

select	allocation_unit_type_desc, allocated_page_page_id, page_type, page_type_desc , allocated_page_iam_page_id
from	sys.dm_db_database_page_allocations(db_id(),object_id('dbo.allocation_unit_demo_all_types'),null,null,'DETAILED')
where	is_allocated = 1;

select * from sys.dm_db_index_physical_stats(db_id(),object_id('dbo.allocation_unit_demo_all_types'),0,null,'DETAILED')

--select len(col_in_row_data) + isnull(len(col_row_overflow_data),0) len_for_overflow_data, len(col_lob_data) len_col_lob_data from dbo.allocation_unit_demo_all_types
```

![pic01]
