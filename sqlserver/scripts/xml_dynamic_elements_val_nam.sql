declare @tx xml 



select @tx = cast(
'
<params-all>
  <params-list>
    <psrc>TableParams</psrc>
	<params>
		<where>1=1</where>
		<where>3=3</where>
		<where>2=2</where>
	</params>
	</params-list>  
  <params-list>
    <psrc>ObjectGeneratorTargetParams</psrc>
	<params>
		<datatype>varchar(100)</datatype>
		<where>2=2</where>
	</params>
  </params-list>
  <params-list>
    <psrc>ObjectGeneratorSourceParams</psrc>
	<params>
		<datatype>bigint</datatype>
		<start_value>10000000</start_value>
		<increment>1</increment>
		<mimimum_value>10000000</mimimum_value>
		<maximum_value>99999999</maximum_value>
		<cache>10000</cache>
	</params>
	</params-list>
</params-all>
' as xml)


select @tx

declare @psrc varchar(100) = 'TableParams'
declare @name varchar(1000) = 'where'


select	t2.params_list.value('psrc[1]', 'varchar(100)') psrc
	,	cast(t3.param.query('local-name(.)') as varchar(1000)) name
	,	t3.param.value('.', 'nvarchar(max)') val	
from	@tx.nodes('params-all') t1(params_all)
		cross apply t1.params_all.nodes('params-list') t2(params_list)
		cross apply t2.params_list.nodes('.//*') t3(param)
where	cast(t3.param.query('local-name(.)') as varchar(1000)) not in ('params', 'psrc')
		and t2.params_list.value('psrc[1]', 'varchar(100)');
