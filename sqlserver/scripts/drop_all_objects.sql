DECLARE @n CHAR(1)
DECLARE @schema_name SYSNAME = 'dbo'

DECLARE @object_name_pattern VARCHAR(1000) = '%EV%'

SET @n = CHAR(10)

DECLARE @stmt NVARCHAR(MAX)

DECLARE @answer CHAR(1) = 'n' -- 'y'

-- procedures
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'drop procedure [' + SCHEMA_NAME(p.schema_id) + '].[' + p.name + ']'
FROM	sys.procedures p
		JOIN sys.schemas s ON p.schema_id = s.schema_id
WHERE	s.name = ISNULL(@schema_name, s.name)	
		AND p.name LIKE (@object_name_pattern)


-- check constraints
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'alter table [' + SCHEMA_NAME(c.schema_id) + '].[' + OBJECT_NAME(c.parent_object_id ) + ']    drop constraint [' + c.name + ']'
FROM	sys.check_constraints c
		JOIN sys.schemas s ON c.schema_id = s.schema_id
WHERE	s.name = ISNULL(@schema_name, s.name)
		AND OBJECT_NAME(c.parent_object_id) LIKE (@object_name_pattern)

-- functions
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'drop function [' + SCHEMA_NAME(o.schema_id) + '].[' + o.name + ']'
FROM	sys.objects o
		JOIN sys.schemas s ON o.schema_id = s.schema_id
WHERE	o.type IN ( 'FN', 'IF', 'TF' )
		AND s.name = ISNULL(@schema_name, s.name)
		AND OBJECT_NAME(o.object_id) LIKE (@object_name_pattern)

-- views
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'drop view [' + SCHEMA_NAME(v.schema_id) + '].[' + v.name + ']'
FROM	sys.views v
		JOIN sys.schemas s ON v.schema_id = s.schema_id
WHERE	s.name = ISNULL(@schema_name, s.name)
		AND OBJECT_NAME(v.object_id) LIKE (@object_name_pattern)

-- foreign keys
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'alter table [' + SCHEMA_NAME(f.schema_id) + '].[' + OBJECT_NAME( f.parent_object_id ) + '] drop constraint [' + f.name + ']'
FROM	sys.foreign_keys f
		JOIN sys.schemas s ON f.schema_id = s.schema_id
WHERE	s.name = ISNULL(@schema_name, s.name)
		AND OBJECT_NAME( f.parent_object_id ) LIKE (@object_name_pattern)

-- tables
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'drop table [' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + ']'
FROM	sys.tables t
		JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE	s.name = ISNULL(@schema_name, s.name)
		AND OBJECT_NAME(t.object_id) LIKE (@object_name_pattern)

-- user defined types
SELECT	@stmt = ISNULL( @stmt + @n, '' ) +
		'drop type [' + SCHEMA_NAME(t.schema_id) + '].[' + t.name + ']'
FROM	sys.types t
		JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE	is_user_defined = 1
		AND s.name = ISNULL(@schema_name, s.name)
		AND t.name LIKE (@object_name_pattern)

PRINT @@SERVERNAME + '.' + DB_NAME()
PRINT 'Are you sure???'
PRINT ''

PRINT @stmt

IF @answer = 'y'
	EXEC sp_executesql @stmt
