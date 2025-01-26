USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

/**
 * @function XMLFatture.sfn_VerificaFormalePartitaIVA
 * @description Verifica formale partita IVA (funzione di sistema)

 * @param @PartitaIVA

 * @returns BIT
*/

IF OBJECT_ID(N'XMLFatture.sfn_VerificaFormalePartitaIVA', N'FN') IS NULL EXEC('CREATE DROP FUNCTION XMLFatture.sfn_VerificaFormalePartitaIVA (@param INT) RETURNS BIT AS BEGIN RETURN 0; END;');
GO

ALTER FUNCTION XMLFatture.sfn_VerificaFormalePartitaIVA (
	@PartitaIVA VARCHAR(16)
)
RETURNS BIT
AS
BEGIN

	DECLARE @risultato BIT = 0;

	IF LEN(@PartitaIVA) = 11
	BEGIN
		DECLARE @index INT = 1;
		DECLARE @char CHAR(1);
		DECLARE @s INT;
		DECLARE @s1 INT;
		DECLARE @dispari BIT;
		DECLARE @r INT;
		DECLARE @c INT;

		SET @risultato = 1;
		SET @s = 0;
		SET @dispari = 1;

		WHILE (@index <= 11) AND (@risultato = 1)
		BEGIN
			SET @char = SUBSTRING(@PartitaIVA, @index, 1);
			IF (@char = '.') OR (ISNUMERIC(@char) = 0)
			BEGIN
				SET @risultato = 0;
			END;
			ELSE
			BEGIN
				IF @index = 11
				BEGIN
					SET @r = @s % 10;
					IF @r = 0
					BEGIN
						SET @c = 0;
					END;
					ELSE
					BEGIN
						SET @c = 10 - @r;
					END;
		
					IF @c <> CAST(@char AS INT)
					BEGIN
						SET @risultato = 0;
					END;
				END;
				ELSE
				BEGIN
					IF @dispari = 1
					BEGIN
						SET @s = @s + CAST(@char AS INT);
						SET @dispari = 0;
					END;
					ELSE
					BEGIN
						SET @s1 = CAST(@char AS INT) * 2 ;
						IF @s1 > 9
						BEGIN
							SET @s1 = @s1 - 9;
						END;
						SET @s = @s + @s1;
						SET @dispari = 1;
					END;
				END;
			END;
			SET @index = @index + 1;
		END;
	END;

	RETURN @risultato;

END;
GO

/*
SELECT XMLFatture.sfn_VerificaFormalePartitaIVA('0336642098');
SELECT XMLFatture.sfn_VerificaFormalePartitaIVA('03366420986');
SELECT XMLFatture.sfn_VerificaFormalePartitaIVA('03366920486');
SELECT XMLFatture.sfn_VerificaFormalePartitaIVA('TRLLRT74B15D918W');
GO
*/

/**
 * @function XMLFatture.sfn_VerificaFormaleCodiceFiscale
 * @description Verifica formale codice fiscale (funzione di sistema)

 * @parameter @CodiceFiscale
 * @parameter @CheckPartitaIVA (default 0)

 * @returns BIT
*/

IF OBJECT_ID(N'XMLFatture.sfn_VerificaFormaleCodiceFiscale', N'FN') IS NULL EXEC('CREATE DROP FUNCTION XMLFatture.sfn_VerificaFormaleCodiceFiscale (@param INT) RETURNS BIT AS BEGIN RETURN 0; END;');
GO

ALTER FUNCTION XMLFatture.sfn_VerificaFormaleCodiceFiscale (
	@CodiceFiscale VARCHAR(16),
	@CheckPartitaIVA BIT = 0
)
RETURNS BIT
AS
BEGIN

	DECLARE @risultato BIT = 0;

	IF LEN(@CodiceFiscale) = 16
	BEGIN
		IF @CodiceFiscale LIKE '[A-Z][A-Z][A-Z][A-Z][A-Z][A-Z][0-9][0-9][A-Z][0-9][0-9][A-Z][0-9][0-9][0-9][A-Z]'
		BEGIN
			SET @risultato = 1;
		END;
	END;

	IF (@CheckPartitaIVA = CAST(1 AS BIT) AND LEN(@CodiceFiscale) = 11)
	BEGIN
		SELECT @risultato = XMLFatture.sfn_VerificaFormalePartitaIVA(@CodiceFiscale);
	END;

	RETURN @risultato;

END;
GO

/*
SELECT XMLFatture.sfn_VerificaFormaleCodiceFiscale('03366420986', 0);
SELECT XMLFatture.sfn_VerificaFormaleCodiceFiscale('03366420986', 1);
SELECT XMLFatture.sfn_VerificaFormaleCodiceFiscale('TRLLRT74B15D918', 0);
SELECT XMLFatture.sfn_VerificaFormaleCodiceFiscale('TRLLRT74B15D918W', 0);
SELECT XMLFatture.sfn_VerificaFormaleCodiceFiscale('TRLLRT74B154918W', 0);
GO
*/

/**
 * @function XMLFatture.sfn_VerificaFormaleBIC
 * @description Verifica formale codice fiscale (funzione di sistema)

 * @parameter @BIC
 * @parameter @CheckPartitaIVA (default 0)

 * @returns BIT
*/

IF OBJECT_ID(N'XMLFatture.sfn_VerificaFormaleBIC', N'FN') IS NULL EXEC('CREATE FUNCTION XMLFatture.sfn_VerificaFormaleBIC (@param INT) RETURNS BIT AS BEGIN RETURN 0; END;');
GO

ALTER FUNCTION XMLFatture.sfn_VerificaFormaleBIC (
	@BIC VARCHAR(100)
)
RETURNS BIT
AS
BEGIN

	DECLARE @risultato BIT = 0;

    IF (@BIC IS NOT NULL)
    BEGIN
        IF (LEN(@BIC) IN (8, 11))
        BEGIN
            IF (SUBSTRING(@BIC, 1, 1) LIKE '[A-Z]')
                AND (SUBSTRING(@BIC, 2, 1) LIKE '[A-Z]')
                AND (SUBSTRING(@BIC, 3, 1) LIKE '[A-Z]')
                AND (SUBSTRING(@BIC, 4, 1) LIKE '[A-Z]')
                AND (SUBSTRING(@BIC, 5, 1) LIKE '[A-Z]')
                AND (SUBSTRING(@BIC, 6, 1) LIKE '[A-Z]')
                AND (SUBSTRING(@BIC, 7, 1) LIKE '[A-Z]' OR SUBSTRING(@BIC, 7, 1) LIKE '[2-9]')
                AND (SUBSTRING(@BIC, 8, 1) LIKE '[A-N]' OR SUBSTRING(@BIC, 8, 1) LIKE '[P-Z]' OR SUBSTRING(@BIC, 8, 1) LIKE '[0-9]')
            BEGIN
                IF (LEN(@BIC) = 8)
                BEGIN
                    SET @risultato = 1;
                END;

                IF (LEN(@BIC) = 11)
                BEGIN
                    IF (SUBSTRING(@BIC, 9, 1) LIKE '[A-Z]' OR SUBSTRING(@BIC, 9, 1) LIKE '[0-9]')
                        AND (SUBSTRING(@BIC, 10, 1) LIKE '[A-Z]' OR SUBSTRING(@BIC, 10, 1) LIKE '[0-9]')
                        AND (SUBSTRING(@BIC, 11, 1) LIKE '[A-Z]' OR SUBSTRING(@BIC, 11, 1) LIKE '[0-9]')
                    BEGIN
                        SET @risultato = 1;
                    END;
                END;
            END;
        END;
    END;

	RETURN @risultato;

END;
GO

/*

SELECT
    T.BIC,
    XMLFatture.sfn_VerificaFormaleBIC(T.BIC) AS IsBICValido

FROM (

SELECT
    N'' AS BIC
UNION ALL SELECT NULL
UNION ALL SELECT N'ABCDEF99'
UNION ALL SELECT N'ABCDEF99AB0'
UNION ALL SELECT N'ABCDEF990A'
UNION ALL SELECT N'ABCD3F99'
UNION ALL SELECT N'ABCDEF99'
UNION ALL SELECT N'ABCDEF11'

) T;

*/

/**
 * @stored_procedure XMLFatture.ssp_VerificaParametriFattura
 * @description Verifica parametri fattura (procedura di sistema)

 * @input_param @sp_name
 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico

 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
*/

