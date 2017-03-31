declare @ns int = 5

select dateadd	( second
				,	( datediff (second, convert(char(8), create_date, 112), dateadd (millisecond, @ns * 1000 / 2, create_date)) / @ns ) * @ns 
				,	convert (char(8), create_date, 112) ) as create_date_runded					
from	sys.objects 
order	by name
