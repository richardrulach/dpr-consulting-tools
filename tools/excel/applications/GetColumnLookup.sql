

USE backofficemortgage


IF OBJECT_ID('tempdb..#tables') IS NOT NULL
	DROP TABLE #tables

CREATE TABLE #tables (
	id			INT			IDENTITY(1,1)		NOT NULL,
	name		SYSNAME							NULL,
	shortName	SYSNAME							NULL,
	numRows		INT								NULL
)

INSERT INTO #tables([name], [shortName])
SELECT 
	t.name,	
	REPLACE(t.name,N'morAppFma_',N'')
FROM 
	sys.tables T

WHERE 
	T.name LIKE 'morAppFMA%'



DECLARE @id			INT,
		@name		SYSNAME,
		@sql		NVARCHAR(1000),
		@numRows	INT

DECLARE myCursor CURSOR FOR 
						SELECT [ID],[NAME] 
						FROM #tables

OPEN myCursor

FETCH myCursor
INTO @id,@name

WHILE (@@FETCH_STATUS = 0)
BEGIN
	SET @sql = N'select @numRowsInternal = count(*) from ' + @name

	EXEC sp_executeSQL @sql, N'@numRowsInternal INT OUTPUT', @numRowsInternal = @numRows OUTPUT

	UPDATE #tables
	SET numRows = @numRows
	WHERE [id] = @id

	FETCH myCursor
	INTO @id,@name
END


CLOSE myCursor
DEALLOCATE myCursor

--SELECT * 
--FROM #tables 
--WHERE numRows > 0
--ORDER BY shortName


SELECT 
	t.name			AS tableName,
	c.name			AS columnName,
	c.column_id		AS columnId
FROM 
				#tables		T 
	INNER JOIN	sys.columns C ON T.name = OBJECT_NAME(C.object_id)
WHERE
	T.numRows > 0
ORDER BY
	T.[name],
	C.column_id