IF OBJECT_ID(N'XMLFatture.ssp_VerificaParametriFattura', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_VerificaParametriFattura AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_VerificaParametriFattura (
	@sp_name sysname,
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @Messaggio NVARCHAR(500);

	IF (@PKEvento IS NULL)
	BEGIN

		EXEC XMLAudit.ssp_GeneraEvento @chiaveGestionale_CodiceNumerico = @codiceNumerico,
										@chiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico,
										@storedProcedure = @sp_name,
										@PKEvento = @PKEvento OUTPUT;

		SET @PKEsitoEvento = -1;
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Impostazione EsitoEvento di default (-1)',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 0; -- 0: trace

	END;
	
	IF (@PKEsitoEvento IS NULL)
	BEGIN

		SET @PKEsitoEvento = -1;

	END;

	IF (@codiceNumerico IS NULL AND @codiceAlfanumerico IS NULL)
	BEGIN
		SET @PKEsitoEvento = 902; -- 902: Valorizzare almeno uno dei parametri @codiceNumerico e @codiceAlfanumerico
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Parametri non validi',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 4; -- 4: error
	END
	ELSE
	BEGIN

		IF (
			@sp_name = N'usp_ImportaFattura'
			OR @sp_name = N'usp_ImportaDatiFattura'
			OR @sp_name = N'usp_ConvalidaFattura'
		)
		BEGIN
		
			IF EXISTS(
				SELECT FEH.PKFatturaElettronicaHeader
				FROM XMLFatture.FatturaElettronicaHeader FEH
				INNER JOIN XMLFatture.Landing_Fattura LF ON LF.PKLanding_Fattura = FEH.PKLanding_Fattura
					AND (
						@codiceNumerico IS NULL
						OR LF.ChiaveGestionale_CodiceNumerico = @codiceNumerico
					)
					AND (
						@codiceAlfanumerico IS NULL
						OR LF.ChiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico
					)
				WHERE FEH.IsValidataDaSDI = CAST(1 AS BIT)
			)
			BEGIN

				SET @PKEsitoEvento = 903; -- 903: Fattura %CODICEFATTURA% già convalidata
				SELECT
					@Messaggio = REPLACE(E.Descrizione, N'%CODICEFATTURA%', COALESCE(@codiceAlfanumerico, N'#' + CONVERT(NVARCHAR(20), @codiceNumerico)))
			
				FROM XMLAudit.EsitoEvento E
				WHERE E.PKEsitoEvento = @PKEsitoEvento;

				EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
											@Messaggio = @Messaggio,
											@PKEsitoEvento = @PKEsitoEvento,
											@LivelloLog = 4; -- 4: error

			END;

		END;

	END;

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_VerificaCampoSDI
 * @description 

 * @param_input @PKValidazione
 * @param_input @IDCampo
 * @param_input @TipoValore (default 'T')
 * @param_input @ValoreTesto
 * @param_input @ValoreIntero
 * @param_input @ValoreDecimale
 * @param_input @ValoreData
 * @param_input @IsObbligatorio (default 1)
 * @param_input @IDNazione
 * @param_input @NumeroLinea
*/

IF OBJECT_ID(N'XMLFatture.ssp_VerificaCampoSDI', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_VerificaCampoSDI AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_VerificaCampoSDI (
	@PKValidazione BIGINT,
	@IDCampo NVARCHAR(20),
	@TipoValore CHAR(1) = 'T', -- T: Testo, I: Intero, D: Decimale, E: Data
	@ValoreTesto NVARCHAR(100) = NULL,
	@ValoreIntero INT = NULL,
	@ValoreDecimale DECIMAL(28, 12) = NULL,
	@ValoreData DATE = NULL,
	@IsObbligatorio BIT = 1,
	@IDNazione CHAR(2) = NULL,
	@NumeroLinea INT = NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @NomeElemento NVARCHAR(100);
	DECLARE @NomeElementoFull NVARCHAR(255);
	DECLARE @DescrizioneCampo NVARCHAR(100);
	DECLARE @PKEvento BIGINT;
	DECLARE @Messaggio NVARCHAR(500);

	SELECT @NomeElemento = NomeElemento,
		@NomeElementoFull = NomeElementoFull
	FROM XMLCodifiche.CampiXML
	WHERE IndiceElemento = @IDCampo;

	SELECT @PKEvento = V.PKEvento
	FROM XMLAudit.Validazione V
	WHERE V.PKValidazione = @PKValidazione;

	--SET @DescrizioneCampo = REPLACE(REPLACE(N'%NOME_ELEMENTO% (%INDICE_ELEMENTO%)', N'%NOME_ELEMENTO%', COALESCE(@NomeElemento, N'')), N'%INDICE_ELEMENTO%', @IDCampo);
	SET @DescrizioneCampo = REPLACE(REPLACE(REPLACE(N'%NOME_ELEMENTO_FULL% (%INDICE_ELEMENTO%%RIGA_ELEMENTO%)', N'%NOME_ELEMENTO_FULL%', COALESCE(@NomeElementoFull, N'')), N'%INDICE_ELEMENTO%', @IDCampo), N'%RIGA_ELEMENTO%', COALESCE(N' riga ' + CONVERT(NVARCHAR(10), @NumeroLinea), N''));

	IF (@TipoValore IS NULL)
	BEGIN

		SET @TipoValore = CASE
			WHEN @ValoreTesto IS NOT NULL THEN 'T'
			WHEN @ValoreIntero IS NOT NULL THEN 'I'
			WHEN @ValoreDecimale IS NOT NULL THEN 'D'
			WHEN @ValoreData IS NOT NULL THEN 'E'
			ELSE '?'
		END;

		IF (@TipoValore = '?')
		BEGIN

			SET @Messaggio = @DescrizioneCampo + REPLACE('Parametro @TipoValore %TIPO_VALORE% non valido', '%TIPO_VALORE%', @TipoValore);

			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,      -- bigint
			                                  @Messaggio = @Messaggio,   -- nvarchar(500)
			                                  @PKEsitoEvento = 307, -- 307: Errore in fase di validazione campo SDI: parametro @TipoValore non valido
			                                  @LivelloLog = 4;     -- tinyint

		END;

	END;

	IF (@IsObbligatorio = 1)
	BEGIN

		IF (
			(@TipoValore = 'T' AND COALESCE(@ValoreTesto, N'') = N'')
			OR (@TipoValore = N'I' AND COALESCE(@ValoreIntero, 0) = 0)
			OR (@TipoValore = N'D' AND COALESCE(@ValoreDecimale, 0.0) = 0.0)
			OR (@TipoValore = N'E' AND COALESCE(@ValoreData, CAST('19000101' AS DATE)) = CAST('19000101' AS DATE))
		)
		BEGIN

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
				@DescrizioneCampo,  -- Campo - nvarchar(100)
				@ValoreTesto,  -- ValoreTesto - nvarchar(100)
				@ValoreIntero,    -- ValoreIntero - int
				@ValoreDecimale, -- ValoreDecimale - decimal(28, 12)
				@ValoreData, -- ValoreData - date
				N'Campo obbligatorio non valorizzato',  -- Messaggio - nvarchar(100)
				4     -- LivelloLog - tinyint
			);

		END;

	END;

	-- Verifica Nazione (lookup XMLCodifiche.Nazione)
	IF (
		(@IDCampo = N'1.1.1.1')
		OR (@IDCampo = N'1.2.1.1.1')
		OR (@IDCampo = N'1.2.2.6')
		OR (@IDCampo = N'1.2.3.6')
		OR (@IDCampo = N'1.3.1.1.1' AND COALESCE(@ValoreTesto, N'') <> N'')
		OR (@IDCampo = N'1.4.1.1.1' AND COALESCE(@ValoreTesto, N'') <> N'')
		OR (@IDCampo = N'1.4.2.6')
		OR (@IDCampo = N'1.4.3.6')
		OR (@IDCampo = N'1.4.4.1.1' AND COALESCE(@ValoreTesto, N'') <> N'')
		OR (@IDCampo = N'1.5.1.1.1' AND COALESCE(@ValoreTesto, N'') <> N'')
	)
	BEGIN

		DECLARE @Nazione NVARCHAR(255);
		SELECT @Nazione = Nazione FROM XMLCodifiche.Nazione WHERE IDNazione = @ValoreTesto;

		IF (@Nazione IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @Nazione),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Nazione non trovata (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;
	END;

	-- Verifica Provincia (lookup XMLCodifiche.Provincia)
	IF (
		COALESCE(@IDNazione, '') = 'IT'
		AND (
			(@IDCampo = N'1.2.2.5')
			OR (@IDCampo = N'1.2.3.5')
			OR (@IDCampo = N'1.4.2.5')
			OR (@IDCampo = N'1.4.3.5')
		)
	)
	BEGIN

		DECLARE @Provincia NVARCHAR(255);
		SELECT @Provincia = Provincia FROM XMLCodifiche.Provincia WHERE IDProvincia = COALESCE(@ValoreTesto, '??'); -- Se la nazione è IT, la provincia deve essere valorizzata

		IF (@Provincia IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @Provincia),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Provincia non trovata (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;
	END;

	-- Verifica formale partita IVA
	IF (
		@IDNazione = 'IT'
		AND (
			(@IDCampo = N'1.2.1.1.2' AND COALESCE(@ValoreTesto, N'') <> N'')
			OR (@IDCampo = N'1.4.1.1.2' AND COALESCE(@ValoreTesto, N'') <> N'')
		)
	)
	BEGIN

		DECLARE @IsPartitaIVAFormalmenteValida BIT;
		SELECT @IsPartitaIVAFormalmenteValida = XMLFatture.sfn_VerificaFormalePartitaIVA(@ValoreTesto);

		IF (@IsPartitaIVAFormalmenteValida = 1)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				N'Partita IVA formalmente valida',
				2
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Verifica formale partita IVA non superata (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica formale codice fiscale
	IF (
		@IDNazione = 'IT'
		AND (
			(@IDCampo = N'1.1.1.2')
			OR (@IDCampo = N'1.2.1.2' AND COALESCE(@ValoreTesto, N'') <> N'')
			OR (@IDCampo = N'1.4.1.2' AND COALESCE(@ValoreTesto, N'') <> N'')
		)
	)
	BEGIN

		DECLARE @IsCodiceFiscaleFormalmenteValido BIT;

		IF (@IDCampo IN (N'1.1.1.2', N'1.2.1.2', N'1.4.1.2'))
		BEGIN
			-- Verifica formale codice fiscale o partita IVA (per i soli campi che possono contenere anche una partita IVA)
			SELECT @IsCodiceFiscaleFormalmenteValido = XMLFatture.sfn_VerificaFormaleCodiceFiscale(@ValoreTesto, 1);
		END;
		ELSE
		BEGIN
			SELECT @IsCodiceFiscaleFormalmenteValido = XMLFatture.sfn_VerificaFormaleCodiceFiscale(@ValoreTesto, 0);
		END;

		IF (@IsCodiceFiscaleFormalmenteValido = 1)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				N'Codice fiscale formalmente valido',
				2
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Verifica formale codice fiscale non superata (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

    -- Verifica formale BIC
	IF (@IDCampo = N'2.4.2.16' AND COALESCE(@ValoreTesto, N'') <> N'')
	BEGIN

		DECLARE @IsBICFormalmenteValido BIT;

		-- Verifica formale BIC
		SELECT @IsBICFormalmenteValido = XMLFatture.sfn_VerificaFormaleBIC(@ValoreTesto);

		IF (@IsBICFormalmenteValido = 1)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				N'BIC formalmente valido',
				2
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Verifica formale BIC non superata (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica formato trasmissione
	IF (
		(@IDCampo = N'1.1.3' AND COALESCE(@ValoreTesto, N'') <> N'')
	)
	BEGIN

		IF (@ValoreTesto IN (N'FPA12', N'FPR12'))
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'FormatoTrasmissione: valore ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				0
			);

		END;
		ELSE
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
			                                                  @IDCampo = N'1.1.3',
			                                                  @CodiceErroreSDI = 428,
			                                                  @valoreTesto = @ValoreTesto,
			                                                  @LivelloLog = 4;
			
		END;

	END;

	-- Verifica codice destinatario (lunghezza)
	IF (
		@IDCampo = N'1.1.4' AND LEN(COALESCE(@ValoreTesto, N'')) NOT IN (6, 7)
	)
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
			                                                @IDCampo = N'1.1.4',
			                                                @CodiceErroreSDI = 311,
			                                                @valoreTesto = @ValoreTesto,
			                                                @LivelloLog = 4;
	END;

	-- Verifica tipo documento (lookup XMLCodifiche.TipoDocumento)
	IF (
		(@IDCampo = N'2.1.1.1')
	)
	BEGIN

		DECLARE @TipoDocumento NVARCHAR(255);
		SELECT @TipoDocumento = TipoDocumento FROM XMLCodifiche.TipoDocumento WHERE IDTipoDocumento = @ValoreTesto;

		IF (@TipoDocumento IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @TipoDocumento),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoDocumento non trovato (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;
	END;

	-- Verifica divisa (lookup XMLCodifiche.Valuta)
	IF (
		(@IDCampo = N'2.1.1.2')
	)
	BEGIN

		DECLARE @Valuta NVARCHAR(255);
		SELECT @Valuta = Valuta FROM XMLCodifiche.Valuta WHERE IDValuta = @ValoreTesto;

		IF (@Valuta IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @Valuta),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Divisa non trovato (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica tipo ritenuta
	IF (
		(@IDCampo = N'2.1.1.5.1' AND @ValoreTesto <> N'')
	)
	BEGIN

		IF (@ValoreTesto IN (N'RT01', N'RT02'))
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoRitenuta: valore ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoRitenuta: valore non ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica causale pagamento
	IF (
		(@IDCampo = N'2.1.1.5.4' AND @ValoreTesto <> N'')
	)
	BEGIN

		DECLARE @CausalePagamento NVARCHAR(512);
		SELECT @CausalePagamento = CausalePagamento FROM XMLCodifiche.CausalePagamento WHERE IDCausalePagamento = @ValoreTesto;

		IF (@CausalePagamento IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				LEFT(REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @CausalePagamento), 100),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				LEFT(REPLACE(N'CausalePagamento non trovata (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', COALESCE(@ValoreTesto, N'')), 100),
				4
			);

		END;
	END;

	-- Verifica bollo virtuale
	IF (
		(@IDCampo = N'2.1.1.6.1' AND @ValoreTesto <> N'')
	)
	BEGIN

		DECLARE @BolloVirtuale NVARCHAR(255);
		SELECT @BolloVirtuale = RispostaSI FROM XMLCodifiche.RispostaSI WHERE IDRispostaSI = @ValoreTesto;

		IF (@BolloVirtuale IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				LEFT(REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @BolloVirtuale), 100),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				LEFT(REPLACE(N'BolloVirtuale non trovato (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', COALESCE(@ValoreTesto, N'')), 100),
				4
			);

		END;
	END;

	-- Verifica tipo cessione/prestazione
	IF (
		(@IDCampo = N'2.2.1.2' AND @ValoreTesto <> N'')
	)
	BEGIN

		IF (@ValoreTesto IN (N'SC', N'PR', N'AB', N'AC'))
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoCessionePrestazione: valore ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoCessionePrestazione: valore non ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica tipo sconto/maggiorazione
	IF (
		(@IDCampo = N'2.2.1.10.1' AND @ValoreTesto <> N'')
	)
	BEGIN

		IF (@ValoreTesto IN (N'SC', N'MG'))
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoScontoMaggiorazione: valore ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'TipoScontoMaggiorazione: valore non ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica "risposta" (lookup XMLCodifiche.RispostaSI)
	IF (
		(@IDCampo = N'2.2.1.13' AND @ValoreTesto <> N'')
	)
	BEGIN

		DECLARE @RispostaSI NVARCHAR(255);
		SELECT @RispostaSI = RispostaSI FROM XMLCodifiche.RispostaSI WHERE IDRispostaSI = @ValoreTesto;

		IF (@RispostaSI IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @RispostaSI),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Divisa non trovato (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica natura (lookup XMLCodifiche.Natura)
	IF (
		(@IDCampo = N'2.2.1.14' AND @ValoreTesto <> N'')
	)
	BEGIN

		DECLARE @Natura NVARCHAR(255);
		SELECT @Natura = Natura FROM XMLCodifiche.Natura WHERE IDNatura = @ValoreTesto;

		IF (@Natura IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @Natura),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Natura non trovata (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica esigilibità IVA
	IF (
		(@IDCampo = N'2.2.2.7')
	)
	BEGIN

		IF (@ValoreTesto IN (N'I', N'D', N'S'))
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'EsigibilitaIVA: valore ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'EsigibilitaIVA: valore non ammesso (%VALORE_TESTO%)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

	-- Verifica modalità pagamento (lookup XMLCodifiche.ModalitaPagamento)
	IF (
		(@IDCampo = N'2.4.2.2' AND @ValoreTesto <> N'')
	)
	BEGIN

		DECLARE @ModalitaPagamento NVARCHAR(255);
		SELECT @ModalitaPagamento = ModalitaPagamento FROM XMLCodifiche.ModalitaPagamento WHERE IDModalitaPagamento = @ValoreTesto;

		IF (@ModalitaPagamento IS NOT NULL)
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES
			(   --0,
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(REPLACE(N'Lookup completata (%VALORE_TESTO% > %VALORE_LOOKUP%)', N'%VALORE_TESTO%', @ValoreTesto), N'%VALORE_LOOKUP%', @ModalitaPagamento),
				0
			);

		END;
		ELSE
		BEGIN

			INSERT INTO XMLAudit.Validazione_Riga
			(
				--PKValidazione_Riga,
				PKValidazione,
				Campo,
				ValoreTesto,
				Messaggio,
				LivelloLog
			)
			VALUES (
				@PKValidazione,
				@DescrizioneCampo,
				@ValoreTesto,
				REPLACE(N'Divisa non trovato (%VALORE_TESTO% > ???)', N'%VALORE_TESTO%', @ValoreTesto),
				4
			);

		END;

	END;

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_ConvalidaFatturaHeader
 * @description Convalida fattura: verifica campi di testata

 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @PKValidazione
*/

IF OBJECT_ID(N'XMLAudit.ssp_ConvalidaFatturaHeader', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_ConvalidaFatturaHeader AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_ConvalidaFatturaHeader (
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKValidazione BIGINT
)
AS
BEGIN

	SET NOCOUNT ON;

	/* declare variables */
	DECLARE @DatiTrasmissione_IdTrasmittente_IdPaese CHAR(2);
	DECLARE @DatiTrasmissione_IdTrasmittente_IdCodice NVARCHAR(28);
	DECLARE @DatiTrasmissione_ProgressivoInvio NVARCHAR(10);
	DECLARE @DatiTrasmissione_FormatoTrasmissione CHAR(5);
	DECLARE @DatiTrasmissione_CodiceDestinatario NVARCHAR(7);
	DECLARE @DatiTrasmissione_PECDestinatario NVARCHAR(256);
	DECLARE @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2);
	DECLARE @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28);
	DECLARE @CedentePrestatore_DatiAnagrafici_CodiceFiscale NVARCHAR(16);
	DECLARE @CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80);
	DECLARE @CedentePrestatore_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60);	
	DECLARE @CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60);	
	DECLARE @CedentePrestatore_DatiAnagrafici_RegimeFiscale CHAR(4);
	DECLARE @CedentePrestatore_Sede_Indirizzo NVARCHAR(60);	
	DECLARE @CedentePrestatore_Sede_NumeroCivico NVARCHAR(8);	
	DECLARE @CedentePrestatore_Sede_CAP CHAR(5);	
	DECLARE @CedentePrestatore_Sede_Comune NVARCHAR(60);	
	DECLARE @CedentePrestatore_Sede_Provincia CHAR(2);
	DECLARE @CedentePrestatore_Sede_Nazione CHAR(2);
	DECLARE @RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2);
	DECLARE @RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28);
	DECLARE @RappresentanteFiscale_DatiAnagrafici_CodiceFiscale NVARCHAR(16);
	DECLARE @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80);	
	DECLARE @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60);	
	DECLARE @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60);	
	DECLARE @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2);
	DECLARE @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28);
	DECLARE @CessionarioCommittente_DatiAnagrafici_CodiceFiscale NVARCHAR(16);
	DECLARE @CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80);	
	DECLARE @CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60);	
	DECLARE @CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60);	
	DECLARE @CessionarioCommittente_Sede_Indirizzo NVARCHAR(60);	
	DECLARE @CessionarioCommittente_Sede_NumeroCivico NVARCHAR(8);	
	DECLARE @CessionarioCommittente_Sede_CAP CHAR(5);	
	DECLARE @CessionarioCommittente_Sede_Comune NVARCHAR(60);
	DECLARE @CessionarioCommittente_Sede_Provincia CHAR(2);
	DECLARE @CessionarioCommittente_Sede_Nazione CHAR(2);
	DECLARE @CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese CHAR(2);
	DECLARE @CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice NVARCHAR(28);
	DECLARE @CessionarioCommittente_RappresentanteFiscale_Denominazione NVARCHAR(80);
	DECLARE @CessionarioCommittente_RappresentanteFiscale_Nome NVARCHAR(60);	
	DECLARE @CessionarioCommittente_RappresentanteFiscale_Cognome NVARCHAR(60);	
	DECLARE @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2);
	DECLARE @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28);
	DECLARE @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale NVARCHAR(16);
	DECLARE @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80);
	DECLARE @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60);	
	DECLARE @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60);	
	DECLARE @SoggettoEmittente CHAR(2);

	BEGIN TRY

		DECLARE cursor_FEH CURSOR FAST_FORWARD READ_ONLY FOR
		SELECT
			DatiTrasmissione_IdTrasmittente_IdPaese
			, DatiTrasmissione_IdTrasmittente_IdCodice
			, DatiTrasmissione_ProgressivoInvio
			, DatiTrasmissione_FormatoTrasmissione
			, DatiTrasmissione_CodiceDestinatario
			, DatiTrasmissione_PECDestinatario
			, CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, CedentePrestatore_DatiAnagrafici_CodiceFiscale
			, CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione
			, CedentePrestatore_DatiAnagrafici_Anagrafica_Nome
			, CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome
			, CedentePrestatore_DatiAnagrafici_RegimeFiscale
			, CedentePrestatore_Sede_Indirizzo
			, CedentePrestatore_Sede_NumeroCivico
			, CedentePrestatore_Sede_CAP
			, CedentePrestatore_Sede_Comune
			, CedentePrestatore_Sede_Provincia
			, CedentePrestatore_Sede_Nazione
			, RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, RappresentanteFiscale_DatiAnagrafici_CodiceFiscale
			, RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione
			, RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome
			, RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome
			, CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, CessionarioCommittente_DatiAnagrafici_CodiceFiscale
			, CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione
			, CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome
			, CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome
			, CessionarioCommittente_Sede_Indirizzo
			, CessionarioCommittente_Sede_NumeroCivico
			, CessionarioCommittente_Sede_CAP
			, CessionarioCommittente_Sede_Comune
			, CessionarioCommittente_Sede_Provincia
			, CessionarioCommittente_Sede_Nazione
			, CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese
			, CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice
			, CessionarioCommittente_RappresentanteFiscale_Denominazione
			, CessionarioCommittente_RappresentanteFiscale_Nome
			, CessionarioCommittente_RappresentanteFiscale_Cognome
			, TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale
			, TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione
			, TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome
			, TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome
			, SoggettoEmittente
 
		FROM XMLFatture.Staging_FatturaElettronicaHeader
		WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
		OPEN cursor_FEH;
	
		FETCH NEXT FROM cursor_FEH INTO
			@DatiTrasmissione_IdTrasmittente_IdPaese
			, @DatiTrasmissione_IdTrasmittente_IdCodice
			, @DatiTrasmissione_ProgressivoInvio
			, @DatiTrasmissione_FormatoTrasmissione
			, @DatiTrasmissione_CodiceDestinatario
			, @DatiTrasmissione_PECDestinatario
			, @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, @CedentePrestatore_DatiAnagrafici_CodiceFiscale
			, @CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione
			, @CedentePrestatore_DatiAnagrafici_Anagrafica_Nome
			, @CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome
			, @CedentePrestatore_DatiAnagrafici_RegimeFiscale
			, @CedentePrestatore_Sede_Indirizzo
			, @CedentePrestatore_Sede_NumeroCivico
			, @CedentePrestatore_Sede_CAP
			, @CedentePrestatore_Sede_Comune
			, @CedentePrestatore_Sede_Provincia
			, @CedentePrestatore_Sede_Nazione
			, @RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, @RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, @RappresentanteFiscale_DatiAnagrafici_CodiceFiscale
			, @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione
			, @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome
			, @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome
			, @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, @CessionarioCommittente_DatiAnagrafici_CodiceFiscale
			, @CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione
			, @CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome
			, @CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome
			, @CessionarioCommittente_Sede_Indirizzo
			, @CessionarioCommittente_Sede_NumeroCivico
			, @CessionarioCommittente_Sede_CAP
			, @CessionarioCommittente_Sede_Comune
			, @CessionarioCommittente_Sede_Provincia
			, @CessionarioCommittente_Sede_Nazione
			, @CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese
			, @CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice
			, @CessionarioCommittente_RappresentanteFiscale_Denominazione
			, @CessionarioCommittente_RappresentanteFiscale_Nome
			, @CessionarioCommittente_RappresentanteFiscale_Cognome
			, @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese
			, @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice
			, @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale
			, @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione
			, @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome
			, @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome
			, @SoggettoEmittente;

		--WHILE @@FETCH_STATUS = 0
		--BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.1.1.1', @ValoreTesto = @DatiTrasmissione_IdTrasmittente_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.1.1.2', @ValoreTesto = @DatiTrasmissione_IdTrasmittente_IdCodice, @IDNazione = @DatiTrasmissione_IdTrasmittente_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.1.2', @ValoreTesto = @DatiTrasmissione_ProgressivoInvio;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.1.3', @ValoreTesto = @DatiTrasmissione_FormatoTrasmissione;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.1.4', @ValoreTesto = @DatiTrasmissione_CodiceDestinatario, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.1.6', @ValoreTesto = @DatiTrasmissione_PECDestinatario, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.1.1', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.1.2', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice, @IDNazione = @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.2', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_CodiceFiscale, @IsObbligatorio = 0, @IDNazione = @CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.3.1', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.3.2', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.3.3', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.1.8', @ValoreTesto = @CedentePrestatore_DatiAnagrafici_RegimeFiscale;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.2.1', @ValoreTesto = @CedentePrestatore_Sede_Indirizzo;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.2.2', @ValoreTesto = @CedentePrestatore_Sede_NumeroCivico, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.2.3', @ValoreTesto = @CedentePrestatore_Sede_CAP;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.2.4', @ValoreTesto = @CedentePrestatore_Sede_Comune;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.2.5', @ValoreTesto = @CedentePrestatore_Sede_Provincia, @IsObbligatorio = 0, @IDNazione = @CedentePrestatore_Sede_Nazione;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.2.2.6', @ValoreTesto = @CedentePrestatore_Sede_Nazione;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.3.1.1.1', @ValoreTesto = @RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.3.1.1.2', @ValoreTesto = @RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.3.1.2', @ValoreTesto = @RappresentanteFiscale_DatiAnagrafici_CodiceFiscale, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.3.1.3.1', @ValoreTesto = @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.3.1.3.2', @ValoreTesto = @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.3.1.3.3', @ValoreTesto = @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.1.1.1', @ValoreTesto = @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.1.1.2', @ValoreTesto = @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, @IsObbligatorio = 0, @IDNazione = @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.1.2', @ValoreTesto = @CessionarioCommittente_DatiAnagrafici_CodiceFiscale, @IsObbligatorio = 0, @IDNazione = @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.1.3.1', @ValoreTesto = @CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.1.3.2', @ValoreTesto = @CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.1.3.3', @ValoreTesto = @CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.2.1', @ValoreTesto = @CessionarioCommittente_Sede_Indirizzo;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.2.2', @ValoreTesto = @CessionarioCommittente_Sede_NumeroCivico, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.2.3', @ValoreTesto = @CessionarioCommittente_Sede_CAP;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.2.4', @ValoreTesto = @CessionarioCommittente_Sede_Comune;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.2.5', @ValoreTesto = @CessionarioCommittente_Sede_Provincia, @IsObbligatorio = 0, @IDNazione = @CessionarioCommittente_Sede_Nazione;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.2.6', @ValoreTesto = @CessionarioCommittente_Sede_Nazione;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.4.1.1', @ValoreTesto = @CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.4.1.2', @ValoreTesto = @CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.4.2', @ValoreTesto = @CessionarioCommittente_RappresentanteFiscale_Denominazione, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.4.3', @ValoreTesto = @CessionarioCommittente_RappresentanteFiscale_Nome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.4.4.4', @ValoreTesto = @CessionarioCommittente_RappresentanteFiscale_Cognome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.5.1.1.1', @ValoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.5.1.1.2', @ValoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.5.1.2', @ValoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.5.1.3.1', @ValoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.5.1.3.2', @ValoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.5.1.3.3', @ValoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'1.6', @ValoreTesto = @SoggettoEmittente, @IsObbligatorio = 0;

		IF (
			(@DatiTrasmissione_FormatoTrasmissione = 'FPA12' AND LEN(@DatiTrasmissione_CodiceDestinatario) <> 6)
			OR (@DatiTrasmissione_FormatoTrasmissione = 'FPR12' AND LEN(@DatiTrasmissione_CodiceDestinatario) <> 7)
		)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'1.1.3',
																@CodiceErroreSDI = 427,
																@valoreTesto = @DatiTrasmissione_FormatoTrasmissione,
																@LivelloLog = 4;

		END;

		IF (
			(@DatiTrasmissione_FormatoTrasmissione = 'FPA12' AND LEN(@DatiTrasmissione_CodiceDestinatario) <> 6)
			OR (@DatiTrasmissione_FormatoTrasmissione = 'FPR12' AND LEN(@DatiTrasmissione_CodiceDestinatario) <> 7)
		)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'1.1.4',
																@CodiceErroreSDI = 427,
																@valoreTesto = @DatiTrasmissione_CodiceDestinatario,
																@LivelloLog = 4;

		END;

		IF (
			/* Specifica Versione 1.2.1 - 1.1.6 <PECDestinatario> non valorizzato a fronte di 1.1.4 <CodiceDestinatario> con valore 0000000
            (@DatiTrasmissione_FormatoTrasmissione = 'FPR12' AND @DatiTrasmissione_CodiceDestinatario = N'0000000' AND COALESCE(@DatiTrasmissione_PECDestinatario, N'') = N'')
			OR (@DatiTrasmissione_FormatoTrasmissione = 'FPR12' AND @DatiTrasmissione_CodiceDestinatario <> N'0000000' AND COALESCE(@DatiTrasmissione_PECDestinatario, N'') <> N'') 
            
            In realtà lo SDI accetta fatture con CodiceDestinatario 0000000 e PEC non valorizzata (OK per i privati senza codice destinatario nè PEC) */
			(@DatiTrasmissione_FormatoTrasmissione = 'FPR12' AND @DatiTrasmissione_CodiceDestinatario <> N'0000000' AND COALESCE(@DatiTrasmissione_PECDestinatario, N'') <> N'')
		)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'1.1.6',
																@CodiceErroreSDI = 426,
																@valoreTesto = @DatiTrasmissione_PECDestinatario,
																@LivelloLog = 4;

		END;


		----IF (
		----	COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N''
		----	OR COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''
		----	OR COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, N'') <> N''
		----)
		----BEGIN

			IF (
				(COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND (COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, N'') = N'' OR COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, N'') = N''))
				OR (COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND (COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, N'') <> N'' OR COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''))
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.2.1.3.1',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, N'') = N'')
				OR (COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.2.1.3.2',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, N'') = N'')
				OR (COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.2.1.3.3',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CedentePrestatore_DatiAnagrafici_Anagrafica_Nome,
																	@LivelloLog = 4;

			END;

		----END;

		IF (
			COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N''
			OR COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''
			OR COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, N'') <> N''
		)
		BEGIN

			IF (
				(COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND (COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, N'') = N'' OR COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, N'') = N''))
				OR (COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND (COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, N'') <> N'' OR COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''))
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.3.1.3.1',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, N'') = N'')
				OR (COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.3.1.3.2',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, N'') = N'')
				OR (COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.3.1.3.3',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome,
																	@LivelloLog = 4;

			END;

		END;

		IF (
			COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N''
			OR COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''
			OR COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, N'') <> N''
		)
		BEGIN

			IF (COALESCE(@CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') = N'' AND COALESCE(@CessionarioCommittente_DatiAnagrafici_CodiceFiscale, N'') = N'')
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.1.1',
																	@CodiceErroreSDI = 417,
																	@valoreTesto = @CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
																	@LivelloLog = 4;

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.1.2',
																	@CodiceErroreSDI = 417,
																	@valoreTesto = @CessionarioCommittente_DatiAnagrafici_CodiceFiscale,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND (COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, N'') = N'' OR COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, N'') = N''))
				OR (COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND (COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, N'') <> N'' OR COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''))
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.1.3.1',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, N'') = N'')
				OR (COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.1.3.2',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, N'') = N'')
				OR (COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.1.3.3',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome,
																	@LivelloLog = 4;

			END;

		END;

		IF (
			COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') <> N''
			OR COALESCE(@CessionarioCommittente_RappresentanteFiscale_Cognome, N'') <> N''
			OR COALESCE(@CessionarioCommittente_RappresentanteFiscale_Nome, N'') <> N''
		)
		BEGIN

			IF (
				(COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') = N'' AND (COALESCE(@CessionarioCommittente_RappresentanteFiscale_Nome, N'') = N'' OR COALESCE(@CessionarioCommittente_RappresentanteFiscale_Cognome, N'') = N''))
				OR (COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') <> N'' AND (COALESCE(@CessionarioCommittente_RappresentanteFiscale_Nome, N'') <> N'' OR COALESCE(@CessionarioCommittente_RappresentanteFiscale_Cognome, N'') <> N''))
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.4.3',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CessionarioCommittente_RappresentanteFiscale_Denominazione,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') = N'' AND COALESCE(@CessionarioCommittente_RappresentanteFiscale_Cognome, N'') = N'')
				OR (COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') <> N'' AND COALESCE(@CessionarioCommittente_RappresentanteFiscale_Cognome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.4.3',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CessionarioCommittente_RappresentanteFiscale_Cognome,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') = N'' AND COALESCE(@CessionarioCommittente_RappresentanteFiscale_Nome, N'') = N'')
				OR (COALESCE(@CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') <> N'' AND COALESCE(@CessionarioCommittente_RappresentanteFiscale_Nome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.4.4.4',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @CessionarioCommittente_RappresentanteFiscale_Nome,
																	@LivelloLog = 4;

			END;

		END;

		IF (
			COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N''
			OR COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''
			OR COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, N'') <> N''
		)
		BEGIN

			IF (
				(COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND (COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, N'') = N'' OR COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, N'') = N''))
				OR (COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND (COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, N'') <> N'' OR COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, N'') <> N''))
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.5.1.3.1',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, N'') = N'')
				OR (COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.5.1.3.2',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome,
																	@LivelloLog = 4;

			END;

			IF (
				(COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') = N'' AND COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, N'') = N'')
				OR (COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') <> N'' AND COALESCE(@TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, N'') <> N'')
			)
			BEGIN

				EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																	@IDCampo = N'1.5.1.3.3',
																	@CodiceErroreSDI = 200,
																	@valoreTesto = @TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome,
																	@LivelloLog = 4;

			END;

		END;

		--    FETCH NEXT FROM cursor_FEH INTO @variable
		--END
	
		CLOSE cursor_FEH;
		DEALLOCATE cursor_FEH;

	END TRY
	BEGIN CATCH

	END CATCH

END;
GO

/**
 * @stored_procedure XMLAudit.ssp_ConvalidaFatturaBody
 * @description Convalida fattura: verifica campi di testata

 * @input_param @PKStaging_FatturaElettronicaBody
 * @input_param @PKValidazione
*/

IF OBJECT_ID(N'XMLAudit.ssp_ConvalidaFatturaBody', N'P') IS NULL EXEC('CREATE PROCEDURE XMLAudit.ssp_ConvalidaFatturaBody AS RETURN 0;');
GO

ALTER PROCEDURE XMLAudit.ssp_ConvalidaFatturaBody (
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKValidazione BIGINT
)
AS
BEGIN

	SET NOCOUNT ON;

	/* declare variables */
	DECLARE @DatiGenerali_DatiGeneraliDocumento_TipoDocumento CHAR(4);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_Divisa CHAR(3);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_Data DATE;
	DECLARE @DatiGenerali_DatiGeneraliDocumento_Numero NVARCHAR(20);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta CHAR(4);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta DECIMAL(14,2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta DECIMAL(5,2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento CHAR(2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale CHAR(2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo DECIMAL(14,2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento DECIMAL(14,2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_Arrotondamento DECIMAL(14,2);
	DECLARE @DatiGenerali_DatiGeneraliDocumento_Art73 CHAR(2);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese CHAR(2);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice NVARCHAR(28);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale NVARCHAR(16);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione NVARCHAR(80);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome NVARCHAR(60);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome NVARCHAR(60);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo NVARCHAR(10);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI NVARCHAR(17);
	DECLARE @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida NVARCHAR(20);
	DECLARE @DatiGenerali_DatiTrasporto_MezzoTrasporto NVARCHAR(80);
	DECLARE @DatiGenerali_DatiTrasporto_CausaleTrasporto NVARCHAR(100);
	DECLARE @DatiGenerali_DatiTrasporto_NumeroColli INT;
	DECLARE @DatiGenerali_DatiTrasporto_Descrizione NVARCHAR(100);
	DECLARE @DatiGenerali_DatiTrasporto_UnitaMisuraPeso NVARCHAR(10);
	DECLARE @DatiGenerali_DatiTrasporto_PesoLordo DECIMAL(6,2);
	DECLARE @DatiGenerali_DatiTrasporto_PesoNetto DECIMAL(6,2);
	DECLARE @DatiGenerali_DatiTrasporto_DataOraRitiro DATETIME;
	DECLARE @DatiGenerali_DatiTrasporto_DataInizioTrasporto DATE;
	DECLARE @DatiGenerali_DatiTrasporto_TipoResa CHAR(3);
	DECLARE @DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo NVARCHAR(60);
	DECLARE @DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico NVARCHAR(8);
	DECLARE @DatiGenerali_DatiTrasporto_IndirizzoResa_CAP CHAR(5);
	DECLARE @DatiGenerali_DatiTrasporto_IndirizzoResa_Comune NVARCHAR(60);
	DECLARE @DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia CHAR(2);
	DECLARE @DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione CHAR(2);
	DECLARE @DatiGenerali_DatiTrasporto_DataOraConsegna DATETIME;
	DECLARE @DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale NVARCHAR(20);
	DECLARE @DatiGenerali_FatturaPrincipale_DataFatturaPrincipale DATE;
	DECLARE @DatiVeicoli_Data DATE;
	DECLARE @DatiVeicoli_TotalePercorso NVARCHAR(15);

	DECLARE cursor_FEB CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        DatiGenerali_DatiGeneraliDocumento_TipoDocumento,
        DatiGenerali_DatiGeneraliDocumento_Divisa,
        DatiGenerali_DatiGeneraliDocumento_Data,
        DatiGenerali_DatiGeneraliDocumento_Numero,
        DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta,
        DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta,
        DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta,
        DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento,
        DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale,
        DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo,
        DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento,
        DatiGenerali_DatiGeneraliDocumento_Arrotondamento,
        DatiGenerali_DatiGeneraliDocumento_Art73,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI,
        DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida,
        DatiGenerali_DatiTrasporto_MezzoTrasporto,
        DatiGenerali_DatiTrasporto_CausaleTrasporto,
        DatiGenerali_DatiTrasporto_NumeroColli,
        DatiGenerali_DatiTrasporto_Descrizione,
        DatiGenerali_DatiTrasporto_UnitaMisuraPeso,
        DatiGenerali_DatiTrasporto_PesoLordo,
        DatiGenerali_DatiTrasporto_PesoNetto,
        DatiGenerali_DatiTrasporto_DataOraRitiro,
        DatiGenerali_DatiTrasporto_DataInizioTrasporto,
        DatiGenerali_DatiTrasporto_TipoResa,
        DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo,
        DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico,
        DatiGenerali_DatiTrasporto_IndirizzoResa_CAP,
        DatiGenerali_DatiTrasporto_IndirizzoResa_Comune,
        DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia,
        DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione,
        DatiGenerali_DatiTrasporto_DataOraConsegna,
        DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale,
        DatiGenerali_FatturaPrincipale_DataFatturaPrincipale,
        DatiVeicoli_Data,
        DatiVeicoli_TotalePercorso
 
	FROM XMLFatture.Staging_FatturaElettronicaBody
	WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEB;
	
	FETCH NEXT FROM cursor_FEB INTO
		@DatiGenerali_DatiGeneraliDocumento_TipoDocumento
		, @DatiGenerali_DatiGeneraliDocumento_Divisa
		, @DatiGenerali_DatiGeneraliDocumento_Data
		, @DatiGenerali_DatiGeneraliDocumento_Numero
		, @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta
		, @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta
		, @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta
		, @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento
		, @DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale
		, @DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo
		, @DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento
		, @DatiGenerali_DatiGeneraliDocumento_Arrotondamento
		, @DatiGenerali_DatiGeneraliDocumento_Art73
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI
		, @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida
		, @DatiGenerali_DatiTrasporto_MezzoTrasporto
		, @DatiGenerali_DatiTrasporto_CausaleTrasporto
		, @DatiGenerali_DatiTrasporto_NumeroColli
		, @DatiGenerali_DatiTrasporto_Descrizione
		, @DatiGenerali_DatiTrasporto_UnitaMisuraPeso
		, @DatiGenerali_DatiTrasporto_PesoLordo
		, @DatiGenerali_DatiTrasporto_PesoNetto
		, @DatiGenerali_DatiTrasporto_DataOraRitiro
		, @DatiGenerali_DatiTrasporto_DataInizioTrasporto
		, @DatiGenerali_DatiTrasporto_TipoResa
		, @DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo
		, @DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico
		, @DatiGenerali_DatiTrasporto_IndirizzoResa_CAP
		, @DatiGenerali_DatiTrasporto_IndirizzoResa_Comune
		, @DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia
		, @DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione
		, @DatiGenerali_DatiTrasporto_DataOraConsegna
		, @DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale
		, @DatiGenerali_FatturaPrincipale_DataFatturaPrincipale
		, @DatiVeicoli_Data
		, @DatiVeicoli_TotalePercorso;

	--WHILE @@FETCH_STATUS = 0
	--BEGIN
	    
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.1', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_TipoDocumento;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.2', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_Divisa;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.3', @TipoValore = 'E', @ValoreData = @DatiGenerali_DatiGeneraliDocumento_Data;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.4', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_Numero;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.5.1', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.5.2', @TipoValore = 'D', @ValoreDecimale = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.5.3', @TipoValore = 'D', @ValoreDecimale = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.5.4', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.6.1', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.6.2', @TipoValore = 'D', @ValoreDecimale = @DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.9', @TipoValore = 'D', @ValoreDecimale = @DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.10', @TipoValore = 'D', @ValoreDecimale = @DatiGenerali_DatiGeneraliDocumento_Arrotondamento, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.12', @ValoreTesto = @DatiGenerali_DatiGeneraliDocumento_Art73, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.1.1', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.1.2', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.2', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.3.1', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.3.2', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.3.3', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.3.4', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.3.5', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.1.4', @ValoreTesto = @DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.2', @ValoreTesto = @DatiGenerali_DatiTrasporto_MezzoTrasporto, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.3', @ValoreTesto = @DatiGenerali_DatiTrasporto_CausaleTrasporto, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.4', @TipoValore = 'I', @ValoreIntero = @DatiGenerali_DatiTrasporto_NumeroColli, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.5', @ValoreTesto = @DatiGenerali_DatiTrasporto_Descrizione, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.6', @ValoreTesto = @DatiGenerali_DatiTrasporto_UnitaMisuraPeso, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.7', @ValoreTesto = @DatiGenerali_DatiTrasporto_PesoLordo, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.8', @ValoreTesto = @DatiGenerali_DatiTrasporto_PesoNetto, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.9', @TipoValore = 'E', @ValoreData = @DatiGenerali_DatiTrasporto_DataOraRitiro, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.10', @TipoValore = 'E', @ValoreData = @DatiGenerali_DatiTrasporto_DataInizioTrasporto, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.11', @ValoreTesto = @DatiGenerali_DatiTrasporto_TipoResa, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.12.1', @ValoreTesto = @DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.12.2', @ValoreTesto = @DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.12.3', @ValoreTesto = @DatiGenerali_DatiTrasporto_IndirizzoResa_CAP, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.12.4', @ValoreTesto = @DatiGenerali_DatiTrasporto_IndirizzoResa_Comune, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.12.5', @ValoreTesto = @DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.12.6', @ValoreTesto = @DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.9.13', @TipoValore = 'E', @ValoreData = @DatiGenerali_DatiTrasporto_DataOraConsegna, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.10.1', @ValoreTesto = @DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.10.2', @TipoValore = 'E', @ValoreData = @DatiGenerali_FatturaPrincipale_DataFatturaPrincipale, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.3.1', @ValoreTesto = @DatiVeicoli_Data, @IsObbligatorio = 0;
	EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.3.2', @ValoreTesto = @DatiVeicoli_TotalePercorso, @IsObbligatorio = 0;

	IF (@DatiGenerali_DatiGeneraliDocumento_Data > CAST(CURRENT_TIMESTAMP AS DATE))
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
						                                  @IDCampo = N'2.1.1.3',
						                                  @CodiceErroreSDI = 403,
						                                  @valoreData = @DatiGenerali_DatiGeneraliDocumento_Data,
						                                  @LivelloLog = 4;

	END;

	IF (@DatiGenerali_DatiGeneraliDocumento_TipoDocumento IN ('TD04', 'TD16', 'TD17', 'TD18', 'TD19'))
	BEGIN

		DECLARE @DataPrimaFatturaCollegata DATE;

		SELECT
			@DataPrimaFatturaCollegata = MIN(FEBDDC.[Data])
		
		FROM XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno FEBDDC
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDDC.PKStaging_FatturaElettronicaBody
			AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		WHERE FEBDDC.TipoDocumentoEsterno = N'FTCL';

		IF (@DatiGenerali_DatiGeneraliDocumento_Data < @DataPrimaFatturaCollegata)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
															  @IDCampo = N'2.1.1.3',
															  @CodiceErroreSDI = 418,
															  @valoreData = @DatiGenerali_DatiGeneraliDocumento_Data,
															  @LivelloLog = 4;
		END;

	END;

	IF (@DatiGenerali_DatiGeneraliDocumento_Numero NOT LIKE N'%[0-9]%')
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
						                                  @IDCampo = N'2.1.1.4',
						                                  @CodiceErroreSDI = 425,
						                                  @valoreTesto = @DatiGenerali_DatiGeneraliDocumento_Numero,
						                                  @LivelloLog = 4;

	END;

	IF (
		@DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta = N''
		AND EXISTS(
			SELECT FEBDL.Ritenuta
			FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL
			INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDL.PKStaging_FatturaElettronicaBody
				AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
			WHERE FEBDL.Ritenuta = 'SI'
		)
	)
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
						                                  @IDCampo = N'2.1.1.5',
						                                  @CodiceErroreSDI = 411,
						                                  @valoreTesto = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta,
						                                  @LivelloLog = 4;

	END;

	IF (
		@DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta = N''
		AND EXISTS(
			SELECT FEBDCP.Ritenuta
			FROM XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale FEBDCP
			INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDCP.PKStaging_FatturaElettronicaBody
				AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
			WHERE FEBDCP.Ritenuta = 'SI'
		)
	)
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
						                                  @IDCampo = N'2.1.1.5',
						                                  @CodiceErroreSDI = 415,
						                                  @valoreTesto = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta,
						                                  @LivelloLog = 4;

	END;

    IF (@DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento <> N'')
    BEGIN

        DECLARE @IsCausalePagamentoObsoleta BIT;
	    SELECT @IsCausalePagamentoObsoleta = IsObsoleta FROM XMLCodifiche.CausalePagamento WHERE IDCausalePagamento = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento;
        IF (@IsCausalePagamentoObsoleta = CAST(1 AS BIT))
        BEGIN

		    EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
															    @IDCampo = N'2.1.1.5.4',
															    @CodiceErroreSDI = 999,
															    @valoreTesto = @DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento,
															    @LivelloLog = 4;

        END;

    END;
    SELECT * FROM XMLCodifiche.CodiceErroreSDI WHERE CodiceErroreSDI = 448
	--    FETCH NEXT FROM cursor_FEH INTO @variable
	--END;

	/*** Causale: inizio ***/

	/* declare variables */
	DECLARE @DatiGenerali_Causale NVARCHAR(200);
	
	DECLARE cursor_FEBC CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBC.DatiGenerali_Causale
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_Causale FEBC
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBC.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBC
	
	FETCH NEXT FROM cursor_FEBC INTO @DatiGenerali_Causale;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.11', @ValoreTesto = @DatiGenerali_Causale, @IsObbligatorio = 0;
	
	    FETCH NEXT FROM cursor_FEBC INTO @DatiGenerali_Causale;
	END
	
	CLOSE cursor_FEBC
	DEALLOCATE cursor_FEBC

	/*** Causale: fine ***/

	/*** DatiDDT: inizio ***/

	/* declare variables */
	DECLARE @NumeroDDT NVARCHAR(20);
	DECLARE @DataDDT DATE;
	
	DECLARE cursor_FEBDDDT CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDDDT.NumeroDDT,
        FEBDDDT.DataDDT
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DatiDDT FEBDDDT
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDDDT.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDDDT
	
	FETCH NEXT FROM cursor_FEBDDDT INTO @NumeroDDT, @DataDDT;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.8.1', @ValoreTesto = @NumeroDDT;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.8,2', @TipoValore = 'E', @ValoreData = @DataDDT;
	
		FETCH NEXT FROM cursor_FEBDDDT INTO @NumeroDDT, @DataDDT;
	END
	
	CLOSE cursor_FEBDDDT
	DEALLOCATE cursor_FEBDDDT

	/*** DatiDDT: fine ***/
	
	/*** DatiDDT_RiferimentoNumeroLinea: inizio ***/

	/* declare variables */
	DECLARE @RiferimentoNumeroLinea INT;
	
	DECLARE cursor_FEBDDDTNL CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDDDTNL.RiferimentoNumeroLinea
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea FEBDDDTNL
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DatiDDT FEBDDDT ON FEBDDDT.PKStaging_FatturaElettronicaBody_DatiDDT = FEBDDDTNL.PKStaging_FatturaElettronicaBody_DatiDDT
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDDDT.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDDDTNL
	
	FETCH NEXT FROM cursor_FEBDDDTNL INTO @RiferimentoNumeroLinea;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.1.1.11', @TipoValore = 'I', @ValoreIntero = @RiferimentoNumeroLinea;
	
		FETCH NEXT FROM cursor_FEBDDDTNL INTO @RiferimentoNumeroLinea;
	END
	
	CLOSE cursor_FEBDDDTNL
	DEALLOCATE cursor_FEBDDDTNL

	/*** DatiDDT: fine ***/

	/*** DettaglioLinee: inizio ***/

	/* declare variables */
	DECLARE @NumeroLinea INT;
	DECLARE @TipoCessionePrestazione CHAR(2);
	DECLARE @Descrizione NVARCHAR(1000);
	DECLARE @Quantita DECIMAL(20, 5);
	DECLARE @UnitaMisura NVARCHAR(10);
	DECLARE @DataInizioPeriodo DATE;
	DECLARE @DataFinePeriodo DATE;
	DECLARE @PrezzoUnitario DECIMAL(20, 5);
	DECLARE @PrezzoTotale DECIMAL(20, 5);
	DECLARE @AliquotaIVA DECIMAL(5, 2);
	DECLARE @Ritenuta CHAR(2);
	DECLARE @Natura VARCHAR(5);
    DECLARE @IsNaturaObsoleta BIT;
	DECLARE @RiferimentoAmministrazione NVARCHAR(20);
	
	DECLARE cursor_FEBDL CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDL.NumeroLinea,
        FEBDL.TipoCessionePrestazione,
        FEBDL.Descrizione,
        FEBDL.Quantita,
        FEBDL.UnitaMisura,
        FEBDL.DataInizioPeriodo,
        FEBDL.DataFinePeriodo,
        FEBDL.PrezzoUnitario,
        FEBDL.PrezzoTotale,
        FEBDL.AliquotaIVA,
        FEBDL.Ritenuta,
        FEBDL.Natura,
        FEBDL.RiferimentoAmministrazione
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDL.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDL
	
	FETCH NEXT FROM cursor_FEBDL INTO
		@NumeroLinea,
        @TipoCessionePrestazione,
        @Descrizione,
        @Quantita,
        @UnitaMisura,
        @DataInizioPeriodo,
        @DataFinePeriodo,
        @PrezzoUnitario,
        @PrezzoTotale,
        @AliquotaIVA,
        @Ritenuta,
        @Natura,
        @RiferimentoAmministrazione;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.1', @TipoValore = 'I', @ValoreIntero = @NumeroLinea, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.2', @ValoreTesto = @TipoCessionePrestazione, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.4', @ValoreTesto = @Descrizione, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.5', @TipoValore = 'D', @ValoreDecimale = @Quantita, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.6', @ValoreTesto = @UnitaMisura, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.7', @TipoValore = 'E', @ValoreData = @DataInizioPeriodo, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.8', @TipoValore = 'E', @ValoreData = @DataFinePeriodo, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.9', @TipoValore = 'D', @ValoreDecimale = @PrezzoUnitario, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.11', @TipoValore = 'D', @ValoreDecimale = @PrezzoTotale, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.12', @TipoValore = 'D', @ValoreDecimale = @AliquotaIVA, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.13', @ValoreTesto = @Ritenuta, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.14', @ValoreTesto = @Natura, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.15', @ValoreTesto = @RiferimentoAmministrazione, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		
		-- TODO: verifica calcolo prezzo totale (elenco controlli versione 1.2)

		IF (@AliquotaIVA > 0.0 AND @AliquotaIVA < 1.0)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.1.12',
																@CodiceErroreSDI = 424,
																@valoreDecimale = @AliquotaIVA,
																@LivelloLog = 4;

		END;

		-- 2.1.1.13 Ritenuta: duplicato di controllo 2.1.1.5

		IF (@Natura = '' AND @AliquotaIVA = 0.0)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.1.14',
																@CodiceErroreSDI = 400,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

		END;

		IF (@Natura <> '' AND @AliquotaIVA <> 0.0)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.1.14',
																@CodiceErroreSDI = 401,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

		END;

		SELECT @IsNaturaObsoleta = IsObsoleta FROM XMLCodifiche.Natura WHERE IDNatura = @Natura;
        IF (@IsNaturaObsoleta = CAST(1 AS BIT))
        BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.1.14',
																@CodiceErroreSDI = 448,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

        END;

		FETCH NEXT FROM cursor_FEBDL INTO
			@NumeroLinea,
			@TipoCessionePrestazione,
			@Descrizione,
			@Quantita,
			@UnitaMisura,
			@DataInizioPeriodo,
			@DataFinePeriodo,
			@PrezzoUnitario,
			@PrezzoTotale,
			@AliquotaIVA,
			@Ritenuta,
			@Natura,
			@RiferimentoAmministrazione;
	END
	
	CLOSE cursor_FEBDL
	DEALLOCATE cursor_FEBDL

	/*** DettaglioLinee: fine ***/

	/*** DettaglioLinee_CodiceArticolo: inizio ***/

	/* declare variables */
    DECLARE @CodiceArticolo_CodiceTipo NVARCHAR(35);
    DECLARE @CodiceArticolo_CodiceValore NVARCHAR(35);
	
	DECLARE cursor_FEBDLCA CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDLCA.CodiceArticolo_CodiceTipo,
        FEBDLCA.CodiceArticolo_CodiceValore
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo FEBDLCA
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee = FEBDLCA.PKStaging_FatturaElettronicaBody_DettaglioLinee
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDL.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDLCA
	
	FETCH NEXT FROM cursor_FEBDLCA INTO @CodiceArticolo_CodiceTipo, @CodiceArticolo_CodiceValore;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.3.1', @ValoreTesto = @CodiceArticolo_CodiceTipo, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.3.2', @ValoreTesto = @CodiceArticolo_CodiceValore, @NumeroLinea = @NumeroLinea;
	
		FETCH NEXT FROM cursor_FEBDLCA INTO @CodiceArticolo_CodiceTipo, @CodiceArticolo_CodiceValore;
	END
	
	CLOSE cursor_FEBDLCA
	DEALLOCATE cursor_FEBDLCA

	/*** DettaglioLinee_CodiceArticolo: fine ***/

	/*** DettaglioLinee_ScontoMaggiorazione: inizio ***/

	/* declare variables */
    DECLARE @ScontoMaggiorazione_Tipo CHAR(2);
    DECLARE @ScontoMaggiorazione_Percentuale DECIMAL(5, 2);
    DECLARE @ScontoMaggiorazione_Importo DECIMAL(14, 2);
	
	DECLARE cursor_FEBDLSM CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDLCA.ScontoMaggiorazione_Tipo,
        FEBDLCA.ScontoMaggiorazione_Percentuale,
        FEBDLCA.ScontoMaggiorazione_Importo
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione FEBDLCA
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee = FEBDLCA.PKStaging_FatturaElettronicaBody_DettaglioLinee
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDL.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDLSM
	
	FETCH NEXT FROM cursor_FEBDLSM INTO @ScontoMaggiorazione_Tipo, @ScontoMaggiorazione_Percentuale, @ScontoMaggiorazione_Importo;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.10.1', @ValoreTesto = @ScontoMaggiorazione_Tipo, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.10.2', @TipoValore = 'D', @ValoreDecimale = @ScontoMaggiorazione_Percentuale, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.1.10.3', @TipoValore = 'D', @ValoreDecimale = @ScontoMaggiorazione_Importo, @IsObbligatorio = 0, @NumeroLinea = @NumeroLinea;

		IF (
			COALESCE(@ScontoMaggiorazione_Tipo, N'') <> N''
			AND COALESCE(@ScontoMaggiorazione_Percentuale, 0.0) = 0.0
			AND COALESCE(@ScontoMaggiorazione_Importo, 0.0) = 0.0
		)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.1.10.1',
																@CodiceErroreSDI = 438,
																@valoreTesto = @ScontoMaggiorazione_Tipo,
																@LivelloLog = 4;

		END;

		FETCH NEXT FROM cursor_FEBDLSM INTO @ScontoMaggiorazione_Tipo, @ScontoMaggiorazione_Percentuale, @ScontoMaggiorazione_Importo;
	END
	
	CLOSE cursor_FEBDLSM
	DEALLOCATE cursor_FEBDLSM

	/*** DettaglioLinee_ScontoMaggiorazione: fine ***/

	/*** DatiRiepilogo: inizio ***/

	DECLARE @AliquoteMancanti INT;

	WITH AliquoteIVA
	AS (
		SELECT DISTINCT
			FEBDL.AliquotaIVA

		FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDL.PKStaging_FatturaElettronicaBody
			AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader

		UNION

		SELECT DISTINCT
			FEBDCP.AliquotaIVA

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale FEBDCP
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDCP.PKStaging_FatturaElettronicaBody
			AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
	)
	SELECT @AliquoteMancanti = COUNT(1)
	FROM AliquoteIVA AIVA
	LEFT JOIN (
		SELECT DISTINCT
			FEBDR.AliquotaIVA

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo FEBDR
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDR.PKStaging_FatturaElettronicaBody
			AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
	) DR ON DR.AliquotaIVA = AIVA.AliquotaIVA
	WHERE DR.AliquotaIVA IS NULL;

	IF (@AliquoteMancanti > 0)
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
															@IDCampo = N'2.2.2',
															@CodiceErroreSDI = 419,
															@valoreDecimale = @AliquoteMancanti,
															@LivelloLog = 4;

	END;

	/* declare variables */
	--DECLARE @AliquotaIVA DECIMAL(5, 2);
	--DECLARE @Natura VARCHAR(5);
	DECLARE @SpeseAccessorie DECIMAL(14, 2);
	DECLARE @Arrotondamento DECIMAL(20, 2);
	DECLARE @ImponibileImporto DECIMAL(14, 2);
	DECLARE @Imposta DECIMAL(14, 2);
	DECLARE @EsigibilitaIVA CHAR(1);
	DECLARE @RiferimentoNormativo NVARCHAR(100);
	
	DECLARE cursor_FEBDR CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDR.AliquotaIVA,
        FEBDR.Natura,
        FEBDR.SpeseAccessorie,
        FEBDR.Arrotondamento,
        FEBDR.ImponibileImporto,
        FEBDR.Imposta,
        FEBDR.EsigibilitaIVA,
        FEBDR.RiferimentoNormativo
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo FEBDR
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDR.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		AND FEBDR.ImponibileImporto > 0.0;
	
	OPEN cursor_FEBDR
	
	FETCH NEXT FROM cursor_FEBDR INTO
		@AliquotaIVA,
		@Natura,
		@SpeseAccessorie,
		@Arrotondamento,
		@ImponibileImporto,
		@Imposta,
		@EsigibilitaIVA,
		@RiferimentoNormativo;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.1', @TipoValore = 'D', @ValoreDecimale = @AliquotaIVA, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.2', @ValoreTesto = @Natura, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.3', @TipoValore = 'D', @ValoreDecimale = @SpeseAccessorie, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.4', @TipoValore = 'D', @ValoreDecimale = @Arrotondamento, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.5', @TipoValore = 'D', @ValoreDecimale = @ImponibileImporto;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.6', @TipoValore = 'D', @ValoreDecimale = @Imposta, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.7', @ValoreTesto = @EsigibilitaIVA, @IsObbligatorio = 1;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.2.2.8', @ValoreTesto = @RiferimentoNormativo, @IsObbligatorio = 0;

		IF (@AliquotaIVA > 0.0 AND @AliquotaIVA < 1.0)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.2.1',
																@CodiceErroreSDI = 424,
																@valoreDecimale = @AliquotaIVA,
																@LivelloLog = 4;

		END;

		IF (LEFT(@Natura, 2) = 'N6' AND @EsigibilitaIVA = 'S')
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.2.2',
																@CodiceErroreSDI = 420,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

		END;

		IF (@Natura = '' AND @AliquotaIVA = 0.0)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.2.2',
																@CodiceErroreSDI = 429,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

		END;

		IF (@Natura <> '' AND @AliquotaIVA <> 0.0)
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.2.2',
																@CodiceErroreSDI = 430,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

		END;

		SELECT @IsNaturaObsoleta = IsObsoleta FROM XMLCodifiche.Natura WHERE IDNatura = @Natura;
        IF (@IsNaturaObsoleta = CAST(1 AS BIT))
        BEGIN

			EXEC XMLAudit.ssp_ScriviLogValidazioneDaErroreSDI @PKValidazione = @PKValidazione,
																@IDCampo = N'2.2.2.2',
																@CodiceErroreSDI = 448,
																@valoreTesto = @Natura,
																@LivelloLog = 4;

        END;

		FETCH NEXT FROM cursor_FEBDR INTO
			@AliquotaIVA,
			@Natura,
			@SpeseAccessorie,
			@Arrotondamento,
			@ImponibileImporto,
			@Imposta,
			@EsigibilitaIVA,
			@RiferimentoNormativo;
	END
	
	CLOSE cursor_FEBDR
	DEALLOCATE cursor_FEBDR

	/*** DatiRiepilogo: fine ***/

	/*** DatiPagamento: inizio ***/

	/* declare variables */
	DECLARE @CondizioniPagamento CHAR(4);
	
	DECLARE cursor_FEBDP CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDP.CondizioniPagamento
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento FEBDP
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDP.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDP
	
	FETCH NEXT FROM cursor_FEBDP INTO @CondizioniPagamento;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.1', @ValoreTesto = @CondizioniPagamento;
	
	    FETCH NEXT FROM cursor_FEBDP INTO @CondizioniPagamento;
	END
	
	CLOSE cursor_FEBDP
	DEALLOCATE cursor_FEBDP

	/*** DatiPagamento: fine ***/

	/*** DatiPagamento_DettaglioPagamento: inizio ***/

	/* declare variables */
	DECLARE @Beneficiario NVARCHAR(200);
	DECLARE @ModalitaPagamento CHAR(4);
	DECLARE @DataRiferimentoTerminiPagamento DATE;
	DECLARE @GiorniTerminiPagamento INT;
	DECLARE @DataScadenzaPagamento DATE;
	DECLARE @ImportoPagamento DECIMAL(14, 2);
	DECLARE @CodUfficioPostale NVARCHAR(20);
	DECLARE @CognomeQuietanzante NVARCHAR(60);
	DECLARE @NomeQuietanzante NVARCHAR(60);
	DECLARE @CFQuietanzante NVARCHAR(16);
	DECLARE @TitoloQuietanzante NVARCHAR(10);
	DECLARE @IstitutoFinanziario NVARCHAR(80);
	DECLARE @IBAN NVARCHAR(34);
	DECLARE @ABI INT;
	DECLARE @CAB INT;
	DECLARE @BIC NVARCHAR(11);
	DECLARE @ScontoPagamentoAnticipato DECIMAL(14, 2);
	DECLARE @DataLimitePagamentoAnticipato DATE;
	DECLARE @PenalitaPagamentiRitardati DECIMAL(14, 2);
	DECLARE @DataDecorrenzaPenale DATE;
	DECLARE @CodicePagamento NVARCHAR(60);
	
	DECLARE cursor_FEBDPDP CURSOR FAST_FORWARD READ_ONLY FOR
	SELECT
        FEBDPDP.Beneficiario,
        FEBDPDP.ModalitaPagamento,
        FEBDPDP.DataRiferimentoTerminiPagamento,
        FEBDPDP.GiorniTerminiPagamento,
        FEBDPDP.DataScadenzaPagamento,
        FEBDPDP.ImportoPagamento,
        FEBDPDP.CodUfficioPostale,
        FEBDPDP.CognomeQuietanzante,
        FEBDPDP.NomeQuietanzante,
        FEBDPDP.CFQuietanzante,
        FEBDPDP.TitoloQuietanzante,
        FEBDPDP.IstitutoFinanziario,
        FEBDPDP.IBAN,
        FEBDPDP.ABI,
        FEBDPDP.CAB,
        FEBDPDP.BIC,
        FEBDPDP.ScontoPagamentoAnticipato,
        FEBDPDP.DataLimitePagamentoAnticipato,
        FEBDPDP.PenalitaPagamentiRitardati,
        FEBDPDP.DataDecorrenzaPenale,
        FEBDPDP.CodicePagamento
	
	FROM XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento FEBDPDP
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento FEBDP ON FEBDP.PKStaging_FatturaElettronicaBody_DatiPagamento = FEBDPDP.PKStaging_FatturaElettronicaBody_DatiPagamento
	INNER JOIN XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDP.PKStaging_FatturaElettronicaBody
		AND FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
	
	OPEN cursor_FEBDPDP
	
	FETCH NEXT FROM cursor_FEBDPDP INTO
		@Beneficiario,
		@ModalitaPagamento,
		@DataRiferimentoTerminiPagamento,
		@GiorniTerminiPagamento,
		@DataScadenzaPagamento,
		@ImportoPagamento,
		@CodUfficioPostale,
		@CognomeQuietanzante,
		@NomeQuietanzante,
		@CFQuietanzante,
		@TitoloQuietanzante,
		@IstitutoFinanziario,
		@IBAN,
		@ABI,
		@CAB,
		@BIC,
		@ScontoPagamentoAnticipato,
		@DataLimitePagamentoAnticipato,
		@PenalitaPagamentiRitardati,
		@DataDecorrenzaPenale,
		@CodicePagamento;
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	    
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.1', @ValoreTesto = @Beneficiario, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.2', @ValoreTesto = @ModalitaPagamento, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.3', @TipoValore = 'E', @ValoreData = @DataRiferimentoTerminiPagamento, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.4', @TipoValore = 'I', @ValoreIntero = @GiorniTerminiPagamento, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.5', @TipoValore = 'E', @ValoreData = @DataScadenzaPagamento, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.6', @TipoValore = 'D', @ValoreDecimale = @ImportoPagamento;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.7', @ValoreTesto = @CodUfficioPostale, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.8', @ValoreTesto = @CognomeQuietanzante, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.9', @ValoreTesto = @NomeQuietanzante, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.10', @ValoreTesto = @CFQuietanzante, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.11', @ValoreTesto = @TitoloQuietanzante, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.12', @ValoreTesto = @IstitutoFinanziario, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.13', @ValoreTesto = @IBAN, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.14', @TipoValore = 'I', @ValoreIntero = @ABI, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.15', @TipoValore = 'I', @ValoreIntero = @CAB, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.16', @ValoreTesto = @BIC, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.17', @TipoValore = 'D', @ValoreDecimale = @ScontoPagamentoAnticipato, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.18', @TipoValore = 'E', @ValoreData = @DataLimitePagamentoAnticipato, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.19', @TipoValore = 'D', @ValoreDecimale = @PenalitaPagamentiRitardati, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.20', @TipoValore = 'E', @ValoreData = @DataDecorrenzaPenale, @IsObbligatorio = 0;
		EXEC XMLFatture.ssp_VerificaCampoSDI @PKValidazione = @PKValidazione, @IDCampo = N'2.4.2.21', @ValoreTesto = @CodicePagamento, @IsObbligatorio = 0;

		FETCH NEXT FROM cursor_FEBDPDP INTO
			@Beneficiario,
			@ModalitaPagamento,
			@DataRiferimentoTerminiPagamento,
			@GiorniTerminiPagamento,
			@DataScadenzaPagamento,
			@ImportoPagamento,
			@CodUfficioPostale,
			@CognomeQuietanzante,
			@NomeQuietanzante,
			@CFQuietanzante,
			@TitoloQuietanzante,
			@IstitutoFinanziario,
			@IBAN,
			@ABI,
			@CAB,
			@BIC,
			@ScontoPagamentoAnticipato,
			@DataLimitePagamentoAnticipato,
			@PenalitaPagamentiRitardati,
			@DataDecorrenzaPenale,
			@CodicePagamento;
	END
	
	CLOSE cursor_FEBDPDP
	DEALLOCATE cursor_FEBDPDP

	/*** DatiPagamento_DettaglioPagamento: fine ***/

	CLOSE cursor_FEB;
	DEALLOCATE cursor_FEB;

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_EsportaFatturaHeader
 * @description Esportazione fattura da tabelle di staging a tabelle "ufficiali" - Testata fattura

 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @PKFatturaElettronicaHeader
 * @input_param @PKEvento

 * @output_param @PKEsitoEvento
*/

IF OBJECT_ID(N'XMLFatture.ssp_EsportaFatturaHeader', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_EsportaFatturaHeader AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_EsportaFatturaHeader (
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKFatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT,
	@PKEsitoEvento SMALLINT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	--BEGIN TRANSACTION; -- L'unica transazione è gestita nella procedura XMLFatture.ssp_EsportaFattura

	BEGIN TRY

		INSERT INTO XMLFatture.FatturaElettronicaHeader
		(
			PKFatturaElettronicaHeader,
			PKLanding_Fattura,
			PKStaging_FatturaElettronicaHeader,
			DatiTrasmissione_IdTrasmittente_IdPaese,
			DatiTrasmissione_IdTrasmittente_IdCodice,
			DatiTrasmissione_ProgressivoInvio,
			DatiTrasmissione_FormatoTrasmissione,
			DatiTrasmissione_CodiceDestinatario,
			DatiTrasmissione_HasContattiTrasmittente,
			DatiTrasmissione_ContattiTrasmittente_Telefono,
			DatiTrasmissione_ContattiTrasmittente_Email,
			DatiTrasmissione_PECDestinatario,
			CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			CedentePrestatore_DatiAnagrafici_CodiceFiscale,
			CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione,
			CedentePrestatore_DatiAnagrafici_Anagrafica_Nome,
			CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome,
			CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo,
			CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI,
			CedentePrestatore_DatiAnagrafici_AlboProfessionale,
			CedentePrestatore_DatiAnagrafici_ProvinciaAlbo,
			CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo,
			CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo,
			CedentePrestatore_DatiAnagrafici_RegimeFiscale,
			CedentePrestatore_Sede_Indirizzo,
			CedentePrestatore_Sede_NumeroCivico,
			CedentePrestatore_Sede_CAP,
			CedentePrestatore_Sede_Comune,
			CedentePrestatore_Sede_Provincia,
			CedentePrestatore_Sede_Nazione,
			CedentePrestatore_HasStabileOrganizzazione,
			CedentePrestatore_StabileOrganizzazione_Indirizzo,
			CedentePrestatore_StabileOrganizzazione_NumeroCivico,
			CedentePrestatore_StabileOrganizzazione_CAP,
			CedentePrestatore_StabileOrganizzazione_Comune,
			CedentePrestatore_StabileOrganizzazione_Provincia,
			CedentePrestatore_StabileOrganizzazione_Nazione,
			CedentePrestatore_HasIscrizioneREA,
			CedentePrestatore_IscrizioneREA_Ufficio,
			CedentePrestatore_IscrizioneREA_NumeroREA,
			CedentePrestatore_IscrizioneREA_CapitaleSociale,
			CedentePrestatore_IscrizioneREA_SocioUnico,
			CedentePrestatore_IscrizioneREA_StatoLiquidazione,
			CedentePrestatore_HasContatti,
			CedentePrestatore_Contatti_Telefono,
			CedentePrestatore_Contatti_Fax,
			CedentePrestatore_Contatti_Email,
			CedentePrestatore_RiferimentoAmministrazione,
			HasRappresentanteFiscale,
			RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			RappresentanteFiscale_DatiAnagrafici_CodiceFiscale,
			RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione,
			RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome,
			RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome,
			RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo,
			RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI,
			CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA,
			CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			CessionarioCommittente_DatiAnagrafici_CodiceFiscale,
			CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione,
			CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome,
			CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome,
			CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo,
			CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI,
			CessionarioCommittente_Sede_Indirizzo,
			CessionarioCommittente_Sede_NumeroCivico,
			CessionarioCommittente_Sede_CAP,
			CessionarioCommittente_Sede_Comune,
			CessionarioCommittente_Sede_Provincia,
			CessionarioCommittente_Sede_Nazione,
			CessionarioCommittente_HasStabileOrganizzazione,
			CessionarioCommittente_StabileOrganizzazione_Indirizzo,
			CessionarioCommittente_StabileOrganizzazione_NumeroCivico,
			CessionarioCommittente_StabileOrganizzazione_CAP,
			CessionarioCommittente_StabileOrganizzazione_Comune,
			CessionarioCommittente_StabileOrganizzazione_Provincia,
			CessionarioCommittente_StabileOrganizzazione_Nazione,
			CessionarioCommittente_HasRappresentanteFiscale,
			CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese,
			CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice,
			CessionarioCommittente_RappresentanteFiscale_Denominazione,
			CessionarioCommittente_RappresentanteFiscale_Nome,
			CessionarioCommittente_RappresentanteFiscale_Cognome,
			HasTerzoIntermediarioOSoggettoEmittente,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo,
			TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI,
			SoggettoEmittente
		)
		SELECT
			@PKFatturaElettronicaHeader,
			SFEH.PKLanding_Fattura,
			SFEH.PKStaging_FatturaElettronicaHeader,
			SFEH.DatiTrasmissione_IdTrasmittente_IdPaese,
			SFEH.DatiTrasmissione_IdTrasmittente_IdCodice,
			SFEH.DatiTrasmissione_ProgressivoInvio,
			SFEH.DatiTrasmissione_FormatoTrasmissione,
			SFEH.DatiTrasmissione_CodiceDestinatario,
			CASE
				WHEN COALESCE(SFEH.DatiTrasmissione_ContattiTrasmittente_Telefono, N'') = N''
					AND COALESCE(SFEH.DatiTrasmissione_ContattiTrasmittente_Email, N'') = N''
				THEN 0
				ELSE 1
			END AS DatiTrasmissione_HasContattiTrasmittente,
			COALESCE(SFEH.DatiTrasmissione_ContattiTrasmittente_Telefono, N'') AS DatiTrasmissione_ContattiTrasmittente_Telefono,
			COALESCE(SFEH.DatiTrasmissione_ContattiTrasmittente_Email, N'') AS DatiTrasmissione_ContattiTrasmittente_Email,
			COALESCE(SFEH.DatiTrasmissione_PECDestinatario, N'') AS DatiTrasmissione_PECDestinatario,
			SFEH.CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			SFEH.CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_CodiceFiscale, N'') AS CedentePrestatore_DatiAnagrafici_CodiceFiscale,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione, N'') AS CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Nome, N'') AS CedentePrestatore_DatiAnagrafici_Anagrafica_Nome,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome, N'') AS CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo, N'') AS CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI, N'') AS CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_AlboProfessionale, N'') AS CedentePrestatore_DatiAnagrafici_AlboProfessionale,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_ProvinciaAlbo, N'') AS CedentePrestatore_DatiAnagrafici_ProvinciaAlbo,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo, N'') AS CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo,
			COALESCE(SFEH.CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo, NULL) AS CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo,
			SFEH.CedentePrestatore_DatiAnagrafici_RegimeFiscale,
			SFEH.CedentePrestatore_Sede_Indirizzo,
			COALESCE(SFEH.CedentePrestatore_Sede_NumeroCivico, N'') AS CedentePrestatore_Sede_NumeroCivico,
			SFEH.CedentePrestatore_Sede_CAP,
			SFEH.CedentePrestatore_Sede_Comune,
			COALESCE(SFEH.CedentePrestatore_Sede_Provincia, N'') AS CedentePrestatore_Sede_Provincia,
			SFEH.CedentePrestatore_Sede_Nazione,
			CASE
				WHEN COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Indirizzo, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_NumeroCivico, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_CAP, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Comune, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Provincia, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Nazione, N'') = N''
				THEN 0
				ELSE 1
			END AS CedentePrestatore_HasStabileOrganizzazione,
			COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Indirizzo, N'') AS CedentePrestatore_StabileOrganizzazione_Indirizzo,
			COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_NumeroCivico, N'') AS CedentePrestatore_StabileOrganizzazione_NumeroCivico,
			COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_CAP, N'') AS CedentePrestatore_StabileOrganizzazione_CAP,
			COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Comune, N'') AS CedentePrestatore_StabileOrganizzazione_Comune,
			COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Provincia, N'') AS CedentePrestatore_StabileOrganizzazione_Provincia,
			COALESCE(SFEH.CedentePrestatore_StabileOrganizzazione_Nazione, N'') AS CedentePrestatore_StabileOrganizzazione_Nazione,
			CASE
				WHEN COALESCE(SFEH.CedentePrestatore_IscrizioneREA_Ufficio, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_IscrizioneREA_NumeroREA, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_IscrizioneREA_CapitaleSociale, 0.0) = 0.0
					AND COALESCE(SFEH.CedentePrestatore_IscrizioneREA_SocioUnico, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_IscrizioneREA_StatoLiquidazione, N'') = N''
				THEN 0
				ELSE 1
			END AS CedentePrestatore_HasIscrizioneREA,
			COALESCE(SFEH.CedentePrestatore_IscrizioneREA_Ufficio, N'') AS CedentePrestatore_IscrizioneREA_Ufficio,
			COALESCE(SFEH.CedentePrestatore_IscrizioneREA_NumeroREA, N'') AS CedentePrestatore_IscrizioneREA_NumeroREA,
			COALESCE(SFEH.CedentePrestatore_IscrizioneREA_CapitaleSociale, 0.0) AS CedentePrestatore_IscrizioneREA_CapitaleSociale,
			COALESCE(SFEH.CedentePrestatore_IscrizioneREA_SocioUnico, N'') AS CedentePrestatore_IscrizioneREA_SocioUnico,
			COALESCE(SFEH.CedentePrestatore_IscrizioneREA_StatoLiquidazione, N'') AS CedentePrestatore_IscrizioneREA_StatoLiquidazione,
			CASE
				WHEN COALESCE(SFEH.CedentePrestatore_Contatti_Telefono, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_Contatti_Fax, N'') = N''
					AND COALESCE(SFEH.CedentePrestatore_Contatti_Email, N'') = N''
				THEN 0
				ELSE 1
			END AS CedentePrestatore_HasContatti,
			COALESCE(SFEH.CedentePrestatore_Contatti_Telefono, N'') AS CedentePrestatore_Contatti_Telefono,
			COALESCE(SFEH.CedentePrestatore_Contatti_Fax, N'') AS CedentePrestatore_Contatti_Fax,
			COALESCE(SFEH.CedentePrestatore_Contatti_Email, N'') AS CedentePrestatore_Contatti_Email,
			COALESCE(SFEH.CedentePrestatore_RiferimentoAmministrazione, N'') AS CedentePrestatore_RiferimentoAmministrazione,
			CASE
				WHEN COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') = N''
					AND COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') = N''
				THEN 0
				ELSE 1
			END AS HasRappresentanteFiscale,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') AS RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') AS RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_CodiceFiscale, N'') AS RappresentanteFiscale_DatiAnagrafici_CodiceFiscale,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione, N'') AS RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome, N'') AS RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome, N'') AS RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo, N'') AS RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo,
			COALESCE(SFEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI, N'') AS RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI,
			CASE
				WHEN COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') = N''
				THEN 0
				ELSE 1
			END AS CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') AS CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') AS CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_CodiceFiscale, N'') AS CessionarioCommittente_DatiAnagrafici_CodiceFiscale,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione, N'') AS CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome, N'') AS CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome, N'') AS CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo, N'') AS CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo,
			COALESCE(SFEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI, N'') AS CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI,
			SFEH.CessionarioCommittente_Sede_Indirizzo,
			COALESCE(SFEH.CessionarioCommittente_Sede_NumeroCivico, N'') AS CessionarioCommittente_Sede_NumeroCivico,
			SFEH.CessionarioCommittente_Sede_CAP,
			SFEH.CessionarioCommittente_Sede_Comune,
			COALESCE(SFEH.CessionarioCommittente_Sede_Provincia, N'') AS CessionarioCommittente_Sede_Provincia,
			SFEH.CessionarioCommittente_Sede_Nazione,
			CASE
				WHEN COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Indirizzo, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_NumeroCivico, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_CAP, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Comune, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Provincia, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Nazione, N'') = N''
				THEN 0
				ELSE 1
			END AS CessionarioCommittente_HasStabileOrganizzazione,
			COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Indirizzo, N'') AS CessionarioCommittente_StabileOrganizzazione_Indirizzo,
			COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_NumeroCivico, N'') AS CessionarioCommittente_StabileOrganizzazione_NumeroCivico,
			COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_CAP, N'') AS CessionarioCommittente_StabileOrganizzazione_CAP,
			COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Comune, N'') AS CessionarioCommittente_StabileOrganizzazione_Comune,
			COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Provincia, N'') AS CessionarioCommittente_StabileOrganizzazione_Provincia,
			COALESCE(SFEH.CessionarioCommittente_StabileOrganizzazione_Nazione, N'') AS CessionarioCommittente_StabileOrganizzazione_Nazione,
			CASE
				WHEN COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese, N'') = N''
					AND COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice, N'') = N''
				THEN 0
				ELSE 1
			END AS HasRappresentanteFiscale,
			COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese, N'') AS CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese,
			COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice, N'') AS CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice,
			COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_Denominazione, N'') AS CessionarioCommittente_RappresentanteFiscale_Denominazione,
			COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_Nome, N'') AS CessionarioCommittente_RappresentanteFiscale_Nome,
			COALESCE(SFEH.CessionarioCommittente_RappresentanteFiscale_Cognome, N'') AS CessionarioCommittente_RappresentanteFiscale_Cognome,
			CASE
				WHEN COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') = N''
					AND COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') = N''
				THEN 0
				ELSE 1
			END AS HasTerzoIntermediarioOSoggettoEmittente,
			CASE
				WHEN COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') = N''
					AND COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') = N''
				THEN 0
				ELSE 1
			END AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo,
			COALESCE(SFEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI, N'') AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI,
			COALESCE(SFEH.SoggettoEmittente, N'') AS SoggettoEmittente
	
		FROM XMLFatture.Staging_FatturaElettronicaHeader SFEH
		WHERE SFEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE('Inserimento XMLFatture.FatturaElettronicaHeader (#%PKFatturaElettronicaHeader%) completato', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		UPDATE XMLFatture.Staging_FatturaElettronicaHeader SET IsValida = CAST(1 AS BIT) WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE('Aggiornamento validità XMLFatture.Staging_FatturaElettronicaHeader (#%PKStaging_FatturaElettronicaHeader%) completato', N'%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		--COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		--IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION; -- L'unica transazione è gestita nella procedura XMLFatture.ssp_EsportaFattura

		SET @PKStaging_FatturaElettronicaHeader = -1;

		SET @PKEsitoEvento = 311; -- 311: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaHeader
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Errore in esportazione testata fattura',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 0; -- 0: trace

	END CATCH;

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_EsportaFatturaBody
 * @description Esportazione fattura da tabelle di staging a tabelle "ufficiali" - Righe fattura

 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @PKFatturaElettronicaHeader
 * @input_param @PKEvento

 * @output_param @PKEsitoEvento
*/

IF OBJECT_ID(N'XMLFatture.ssp_EsportaFatturaBody', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_EsportaFatturaBody AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_EsportaFatturaBody (
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKFatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT,
	@PKEsitoEvento BIGINT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @NomeTabella sysname;
	DECLARE @Messaggio NVARCHAR(500);

	--BEGIN TRANSACTION;

	BEGIN TRY

		/* FatturaElettronicaBody: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody';
		INSERT INTO XMLFatture.FatturaElettronicaBody
		(
			--PKFatturaElettronicaBody,
			PKFatturaElettronicaHeader,
			PKStaging_FatturaElettronicaBody,
			DatiGenerali_DatiGeneraliDocumento_TipoDocumento,
			DatiGenerali_DatiGeneraliDocumento_Divisa,
			DatiGenerali_DatiGeneraliDocumento_Data,
			DatiGenerali_DatiGeneraliDocumento_Numero,
			DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta,
			DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta,
			DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta,
			DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta,
			DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento,
			DatiGenerali_DatiGeneraliDocumento_HasDatiBollo,
			DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale,
			DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo,
			DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento,
			DatiGenerali_DatiGeneraliDocumento_Arrotondamento,
			DatiGenerali_DatiGeneraliDocumento_Art73,
			DatiGenerali_HasDatiTrasporto,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI,
			DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida,
			DatiGenerali_DatiTrasporto_MezzoTrasporto,
			DatiGenerali_DatiTrasporto_CausaleTrasporto,
			DatiGenerali_DatiTrasporto_NumeroColli,
			DatiGenerali_DatiTrasporto_Descrizione,
			DatiGenerali_DatiTrasporto_UnitaMisuraPeso,
			DatiGenerali_DatiTrasporto_PesoLordo,
			DatiGenerali_DatiTrasporto_PesoNetto,
			DatiGenerali_DatiTrasporto_DataOraRitiro,
			DatiGenerali_DatiTrasporto_DataInizioTrasporto,
			DatiGenerali_DatiTrasporto_TipoResa,
			DatiGenerali_DatiTrasporto_HasIndirizzoResa,
			DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo,
			DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico,
			DatiGenerali_DatiTrasporto_IndirizzoResa_CAP,
			DatiGenerali_DatiTrasporto_IndirizzoResa_Comune,
			DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia,
			DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione,
			DatiGenerali_DatiTrasporto_DataOraConsegna,
			DatiGenerali_HasFatturaPrincipale,
			DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale,
			DatiGenerali_FatturaPrincipale_DataFatturaPrincipale,
			DatiGenerali_HasDatiVeicoli,
			DatiVeicoli_Data,
			DatiVeicoli_TotalePercorso
		)
		SELECT
			@PKFatturaElettronicaHeader,
			SFEB.PKStaging_FatturaElettronicaBody,
			SFEB.DatiGenerali_DatiGeneraliDocumento_TipoDocumento,
			SFEB.DatiGenerali_DatiGeneraliDocumento_Divisa,
			SFEB.DatiGenerali_DatiGeneraliDocumento_Data,
			SFEB.DatiGenerali_DatiGeneraliDocumento_Numero,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta, 0.0) > 0.0 THEN 1 ELSE 0 END AS DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta ELSE '' END AS DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta ELSE NULL END AS DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta ELSE NULL END AS DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento ELSE '' END AS DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo, 0.0) > 0.0 THEN 1 ELSE 0 END AS DatiGenerali_DatiGeneraliDocumento_HasDatiBollo,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale ELSE NULL END AS DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo ELSE NULL END AS DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento ELSE NULL END AS DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_Arrotondamento, 0.0) > 0.0 THEN SFEB.DatiGenerali_DatiGeneraliDocumento_Arrotondamento ELSE NULL END AS DatiGenerali_DatiGeneraliDocumento_Arrotondamento,
			CASE WHEN COALESCE(SFEB.DatiGenerali_DatiGeneraliDocumento_Art73, '') <> '' THEN SFEB.DatiGenerali_DatiGeneraliDocumento_Art73 ELSE '' END AS DatiGenerali_DatiGeneraliDocumento_Art73,
			0 AS DatiGenerali_HasDatiTrasporto,
			'' AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI,
			NULL AS DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida,
			NULL AS DatiGenerali_DatiTrasporto_MezzoTrasporto,
			NULL AS DatiGenerali_DatiTrasporto_CausaleTrasporto,
			NULL AS DatiGenerali_DatiTrasporto_NumeroColli,
			NULL AS DatiGenerali_DatiTrasporto_Descrizione,
			NULL AS DatiGenerali_DatiTrasporto_UnitaMisuraPeso,
			NULL AS DatiGenerali_DatiTrasporto_PesoLordo,
			NULL AS DatiGenerali_DatiTrasporto_PesoNetto,
			NULL AS DatiGenerali_DatiTrasporto_DataOraRitiro,
			NULL AS DatiGenerali_DatiTrasporto_DataInizioTrasporto,
			'' AS DatiGenerali_DatiTrasporto_TipoResa,
			0 AS DatiGenerali_DatiTrasporto_HasIndirizzoResa,
			NULL AS DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo,
			NULL AS DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico,
			NULL AS DatiGenerali_DatiTrasporto_IndirizzoResa_CAP,
			NULL AS DatiGenerali_DatiTrasporto_IndirizzoResa_Comune,
			'' AS DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia,
			'' AS DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione,
			NULL AS DatiGenerali_DatiTrasporto_DataOraConsegna,
			CASE WHEN COALESCE(SFEB.DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale, N'') = N'' THEN 0 ELSE 1 END AS DatiGenerali_HasFatturaPrincipale,
			CASE WHEN COALESCE(SFEB.DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale, N'') = N'' THEN SFEB.DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale ELSE NULL END AS DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale,
			CASE WHEN COALESCE(SFEB.DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale, N'') = N'' THEN SFEB.DatiGenerali_FatturaPrincipale_DataFatturaPrincipale ELSE NULL END AS DatiGenerali_FatturaPrincipale_DataFatturaPrincipale,
			0 AS HasDatiVeicoli,
			NULL AS DatiVeicoli_Data,
			NULL AS DatiVeicoli_TotalePercorso

		FROM XMLFatture.Staging_FatturaElettronicaBody SFEB
		WHERE SFEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody: Fine */

		/* FatturaElettronicaBody_DatiCassaPrevidenziale : Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiCassaPrevidenziale';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale
		(
		    --PKFatturaElettronicaBody_DatiCassaPrevidenziale,
		    PKFatturaElettronicaBody,
		    TipoCassa,
		    AlCassa,
		    ImportoContributoCassa,
		    ImponibileCassa,
		    AliquotaIVA,
		    Ritenuta,
		    Natura,
		    RiferimentoAmministrazione
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDCP.TipoCassa,
            SFEBDCP.AlCassa,
            SFEBDCP.ImportoContributoCassa,
            SFEBDCP.ImponibileCassa,
            SFEBDCP.AliquotaIVA,
            SFEBDCP.Ritenuta,
            SFEBDCP.Natura,
            SFEBDCP.RiferimentoAmministrazione 

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale SFEBDCP
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDCP.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiCassaPrevidenziale : Fine */

		/* FatturaElettronicaBody_ScontoMaggiorazione: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_ScontoMaggiorazione';

		INSERT INTO XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione
		(
		    --PKFatturaElettronicaBody_ScontoMaggiorazione,
		    PKFatturaElettronicaBody,
		    Tipo,
		    Percentuale,
		    Importo
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBSM.Tipo,
            SFEBSM.Percentuale,
            SFEBSM.Importo

		FROM XMLFatture.Staging_FatturaElettronicaBody_ScontoMaggiorazione SFEBSM
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBSM.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_ScontoMaggiorazione: Fine */

		/* FatturaElettronicaBody_Causale: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_Causale';

		INSERT INTO XMLFatture.FatturaElettronicaBody_Causale
		(
		    --PKFatturaElettronicaBody_Causale,
		    PKFatturaElettronicaBody,
		    DatiGenerali_Causale
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBC.DatiGenerali_Causale

		FROM XMLFatture.Staging_FatturaElettronicaBody_Causale SFEBC
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBC.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_Causale: Fine */

		/* FatturaElettronicaBody_DocumentoEsterno: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DocumentoEsterno';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DocumentoEsterno
		(
		    --PKFatturaElettronicaBody_DocumentoEsterno,
		    PKFatturaElettronicaBody,
		    TipoDocumentoEsterno,
		    IdDocumento,
		    Data,
		    NumItem,
		    CodiceCommessaConvenzione,
		    CodiceCUP,
		    CodiceCIG
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDE.TipoDocumentoEsterno,
            SFEBDE.IdDocumento,
            SFEBDE.Data,
            SFEBDE.NumItem,
            SFEBDE.CodiceCommessaConvenzione,
            SFEBDE.CodiceCUP,
            SFEBDE.CodiceCIG

		FROM XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno SFEBDE
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDE.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DocumentoEsterno: Fine */

		/* FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea';

        INSERT INTO XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea
        (
            --PKFatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea,
            PKFatturaElettronicaBody_DocumentoEsterno,
            RiferimentoNumeroLinea
        )
        SELECT
            FEBDE.PKFatturaElettronicaBody_DocumentoEsterno,
            SFEBDERNL.RiferimentoNumeroLinea

		FROM XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea SFEBDERNL
        INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno SFEBDE ON SFEBDE.PKStaging_FatturaElettronicaBody_DocumentoEsterno = SFEBDERNL.PKStaging_FatturaElettronicaBody_DocumentoEsterno
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDE.PKStaging_FatturaElettronicaBody
        INNER JOIN XMLFatture.FatturaElettronicaBody_DocumentoEsterno FEBDE ON FEBDE.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
            AND FEBDE.IdDocumento = SFEBDE.IdDocumento
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
        ORDER BY SFEBDE.PKStaging_FatturaElettronicaBody_DocumentoEsterno,
            SFEBDERNL.RiferimentoNumeroLinea;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea: Fine */

		/* FatturaElettronicaBody_DatiSAL: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiSAL';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiSAL
		(
		    --PKFatturaElettronicaBody_DatiSAL,
		    PKFatturaElettronicaBody,
		    RiferimentoFase
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDS.RiferimentoFase

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiSAL SFEBDS
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDS.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiSAL: Fine */

		/* FatturaElettronicaBody_DatiDDT: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiDDT';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiDDT
		(
		    --PKFatturaElettronicaBody_DatiDDT,
		    PKFatturaElettronicaBody,
		    NumeroDDT,
		    DataDDT
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDDT.NumeroDDT,
            SFEBDDT.DataDDT

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiDDT SFEBDDT
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDDT.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiDDT: Fine */

		/* FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea
		(
		    --PKFatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea,
		    PKFatturaElettronicaBody_DatiDDT,
		    RiferimentoNumeroLinea
		)
		SELECT
			FEBDDT.PKFatturaElettronicaBody_DatiDDT,
            SFEBDDTRNL.RiferimentoNumeroLinea

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea SFEBDDTRNL
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DatiDDT SFEBDDDT ON SFEBDDDT.PKStaging_FatturaElettronicaBody_DatiDDT = SFEBDDTRNL.PKStaging_FatturaElettronicaBody_DatiDDT
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody SFEB ON SFEB.PKStaging_FatturaElettronicaBody = SFEBDDDT.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEB.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		INNER JOIN XMLFatture.FatturaElettronicaBody_DatiDDT FEBDDT ON FEBDDT.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody AND FEBDDT.DataDDT = SFEBDDDT.DataDDT AND FEBDDT.NumeroDDT = SFEBDDDT.NumeroDDT;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea: Fine */

		/* FatturaElettronicaBody_DettaglioLinee: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DettaglioLinee';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DettaglioLinee
		(
		    --PKFatturaElettronicaBody_DettaglioLinee,
		    PKFatturaElettronicaBody,
		    NumeroLinea,
		    TipoCessionePrestazione,
		    Descrizione,
		    Quantita,
		    UnitaMisura,
		    DataInizioPeriodo,
		    DataFinePeriodo,
		    PrezzoUnitario,
		    PrezzoTotale,
		    AliquotaIVA,
		    Ritenuta,
		    Natura,
		    RiferimentoAmministrazione
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDL.NumeroLinea,
            SFEBDL.TipoCessionePrestazione,
            SFEBDL.Descrizione,
            SFEBDL.Quantita,
            SFEBDL.UnitaMisura,
            SFEBDL.DataInizioPeriodo,
            SFEBDL.DataFinePeriodo,
            SFEBDL.PrezzoUnitario,
            SFEBDL.PrezzoTotale,
            SFEBDL.AliquotaIVA,
            SFEBDL.Ritenuta,
            SFEBDL.Natura,
            SFEBDL.RiferimentoAmministrazione

		FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee SFEBDL
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDL.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DettaglioLinee: Fine */

		/* FatturaElettronicaBody_DettaglioLinee_CodiceArticolo: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DettaglioLinee_CodiceArticolo';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo
		(
		    --PKFatturaElettronicaBody_DettaglioLinee_CodiceArticolo,
		    PKFatturaElettronicaBody_DettaglioLinee,
		    CodiceArticolo_CodiceTipo,
		    CodiceArticolo_CodiceValore
		)
		SELECT
			FEBDL.PKFatturaElettronicaBody_DettaglioLinee,
            SFEBDLCA.CodiceArticolo_CodiceTipo,
            SFEBDLCA.CodiceArticolo_CodiceValore

		FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo SFEBDLCA
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee SFEBDL ON SFEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee = SFEBDLCA.PKStaging_FatturaElettronicaBody_DettaglioLinee
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody SFEB ON SFEB.PKStaging_FatturaElettronicaBody = SFEBDL.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEB.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		INNER JOIN XMLFatture.FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody AND FEBDL.NumeroLinea = SFEBDL.NumeroLinea;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DettaglioLinee_CodiceArticolo: Fine */

		/* FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione
		(
		    --PKFatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione,
		    PKFatturaElettronicaBody_DettaglioLinee,
		    ScontoMaggiorazione_Tipo,
		    ScontoMaggiorazione_Percentuale,
		    ScontoMaggiorazione_Importo
		)
		SELECT
			FEBDL.PKFatturaElettronicaBody_DettaglioLinee,
            SFEBDLSM.ScontoMaggiorazione_Tipo,
            SFEBDLSM.ScontoMaggiorazione_Percentuale,
            SFEBDLSM.ScontoMaggiorazione_Importo

		FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione SFEBDLSM
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee SFEBDL ON SFEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee = SFEBDLSM.PKStaging_FatturaElettronicaBody_DettaglioLinee
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody SFEB ON SFEB.PKStaging_FatturaElettronicaBody = SFEBDL.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEB.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		INNER JOIN XMLFatture.FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody AND FEBDL.NumeroLinea = SFEBDL.NumeroLinea;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione: Fine */

		/* FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
		(
		    --PKFatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali,
		    PKFatturaElettronicaBody_DettaglioLinee,
		    AltriDatiGestionali_TipoDato,
		    AltriDatiGestionali_RiferimentoTesto,
		    AltriDatiGestionali_RiferimentoNumero,
		    AltriDatiGestionali_RiferimentoData
		)
		SELECT
			FEBDL.PKFatturaElettronicaBody_DettaglioLinee,
            SFEBDLADG.AltriDatiGestionali_TipoDato,
            SFEBDLADG.AltriDatiGestionali_RiferimentoTesto,
            SFEBDLADG.AltriDatiGestionali_RiferimentoNumero,
            SFEBDLADG.AltriDatiGestionali_RiferimentoData

		FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali SFEBDLADG
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee SFEBDL ON SFEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee = SFEBDLADG.PKStaging_FatturaElettronicaBody_DettaglioLinee
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody SFEB ON SFEB.PKStaging_FatturaElettronicaBody = SFEBDL.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEB.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		INNER JOIN XMLFatture.FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody AND FEBDL.NumeroLinea = SFEBDL.NumeroLinea;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali: Fine */

		/* FatturaElettronicaBody_DatiRiepilogo: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiRiepilogo';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiRiepilogo
		(
		    --PKFatturaElettronicaBody_DatiRiepilogo,
		    PKFatturaElettronicaBody,
		    AliquotaIVA,
		    Natura,
		    SpeseAccessorie,
		    Arrotondamento,
		    ImponibileImporto,
		    Imposta,
		    EsigibilitaIVA,
		    RiferimentoNormativo
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDR.AliquotaIVA,
            COALESCE(SFEBDR.Natura, '') AS Natura,
            SFEBDR.SpeseAccessorie,
            SFEBDR.Arrotondamento,
            SFEBDR.ImponibileImporto,
            SFEBDR.Imposta,
            SFEBDR.EsigibilitaIVA,
            SFEBDR.RiferimentoNormativo

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo SFEBDR
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDR.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiRiepilogo: Fine */

		/* FatturaElettronicaBody_DatiPagamento: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiPagamento';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiPagamento
		(
		    --PKFatturaElettronicaBody_DatiPagamento,
		    PKFatturaElettronicaBody,
		    CondizioniPagamento
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBDP.CondizioniPagamento

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento SFEBDP
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDP.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiPagamento: Fine */

		/* FatturaElettronicaBody_DatiPagamento_DettaglioPagamento: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_DatiPagamento_DettaglioPagamento';

		INSERT INTO XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento
		(
		    --PKFatturaElettronicaBody_DatiPagamento_DettaglioPagamento,
		    PKFatturaElettronicaBody_DatiPagamento,
		    Beneficiario,
		    ModalitaPagamento,
		    DataRiferimentoTerminiPagamento,
		    GiorniTerminiPagamento,
		    DataScadenzaPagamento,
		    ImportoPagamento,
		    CodUfficioPostale,
		    CognomeQuietanzante,
		    NomeQuietanzante,
		    CFQuietanzante,
		    TitoloQuietanzante,
		    IstitutoFinanziario,
		    IBAN,
		    ABI,
		    CAB,
		    BIC,
		    ScontoPagamentoAnticipato,
		    DataLimitePagamentoAnticipato,
		    PenalitaPagamentiRitardati,
		    DataDecorrenzaPenale,
		    CodicePagamento
		)
		SELECT
			FEBDP.PKFatturaElettronicaBody_DatiPagamento,
            SFEBDPDP.Beneficiario,
            SFEBDPDP.ModalitaPagamento,
            SFEBDPDP.DataRiferimentoTerminiPagamento,
            SFEBDPDP.GiorniTerminiPagamento,
            SFEBDPDP.DataScadenzaPagamento,
            SFEBDPDP.ImportoPagamento,
            SFEBDPDP.CodUfficioPostale,
            SFEBDPDP.CognomeQuietanzante,
            SFEBDPDP.NomeQuietanzante,
            SFEBDPDP.CFQuietanzante,
            SFEBDPDP.TitoloQuietanzante,
            SFEBDPDP.IstitutoFinanziario,
            SFEBDPDP.IBAN,
            SFEBDPDP.ABI,
            SFEBDPDP.CAB,
            SFEBDPDP.BIC,
            SFEBDPDP.ScontoPagamentoAnticipato,
            SFEBDPDP.DataLimitePagamentoAnticipato,
            SFEBDPDP.PenalitaPagamentiRitardati,
            SFEBDPDP.DataDecorrenzaPenale,
            SFEBDPDP.CodicePagamento

		FROM XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento SFEBDPDP
		INNER JOIN XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento SFEBDP ON SFEBDP.PKStaging_FatturaElettronicaBody_DatiPagamento = SFEBDPDP.PKStaging_FatturaElettronicaBody_DatiPagamento
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBDP.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
		INNER JOIN XMLFatture.FatturaElettronicaBody_DatiPagamento FEBDP ON FEBDP.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody AND FEBDP.CondizioniPagamento = SFEBDP.CondizioniPagamento;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_DatiPagamento_DettaglioPagamento: Fine */

		/* FatturaElettronicaBody_Allegati: Inizio */
		SET @NomeTabella = N'FatturaElettronicaBody_Allegati';

		INSERT INTO XMLFatture.FatturaElettronicaBody_Allegati
		(
		    --PKFatturaElettronicaBody_Allegati,
		    PKFatturaElettronicaBody,
		    NomeAttachment,
		    AlgoritmoCompressione,
		    FormatoAttachment,
		    DescrizioneAttachment,
		    Attachment
		)
		SELECT
			FEB.PKFatturaElettronicaBody,
            SFEBA.NomeAttachment,
            SFEBA.AlgoritmoCompressione,
            SFEBA.FormatoAttachment,
            SFEBA.DescrizioneAttachment,
            SFEBA.Attachment

		FROM XMLFatture.Staging_FatturaElettronicaBody_Allegati SFEBA
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = SFEBA.PKStaging_FatturaElettronicaBody
		INNER JOIN XMLFatture.FatturaElettronicaHeader FEH ON FEH.PKFatturaElettronicaHeader = FEB.PKFatturaElettronicaHeader
			AND FEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		SET @Messaggio = REPLACE(REPLACE(REPLACE('Inserimento XMLFatture.%NOME_TABELLA% (#%PKFatturaElettronicaHeader%) completato (%ROWCOUNT% righe)', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader)), N'%NOME_TABELLA%', @NomeTabella), N'%ROWCOUNT%', CONVERT(NVARCHAR(10), @@ROWCOUNT));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

		/* FatturaElettronicaBody_Allegati: Fine */

		--COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

		SET @PKStaging_FatturaElettronicaHeader = -1;

		SET @Messaggio = REPLACE(N'Errore in esportazione fattura (tabella %NOME_TABELLA%)', N'%NOME_TABELLA%', @NomeTabella);

		SET @PKEsitoEvento = CASE @NomeTabella
			WHEN N'FatturaElettronicaBody' THEN 313 -- 313: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody
			WHEN N'FatturaElettronicaBody_DatiCassaPrevidenziale' THEN 314 -- 314: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale
			WHEN N'FatturaElettronicaBody_ScontoMaggiorazione' THEN 315 -- 315: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione
			WHEN N'FatturaElettronicaBody_DocumentoEsterno' THEN 317 -- 317: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DocumentoEsterno
			WHEN N'FatturaElettronicaBody_Causale' THEN 316 -- 316: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_Causale
			WHEN N'FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea' THEN 318 -- 318: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea
			WHEN N'FatturaElettronicaBody_DocumentoEsterno*' THEN 319 -- 319: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DocumentoEsterno*
			WHEN N'FatturaElettronicaBody_DatiSAL' THEN 320 -- 320: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiSAL
			WHEN N'FatturaElettronicaBody_DatiDDT' THEN 321 -- 321: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiDDT
			WHEN N'FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea' THEN 322 -- 322: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea
			WHEN N'FatturaElettronicaBody_DettaglioLinee' THEN 323 -- 323: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DettaglioLinee
			WHEN N'FatturaElettronicaBody_DettaglioLinee_CodiceArticolo' THEN 324 -- 324: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo
			WHEN N'FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione' THEN 325 -- 325: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione
			WHEN N'FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali' THEN 326 -- 326: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
			WHEN N'FatturaElettronicaBody_DatiRiepilogo' THEN 327 -- 327: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiRiepilogo
			WHEN N'FatturaElettronicaBody_DatiPagamento' THEN 328 -- 328: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiPagamento
			WHEN N'FatturaElettronicaBody_DatiPagamento_DettaglioPagamento' THEN 329 -- 329: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento
			WHEN N'FatturaElettronicaBody_Allegati' THEN 330 -- 330: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody_Allegati
			ELSE 312 -- 312: Eccezione in fase di inserimento XMLFatture.FatturaElettronicaBody*
		END;

		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 0; -- 0: trace

	END CATCH;

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_EsportaFattura
 * @description Esportazione fattura da tabelle di staging a tabelle "ufficiali"

 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @PKEvento

 * @output_param @PKEsitoEvento
 * @output_param @PKFatturaElettronicaHeader
*/

IF OBJECT_ID(N'XMLFatture.ssp_EsportaFattura', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_EsportaFattura AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_EsportaFattura (
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@PKFatturaElettronicaHeader BIGINT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	--BEGIN TRANSACTION;

	SET @PKFatturaElettronicaHeader = NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaHeader;

	EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
								@Messaggio = N'Recupero chiave per esportazione fattura',
								@LivelloLog = 0; -- 0: trace

	BEGIN TRY

		PRINT REPLACE(REPLACE('@PKStaging_FatturaElettronicaHeader #%PKStaging_FatturaElettronicaHeader% > @PKFatturaElettronicaHeader #%PKFatturaElettronicaHeader%', '%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(20), @PKStaging_FatturaElettronicaHeader)), '%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(20), @PKFatturaElettronicaHeader));

		EXEC XMLFatture.ssp_EsportaFatturaHeader @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
		                                         @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,
		                                         @PKEvento = @PKEvento,
		                                         @PKEsitoEvento = @PKEsitoEvento OUTPUT;

		IF (@PKEsitoEvento < 0)
		BEGIN

			EXEC XMLFatture.ssp_EsportaFatturaBody @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
			                                       @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,
			                                       @PKEvento = @PKEvento,
			                                       @PKEsitoEvento = @PKEsitoEvento OUTPUT;

			SET @PKEsitoEvento = 0;
			SET @Messaggio = REPLACE('Esportazione righe fattura #%PKFatturaElettronicaHeader% completata', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader));
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = @Messaggio,
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 2; -- 2: info
		END;

	END TRY
	BEGIN CATCH

		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

		SET @PKStaging_FatturaElettronicaHeader = -1;

		SET @PKEsitoEvento = 350; -- 350: Errore generico in fase di esportazione fattura
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Errore generico in fase di esportazione fattura',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 4; -- 4: error

	END CATCH;

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_GeneraXMLFatturaHeader
 * @description Generazione file XML fattura convalidata - Header (procedura di sistema)

 * @input_param @FatturaElettronicaHeader
 * @input_param @PKEvento

 * @output_param @PKEsitoEvento
 * @output_param @XMLOutput
*/

IF OBJECT_ID(N'XMLFatture.ssp_GeneraXMLFatturaHeader', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_GeneraXMLFatturaHeader AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_GeneraXMLFatturaHeader (
	@PKFatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@XMLOutput XML OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	SET @XMLOutput = (
		SELECT
			FEH.DatiTrasmissione_IdTrasmittente_IdPaese AS [DatiTrasmissione/IdTrasmittente/IdPaese],
			FEH.DatiTrasmissione_IdTrasmittente_IdCodice AS [DatiTrasmissione/IdTrasmittente/IdCodice],
			FEH.DatiTrasmissione_ProgressivoInvio AS [DatiTrasmissione/ProgressivoInvio],
			FEH.DatiTrasmissione_FormatoTrasmissione AS [DatiTrasmissione/FormatoTrasmissione],
			FEH.DatiTrasmissione_CodiceDestinatario AS [DatiTrasmissione/CodiceDestinatario],

			--FEH.DatiTrasmissione_HasContattiTrasmittente AS [DatiTrasmissione/HasContattiTrasmittente],
			CASE WHEN (FEH.DatiTrasmissione_HasContattiTrasmittente = CAST(0 AS BIT) OR FEH.DatiTrasmissione_ContattiTrasmittente_Telefono = N'') THEN NULL ELSE FEH.DatiTrasmissione_ContattiTrasmittente_Telefono END AS [DatiTrasmissione/ContattiTrasmittente/Telefono],
			CASE WHEN (FEH.DatiTrasmissione_HasContattiTrasmittente = CAST(0 AS BIT) OR FEH.DatiTrasmissione_ContattiTrasmittente_Email = N'') THEN NULL ELSE FEH.DatiTrasmissione_ContattiTrasmittente_Email END AS [DatiTrasmissione/ContattiTrasmittente/Email],
			CASE WHEN FEH.DatiTrasmissione_PECDestinatario = N'' THEN NULL ELSE FEH.DatiTrasmissione_PECDestinatario END AS [DatiTrasmissione/PECDestinatario],

			FEH.CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese AS [CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdPaese],
			FEH.CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice AS [CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdCodice],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_CodiceFiscale = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_CodiceFiscale END AS [CedentePrestatore/DatiAnagrafici/CodiceFiscale],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione END AS [CedentePrestatore/DatiAnagrafici/Anagrafica/Denominazione],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Nome = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Nome END AS [CedentePrestatore/DatiAnagrafici/Anagrafica/Nome],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome END AS [CedentePrestatore/DatiAnagrafici/Anagrafica/Cognome],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo END AS [CedentePrestatore/DatiAnagrafici/Anagrafica/Titolo],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI END AS [CedentePrestatore/DatiAnagrafici/Anagrafica/CodEORI],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_AlboProfessionale = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_AlboProfessionale END AS [CedentePrestatore/DatiAnagrafici/AlboProfessionale],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_ProvinciaAlbo = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_ProvinciaAlbo END AS [CedentePrestatore/DatiAnagrafici/ProvinciaAlbo],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo END AS [CedentePrestatore/DatiAnagrafici/NumeroIscrizioneAlbo],
			CASE WHEN FEH.CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo = N'' THEN NULL ELSE FEH.CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo END AS [CedentePrestatore/DatiAnagrafici/DataIscrizioneAlbo],
			FEH.CedentePrestatore_DatiAnagrafici_RegimeFiscale AS [CedentePrestatore/DatiAnagrafici/RegimeFiscale],
			FEH.CedentePrestatore_Sede_Indirizzo AS [CedentePrestatore/Sede/Indirizzo],
			CASE WHEN FEH.CedentePrestatore_Sede_NumeroCivico = N'' THEN NULL ELSE FEH.CedentePrestatore_Sede_NumeroCivico END AS [CedentePrestatore/Sede/NumeroCivico],
			FEH.CedentePrestatore_Sede_CAP AS [CedentePrestatore/Sede/CAP],
			FEH.CedentePrestatore_Sede_Comune AS [CedentePrestatore/Sede/Comune],
            CASE WHEN FEH.CedentePrestatore_Sede_Nazione = N'IT' AND LEN(LTRIM(RTRIM(COALESCE(FEH.CedentePrestatore_Sede_Provincia, N'')))) = 2 THEN FEH.CedentePrestatore_Sede_Provincia ELSE NULL END AS [CedentePrestatore/Sede/Provincia],
            FEH.CedentePrestatore_Sede_Nazione AS [CedentePrestatore/Sede/Nazione],
			--FEH.CedentePrestatore_HasStabileOrganizzazione AS [CedentePrestatore/HasStabileOrganizzazione],
			CASE WHEN (FEH.CedentePrestatore_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CedentePrestatore_StabileOrganizzazione_Indirizzo = N'') THEN NULL ELSE FEH.CedentePrestatore_StabileOrganizzazione_Indirizzo END AS [CedentePrestatore/StabileOrganizzazione/Indirizzo],
			CASE WHEN (FEH.CedentePrestatore_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CedentePrestatore_StabileOrganizzazione_NumeroCivico = N'') THEN NULL ELSE FEH.CedentePrestatore_StabileOrganizzazione_NumeroCivico END AS [CedentePrestatore/StabileOrganizzazione/NumeroCivico],
			CASE WHEN (FEH.CedentePrestatore_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CedentePrestatore_StabileOrganizzazione_CAP = N'') THEN NULL ELSE FEH.CedentePrestatore_StabileOrganizzazione_CAP END AS [CedentePrestatore/StabileOrganizzazione/CAP],
			CASE WHEN (FEH.CedentePrestatore_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CedentePrestatore_StabileOrganizzazione_Comune = N'') THEN NULL ELSE FEH.CedentePrestatore_StabileOrganizzazione_Comune END AS [CedentePrestatore/StabileOrganizzazione/Comune],
			CASE WHEN (FEH.CedentePrestatore_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CedentePrestatore_StabileOrganizzazione_Provincia = N'') THEN NULL ELSE FEH.CedentePrestatore_StabileOrganizzazione_Provincia END AS [CedentePrestatore/StabileOrganizzazione/Provincia],
			CASE WHEN (FEH.CedentePrestatore_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CedentePrestatore_StabileOrganizzazione_Nazione = N'') THEN NULL ELSE FEH.CedentePrestatore_StabileOrganizzazione_Nazione END AS [CedentePrestatore/StabileOrganizzazione/Nazione],
			--FEH.CedentePrestatore_HasIscrizioneREA AS [CedentePrestatore/HasIscrizioneREA],
			CASE WHEN (FEH.CedentePrestatore_HasIscrizioneREA = CAST(0 AS BIT) OR FEH.CedentePrestatore_IscrizioneREA_Ufficio = N'') THEN NULL ELSE FEH.CedentePrestatore_IscrizioneREA_Ufficio END AS [CedentePrestatore/IscrizioneREA/Ufficio],
			CASE WHEN (FEH.CedentePrestatore_HasIscrizioneREA = CAST(0 AS BIT) OR FEH.CedentePrestatore_IscrizioneREA_NumeroREA = N'') THEN NULL ELSE FEH.CedentePrestatore_IscrizioneREA_NumeroREA END AS [CedentePrestatore/IscrizioneREA/NumeroREA],
			CASE WHEN (FEH.CedentePrestatore_HasIscrizioneREA = CAST(0 AS BIT) OR FEH.CedentePrestatore_IscrizioneREA_CapitaleSociale = N'') THEN NULL ELSE FEH.CedentePrestatore_IscrizioneREA_CapitaleSociale END AS [CedentePrestatore/IscrizioneREA/CapitaleSociale],
			CASE WHEN (FEH.CedentePrestatore_HasIscrizioneREA = CAST(0 AS BIT) OR FEH.CedentePrestatore_IscrizioneREA_SocioUnico = N'') THEN NULL ELSE FEH.CedentePrestatore_IscrizioneREA_SocioUnico END AS [CedentePrestatore/IscrizioneREA/SocioUnico],
			CASE WHEN (FEH.CedentePrestatore_HasIscrizioneREA = CAST(0 AS BIT) OR FEH.CedentePrestatore_IscrizioneREA_StatoLiquidazione = N'') THEN NULL ELSE FEH.CedentePrestatore_IscrizioneREA_StatoLiquidazione END AS [CedentePrestatore/IscrizioneREA/StatoLiquidazione],
			--FEH.CedentePrestatore_HasContatti AS [CedentePrestatore/HasContatti],
			CASE WHEN (FEH.CedentePrestatore_HasContatti = CAST(0 AS BIT) OR FEH.CedentePrestatore_Contatti_Telefono = N'') THEN NULL ELSE FEH.CedentePrestatore_Contatti_Telefono END AS [CedentePrestatore/Contatti/Telefono],
			CASE WHEN (FEH.CedentePrestatore_HasContatti = CAST(0 AS BIT) OR FEH.CedentePrestatore_Contatti_Fax = N'') THEN NULL ELSE FEH.CedentePrestatore_Contatti_Fax END AS [CedentePrestatore/Contatti/Fax],
			CASE WHEN (FEH.CedentePrestatore_HasContatti = CAST(0 AS BIT) OR FEH.CedentePrestatore_Contatti_Email = N'') THEN NULL ELSE FEH.CedentePrestatore_Contatti_Email END AS [CedentePrestatore/Contatti/Email],
			CASE WHEN FEH.CedentePrestatore_RiferimentoAmministrazione = N'' THEN NULL ELSE FEH.CedentePrestatore_RiferimentoAmministrazione END AS [CedentePrestatore/RiferimentoAmministrazione],

			--FEH.HasRappresentanteFiscale AS [HasRappresentanteFiscale],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese END AS [RappresentanteFiscale/DatiAnagrafici/IdFiscaleIVA/IdPaese],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice END AS [RappresentanteFiscale/DatiAnagrafici/IdFiscaleIVA/IdCodice],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_CodiceFiscale = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_CodiceFiscale END AS [RappresentanteFiscale/DatiAnagrafici/CodiceFiscale],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione END AS [RappresentanteFiscale/DatiAnagrafici/Anagrafica/Denominazione],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome END AS [RappresentanteFiscale/DatiAnagrafici/Anagrafica/Nome],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome END AS [RappresentanteFiscale/DatiAnagrafici/Anagrafica/Cognome],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo END AS [RappresentanteFiscale/DatiAnagrafici/Anagrafica/Titolo],
			CASE WHEN (FEH.HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI = N'') THEN NULL ELSE FEH.RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI END AS [RappresentanteFiscale/DatiAnagrafici/Anagrafica/CodEORI],

			--FEH.CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA AS [CessionarioCommittente/DatiAnagrafici/HasIdFiscaleIVA],
			CASE WHEN (FEH.CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA = CAST(0 AS BIT) OR FEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese = N'') THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese END AS [CessionarioCommittente/DatiAnagrafici/IdFiscaleIVA/IdPaese],
			CASE WHEN (FEH.CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA = CAST(0 AS BIT) OR FEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice = N'') THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice END AS [CessionarioCommittente/DatiAnagrafici/IdFiscaleIVA/IdCodice],
			CASE WHEN FEH.CessionarioCommittente_DatiAnagrafici_CodiceFiscale = N'' THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_CodiceFiscale END AS [CessionarioCommittente/DatiAnagrafici/CodiceFiscale],
			CASE WHEN FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione = N'' THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione END AS [CessionarioCommittente/DatiAnagrafici/Anagrafica/Denominazione],
			CASE WHEN FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome = N'' THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome END AS [CessionarioCommittente/DatiAnagrafici/Anagrafica/Nome],
			CASE WHEN FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome = N'' THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome END AS [CessionarioCommittente/DatiAnagrafici/Anagrafica/Cognome],
			CASE WHEN FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo = N'' THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo END AS [CessionarioCommittente/DatiAnagrafici/Anagrafica/Titolo],
			CASE WHEN FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI = N'' THEN NULL ELSE FEH.CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI END AS [CessionarioCommittente/DatiAnagrafici/Anagrafica/CodEORI],
			FEH.CessionarioCommittente_Sede_Indirizzo AS [CessionarioCommittente/Sede/Indirizzo],
			CASE WHEN FEH.CessionarioCommittente_Sede_NumeroCivico = N'' THEN NULL ELSE FEH.CessionarioCommittente_Sede_NumeroCivico END AS [CessionarioCommittente/Sede/NumeroCivico],
			FEH.CessionarioCommittente_Sede_CAP AS [CessionarioCommittente/Sede/CAP],
			FEH.CessionarioCommittente_Sede_Comune AS [CessionarioCommittente/Sede/Comune],
			CASE WHEN FEH.CessionarioCommittente_Sede_Nazione = N'IT' AND LEN(LTRIM(RTRIM(COALESCE(FEH.CessionarioCommittente_Sede_Provincia, N'')))) = 2 THEN FEH.CessionarioCommittente_Sede_Provincia ELSE NULL END AS [CessionarioCommittente/Sede/Provincia],
			FEH.CessionarioCommittente_Sede_Nazione AS [CessionarioCommittente/Sede/Nazione],
			--FEH.CessionarioCommittente_HasStabileOrganizzazione AS [CessionarioCommittente/HasStabileOrganizzazione],
			CASE WHEN (FEH.CessionarioCommittente_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CessionarioCommittente_StabileOrganizzazione_Indirizzo = N'') THEN NULL ELSE FEH.CessionarioCommittente_StabileOrganizzazione_Indirizzo END AS [CessionarioCommittente/StabileOrganizzazione/Indirizzo],
			CASE WHEN (FEH.CessionarioCommittente_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CessionarioCommittente_StabileOrganizzazione_NumeroCivico = N'') THEN NULL ELSE FEH.CessionarioCommittente_StabileOrganizzazione_NumeroCivico END AS [CessionarioCommittente/StabileOrganizzazione/NumeroCivico],
			CASE WHEN (FEH.CessionarioCommittente_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CessionarioCommittente_StabileOrganizzazione_CAP = N'') THEN NULL ELSE FEH.CessionarioCommittente_StabileOrganizzazione_CAP END AS [CessionarioCommittente/StabileOrganizzazione/CAP],
			CASE WHEN (FEH.CessionarioCommittente_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CessionarioCommittente_StabileOrganizzazione_Comune = N'') THEN NULL ELSE FEH.CessionarioCommittente_StabileOrganizzazione_Comune END AS [CessionarioCommittente/StabileOrganizzazione/Comune],
			CASE WHEN (FEH.CessionarioCommittente_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CessionarioCommittente_StabileOrganizzazione_Provincia = N'') THEN NULL ELSE FEH.CessionarioCommittente_StabileOrganizzazione_Provincia END AS [CessionarioCommittente/StabileOrganizzazione/Provincia],
			CASE WHEN (FEH.CessionarioCommittente_HasStabileOrganizzazione = CAST(0 AS BIT) OR FEH.CessionarioCommittente_StabileOrganizzazione_Nazione = N'') THEN NULL ELSE FEH.CessionarioCommittente_StabileOrganizzazione_Nazione END AS [CessionarioCommittente/StabileOrganizzazione/Nazione],
			--FEH.CessionarioCommittente_HasRappresentanteFiscale AS [CessionarioCommittente/HasRappresentanteFiscale],
			CASE WHEN (FEH.CessionarioCommittente_HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese = N'') THEN NULL ELSE FEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese END AS [CessionarioCommittente/RappresentanteFiscale/IdFiscaleIVA/IdPaese],
			CASE WHEN (FEH.CessionarioCommittente_HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice = N'') THEN NULL ELSE FEH.CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice END AS [CessionarioCommittente/RappresentanteFiscale/IdFiscaleIVA/IdCodice],
			CASE WHEN (FEH.CessionarioCommittente_HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.CessionarioCommittente_RappresentanteFiscale_Denominazione = N'') THEN NULL ELSE FEH.CessionarioCommittente_RappresentanteFiscale_Denominazione END AS [CessionarioCommittente/RappresentanteFiscale/Denominazione],
			CASE WHEN (FEH.CessionarioCommittente_HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.CessionarioCommittente_RappresentanteFiscale_Nome = N'') THEN NULL ELSE FEH.CessionarioCommittente_RappresentanteFiscale_Nome END AS [CessionarioCommittente/RappresentanteFiscale/Nome],
			CASE WHEN (FEH.CessionarioCommittente_HasRappresentanteFiscale = CAST(0 AS BIT) OR FEH.CessionarioCommittente_RappresentanteFiscale_Cognome = N'') THEN NULL ELSE FEH.CessionarioCommittente_RappresentanteFiscale_Cognome END AS [CessionarioCommittente/RappresentanteFiscale/Cognome],

			--FEH.HasTerzoIntermediarioOSoggettoEmittente AS [HasTerzoIntermediarioOSoggettoEmittente],
			--FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/HasIdFiscaleIVA],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/IdFiscaleIVA/IdPaese],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/IdFiscaleIVA/IdCodice],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/CodiceFiscale],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/Anagrafica/Denominazione],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/Anagrafica/Nome],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/Anagrafica/Cognome],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/Anagrafica/Titolo],
			CASE WHEN (FEH.HasTerzoIntermediarioOSoggettoEmittente = CAST(0 AS BIT) OR FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI = N'') THEN NULL ELSE FEH.TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI END AS [TerzoIntermediarioOSoggettoEmittente/DatiAnagrafici/Anagrafica/CodEORI],

			CASE WHEN FEH.SoggettoEmittente = N'' THEN NULL ELSE FEH.SoggettoEmittente END AS [SoggettoEmittente]

		FROM XMLFatture.FatturaElettronicaHeader FEH
		WHERE FEH.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
		FOR XML PATH ('FatturaElettronicaHeader')
	);

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_GeneraXMLFatturaBody
 * @description Generazione file XML fattura convalidata - Body (procedura di sistema)

 * @input_param @FatturaElettronicaHeader
 * @input_param @PKEvento

 * @output_param @PKEsitoEvento
 * @output_param @XMLOutput
