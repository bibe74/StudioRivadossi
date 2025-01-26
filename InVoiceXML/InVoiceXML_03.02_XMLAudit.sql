USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'XMLAudit')
BEGIN
	EXEC ('CREATE SCHEMA XMLAudit AUTHORIZATION dbo;');
END;
GO

/*

DROP TABLE IF EXISTS XMLAudit.LivelloLog;
DROP TABLE IF EXISTS XMLAudit.TipoEvento;
DROP TABLE IF EXISTS XMLAudit.EsitoEvento;
DROP TABLE IF EXISTS XMLAudit.Evento_Riga; DROP TABLE IF EXISTS XMLAudit.Evento;
DROP TABLE IF EXISTS XMLAudit.Validazione_Riga; DROP SEQUENCE IF EXISTS XMLAudit.seq_Validazione_Riga; DROP TABLE IF EXISTS XMLAudit.Validazione; DROP SEQUENCE IF EXISTS XMLAudit.seq_Validazione;
GO

*/

/**
 * @table XMLAudit.LivelloLog
 * @description Tabella con tipi di evento
*/

--DROP TABLE IF EXISTS XMLAudit.LivelloLog;
GO

IF OBJECT_ID(N'XMLAudit.LivelloLog', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.LivelloLog (
		PKLivelloLog SMALLINT NOT NULL CONSTRAINT PK_XMLAudit_LivelloLog PRIMARY KEY CLUSTERED,
		Codice NVARCHAR(10) NOT NULL,
		Descrizione NVARCHAR(255) NOT NULL
	);

	INSERT INTO XMLAudit.LivelloLog
	(
		PKLivelloLog,
		Codice,
		Descrizione
	)
	VALUES (0, N'T', N'Trace')
	, (1, N'D', N'Debug')
	, (2, N'I', N'Info')
	, (3, N'W', N'Warning')
	, (4, N'W', N'Error')
	;

END;
GO

/**
 * @table XMLAudit.TipoEvento
 * @description Tabella con tipi di evento
*/

--DROP TABLE IF EXISTS XMLAudit.TipoEvento;
GO

IF OBJECT_ID(N'XMLAudit.TipoEvento', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.TipoEvento (
		PKTipoEvento SMALLINT NOT NULL CONSTRAINT PK_XMLAudit_TipoEvento PRIMARY KEY CLUSTERED,
		Codice NVARCHAR(10) NOT NULL,
		Descrizione NVARCHAR(255) NOT NULL
	);

	INSERT INTO XMLAudit.TipoEvento
	(
		PKTipoEvento,
		Codice,
		Descrizione
	)
	VALUES (10, N'IF', N'Importazione fattura')
	, (20, N'IDF', N'Importazione dati fattura')
	, (30, N'VF', N'Validazione fattura')
	, (40, N'EXML', N'Esportazione XML')
	;

END;
GO

/**
 * @table XMLAudit.EsitoEvento
 * @description Tabella con codici e descrizioni degli esiti
*/

--DROP TABLE IF EXISTS XMLAudit.EsitoEvento;
GO

IF OBJECT_ID(N'XMLAudit.EsitoEvento', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.EsitoEvento (
		PKEsitoEvento SMALLINT NOT NULL CONSTRAINT PK_XMLAudit_EsitoEvento PRIMARY KEY CLUSTERED,
		Codice NVARCHAR(10) NOT NULL,
		Descrizione NVARCHAR(255) NOT NULL
	);

	INSERT INTO XMLAudit.EsitoEvento
	(
		PKEsitoEvento,
		Codice,
		Descrizione
	)
	SELECT
		PKEsitoEvento,
        CodiceErroreEvento,
        DescrizioneErroreEvento

	FROM XMLCodifiche.CodiceErroreEvento
	ORDER BY PKEsitoEvento;

END;
GO

/**
 * @table XMLAudit.Evento
 * @description Tabella di log degli eventi - testata
*/

--DROP TABLE IF EXISTS XMLAudit.Evento_Riga; DROP TABLE IF EXISTS XMLAudit.Evento;
GO

IF OBJECT_ID(N'XMLAudit.Evento', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.Evento (
		PKEvento BIGINT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_XMLAudit_Evento PRIMARY KEY CLUSTERED,
		ChiaveGestionale_CodiceNumerico BIGINT NULL,
		ChiaveGestionale_CodiceAlfanumerico NVARCHAR(40) NULL,

		DataOra DATETIME2 NOT NULL CONSTRAINT DFT_XMLAudit_Evento_DataOra DEFAULT (SYSDATETIME()),
		StoredProcedure sysname NULL,
		PKEsitoEvento SMALLINT NULL
	);

END;
GO

/**
 * @table XMLAudit.Evento_Riga
 * @description Tabella di log degli eventi - righe
*/

--DROP TABLE IF EXISTS XMLAudit.Evento_Riga;
GO

IF OBJECT_ID(N'XMLAudit.Evento_Riga', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.Evento_Riga (
		PKEvento_Riga BIGINT IDENTITY(1, 1) NOT NULL CONSTRAINT PK_XMLAudit_Evento_Riga PRIMARY KEY CLUSTERED,
		PKEvento BIGINT NOT NULL CONSTRAINT FK_XMLAudit_Evento_Riga_PKEvento FOREIGN KEY REFERENCES XMLAudit.Evento (PKEvento),

		DataOra DATETIME2 NOT NULL CONSTRAINT DFT_XMLAudit_Evento_Riga_DataOra DEFAULT (SYSDATETIME()),
		Messaggio NVARCHAR(500) NOT NULL,
		LivelloLog TINYINT NOT NULL CONSTRAINT DFT_XMLAudit_Evento_Riga_LivelloLog DEFAULT (0)
		/*
		LivelloLog:
		0 - trace
		1 - debug
		2 - info
		3 - warn
		4 - error
		*/
	);

END;
GO

/**
 * @table XMLAudit.Validazione
 * @description Tabella di log delle validazioni
*/

--DROP TABLE IF EXISTS XMLAudit.Validazione_Riga; DROP SEQUENCE IF EXISTS XMLAudit.seq_Validazione_Riga; DROP TABLE IF EXISTS XMLAudit.Validazione; DROP SEQUENCE IF EXISTS XMLAudit.seq_Validazione;
GO

IF OBJECT_ID(N'XMLAudit.seq_Validazione', 'SO') IS NULL
BEGIN

	CREATE SEQUENCE XMLAudit.seq_Validazione
		AS BIGINT
		START WITH 1
		INCREMENT BY 1
		MINVALUE 1
		NO CYCLE
		CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLAudit.Validazione', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.Validazione (
		PKValidazione BIGINT NOT NULL CONSTRAINT DFT_XMLAudit_Validazione_PKValidazione DEFAULT (NEXT VALUE FOR XMLAudit.seq_Validazione),
		PKStaging_FatturaElettronicaHeader BIGINT NOT NULL,
		DataOraValidazione DATETIME2 NOT NULL CONSTRAINT DFT_XMLAudit_Validazione_DataOraValidazione DEFAULT (SYSDATETIME()),
		PKEvento BIGINT NOT NULL CONSTRAINT FK_XMLAudit_Validazione_PKEvento FOREIGN KEY REFERENCES XMLAudit.Evento (PKEvento),
		PKStato TINYINT NOT NULL CONSTRAINT DFT_XMLAudit_Validazione_PKStato DEFAULT (1), -- 1: in corso, 0: completata
		IsValida BIT NOT NULL CONSTRAINT DFT_XMLFatture_IsValida DEFAULT (0),

		CONSTRAINT PK_XMLAudit_Validazione PRIMARY KEY CLUSTERED (PKValidazione)

	);

END;
GO

/**
 * @table XMLAudit.Validazione_Riga
 * @description Tabella di log delle validazioni (righe)
*/

--DROP TABLE IF EXISTS XMLAudit.Validazione_Riga; DROP SEQUENCE IF EXISTS XMLAudit.seq_Validazione_Riga;
GO

IF OBJECT_ID(N'XMLAudit.seq_Validazione_Riga', 'SO') IS NULL
BEGIN

	CREATE SEQUENCE XMLAudit.seq_Validazione_Riga
		AS BIGINT
		START WITH 1
		INCREMENT BY 1
		MINVALUE 1
		NO CYCLE
		CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLAudit.Validazione_Riga', N'U') IS NULL
BEGIN

	CREATE TABLE XMLAudit.Validazione_Riga (
		PKValidazione_Riga BIGINT NOT NULL CONSTRAINT DFT_XMLAudit_Validazione_Riga_PKValidazione_Riga DEFAULT (NEXT VALUE FOR XMLAudit.seq_Validazione_Riga),
		PKValidazione BIGINT NOT NULL CONSTRAINT FK_XMLAudit_Validazione_Riga_PKValidazione FOREIGN KEY REFERENCES XMLAudit.Validazione (PKValidazione),

		Campo NVARCHAR(100) NOT NULL,
		ValoreTesto NVARCHAR(100) NULL,
		ValoreIntero INT NULL,
		ValoreDecimale DECIMAL(28, 12) NULL,
		ValoreData DATETIME2 NULL,

		Messaggio NVARCHAR(512) NULL,
		LivelloLog TINYINT NOT NULL CONSTRAINT DFT_XMLAudit_Validazione_Riga_LivelloLog DEFAULT (0),

		CONSTRAINT PK_XMLAudit_Validazione_Riga PRIMARY KEY CLUSTERED (PKValidazione_Riga)

	);

END;
GO
