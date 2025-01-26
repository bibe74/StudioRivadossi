--USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'FXML')
BEGIN
	EXEC ('CREATE SCHEMA FXML AUTHORIZATION dbo;');
END;
GO

/**
 * @stored_procedure FXML.usp_LeggiLogEvento
 * @description

 * @param_input @IDDocumento
 * @param_input @PKEvento
 * @param_input @LivelloLog
*/

CREATE OR ALTER PROCEDURE FXML.usp_LeggiLogEvento (
	@IDDocumento UNIQUEIDENTIFIER,
	@PKEvento BIGINT,
	@LivelloLog TINYINT = NULL
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @codiceNumerico INT;
	DECLARE @codiceAlfanumerico NVARCHAR(40);

	SELECT
		@codiceNumerico = D.NumeroInt,
		@codiceAlfanumerico = CONVERT(NVARCHAR(40), @IDDocumento)

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.ID = @IDDocumento;

	EXEC InVoiceXML.XMLAudit.usp_LeggiLogEvento @chiaveGestionale_CodiceNumerico = @codiceNumerico,       -- bigint
	                                            @chiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico, -- nvarchar(40)
	                                            @PKEvento = @PKEvento,                              -- bigint
	                                            @LivelloLog = @LivelloLog                             -- tinyint

END;
GO

/**
 * @stored_procedure FXML.usp_LeggiLogValidazione
 * @description

 * @param_input @IDDocumento
 * @param_input @PKValidazione
 * @param_input @LivelloLog
*/

CREATE OR ALTER PROCEDURE FXML.usp_LeggiLogValidazione (
	@IDDocumento UNIQUEIDENTIFIER,
	@PKValidazione BIGINT,
	@LivelloLog TINYINT = NULL
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @codiceNumerico INT;
	DECLARE @codiceAlfanumerico NVARCHAR(40);

	SELECT
		@codiceNumerico = D.NumeroInt,
		@codiceAlfanumerico = CONVERT(NVARCHAR(40), @IDDocumento)

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.ID = @IDDocumento;

	EXEC InVoiceXML.XMLAudit.usp_LeggiLogValidazione @chiaveGestionale_CodiceNumerico = @codiceNumerico,       -- bigint
	                                            @chiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico, -- nvarchar(40)
	                                            @PKValidazione = @PKValidazione,                              -- bigint
	                                            @LivelloLog = @LivelloLog                             -- tinyint

END;
GO

/**
 * @stored_procedure FXML.usp_EsportaFattura
 * @description

 * @param_input @IDDocumento

 * @param_output @PKEvento
 * @param_output @PKEsitoEvento
 * @param_output @PKLanding_Fattura
*/

CREATE OR ALTER PROCEDURE FXML.usp_EsportaFattura (
	@IDDocumento UNIQUEIDENTIFIER,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@PKLanding_Fattura BIGINT OUTPUT
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @codiceNumerico INT;
	DECLARE @codiceAlfanumerico NVARCHAR(40);

	SELECT
		@codiceNumerico = D.NumeroInt,
		@codiceAlfanumerico = CONVERT(NVARCHAR(40), @IDDocumento)

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.ID = @IDDocumento;

	BEGIN TRY

		EXEC InVoiceXML.XMLFatture.usp_ImportaFattura @codiceNumerico = @codiceNumerico,
													  @codiceAlfanumerico = @codiceAlfanumerico,
													  @PKEvento = @PKEvento OUTPUT,
													  @PKEsitoEvento = @PKEsitoEvento OUTPUT,
													  @PKLanding_Fattura = @PKLanding_Fattura OUTPUT;

		PRINT REPLACE('Fattura esportata, assegnato PKLanding_Fattura #%PKLanding_Fattura%', '%PKLanding_Fattura%', CONVERT(VARCHAR(20), @PKLanding_Fattura));

	END TRY
	BEGIN CATCH

		-- TODO: gestire l'eccezione in importazione
		PRINT 'TODO: gestire l''eccezione in importazione';

	END CATCH

	IF (@PKEsitoEvento = 0)
	BEGIN
		PRINT 'Proseguo nell''esportazione';
	END;

	EXEC InVoiceXML.XMLAudit.usp_LeggiLogEvento @chiaveGestionale_CodiceNumerico = @codiceNumerico,
	                                            @chiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico,
	                                            @PKEvento = @PKEvento,
	                                            @LivelloLog = 0; -- 0: trace, 1: debug, 2: info, 3: warn, 4: error

END;
GO

/**
 * @stored_procedure FXML.usp_EsportaDatiFattura
 * @description

 * @param_input @IDDocumento
 * @param_input @PKLanding_Fattura

 * @param_output @PKEvento
 * @param_output @PKEsitoEvento
 * @param_output @PKStaging_FatturaElettronicaHeader
*/

CREATE OR ALTER PROCEDURE FXML.usp_EsportaDatiFattura (
	@IDDocumento UNIQUEIDENTIFIER,
	@PKLanding_Fattura BIGINT,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@PKStaging_FatturaElettronicaHeader BIGINT OUTPUT
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @codiceNumerico INT;
	DECLARE @codiceAlfanumerico NVARCHAR(40);

	SELECT
		@codiceNumerico = D.NumeroInt,
		@codiceAlfanumerico = CONVERT(NVARCHAR(40), @IDDocumento)

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.ID = @IDDocumento;

	EXEC InVoiceXML.XMLFatture.usp_ImportaDatiFattura @codiceNumerico = @codiceNumerico,
	                                                  @codiceAlfanumerico = @codiceAlfanumerico,
	                                                  @PKLanding_Fattura = @PKLanding_Fattura,
	                                                  @PKEvento = @PKEvento OUTPUT,
	                                                  @PKEsitoEvento = @PKEsitoEvento OUTPUT,
	                                                  @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader OUTPUT;

	EXEC FXML.ssp_EsportaDatiFattura_Header @IDDocumento = @IDDocumento,
	                                        @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

	PRINT REPLACE('Testata fattura esportata, assegnato PKStaging_FatturaElettronicaHeader #%PKStaging_FatturaElettronicaHeader%', '%PKStaging_FatturaElettronicaHeader%', CONVERT(VARCHAR(20), @PKStaging_FatturaElettronicaHeader));

	EXEC FXML.ssp_EsportaDatiFattura_Body @IDDocumento = @IDDocumento,
	                                      @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	PRINT REPLACE('Righe fattura esportate per PKStaging_FatturaElettronicaHeader #%PKStaging_FatturaElettronicaHeader%', '%PKStaging_FatturaElettronicaHeader%', CONVERT(VARCHAR(20), @PKStaging_FatturaElettronicaHeader));

END;
GO

/**
 * @stored_procedure FXML.usp_ConvalidaFattura
 * @description

 * @param_input @IDDocumento
 * @param_input @PKStaging_FatturaElettronicaHeader

 * @param_output @PKEvento
 * @param_output @PKEsitoEvento
 * @param_output @IsValida
 * @param_output @PKValidazione
 * @param_output @PKFatturaElettronicaHeader
*/

CREATE OR ALTER PROCEDURE FXML.usp_ConvalidaFattura (
	@IDDocumento UNIQUEIDENTIFIER,
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@IsValida BIT OUTPUT,
	@PKValidazione BIGINT OUTPUT,
	@PKFatturaElettronicaHeader BIGINT OUTPUT
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @codiceNumerico INT;
	DECLARE @codiceAlfanumerico NVARCHAR(40);

	SELECT
		@codiceNumerico = D.NumeroInt,
		@codiceAlfanumerico = CONVERT(NVARCHAR(40), @IDDocumento)

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.ID = @IDDocumento;

	EXEC InVoiceXML.XMLFatture.usp_ConvalidaFattura @codiceNumerico = @codiceNumerico,
	                                                @codiceAlfanumerico = @codiceAlfanumerico,
	                                                @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
	                                                @PKEvento = @PKEvento OUTPUT,
	                                                @PKEsitoEvento = @PKEsitoEvento OUTPUT,
													@IsValida = @IsValida OUTPUT,
	                                                @PKValidazione = @PKValidazione OUTPUT,
	                                                @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT;

END;
GO

/**
 * @stored_procedure FXML.usp_GeneraXMLFattura
 * @description

 * @param_input @IDDocumento
 * @param_input @PKFatturaElettronicaHeader

 * @param_output @PKEvento
 * @param_output @PKEsitoEvento
 * @param_output @XML
*/

CREATE OR ALTER PROCEDURE FXML.usp_GeneraXMLFattura (
	@IDDocumento UNIQUEIDENTIFIER,
	@PKFatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@XMLOutput XML OUTPUT
) AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @codiceNumerico INT;
	DECLARE @codiceAlfanumerico NVARCHAR(40);

	SELECT
		@codiceNumerico = D.NumeroInt,
		@codiceAlfanumerico = CONVERT(NVARCHAR(40), @IDDocumento)

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.ID = @IDDocumento;

	EXEC InVoiceXML.XMLFatture.usp_GeneraXMLFattura @codiceNumerico = @codiceNumerico,                    -- bigint
	                                                @codiceAlfanumerico = @codiceAlfanumerico,              -- nvarchar(40)
	                                                @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,        -- bigint
	                                                @PKEvento = @PKEvento OUTPUT,           -- bigint
	                                                @PKEsitoEvento = @PKEsitoEvento OUTPUT, -- smallint
	                                                @XMLOutput = @XMLOutput OUTPUT                      -- text

END;
GO

/**
 * @stored_procedure FXML.usp_VerificaParametri
 * @description Verifica parametri per fatturazione elettronica

 * @param_input @DataInizioFatturazioneElettronica

*/

CREATE OR ALTER PROCEDURE FXML.usp_VerificaParametri (
	@DataInizioFatturazioneElettronica DATETIME = NULL,
	@debug BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF (@DataInizioFatturazioneElettronica IS NULL)
	BEGIN
		SELECT @DataInizioFatturazioneElettronica = CONVERT(DATETIME, CP.Valore)
		FROM dbo.Conf_Parametri CP
		WHERE CP.ID = N'Company.SDI_DataInizioFatturazioneElettronica';
	END;

	IF (@DataInizioFatturazioneElettronica IS NULL) SET @DataInizioFatturazioneElettronica = CAST('20190101' AS DATETIME);

	IF OBJECT_ID('tempdb..#FattureDaVerificare') IS NOT NULL
	BEGIN
		DROP TABLE #FattureDaVerificare;
	END;

	SELECT
		D.ID,
		D.IDTipo,
		D.IDCliFor,
		D.Numero,
		D.Data,
		D.TotDoc

	INTO #FattureDaVerificare
	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	WHERE D.Data >= @DataInizioFatturazioneElettronica
	ORDER BY D.Data,
		D.Numero;

	IF (@debug = CAST(1 AS BIT))
	BEGIN

		SELECT
			D.ID,
            D.IDTipo,
            D.IDCliFor,
            D.Numero,
            D.Data,
            D.TotDoc

		FROM #FattureDaVerificare D
		ORDER BY D.Data,
			D.Numero;

	END;

	SELECT DISTINCT
		N'dbo' AS schema_name,
		N'CliFor' AS table_name,
		CF.Codice AS Codice,
		CF.Intestazione AS Descrizione,
		101 AS IDVerifica,
		N'Cliente senza CodiceDestinatario nè PECDestinatario' AS Note

	FROM #FattureDaVerificare D
	INNER JOIN dbo.CliFor CF ON CF.ID = D.IDCliFor
		AND COALESCE(CF.SDI_CodiceDestinatarioCliente, N'') = N''
		AND COALESCE(CF.SDI_PECDestinatarioCliente, N'') = N''
	LEFT JOIN dbo.Nazioni N ON N.ID = CF.Nazione

	WHERE D.Data >= @DataInizioFatturazioneElettronica
		AND COALESCE(N.SDI_IDNazione, N'IT') = N'IT' -- Escludo i clienti esteri

	UNION ALL

	SELECT DISTINCT
		N'dbo' AS schema_name,
		N'CliFor' AS table_name,
		CF.Codice AS Codice,
		CF.Intestazione AS Descrizione,
		102 AS IDVerifica,
		N'Cliente senza Nazione' AS Note

	FROM #FattureDaVerificare D
	INNER JOIN dbo.CliFor CF ON CF.ID = D.IDCliFor
	LEFT JOIN dbo.Nazioni N ON N.ID = CF.Nazione

	WHERE D.Data >= @DataInizioFatturazioneElettronica
		AND N.SDI_IDNazione IS NULL

	UNION ALL

	SELECT DISTINCT
		N'dbo' AS schema_name,
		N'CliFor' AS table_name,
		CF.Codice AS Codice,
		CF.Intestazione AS Descrizione,
		103 AS IDVerifica,
		N'Cliente senza Partita IVA nè Codice Fiscale' AS Note

	FROM #FattureDaVerificare D
	INNER JOIN dbo.CliFor CF ON CF.ID = D.IDCliFor
		AND COALESCE(CF.SDI_CodiceDestinatarioCliente, N'') = N''
		AND COALESCE(CF.SDI_PECDestinatarioCliente, N'') = N''
	LEFT JOIN dbo.Nazioni N ON N.ID = CF.Nazione

	WHERE D.Data >= @DataInizioFatturazioneElettronica
		AND COALESCE(N.SDI_IDNazione, N'IT') = N'IT' -- Escludo i clienti esteri
		AND COALESCE(CF.PI, N'') = N''
		AND COALESCE(CF.CF, N'') = N''

	ORDER BY schema_name,
		table_name,
		Codice,
		IDVerifica;

END;
GO

--EXEC FXML.usp_VerificaParametri @DataInizioFatturazioneElettronica = '20180101';
GO

EXEC FXML.usp_VerificaParametri @DataInizioFatturazioneElettronica = '20180101', -- datetime
                                @debug = 1                                 -- bit
GO

/**
 * @stored_procedure FXML.usp_VerificaCoerenzaDatiBollo
 * @description Verifica coerenza importi IVA esente/spese bollo

 * @param_input @DataInizio
 * @param_input @DataFine

*/

CREATE OR ALTER PROCEDURE FXML.usp_VerificaCoerenzaDatiBollo (
	@DataInizio DATETIME = NULL,
	@DataFine DATETIME = NULL
) AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @ImportoSoglia DECIMAL(19, 6) = 77.47;

    IF (@DataInizio IS NULL) SET @DataInizio = CAST('20190101' AS DATETIME);
    IF (@DataFine IS NULL) SET @DataFine = DATEADD(YEAR, 1, DATEADD(DAY, -DATEPART(DAYOFYEAR, CAST(CURRENT_TIMESTAMP AS DATE)), CURRENT_TIMESTAMP));

    SELECT @DataInizio AS DataInizio, @DataFine AS DataFine;

    WITH FattureOltreSoglia
    AS (
        SELECT
            D.Data AS DataDocumento,
            DI.IDDocumento,
            D.NumeroInt,
            D.Numero,
            SUM(DI.ImpNetto) AS ImponibileIVAEsente

        FROM dbo.Documenti_Iva DI
        INNER JOIN dbo.Documenti D ON D.ID = DI.IDDocumento
        INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
            AND DT.SDI_IsValido = CAST(1 AS BIT)
        INNER JOIN dbo.CodiciIva CIVA ON CIVA.ID = DI.CodIva
            AND CIVA.Perc = 0.0
        WHERE D.Data BETWEEN @DataInizio AND @DataFine
        GROUP BY D.Data,
            DI.IDDocumento,
            D.NumeroInt,
            D.Numero
        HAVING SUM(DI.ImpNetto) > 77.47
    ), SpeseBollo
    AS (
        SELECT
            D.Data AS DataDocumento,
            DS.IDDocumento,
            D.NumeroInt,
            D.Numero,
            SUM(DS.ImpNetto) AS ImponibileNettoBollo,
            SUM(DS.ImpLordo) AS ImponibileLordoBollo

        FROM dbo.Documenti_Spese DS
        INNER JOIN dbo.Documenti D ON D.ID = DS.IDDocumento
            AND D.Data BETWEEN @DataInizio AND @DataFine
        INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
            AND DT.SDI_IsValido = CAST(1 AS BIT)
        WHERE DS.IsBollo = CAST(1 AS BIT)
        GROUP BY D.Data,
            DS.IDDocumento,
            D.NumeroInt,
            D.Numero
    )
    SELECT
        COALESCE(FOS.DataDocumento, SB.DataDocumento) AS DataDocumento,
        COALESCE(FOS.IDDocumento, SB.IDDocumento) AS IDDocumento,
        COALESCE(FOS.NumeroInt, SB.NumeroInt) AS NumeroInt,
        COALESCE(FOS.Numero, SB.Numero) AS Numero,
        FOS.ImponibileIVAEsente,
        SB.ImponibileNettoBollo,
        SB.ImponibileLordoBollo

    FROM FattureOltreSoglia FOS
    FULL JOIN SpeseBollo SB ON SB.IDDocumento = FOS.IDDocumento
    ORDER BY COALESCE(FOS.DataDocumento, SB.DataDocumento),
        COALESCE(FOS.NumeroInt, SB.NumeroInt);

END;
GO
