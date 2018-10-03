
if object_id('tempdb..#tmp1') is not null drop table #tmp1
if object_id('tempdb..#tmp2') is not null drop table #tmp2
if object_id('tempdb..#tmp3') is not null drop table #tmp3
go

create table #tmp1 (k int not null,	val1 varchar(10), date_from datetime, date_to datetime)
create table #tmp2 (k int not null,	val2 varchar(10), date_from datetime, date_to datetime)
create table #tmp3 (k int not null,	val3 varchar(10), date_from datetime, date_to datetime)

insert into #tmp1(k,val1,date_from,date_to)
select 1, 't1a1', '1999-01-01', '2010-01-01'
union all
select 1, 't1b1', '2010-01-01', '9999-01-01'
union all
select 2, 't1a2', '1900-01-01', '2012-01-01'
union all
select 2, 't1b2', '2012-01-01', '9999-01-01'

insert into #tmp2(k,val2,date_from,date_to)
select 1, 't2a1', '1900-01-01', '2000-01-01'
union all
select 1, 't2b1', '2000-01-01', '9999-01-01'
union all
select 2, 't2a2', '1900-01-01', '2013-01-01'
union all
select 2, 't2b2', '2013-01-01', '2016-01-01'
union all
select 2, 't2c2', '2016-01-01', '9999-01-01'

select	* from #tmp1
select	* from #tmp2

select	* 
from	#tmp1 t1
		join #tmp2 t2 on t1.k = t2.k
where	t1.k = 1

select	IIF(t1.date_from > t2.date_from, t1.date_from, t2.date_from) date_from_m,	
		IIF(t1.date_to < t2.date_to, t1.date_to, t2.date_to) date_to_m	
	,	t1.k
	,	val1
	,	val2
	,	'###'
	,	*
from	#tmp1 t1
		left join #tmp2 t2 on t1.k = t2.k and t1.date_from <= t2.date_to and t2.date_from <= t1.date_to
where	t1.k = 1