*/

IF OBJECT_ID(N'XMLFatture.ssp_GeneraXMLFatturaBody', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_GeneraXMLFatturaBody AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_GeneraXMLFatturaBody (
	@PKFatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@XMLOutput XML OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	SET @XMLOutput = (
		SELECT
            FEB.DatiGenerali_DatiGeneraliDocumento_TipoDocumento AS [DatiGenerali/DatiGeneraliDocumento/TipoDocumento],
            FEB.DatiGenerali_DatiGeneraliDocumento_Divisa AS [DatiGenerali/DatiGeneraliDocumento/Divisa],
            FEB.DatiGenerali_DatiGeneraliDocumento_Data AS [DatiGenerali/DatiGeneraliDocumento/Data],
            FEB.DatiGenerali_DatiGeneraliDocumento_Numero AS [DatiGenerali/DatiGeneraliDocumento/Numero],

            --FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta,
            CASE WHEN (FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta END AS [DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/TipoRitenuta],
            CASE WHEN (FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta END AS [DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/ImportoRitenuta],
            CASE WHEN (FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta END AS [DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/AliquotaRitenuta],
            CASE WHEN (FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento END AS [DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/CausalePagamento],

            --FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiBollo,
            CASE WHEN (FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiBollo = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale END AS [DatiGenerali/DatiGeneraliDocumento/DatiBollo/BolloVirtuale],
            CASE WHEN (FEB.DatiGenerali_DatiGeneraliDocumento_HasDatiBollo = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo END AS [DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo],
			
			-- DatiCassaPrevidenziale
			(
				SELECT
                    DCP.TipoCassa,
                    DCP.AlCassa,
                    DCP.ImportoContributoCassa,
                    DCP.ImponibileCassa,
                    DCP.AliquotaIVA,
                    CASE WHEN (DCP.Ritenuta = '') THEN NULL ELSE DCP.Ritenuta END AS Ritenuta,
                    CASE WHEN (DCP.Natura = '') THEN NULL ELSE DCP.Natura END AS Natura,
                    DCP.RiferimentoAmministrazione

				FROM XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale DCP
				WHERE DCP.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
				FOR XML PATH (''), TYPE
			) AS [DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale],

			-- ScontoMaggiorazione
			(
				SELECT
                    DSM.Tipo,
                    DSM.Percentuale,
                    DSM.Importo

				FROM XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione DSM
				WHERE DSM.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
				FOR XML PATH (''), TYPE
			) AS [DatiGenerali/DatiGeneraliDocumento/ScontoMaggiorazione],

            FEB.DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento AS [DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento],
            FEB.DatiGenerali_DatiGeneraliDocumento_Arrotondamento AS [DatiGenerali/DatiGeneraliDocumento/Arrotondamento],

			-- Causale
			(
				SELECT
					C.DatiGenerali_Causale AS [Causale]
			
				FROM XMLFatture.FatturaElettronicaBody_Causale C
				----INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKFatturaElettronicaBody = FEBC.PKFatturaElettronicaBody
				----	AND FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
				WHERE C.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
				FOR XML PATH(''), TYPE
			) AS [DatiGenerali/DatiGeneraliDocumento],

            CASE WHEN (COALESCE(FEB.DatiGenerali_DatiGeneraliDocumento_Art73, '') = '') THEN NULL ELSE FEB.DatiGenerali_DatiGeneraliDocumento_Art73 END AS [DatiGenerali/DatiGeneraliDocumento/Art73],

			-- DocumentoEsterno
			(
				SELECT
					-- DocumentoEsterno_RiferimentoNumeroLinea
					(
						SELECT
                            DERNL.RiferimentoNumeroLinea

						FROM XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea DERNL
						----INNER JOIN XMLFatture.FatturaElettronicaBody_DatiDDT DDDT ON DDDT.PKFatturaElettronicaBody_DatiDDT = DDDTRNL.PKFatturaElettronicaBody_DatiDDT
						----	AND DDDT.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
						WHERE DERNL.PKFatturaElettronicaBody_DocumentoEsterno = DEOACQ.PKFatturaElettronicaBody_DocumentoEsterno
                        ORDER BY DERNL.RiferimentoNumeroLinea
						FOR XML PATH (''), TYPE
					),
                    DEOACQ.IdDocumento,
					DEOACQ.Data,
					DEOACQ.CodiceCUP,
					DEOACQ.CodiceCIG

				FROM XMLFatture.FatturaElettronicaBody_DocumentoEsterno DEOACQ

				WHERE DEOACQ.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
					AND DEOACQ.TipoDocumentoEsterno = 'OACQ'
				FOR XML PATH ('DatiOrdineAcquisto'), TYPE
			) AS [DatiGenerali],

            -- FattureCollegate
            (
                SELECT
                    DEFFOR.IdDocumento,
                    DEFFOR.Data
            
                FROM XMLFatture.FatturaElettronicaBody_DocumentoEsterno DEFFOR
            
                WHERE DEFFOR.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
                    AND DEFFOR.TipoDocumentoEsterno = 'FTCL'
                FOR XML PATH ('DatiFattureCollegate'), TYPE
            ) AS [DatiGenerali],

			--N'%TODO%' AS [DatiGenerali/DatiSAL],

			-- DatiDDT
			(
				SELECT
                    DDDT.NumeroDDT,
                    DDDT.DataDDT,

					-- DatiDDT_RiferimentoNumeroLinea
					(
						SELECT
                            DDDTRNL.RiferimentoNumeroLinea

						FROM XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea DDDTRNL
						----INNER JOIN XMLFatture.FatturaElettronicaBody_DatiDDT DDDT ON DDDT.PKFatturaElettronicaBody_DatiDDT = DDDTRNL.PKFatturaElettronicaBody_DatiDDT
						----	AND DDDT.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
						WHERE DDDTRNL.PKFatturaElettronicaBody_DatiDDT = DDDT.PKFatturaElettronicaBody_DatiDDT
                        ORDER BY DDDTRNL.RiferimentoNumeroLinea
						FOR XML PATH (''), TYPE
					)

				FROM XMLFatture.FatturaElettronicaBody_DatiDDT DDDT
				----INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKFatturaElettronicaBody = DDDT.PKFatturaElettronicaBody
				----	AND FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
				WHERE DDDT.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
				FOR XML PATH ('DatiDDT'), TYPE
			) AS [DatiGenerali],

            --FEB.DatiGenerali_HasDatiTrasporto,
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/IdFiscaleIVA/IdPaese],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/IdFiscaleIVA/IdCodice],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/CodiceFiscale],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/Anagrafica/Denominazione],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/Anagrafica/Nome],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/Anagrafica/Cognome],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/Anagrafica/Titolo],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/Anagrafica/CodEORI],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida END AS [DatiGenerali/DatiTrasporto/DatiAnagraficiVettore/NumeroLicenzaGuida],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_MezzoTrasporto, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_MezzoTrasporto END AS [DatiGenerali/DatiTrasporto/MezzoTrasporto],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_CausaleTrasporto, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_CausaleTrasporto END AS [DatiGenerali/DatiTrasporto/CausaleTrasporto],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_NumeroColli, 0) = 0) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_NumeroColli END AS [DatiGenerali/DatiTrasporto/NumeroColli],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_Descrizione, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_Descrizione END AS [DatiGenerali/DatiTrasporto/Descrizione],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_UnitaMisuraPeso, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_UnitaMisuraPeso END AS [DatiGenerali/DatiTrasporto/UnitaMisuraPeso],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_PesoLordo, 0.0) = 0.0) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_PesoLordo END AS [DatiGenerali/DatiTrasporto/PesoLordo],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_PesoNetto, 0.0) = 0.0) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_PesoNetto END AS [DatiGenerali/DatiTrasporto/PesoNetto],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DataOraRitiro END AS [DatiGenerali/DatiTrasporto/DataOraRitiro],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DataInizioTrasporto END AS [DatiGenerali/DatiTrasporto/DataInizioTrasporto],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR COALESCE (FEB.DatiGenerali_DatiTrasporto_TipoResa, N'') = N'') THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_TipoResa END AS [DatiGenerali/DatiTrasporto/TipoResa],
            --FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa,
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo END AS [DatiGenerali/DatiTrasporto/IndirizzoResa/Indirizzo],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico END AS [DatiGenerali/DatiTrasporto/IndirizzoResa/NumeroCivico],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_IndirizzoResa_CAP END AS [DatiGenerali/DatiTrasporto/IndirizzoResa/CAP],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_IndirizzoResa_Comune END AS [DatiGenerali/DatiTrasporto/IndirizzoResa/Comune],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia END AS [DatiGenerali/DatiTrasporto/IndirizzoResa/Provincia],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT) OR FEB.DatiGenerali_DatiTrasporto_HasIndirizzoResa = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione END AS [DatiGenerali/DatiTrasporto/IndirizzoResa/Nazione],
            CASE WHEN (FEB.DatiGenerali_HasDatiTrasporto = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_DatiTrasporto_DataOraConsegna END AS [DatiGenerali/DatiTrasporto/DataOraConsegna],

            --FEB.DatiGenerali_HasFatturaPrincipale,
            CASE WHEN (FEB.DatiGenerali_HasFatturaPrincipale = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale END AS [DatiGenerali/FatturaPrincipale/NumeroFatturaPrincipale],
            CASE WHEN (FEB.DatiGenerali_HasFatturaPrincipale = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiGenerali_FatturaPrincipale_DataFatturaPrincipale END AS [DatiGenerali/FatturaPrincipale/DataFatturaPrincipale],

			(
				SELECT
				-- DettaglioLinee
				(
					SELECT
						DL.NumeroLinea,
						CASE WHEN (DL.TipoCessionePrestazione = '') THEN NULL ELSE DL.TipoCessionePrestazione END AS TipoCessionePrestazione,

						-- DettaglioLinee_CodiceArticolo
						(
							SELECT
								CA.CodiceArticolo_CodiceTipo AS [CodiceTipo],
								CA.CodiceArticolo_CodiceValore AS [CodiceValore]

							FROM XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo CA
							WHERE CA.PKFatturaElettronicaBody_DettaglioLinee = DL.PKFatturaElettronicaBody_DettaglioLinee
							FOR XML PATH('CodiceArticolo'), TYPE
						),

						DL.Descrizione,
						DL.Quantita,
						CASE WHEN COALESCE(DL.UnitaMisura, N'') = N'' THEN NULL ELSE DL.UnitaMisura END AS UnitaMisura,
						DL.DataInizioPeriodo,
						DL.DataFinePeriodo,
						DL.PrezzoUnitario,

						-- DettaglioLinee_ScontoMaggiorazione
						(
							SELECT
								SM.ScontoMaggiorazione_Tipo AS [Tipo],
								SM.ScontoMaggiorazione_Percentuale AS [Percentuale],
								SM.ScontoMaggiorazione_Importo AS [Importo]

							FROM XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione SM
							WHERE SM.PKFatturaElettronicaBody_DettaglioLinee = DL.PKFatturaElettronicaBody_DettaglioLinee
							FOR XML PATH('ScontoMaggiorazione'), TYPE
						),

						DL.PrezzoTotale,
						DL.AliquotaIVA,
						CASE WHEN DL.Ritenuta = '' THEN NULL ELSE DL.Ritenuta END AS Ritenuta,
						CASE WHEN DL.Natura = '' THEN NULL ELSE DL.Natura END AS Natura,
						DL.RiferimentoAmministrazione,

						-- DettaglioLinee_AltriDatiGestionali
						(
							SELECT
								SM.AltriDatiGestionali_TipoDato AS [TipoDato],
								SM.AltriDatiGestionali_RiferimentoTesto AS [RiferimentoTesto],
								SM.AltriDatiGestionali_RiferimentoNumero AS [RiferimentoNumero],
								SM.AltriDatiGestionali_RiferimentoData AS [RiferimentoData]

							FROM XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali SM
							WHERE SM.PKFatturaElettronicaBody_DettaglioLinee = DL.PKFatturaElettronicaBody_DettaglioLinee
							FOR XML PATH('AltriDatiGestionali'), TYPE
						)

					FROM XMLFatture.FatturaElettronicaBody_DettaglioLinee DL
					WHERE DL.PKFatturaElettronicaBody = FEB2.PKFatturaElettronicaBody
					FOR XML PATH ('DettaglioLinee'), TYPE
				),

				-- DatiRiepilogo
				(
					SELECT
                        DR.AliquotaIVA,
                        CASE WHEN DR.Natura = '' THEN NULL ELSE DR.Natura END AS Natura,
                        DR.SpeseAccessorie,
                        DR.Arrotondamento,
                        DR.ImponibileImporto,
                        DR.Imposta,
                        DR.EsigibilitaIVA,
                        DR.RiferimentoNormativo

					FROM XMLFatture.FatturaElettronicaBody_DatiRiepilogo DR
					WHERE DR.PKFatturaElettronicaBody = FEB2.PKFatturaElettronicaBody
					FOR XML PATH ('DatiRiepilogo'), TYPE
				)

				FROM XMLFatture.FatturaElettronicaBody FEB2
				WHERE FEB2.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
				FOR XML PATH (''), TYPE
			) AS [DatiBeniServizi],

            --FEB.DatiGenerali_HasDatiVeicoli,
			CASE WHEN (FEB.DatiGenerali_HasDatiVeicoli = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiVeicoli_Data END AS [DatiVeicoli/Data],
            CASE WHEN (FEB.DatiGenerali_HasDatiVeicoli = CAST(0 AS BIT)) THEN NULL ELSE FEB.DatiVeicoli_TotalePercorso END AS [DatiVeicoli/TotalePercorso],

			-- DatiPagamento
			(
				SELECT
                    DP.CondizioniPagamento,

					-- DatiPagamento_DettaglioPagamento
					(
						SELECT
                            DPDP.Beneficiario,
                            DPDP.ModalitaPagamento,
                            DPDP.DataRiferimentoTerminiPagamento,
                            DPDP.GiorniTerminiPagamento,
                            DPDP.DataScadenzaPagamento,
                            DPDP.ImportoPagamento,
                            DPDP.CodUfficioPostale,
                            DPDP.CognomeQuietanzante,
                            DPDP.NomeQuietanzante,
                            DPDP.CFQuietanzante,
                            DPDP.TitoloQuietanzante,
                            DPDP.IstitutoFinanziario,
                            CASE WHEN COALESCE(DPDP.IBAN, N'') = N'' THEN NULL ELSE DPDP.IBAN END AS IBAN,
                            CASE WHEN COALESCE(DPDP.ABI, 0) > 0 THEN RIGHT('00000' + CONVERT(NVARCHAR(5), DPDP.ABI), 5) ELSE NULL END AS ABI,
                            CASE WHEN COALESCE(DPDP.CAB, 0) > 0 THEN RIGHT('00000' + CONVERT(NVARCHAR(5), DPDP.CAB), 5) ELSE NULL END AS CAB,
                            CASE WHEN COALESCE(DPDP.BIC, N'') = N'' THEN NULL ELSE DPDP.BIC END AS BIC,
                            DPDP.ScontoPagamentoAnticipato,
                            DPDP.DataLimitePagamentoAnticipato,
                            DPDP.PenalitaPagamentiRitardati,
                            DPDP.DataDecorrenzaPenale,
                            DPDP.CodicePagamento

						FROM XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento DPDP
						WHERE DPDP.PKFatturaElettronicaBody_DatiPagamento = DP.PKFatturaElettronicaBody_DatiPagamento
						FOR XML PATH ('DettaglioPagamento'), TYPE
					)

				FROM XMLFatture.FatturaElettronicaBody_DatiPagamento DP
				WHERE DP.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
				FOR XML PATH (''), TYPE
			) AS [DatiPagamento],

			N'%ALLEGATI%' AS [Allegati]

		FROM XMLFatture.FatturaElettronicaHeader FEH
		INNER JOIN XMLFatture.FatturaElettronicaBody FEB ON FEB.PKFatturaElettronicaHeader = FEH.PKFatturaElettronicaHeader                                                                                                                                                                                                                    --AND CONVERT(INT, CURRENT_TIMESTAMP) < 43464
		WHERE FEH.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
		FOR XML PATH ('FatturaElettronicaBody')
	);

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_RestartSequences
 * @description Allineamento sequenze

*/

IF OBJECT_ID(N'XMLFatture.ssp_RestartSequences', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_RestartSequences AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_RestartSequences
AS
BEGIN

/* declare variables */
DECLARE @sequenceName sysname;
DECLARE @maxValue INT = 0;
DECLARE @sqlStatement NVARCHAR(4000);

DECLARE curSequence CURSOR FAST_FORWARD READ_ONLY FOR SELECT name FROM sys.sequences WHERE name NOT LIKE N'seq_Validazione%';

OPEN curSequence;

FETCH NEXT FROM curSequence INTO @sequenceName;

WHILE @@FETCH_STATUS = 0
BEGIN
    
    SET @sqlStatement = REPLACE(N'SELECT @maxValue = MAX(PK%TABLE_NAME%) FROM XMLFatture.%TABLE_NAME%;', N'%TABLE_NAME%', REPLACE(@sequenceName, N'seq_', N''));
    EXEC sp_executesql @stmt = @sqlStatement,
        @params = N'@maxValue INT OUTPUT',
        @maxValue = @maxValue OUTPUT;
    PRINT 'ALTER SEQUENCE XMLFatture.' + @sequenceName + ' RESTART WITH ' + CONVERT(NVARCHAR(10), @maxValue) + ';';

    FETCH NEXT FROM curSequence INTO @sequenceName;
END;

CLOSE curSequence;
DEALLOCATE curSequence;

END;
GO
