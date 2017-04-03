DECLARE @command varchar(1000)

SELECT @command = 'IF ''?'' IN(''master'', ''model'', ''msdb'', ''tempdb'') begin use ? select db_name() end'

select @command

EXEC sp_MSforeachdb  @command
