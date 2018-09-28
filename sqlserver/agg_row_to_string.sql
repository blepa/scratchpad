-- generate list with last separator
select	
( 
select	isnull(c.name, c.name) + ','
from	sys.objects c
for		xml path(''), type).value('.', 'varchar(max)')

-- generate list without last separator (stuff for remove first separator)
select	
stuff( 
( 
select	',' + isnull(c.name, c.name) 
from	sys.objects c
for		xml path(''), type).value('.', 'varchar(max)')
,1,1,'')

