USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

/**
 * @stored_procedure XMLFatture.usp_ImportaFattura
 * @description Importazione fattura da gestionale

 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico

 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
 * @output_param @PKLanding_Fattura
*/

IF OBJECT_ID(N'XMLFatture.usp_ImportaFattura', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.usp_ImportaFattura AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.usp_ImportaFattura (
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@PKLanding_Fattura BIGINT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
	                                             @codiceNumerico = @codiceNumerico,
	                                             @codiceAlfanumerico = @codiceAlfanumerico,
	                                             @PKEvento = @PKEvento OUTPUT,
	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT;

	IF (@PKEsitoEvento < 0)
	BEGIN

		BEGIN TRANSACTION;

		SET @PKLanding_Fattura = NEXT VALUE FOR XMLFatture.seq_Landing_Fattura;

		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Recupero chiave per inserimento fattura',
									@LivelloLog = 0; -- 0: trace

		BEGIN TRY

			UPDATE XMLFatture.Landing_Fattura
			SET IsUltimaRevisione = CAST(0 AS BIT)
			WHERE ChiaveGestionale_CodiceNumerico = COALESCE(@codiceNumerico, -101)
				OR ChiaveGestionale_CodiceAlfanumerico = COALESCE(@codiceAlfanumerico, N'???');

			INSERT INTO XMLFatture.Landing_Fattura
			(
				PKLanding_Fattura,
				ChiaveGestionale_CodiceNumerico,
				ChiaveGestionale_CodiceAlfanumerico,
				IsUltimaRevisione
			)
			SELECT
				@PKLanding_Fattura AS PKLanding_Fattura,
				COALESCE(@codiceNumerico, 0) AS ChiaveGestionale_CodiceNumerico,
				COALESCE(@codiceAlfanumerico, N'') AS ChiaveGestionale_CodiceAlfanumerico,
				CAST(1 AS BIT) AS IsUltimaRevisione;

			COMMIT TRANSACTION;

			SET @PKEsitoEvento = 0; -- 0: Nessun errore
			SET @Messaggio = REPLACE('Inserimento fattura (#%PKLanding_Fattura%) completato', N'%PKLanding_Fattura%', CONVERT(NVARCHAR(10), @PKLanding_Fattura));
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = @Messaggio,
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 2; -- 2: info

		END TRY
		BEGIN CATCH

			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

			SET @PKLanding_Fattura = -1;

			SET @PKEsitoEvento = 103; -- 103: Eccezione in fase di inserimento XMLFatture.Landing_Fattura
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = N'Errore in inserimento fattura',
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 0; -- 0: trace

		END CATCH;

	END;

END;
GO

/**
 * @stored_procedure XMLFatture.usp_ImportaDatiFattura
 * @description Importazione dati fattura da gestionale

 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico
 * @input_param @PKLanding_Fattura
 
 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
 * @output_param @PKStaging_FatturaElettronicaHeader
*/

IF OBJECT_ID(N'XMLFatture.usp_ImportaDatiFattura', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.usp_ImportaDatiFattura AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.usp_ImportaDatiFattura (
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKLanding_Fattura BIGINT,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@PKStaging_FatturaElettronicaHeader BIGINT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
	                                             @codiceNumerico = @codiceNumerico,
	                                             @codiceAlfanumerico = @codiceAlfanumerico,
	                                             @PKEvento = @PKEvento OUTPUT,
	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT;

	SELECT @PKEsitoEvento AS PKEsitoEvento;

	IF (@PKEsitoEvento < 0)
	BEGIN

		BEGIN TRANSACTION;

		SELECT @PKStaging_FatturaElettronicaHeader = NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaHeader;

		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Recupero chiave per inserimento dati fattura',
									@LivelloLog = 0; -- 0: trace

		BEGIN TRY

			INSERT INTO XMLFatture.Staging_FatturaElettronicaHeader
			(
				PKStaging_FatturaElettronicaHeader,
				PKLanding_Fattura
			)
			SELECT
				@PKStaging_FatturaElettronicaHeader,
				F.PKLanding_Fattura

			FROM XMLFatture.Landing_Fattura F
			WHERE F.PKLanding_Fattura = @PKLanding_Fattura
			AND (
				F.ChiaveGestionale_CodiceNumerico = @codiceNumerico
				OR F.ChiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico
			);

			COMMIT TRANSACTION;

			SET @PKEsitoEvento = 0; -- 0: Nessun errore
			SET @Messaggio = REPLACE('Inserimento record per dati fattura (#%PKStaging_FatturaElettronicaHeader%) completato', N'%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader));
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = @Messaggio,
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 2; -- 2: info

		END TRY
		BEGIN CATCH

			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

			SET @PKLanding_Fattura = -1;

			SET @PKEsitoEvento = 203; -- 203: Eccezione in fase di inserimento XMLFatture.Staging_FatturaElettronicaHeader
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = N'Errore in inserimento record per dati fattura',
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 0; -- 0: trace

		END CATCH

	END;

END;
GO

/**
 * @stored_procedure XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_Causale
 * @description Importazione dati fattura da gestionale

 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico
 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @DatiGenerali_Causale
 
 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
*/

IF OBJECT_ID(N'XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_Causale', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_Causale AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_Causale (
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKStaging_FatturaElettronicaHeader BIGINT,
    @DatiGenerali_Causale NVARCHAR(200) = NULL,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
	                                             @codiceNumerico = @codiceNumerico,
	                                             @codiceAlfanumerico = @codiceAlfanumerico,
	                                             @PKEvento = @PKEvento OUTPUT,
	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT;

	SELECT @PKEsitoEvento AS PKEsitoEvento;

	IF (@PKEsitoEvento < 0)
	BEGIN

		BEGIN TRANSACTION;

		BEGIN TRY

            DECLARE @PKStaging_FatturaElettronicaBody BIGINT;

            SELECT @PKStaging_FatturaElettronicaBody = MAX(SFEB.PKStaging_FatturaElettronicaBody)
            FROM XMLFatture.Staging_FatturaElettronicaBody SFEB
            WHERE SFEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

            IF (
                @PKStaging_FatturaElettronicaBody IS NOT NULL
                AND (
                    @DatiGenerali_Causale IS NOT NULL
                )
            )
            BEGIN

                INSERT INTO XMLFatture.Staging_FatturaElettronicaBody_Causale
                (
                    --PKStaging_FatturaElettronicaBody_Causale,
                    PKStaging_FatturaElettronicaBody,
                    DatiGenerali_Causale
                )
                VALUES (
                    @PKStaging_FatturaElettronicaBody,
                    @DatiGenerali_Causale
                );
           

            END;

			COMMIT TRANSACTION;

			SET @PKEsitoEvento = 0; -- 0: Nessun errore
			SET @Messaggio = REPLACE('Inserimento dati Causale per fattura (#%PKStaging_FatturaElettronicaHeader%) completato', N'%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader));
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = @Messaggio,
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 2; -- 2: info

		END TRY
		BEGIN CATCH

			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

			SET @PKEsitoEvento = 212; -- 212: Eccezione in fase di inserimento XMLFatture.Staging_FatturaElettronicaBody*
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = N'Errore in inserimento dati Causale per fattura',
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 4; -- 4: error

		END CATCH

	END;

END;
GO

/**
 * @stored_procedure XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
 * @description Importazione dati fattura da gestionale

 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico
 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @SDI_NumeroLinea
 * @input_param @AltriDatiGestionali_TipoDato
 * @input_param @AltriDatiGestionali_RiferimentoTesto
 * @input_param @AltriDatiGestionali_RiferimentoNumero
 * @input_param @AltriDatiGestionali_RiferimentoData
 
 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
*/

IF OBJECT_ID(N'XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.usp_ImportaDatiFattura_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali (
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKStaging_FatturaElettronicaHeader BIGINT,
    @SDI_NumeroLinea INT,
    @AltriDatiGestionali_TipoDato NVARCHAR(10) = NULL,
    @AltriDatiGestionali_RiferimentoTesto NVARCHAR(60) = NULL,
    @AltriDatiGestionali_RiferimentoNumero DECIMAL(20, 5) = NULL,
    @AltriDatiGestionali_RiferimentoData DATE = NULL,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
	                                             @codiceNumerico = @codiceNumerico,
	                                             @codiceAlfanumerico = @codiceAlfanumerico,
	                                             @PKEvento = @PKEvento OUTPUT,
	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT;

	SELECT @PKEsitoEvento AS PKEsitoEvento;

	IF (@PKEsitoEvento < 0)
	BEGIN

		BEGIN TRANSACTION;

		BEGIN TRY

            DECLARE @PKStaging_FatturaElettronicaBody_DettaglioLinee BIGINT;

            SELECT @PKStaging_FatturaElettronicaBody_DettaglioLinee = MAX(SFEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee)
            FROM XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee SFEBDL
            INNER JOIN XMLFatture.Staging_FatturaElettronicaBody SFEB ON SFEB.PKStaging_FatturaElettronicaBody = SFEBDL.PKStaging_FatturaElettronicaBody
                AND SFEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
            WHERE SFEBDL.NumeroLinea = @SDI_NumeroLinea;

            IF (
                @PKStaging_FatturaElettronicaBody_DettaglioLinee IS NOT NULL
                AND (
                    @AltriDatiGestionali_TipoDato IS NOT NULL
                )
            )
            BEGIN

                INSERT INTO XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
                (
                    --PKStaging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali,
                    PKStaging_FatturaElettronicaBody_DettaglioLinee,
                    AltriDatiGestionali_TipoDato,
                    AltriDatiGestionali_RiferimentoTesto,
                    AltriDatiGestionali_RiferimentoNumero,
                    AltriDatiGestionali_RiferimentoData
                )
                VALUES (
                    @PKStaging_FatturaElettronicaBody_DettaglioLinee,
                    @AltriDatiGestionali_TipoDato,
                    @AltriDatiGestionali_RiferimentoTesto,
                    @AltriDatiGestionali_RiferimentoNumero,
                    @AltriDatiGestionali_RiferimentoData
                );

            END;

			COMMIT TRANSACTION;

			SET @PKEsitoEvento = 0; -- 0: Nessun errore
			SET @Messaggio = REPLACE(REPLACE('Inserimento AltriDatiGestionali per riga fattura (#%PKStaging_FatturaElettronicaHeader%/%SDI_NumeroLinea%) completato', N'%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader)), N'%SDI_NumeroLinea%', CONVERT(NVARCHAR(10), @SDI_NumeroLinea));
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = @Messaggio,
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 2; -- 2: info

		END TRY
		BEGIN CATCH

			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

			SET @PKEsitoEvento = 212; -- 212: Eccezione in fase di inserimento XMLFatture.Staging_FatturaElettronicaBody*
			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = N'Errore in inserimento AltriDatiGestionali per riga fattura',
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 4; -- 4: error

		END CATCH

	END;

END;
GO

/**
 * @stored_procedure XMLFatture.usp_ConvalidaFattura
 * @description Convalida dati fattura importata

 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico
 * @input_param @PKStaging_FatturaElettronicaHeader

 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
 * @output_param @IsValida
 * @output_param @PKValidazione
 * @output_param @PKFatturaElettronicaHeader
*/

IF OBJECT_ID(N'XMLFatture.usp_ConvalidaFattura', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.usp_ConvalidaFattura AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.usp_ConvalidaFattura (
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@IsValida BIT OUTPUT,
	@PKValidazione BIGINT OUTPUT,
	@PKFatturaElettronicaHeader BIGINT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);
	DECLARE @isUltimaRevisione_check BIT;
	DECLARE @PKStaging_FatturaElettronicaHeader_check BIGINT;

	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
	                                             @codiceNumerico = @codiceNumerico,
	                                             @codiceAlfanumerico = @codiceAlfanumerico,
	                                             @PKEvento = @PKEvento OUTPUT,
	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT;

	IF (@PKEsitoEvento < 0)
	BEGIN

		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Verifica parametri fattura: OK',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 0; -- 0: trace

		SELECT TOP 1
			@isUltimaRevisione_check = LF.IsUltimaRevisione

		FROM XMLFatture.Landing_Fattura LF
		WHERE (
			@codiceNumerico IS NULL
			OR LF.ChiaveGestionale_CodiceNumerico = @codiceNumerico
		)
		AND (
			@codiceAlfanumerico IS NULL
			OR LF.ChiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico
		)
		ORDER BY LF.PKLanding_Fattura DESC;

		IF (@isUltimaRevisione_check IS NULL)
		BEGIN

			SET @PKEsitoEvento = 304; -- 304: Fattura %CODICEFATTURA% non ancora trasmessa
			SELECT
				@Messaggio = REPLACE(E.Descrizione, N'%CODICEFATTURA%', COALESCE(@codiceAlfanumerico, N'#' + CONVERT(NVARCHAR(20), @codiceNumerico)))
			
			FROM XMLAudit.EsitoEvento E
			WHERE E.PKEsitoEvento = @PKEsitoEvento;

			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = @Messaggio,
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 4; -- 4: error

		END
		ELSE
		BEGIN

			EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
										@Messaggio = N'Verifica esistenza ultima revisione: OK',
										@PKEsitoEvento = @PKEsitoEvento,
										@LivelloLog = 0; -- 0: trace

			SELECT TOP 1
				@PKStaging_FatturaElettronicaHeader_check = SFEH.PKStaging_FatturaElettronicaHeader

			FROM XMLFatture.Landing_Fattura LF
			INNER JOIN XMLFatture.Staging_FatturaElettronicaHeader SFEH ON SFEH.PKLanding_Fattura = LF.PKLanding_Fattura
			WHERE (
				@codiceNumerico IS NULL
				OR LF.ChiaveGestionale_CodiceNumerico = @codiceNumerico
			)
			AND (
				@codiceAlfanumerico IS NULL
				OR LF.ChiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico
			)
			AND LF.IsUltimaRevisione = CAST(1 AS BIT)
			ORDER BY LF.PKLanding_Fattura DESC;

			IF (@PKStaging_FatturaElettronicaHeader_check IS NULL)
			BEGIN

				SET @PKEsitoEvento = 305; -- 305: Revisione mancante per la fattura %CODICEFATTURA%
				SELECT
					@Messaggio = REPLACE(E.Descrizione, N'%CODICEFATTURA%', COALESCE(@codiceAlfanumerico, N'#' + CONVERT(NVARCHAR(20), @codiceNumerico)))
			
				FROM XMLAudit.EsitoEvento E
				WHERE E.PKEsitoEvento = @PKEsitoEvento;

				EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
											@Messaggio = @Messaggio,
											@PKEsitoEvento = @PKEsitoEvento,
											@LivelloLog = 4; -- 4: error

			END
			ELSE
			BEGIN

				IF (@PKStaging_FatturaElettronicaHeader_check <> @PKStaging_FatturaElettronicaHeader)
				BEGIN

					SET @PKEsitoEvento = 306; -- 306: Revisione #%PKStaging_FatturaElettronicaHeader% errata per la fattura %CODICEFATTURA%
					SELECT
						@Messaggio = REPLACE(REPLACE(E.Descrizione, N'%CODICEFATTURA%', COALESCE(@codiceAlfanumerico, N'#' + CONVERT(NVARCHAR(20), @codiceNumerico))), N'%PKStaging_FatturaElettronicaHeader%', @PKStaging_FatturaElettronicaHeader)
			
					FROM XMLAudit.EsitoEvento E
					WHERE E.PKEsitoEvento = @PKEsitoEvento;

					EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
												@Messaggio = @Messaggio,
												@PKEsitoEvento = @PKEsitoEvento,
												@LivelloLog = 4; -- 4: error

				END
				ELSE
				BEGIN

					EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
												@Messaggio = N'Verifica validità ultima revisione: OK',
												@PKEsitoEvento = @PKEsitoEvento,
												@LivelloLog = 0; -- 0: trace

					EXEC XMLAudit.ssp_GeneraValidazione @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
					                                      @PKEvento = @PKEvento,
					                                      @PKValidazione = @PKValidazione OUTPUT;

					EXEC XMLAudit.ssp_ConvalidaFatturaHeader @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
						@PKValidazione = @PKValidazione;

					EXEC XMLAudit.ssp_ConvalidaFatturaBody @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
						@PKValidazione = @PKValidazione;

					----INSERT INTO XMLAudit.Validazione_Riga
					----(
					----	--PKValidazione_Riga,
					----	PKValidazione,
					----	Campo,
					----	Messaggio,
					----	LivelloLog
					----)
					----VALUES
					----(
					----	@PKValidazione,
					----	N'<togliere>',
					----	N'segnaposto per non verifica validazione',
					----	4
					----);

					DECLARE @MaxLivelloLog TINYINT;
					SELECT @MaxLivelloLog = MAX(LivelloLog) FROM XMLAudit.Validazione_Riga WHERE PKValidazione = @PKValidazione;

					SET @IsValida = CASE WHEN @MaxLivelloLog < 4 THEN 1 ELSE 0 END;

					IF (@IsValida = CAST(1 AS BIT))
					BEGIN

						UPDATE XMLAudit.Validazione SET PKStato = 2, IsValida = @IsValida WHERE PKValidazione = @PKValidazione;
						EXEC XMLAudit.ssp_ScriviLogValidazione @PKValidazione = @PKValidazione,
						                                       @campo = N'',
						                                       @Messaggio = N'Validazione completata con successo',
						                                       @LivelloLog = 2;

						EXEC XMLFatture.ssp_EsportaFattura @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
						                                   @PKEvento = @PKEvento,
						                                   @PKEsitoEvento = @PKEsitoEvento OUTPUT,
						                                   @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT;

						EXEC XMLAudit.ssp_ScriviLogValidazione @PKValidazione = @PKValidazione,
						                                       @campo = N'',
						                                       @Messaggio = N'Esportazione fattura completata con successo',
						                                       @LivelloLog = 2;

					END;
					ELSE
					BEGIN

						EXEC XMLAudit.ssp_ScriviLogValidazione @PKValidazione = @PKValidazione,
						                                       @campo = N'',
						                                       @Messaggio = N'Validazione completata con errori (verificare log validazione)',
						                                       @LivelloLog = 4;

					END;

					UPDATE XMLFatture.Staging_FatturaElettronicaHeader SET IsValida = @IsValida, DataOraUltimaValidazione = CURRENT_TIMESTAMP WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
					EXEC XMLAudit.ssp_ScriviLogValidazione @PKValidazione = @PKValidazione,
						                                    @campo = N'',
						                                    @Messaggio = N'Aggiornamento validità fattura completato con successo',
						                                    @LivelloLog = 2;

				END;

			END;

		END;

	END;

END;
GO

/**
 * @stored_procedure XMLFatture.usp_GeneraXMLFattura
 * @description Generazione file XML fattura convalidata

 * @input_param @codiceNumerico
 * @input_param @codiceAlfanumerico
 * @input_param @FatturaElettronicaHeader

 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
 * @output_param @XMLOutput
*/

IF OBJECT_ID(N'XMLFatture.usp_GeneraXMLFattura', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.usp_GeneraXMLFattura AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.usp_GeneraXMLFattura (
	@codiceNumerico BIGINT = NULL,
	@codiceAlfanumerico NVARCHAR(40) = NULL,
	@PKFatturaElettronicaHeader BIGINT,
	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
	@XMLOutput XML OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);
	DECLARE @XMLOutputHeader XML;
	DECLARE @XMLOutputBody XML;

	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
	                                             @codiceNumerico = @codiceNumerico,
	                                             @codiceAlfanumerico = @codiceAlfanumerico,
	                                             @PKEvento = @PKEvento OUTPUT,
	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT;

	IF (@PKEsitoEvento < 0)
	BEGIN

		EXEC XMLFatture.ssp_GeneraXMLFatturaHeader @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,
		                                           @PKEvento = @PKEvento,
		                                           @PKEsitoEvento = @PKEsitoEvento OUTPUT,
		                                           @XMLOutput = @XMLOutputHeader OUTPUT;
		
		IF (@PKEsitoEvento < 0)
		BEGIN

			EXEC XMLFatture.ssp_GeneraXMLFatturaBody @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,
												     @PKEvento = @PKEvento,
												     @PKEsitoEvento = @PKEsitoEvento OUTPUT,
												     @XMLOutput = @XMLOutputBody OUTPUT;
		
			SELECT @XMLOutputBody;

			IF (@PKEsitoEvento < 0)
			BEGIN

                DECLARE @FormatoTrasmissione CHAR(5);

                SELECT @FormatoTrasmissione = DatiTrasmissione_FormatoTrasmissione
                FROM XMLFatture.FatturaElettronicaHeader
                WHERE PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

				-- Versione "cruda" (non formalmente corretta)
				SET @XMLOutput = (SELECT @XMLOutputHeader, @XMLOutputBody FOR XML PATH ('FatturaElettronica'));

				-- Versione con namespaces
				WITH XMLNAMESPACES ('http://www.w3.org/2000/09/xmldsig#' AS ds, 'http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2' AS p, 'http://www.w3.org/2001/XMLSchema-instance' AS xsi)
				SELECT @XMLOutput = (SELECT @FormatoTrasmissione AS '@versione', @XMLOutputHeader, @XMLOutputBody FOR XML PATH ('p:FatturaElettronica'));

				-- Versione con namespaces e foglio di stile XSL
				SET @XMLOutput.modify('
    insert <?xml-stylesheet type="text/xsl" href="(File per visualizzazione fattura elettronica 1.2.1 - NON inviare).xsl"?>
    before /*[1]
')

				UPDATE XMLFatture.FatturaElettronicaHeader
				SET IsEsportata = CAST(1 AS BIT),
					DataOraUltimaEsportazione = CURRENT_TIMESTAMP,
					XMLOutput = @XMLOutput

				WHERE PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

				SET @Messaggio = REPLACE('Aggiornamento data ultima esportazione fattura (#%PKFatturaElettronicaHeader%) completata', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader));
				EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
											@Messaggio = @Messaggio,
											@PKEsitoEvento = @PKEsitoEvento,
											@LivelloLog = 2; -- 2: info

				SET @PKEsitoEvento = 0; -- 0: Nessun errore
				SET @Messaggio = REPLACE('Generazione XML fattura (#%PKFatturaElettronicaHeader%) completata', N'%PKFatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKFatturaElettronicaHeader));
				EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
											@Messaggio = @Messaggio,
											@PKEsitoEvento = @PKEsitoEvento,
											@LivelloLog = 2; -- 2: info

			END;

		END;

	END;

END;
GO
