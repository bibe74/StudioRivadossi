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

/**
 * @stored_procedure XMLAudit.ssp_GeneraEvento
 * @description Generazione nuovo evento (procedura di sistema)

 * @param_input @chiaveGestionale_CodiceNumerico
 * @param_input @chiaveGestionale_CodiceAlfanumerico
 * @param_input @storedProcedure

 * @param_output @PKEvento

*/

IF OBJECT_ID(N'XMLAudit.ssp_GeneraEvento', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_GeneraEvento AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_GeneraEvento (
	@chiaveGestionale_CodiceNumerico BIGINT = NULL,
	@chiaveGestionale_CodiceAlfanumerico NVARCHAR(40) = NULL,
	@storedProcedure sysname = NULL,
	@PKEvento BIGINT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO XMLAudit.Evento
	(
	    ChiaveGestionale_CodiceNumerico,
	    ChiaveGestionale_CodiceAlfanumerico,
	    DataOra,
	    StoredProcedure,
	    PKEsitoEvento
	)
	VALUES
	(   @chiaveGestionale_CodiceNumerico,             -- ChiaveGestionale_CodiceNumerico - bigint
	    @chiaveGestionale_CodiceAlfanumerico,           -- ChiaveGestionale_CodiceAlfanumerico - nvarchar(40)
	    SYSDATETIME(), -- DataOra - datetime2(7)
	    @storedProcedure,          -- StoredProcedure - sysname
	    -1              -- PKEsitoEvento - smallint
	);

	SELECT @PKEvento = SCOPE_IDENTITY();

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_ScriviLogEvento
 * @description Scrittura riga di log evento (procedura di sistema)

 * @param_input @PKEvento
 * @param_input @Messaggio
 * @param_input @PKEsitoEvento
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.ssp_ScriviLogEvento', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_ScriviLogEvento AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_ScriviLogEvento (
	@PKEvento BIGINT,
	@Messaggio NVARCHAR(500),
	@PKEsitoEvento SMALLINT = NULL,
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @LivelloLog = COALESCE(@LivelloLog, 0); -- 0: trace

	INSERT INTO XMLAudit.Evento_Riga
	(
	    PKEvento,
	    DataOra,
	    Messaggio,
		LivelloLog
	)
	VALUES
	(   @PKEvento,
	    SYSDATETIME(),
	    @Messaggio,
		@LivelloLog
	);

	IF (@PKEsitoEvento IS NOT NULL)
	BEGIN

		UPDATE XMLAudit.Evento
		SET PKEsitoEvento = @PKEsitoEvento
		WHERE PKEvento = @PKEvento;

	END;

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_LeggiLogEvento
 * @description Lettura log evento (procedura di sistema)

 * @param_input @PKEvento
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.ssp_LeggiLogEvento', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_LeggiLogEvento AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_LeggiLogEvento (
	@PKEvento BIGINT,
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @LivelloLog = COALESCE(@LivelloLog, 2); -- 2: info

	SELECT
		ER.PKEvento_Riga,
		ER.PKEvento,
		ER.DataOra,
		ER.Messaggio,
		ER.LivelloLog

	FROM XMLAudit.Evento E
	INNER JOIN XMLAudit.Evento_Riga ER ON ER.PKEvento = E.PKEvento
	WHERE E.PKEvento = @PKEvento
		AND ER.LivelloLog >= @LivelloLog
	ORDER BY ER.PKEvento_Riga;

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_GeneraValidazione
 * @description Generazione nuova validazione (procedura di sistema)

 * @param_input @PKStaging_FatturaElettronicaHeader
 * @param_input @PKEvento

 * @param_output @PKValidazione

*/

IF OBJECT_ID(N'XMLAudit.ssp_GeneraValidazione', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_GeneraValidazione AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_GeneraValidazione (
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT,
	@PKValidazione BIGINT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	SET @PKValidazione = NEXT VALUE FOR XMLAudit.seq_Validazione;

	INSERT INTO XMLAudit.Validazione
	(
	    PKValidazione,
	    PKStaging_FatturaElettronicaHeader,
	    DataOraValidazione,
	    PKEvento,
	    PKStato,
	    IsValida
	)
	VALUES
	(   @PKValidazione,             -- PKValidazione - bigint
	    @PKStaging_FatturaElettronicaHeader,             -- PKStaging_FatturaElettronicaHeader - bigint
	    SYSDATETIME(), -- DataOraValidazione - datetime2(7)
	    @PKEvento,             -- PKEvento - bigint
		1,             -- PKStato - tinyint
	    0           -- IsValida - bit
	);

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_ScriviLogValidazione
 * @description Scrittura riga di log Validazione (procedura di sistema)

 * @param_input @PKValidazione
 * @param_input @campo
 * @param_input @valoreTesto
 * @param_input @valoreIntero
 * @param_input @valoreDecimale
 * @param_input @valoreData
 * @param_input @Messaggio
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.ssp_ScriviLogValidazione', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_ScriviLogValidazione AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_ScriviLogValidazione (
	@PKValidazione BIGINT,
	@campo NVARCHAR(100),
	@valoreTesto NVARCHAR(100) = NULL,
	@valoreIntero INT = NULL,
	@valoreDecimale DECIMAL(28, 12) = NULL,
	@valoreData DATETIME2 = NULL,
	@Messaggio NVARCHAR(500),
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @LivelloLog = COALESCE(@LivelloLog, 0); -- 0: trace

	INSERT INTO XMLAudit.Validazione_Riga
	(
	    --PKValidazione_Riga,
	    PKValidazione,
	    Campo,
	    ValoreTesto,
	    ValoreIntero,
	    ValoreDecimale,
		ValoreData,
	    Messaggio,
		LivelloLog
	)
	VALUES
	(   --0,    -- PKValidazione_Riga - bigint
	    @PKValidazione,    -- PKValidazione - bigint
	    @campo,  -- Campo - nvarchar(100)
	    @valoreTesto,  -- ValoreTesto - nvarchar(100)
	    @valoreIntero,    -- ValoreIntero - int
	    @valoreDecimale, -- ValoreDecimale - decimal(28, 12)
		@valoreData, -- ValoreData - datetime2
	    @Messaggio,   -- Messaggio - nvarchar(100)
		@LivelloLog		-- LivelloLog - tinyint
	);

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI
 * @description Scrittura riga di log Validazione (procedura di sistema)

 * @param_input @PKValidazione
 * @param_input @IDCampo
 * @param_input @CodiceErroreSDI
 * @param_input @valoreTesto
 * @param_input @valoreIntero
 * @param_input @valoreDecimale
 * @param_input @valoreData
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI (
	@PKValidazione BIGINT,
	@IDCampo NVARCHAR(20),
	@CodiceErroreSDI SMALLINT,
	--@campo NVARCHAR(100),
	@valoreTesto NVARCHAR(100) = NULL,
	@valoreIntero INT = NULL,
	@valoreDecimale DECIMAL(28, 12) = NULL,
	@valoreData DATETIME2 = NULL,
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @NomeElemento NVARCHAR(100);
	DECLARE @DescrizioneCampo NVARCHAR(500);
	DECLARE @Messaggio NVARCHAR(100);

	SELECT @NomeElemento = NomeElemento
	FROM XMLCodifiche.CampiXML
	WHERE IndiceElemento = @IDCampo;

	SET @DescrizioneCampo = REPLACE(REPLACE(N'%NOME_ELEMENTO% (%INDICE_ELEMENTO%)', N'%NOME_ELEMENTO%', COALESCE(@NomeElemento, N'')), N'%INDICE_ELEMENTO%', @IDCampo);

	SELECT
		@Messaggio = DescrizioneErroreSDI
	FROM XMLCodifiche.CodiceErroreSDI
	WHERE IDCampo = @IDCampo
		AND CodiceErroreSDI = @CodiceErroreSDI;

	SELECT @Messaggio = COALESCE(@Messaggio, REPLACE(REPLACE(N'Errore generico: CodiceErroreSDI %CODICE_ERRORE_SDI% non definito per %DESCRIZIONE_CAMPO%', N'%DESCRIZIONE_CAMPO%', @DescrizioneCampo), N'%CODICE_ERRORE_SDI%', CONVERT(NVARCHAR(10), @CodiceErroreSDI)));

	INSERT INTO XMLAudit.Validazione_Riga
	(
		--PKValidazione_Riga,
		PKValidazione,
		Campo,
		ValoreTesto,
		ValoreIntero,
		ValoreDecimale,
		ValoreData,
		Messaggio,
		LivelloLog
	)
	VALUES (
		@PKValidazione,
		@DescrizioneCampo,
		@valoreTesto,
		@valoreIntero,
		@valoreDecimale,
		@valoreData,
		@Messaggio,
		@LivelloLog
	);

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_LeggiLogValidazione
 * @description Lettura log Validazione (procedura di sistema)

 * @param_input @PKValidazione
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.ssp_LeggiLogValidazione', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_LeggiLogValidazione AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_LeggiLogValidazione (
	@PKValidazione BIGINT,
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @LivelloLog = COALESCE(@LivelloLog, 2); -- 2: info

	SELECT
		VR.PKValidazione_Riga,
		VR.PKValidazione,
		VR.Campo,
		VR.ValoreTesto,
		VR.ValoreIntero,
		VR.ValoreDecimale,
		VR.ValoreData,
		VR.Messaggio,
		VR.LivelloLog

	FROM XMLAudit.Validazione V
	INNER JOIN XMLAudit.Validazione_Riga VR ON VR.PKValidazione = V.PKValidazione
	WHERE V.PKValidazione = @PKValidazione
		AND VR.LivelloLog >= @LivelloLog
	ORDER BY VR.PKValidazione_Riga;

END;
GO
