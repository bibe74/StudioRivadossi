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
 * @stored_procedure XMLAudit.usp_LeggiLogEvento
 * @description Lettura log evento

 * @param_input @PKEvento
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.usp_LeggiLogEvento', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.usp_LeggiLogEvento AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.usp_LeggiLogEvento (
	@chiaveGestionale_CodiceNumerico BIGINT = NULL,
	@chiaveGestionale_CodiceAlfanumerico NVARCHAR(40) = NULL,
	@PKEvento BIGINT,
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @LivelloLog = COALESCE(@LivelloLog, 2); -- 2: info

	IF NOT (@chiaveGestionale_CodiceNumerico IS NULL AND @chiaveGestionale_CodiceAlfanumerico IS NULL)
	BEGIN

		SELECT
			ER.PKEvento_Riga,
			ER.PKEvento,
			ER.DataOra,
			ER.Messaggio,
			ER.LivelloLog

		FROM XMLAudit.Evento E
		INNER JOIN XMLAudit.Evento_Riga ER ON ER.PKEvento = E.PKEvento
		WHERE E.PKEvento = @PKEvento
			AND (
				@chiaveGestionale_CodiceNumerico IS NULL
				OR E.ChiaveGestionale_CodiceNumerico = @chiaveGestionale_CodiceNumerico
			)
			AND (
				@chiaveGestionale_CodiceAlfanumerico IS NULL
				OR E.ChiaveGestionale_CodiceAlfanumerico = @chiaveGestionale_CodiceAlfanumerico
			)
			AND ER.LivelloLog >= @LivelloLog
		ORDER BY ER.PKEvento_Riga;

	END;

END;
GO

/**
 * @stored_procedure XMLAudit.usp_LeggiLogValidazione
 * @description Lettura log Validazione

 * @param_input @chiaveGestionale_CodiceNumerico
 * @param_input @chiaveGestionale_CodiceAlfanumerico
 * @param_input @PKValidazione
 * @param_input @LivelloLog

*/

IF OBJECT_ID(N'XMLAudit.usp_LeggiLogValidazione', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.usp_LeggiLogValidazione AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.usp_LeggiLogValidazione (
	@chiaveGestionale_CodiceNumerico BIGINT = NULL,
	@chiaveGestionale_CodiceAlfanumerico NVARCHAR(40) = NULL,
	@PKValidazione BIGINT,
	@LivelloLog TINYINT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	SELECT @LivelloLog = COALESCE(@LivelloLog, 2); -- 2: info

	IF NOT (@chiaveGestionale_CodiceNumerico IS NULL AND @chiaveGestionale_CodiceAlfanumerico IS NULL)
	BEGIN

		SELECT
			ER.PKValidazione_Riga,
			ER.PKValidazione,
			ER.Campo,
			ER.ValoreTesto,
			ER.ValoreIntero,
			ER.ValoreDecimale,
			ER.Messaggio,
			ER.LivelloLog

		FROM XMLAudit.Validazione E
		INNER JOIN XMLFatture.Staging_FatturaElettronicaHeader SFEH ON SFEH.PKStaging_FatturaElettronicaHeader = E.PKStaging_FatturaElettronicaHeader
		INNER JOIN XMLFatture.Landing_Fattura LF ON LF.PKLanding_Fattura = SFEH.PKLanding_Fattura
			AND (
				@chiaveGestionale_CodiceNumerico IS NULL
				OR LF.ChiaveGestionale_CodiceNumerico = @chiaveGestionale_CodiceNumerico
			)
			AND (
				@chiaveGestionale_CodiceAlfanumerico IS NULL
				OR LF.ChiaveGestionale_CodiceAlfanumerico = @chiaveGestionale_CodiceAlfanumerico
			)
		INNER JOIN XMLAudit.Validazione_Riga ER ON ER.PKValidazione = E.PKValidazione
		WHERE E.PKValidazione = @PKValidazione
		ORDER BY ER.PKValidazione_Riga;

	END;

END;
GO
