USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

/**
 * @stored_procedure XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_Causale
 * @description Importazione diretta tabella 

 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @DatiGenerali_Causale

 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
 * @output_param @PKStaging_FatturaElettronicaBody_Causale
*/

IF OBJECT_ID(N'XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_Causale', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_Causale AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_Causale (
	@PKStaging_FatturaElettronicaHeader BIGINT,

    @DatiGenerali_Causale NVARCHAR(200) = NULL,

	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
    @PKStaging_FatturaElettronicaBody_Causale BIGINT OUTPUT
)
AS
BEGIN
    
    SET NOCOUNT ON;

	--DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	BEGIN TRANSACTION;

	SELECT @PKStaging_FatturaElettronicaBody_Causale = NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_Causale;

	EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
								@Messaggio = N'Recupero chiave per inserimento dati fattura (Staging_FatturaElettronicaBody_Causale)',
								@LivelloLog = 0; -- 0: trace

	BEGIN TRY

        INSERT INTO XMLFatture.Staging_FatturaElettronicaBody_Causale
        (
            PKStaging_FatturaElettronicaBody_Causale,
            PKStaging_FatturaElettronicaBody,
            DatiGenerali_Causale
        )
        SELECT
            @PKStaging_FatturaElettronicaBody_Causale,
            SFEB.PKStaging_FatturaElettronicaBody,
            @DatiGenerali_Causale

        FROM XMLFatture.Staging_FatturaElettronicaBody SFEB
        WHERE SFEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		COMMIT TRANSACTION;

		SET @PKEsitoEvento = 0; -- 0: Nessun errore
		SET @Messaggio = REPLACE('Inserimento record per dati fattura (Staging_FatturaElettronicaBody_Causale) (#%PKStaging_FatturaElettronicaHeader%) completato', N'%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

	END TRY
	BEGIN CATCH

		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

		SET @PKStaging_FatturaElettronicaBody_Causale = -1;

		SET @PKEsitoEvento = 212; -- 212: Eccezione in fase di inserimento XMLFatture.Staging_FatturaElettronicaBody*
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Errore in inserimento record per dati fattura (Staging_FatturaElettronicaBody_Causale)',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 0; -- 0: trace

	END CATCH

END;
GO

/**
 * @stored_procedure XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_DatiCassaPrevidenziale
 * @description Importazione diretta tabella 

 * @input_param @PKStaging_FatturaElettronicaHeader
 * @input_param @DatiGenerali_DatiCassaPrevidenziale

 * @output_param @PKEvento
 * @output_param @PKEsitoEvento
 * @output_param @PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale
*/

IF OBJECT_ID(N'XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_DatiCassaPrevidenziale', N'P') IS NULL EXEC('CREATE PROCEDURE XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_DatiCassaPrevidenziale AS RETURN 0;');
GO

ALTER PROCEDURE XMLFatture.ssp_ImportaDatiFatturaElettronicaBody_DatiCassaPrevidenziale (
	@PKStaging_FatturaElettronicaHeader BIGINT,

    @TipoCassa CHAR(4) = NULL,
    @AlCassa DECIMAL(5, 2) = NULL,
    @ImportoContributoCassa DECIMAL(14, 2) = NULL,
    @ImponibileCassa DECIMAL(14, 2) = NULL,
    @AliquotaIVA DECIMAL(5, 2) = NULL,
    @Ritenuta CHAR(2) = NULL,
    @Natura CHAR(2) = NULL,
    @RiferimentoAmministrazione NVARCHAR(20) = NULL,

	@PKEvento BIGINT OUTPUT,
	@PKEsitoEvento SMALLINT OUTPUT,
    @PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale BIGINT OUTPUT
)
AS
BEGIN
    
    SET NOCOUNT ON;

	--DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);
	DECLARE @Messaggio NVARCHAR(500);

	BEGIN TRANSACTION;

	SELECT @PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale = NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale;

	EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
								@Messaggio = N'Recupero chiave per inserimento dati fattura (Staging_FatturaElettronicaBody_DatiCassaPrevidenziale)',
								@LivelloLog = 0; -- 0: trace

	BEGIN TRY

        INSERT INTO XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale
        (
            PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale,
            PKStaging_FatturaElettronicaBody,
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
            @PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale,
            SFEB.PKStaging_FatturaElettronicaBody,
            @TipoCassa,
            @AlCassa,
            @ImportoContributoCassa,
            @ImponibileCassa,
            @AliquotaIVA,
            @Ritenuta,
            @Natura,
            @RiferimentoAmministrazione

        FROM XMLFatture.Staging_FatturaElettronicaBody SFEB
        WHERE SFEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

		COMMIT TRANSACTION;

		SET @PKEsitoEvento = 0; -- 0: Nessun errore
		SET @Messaggio = REPLACE('Inserimento record per dati fattura (Staging_FatturaElettronicaBody_DatiCassaPrevidenziale) (#%PKStaging_FatturaElettronicaHeader%) completato', N'%PKStaging_FatturaElettronicaHeader%', CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader));
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = @Messaggio,
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 2; -- 2: info

	END TRY
	BEGIN CATCH

		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;

		SET @PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale = -1;

		SET @PKEsitoEvento = 212; -- 212: Eccezione in fase di inserimento XMLFatture.Staging_FatturaElettronicaBody*
		EXEC XMLAudit.ssp_ScriviLogEvento @PKEvento = @PKEvento,
									@Messaggio = N'Errore in inserimento record per dati fattura (Staging_FatturaElettronicaBody_DatiCassaPrevidenziale)',
									@PKEsitoEvento = @PKEsitoEvento,
									@LivelloLog = 0; -- 0: trace

	END CATCH

END;
GO
