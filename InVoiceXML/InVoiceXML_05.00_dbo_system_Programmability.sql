USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/**
 * @stored_procedure dbo.ssp_ReleaseNewVersion
 * @description Rilascio nuova versione

 * @param_input @Revision
*/

IF OBJECT_ID(N'dbo.ssp_ReleaseNewVersion', N'P') IS NULL EXEC('CREATE PROCEDURE dbo.ssp_ReleaseNewVersion AS RETURN 0;');
GO

ALTER PROCEDURE dbo.ssp_ReleaseNewVersion (
	@Revision INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Tipo CHAR(15) = 'Database';
	--DECLARE @CanTruncateTable BIT = 0;

	IF (@Revision IS NULL)
	BEGIN
		SELECT @Revision = 1 + COALESCE(MAX(Revision), 0)
		FROM dbo.Versioni
		WHERE Tipo = @Tipo;
	END;

	--SELECT @Revision;

	BEGIN TRANSACTION 

	DELETE FROM dbo.Versioni WHERE Tipo = @Tipo;

	IF NOT EXISTS(SELECT ID FROM dbo.Versioni)
	BEGIN
		--SET @CanTruncateTable = 1;

		TRUNCATE TABLE dbo.Versioni;

	END;

	--SELECT @CanTruncateTable;

	/* declare variables */
	DECLARE @newRevision INT;
	
	DECLARE curRevision CURSOR FAST_FORWARD READ_ONLY FOR SELECT T.Revision FROM (SELECT ROW_NUMBER() OVER (ORDER BY O.object_id) AS Revision FROM sys.objects O) T WHERE T.Revision <= @Revision;
	
	OPEN curRevision;
	
	FETCH NEXT FROM curRevision INTO @newRevision;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT INTO dbo.Versioni
		(
		    Tipo,
		    Data,
		    Major,
		    Minor,
		    Build,
		    Revision,
		    Bin
		)
		VALUES
		(   @Tipo,        -- Tipo - char(15)
		    CURRENT_TIMESTAMP, -- Data - datetime
		    1,         -- Major - int
		    0,         -- Minor - int
		    0,         -- Build - int
		    @newRevision,         -- Revision - int
		    NULL       -- Bin - varbinary(max)
		);	    
	
	    FETCH NEXT FROM curRevision INTO @newRevision;
	END;
	
	CLOSE curRevision;
	DEALLOCATE curRevision;

	COMMIT TRANSACTION 

END;
GO

EXEC dbo.ssp_ReleaseNewVersion @Revision = 15; -- int
GO

EXEC dbo.ssp_ReleaseNewVersion; -- int
GO

SELECT * FROM dbo.Versioni;
GO
