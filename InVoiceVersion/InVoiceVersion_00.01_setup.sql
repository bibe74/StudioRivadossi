USE InVoiceVersion;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/**
 * @table dbo.Installazioni
 * @description Tabella con l'elenco delle installazioni
*/

--DROP TABLE dbo.Installazioni;
GO

IF OBJECT_ID(N'dbo.Installazioni', N'U') IS NULL
BEGIN

CREATE TABLE dbo.Installazioni
(
    ID UNIQUEIDENTIFIER NOT NULL CONSTRAINT PK_dbo_Installazioni PRIMARY KEY CLUSTERED,
    Descrizione NVARCHAR(60) NOT NULL,
    DataInizioAttivita DATE NULL,
    VersioneAttuale NVARCHAR(10) NOT NULL,
    DataUltimoAggiornamento DATE NOT NULL,
    DataScadenzaLicenza DATE NULL
);

END;
GO

/**
 * @table dbo.LogAggiornamenti
 * @description Tabella con l'elenco delle attività di aggiornamento
*/

--DROP TABLE dbo.LogAggiornamenti;
GO

IF OBJECT_ID(N'dbo.LogAggiornamenti', N'U') IS NULL
BEGIN

CREATE TABLE dbo.LogAggiornamenti
(
    ID INT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_dbo_LogAggiornamenti PRIMARY KEY CLUSTERED,
    IDInstallazione UNIQUEIDENTIFIER NOT NULL CONSTRAINT FK_dbo_LogAggiornamenti_IDInstallazione REFERENCES dbo.Installazioni (ID),
    DataOraAggiornamento DATETIME NOT NULL CONSTRAINT DFT_dbo_LogAggiornamenti_DataOraAggiornamento DEFAULT (CURRENT_TIMESTAMP),
    VersioneIniziale NVARCHAR(10) NOT NULL,
    VersioneFinale NVARCHAR(10) NOT NULL
);

END;
GO

/**
 * @storedprocedure dbo.usp_RegistraAggiornamento
 * @description Procedura per la registrazione di un nuovo aggiornamento
*/

IF OBJECT_ID(N'dbo.usp_RegistraAggiornamento', N'P') IS NULL EXEC('CREATE PROCEDURE dbo.usp_RegistraAggiornamento AS RETURN 0;');
GO

ALTER PROCEDURE dbo.usp_RegistraAggiornamento (
    @IDInstallazione UNIQUEIDENTIFIER,
    @VersioneIniziale NVARCHAR(10),
    @VersioneFinale NVARCHAR(10),
    @DataOraAggiornamento DATETIME = NULL
)
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Messaggio NVARCHAR(200);
    DECLARE @LastVersioneAttuale NVARCHAR(10);

    SELECT TOP 1
        @LastVersioneAttuale = VersioneAttuale
    FROM dbo.Installazioni
    WHERE ID = @IDInstallazione;

    IF (@LastVersioneAttuale IS NULL)
    BEGIN

        SET @Messaggio = REPLACE(N'Installazione %ID_INSTALLAZIONE% non esistente', N'%ID_INSTALLAZIONE%', @IDInstallazione);
        RAISERROR(@Messaggio, 0, 1) WITH NOWAIT;
        RETURN 101;

    END;

    IF (@DataOraAggiornamento IS NULL) SET @DataOraAggiornamento = CURRENT_TIMESTAMP;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.LogAggiornamenti (
            IDInstallazione,
            DataOraAggiornamento,
            VersioneIniziale,
            VersioneFinale
        )
        VALUES
        (   @IDInstallazione,      -- IDInstallazione - uniqueidentifier
            @DataOraAggiornamento, -- DataOraAggiornamento - datetime
            @VersioneIniziale,       -- VersioneIniziale - nvarchar(10)
            @VersioneFinale        -- VersioneFinale - nvarchar(10)
        );

        UPDATE dbo.Installazioni
        SET VersioneAttuale = @VersioneFinale,
            DataUltimoAggiornamento = @DataOraAggiornamento

        WHERE ID = @IDInstallazione;

        RETURN 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK;

        SET @Messaggio = N'Errore generico';
        RAISERROR(@Messaggio, 0, 1) WITH NOWAIT;
        RETURN 101;

    END CATCH

END;
GO
