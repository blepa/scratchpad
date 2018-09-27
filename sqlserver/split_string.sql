set nocount on

declare @list varchar(max) = 'A1,B12,C123,D1234,E12345,F123456,G1,H12,'
declare @separator char(1) = ','

declare @list_table table (val varchar(max))

-- loop 
declare @p int = 1
declare @l int = 1

while charindex(@separator,@list,@p) > 0
begin
	set @l = charindex(',', @list, @p) - @p

	insert into @list_table(val)
	select substring(@list,@p,@l)

	set @p = charindex(',', @list, @p+@l) + 1
end

select * from @list_table
 
--cte
;with list_table
as
(
	select	cast(1 as int) p
		,	charindex(@separator, @list) l
	union all
	select	cast(l + 1 as int) p
		,	charindex(@separator, @list, l+1) l
	from	list_table
	where	charindex(@separator, @list, l+1) > 0
)

select	substring(@list,cte.p,cte.l-cte.p)
from	list_table cte
where	cte.l - cte.p > 0

--xml
declare	@xml xml = cast(('<val>' + replace(@list,@separator,'</val><val>')+'</val>') as xml)

select	v.value('.','varchar(max)') as val
from	@xml.nodes('val') as x(v)
