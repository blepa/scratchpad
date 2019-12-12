# Allocation Unit #

Demo:
```sql
-- in_row_data: 
-- a row fits on single page, row is not bigger than 8kb.
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

-- select len(col_varchar_1000) len_col_varchar_1000, len(col_varchar_5000) col_varchar_5000, * from dbo.allocation_unit_demo_in_row_data 
```
