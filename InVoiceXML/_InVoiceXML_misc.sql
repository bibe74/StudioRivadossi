/* XMLCodifiche.CodiciErroreSDI: Inizio */

SELECT * FROM XMLCodifiche.CodiciErroreSDI ORDER BY IDCodiceErroreSDI;
GO

SELECT  N'00300' AS IDCodiceErroreSDI, N'1.1.1.2 <IdCodice> non valido' AS CodiceErroreSDI
UNION ALL SELECT  N'00428', N'1.1.3 <FormatoTrasmissione> con valore diverso da “FPA12” e “FPR12”'
UNION ALL SELECT  N'00427', N'1.1.4 <CodiceDestinatario> di 7 caratteri a fronte di 1.1.3 <FormatoTrasmissione> con valore “FPA12” o 1.1.4 <CodiceDestinatario> di 6 caratteri a fronte di 1.1.3 <FormatoTrasmissione> con valore “FPR12”'
UNION ALL SELECT  N'00311', N'1.1.4 <CodiceDestinatario> non valido'
UNION ALL SELECT  N'00312', N'1.1.4 <CodiceDestinatario> non attivo'
UNION ALL SELECT  N'00427', N'1.1.4 <CodiceDestinatario> di 7 caratteri a fronte di 1.1.3 <FormatoTrasmissione> con valore “FPA12” o 1.1.4 <CodiceDestinatario> di 6 caratteri a fronte di 1.1.3 <FormatoTrasmissione> con valore “FPR12”'
UNION ALL SELECT  N'00398', N'Codice Ufficio presente ed univocamente identificabile nell’anagrafica IPA di riferimento, in presenza di 1.1.4 <CodiceDestinatario> valorizzato con codice ufficio “Centrale”'
UNION ALL SELECT  N'00399', N'CodiceFiscale del CessionarioCommittente presente nell’anagrafica IPA di riferimento in presenza di 1.1.4 <CodiceDestinatario> valorizzato  a “999999”'
UNION ALL SELECT  N'00426', N'1.1.6 <PECDestinatario> non valorizzato a fronte di 1.1.4 <CodiceDestinatario> con valore 0000000, o 1.1.6 <PECDestinatario> valorizzato a fronte di 1.1.4 <Codice Destinatario> con valore diverso da 0000000'
UNION ALL SELECT  N'00301', N'1.2.1.1.2 <IdCodice> non valido'
UNION ALL SELECT  N'00302', N'1.2.1.2 <CodiceFiscale> non valido'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non sono valorizzati i campi <Nome> e <Cognome> seguenti
- è valorizzato ma lo sono pure i campi <Nome> e/o <Cognome> seguenti)'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00303', N'1.3.1.1.2 <IdCodice> o 1.4.4.1.2 <IdCodice> non valido'
UNION ALL SELECT  N'00304', N'1.3.1.2 <CodiceFiscale> non valido'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non sono valorizzati i campi <Nome> e <Cognome> seguenti
- è valorizzato ma lo sono pure i campi <Nome> e/o <Cognome> seguenti)'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00417', N'1.4.1.1 <IdFiscaleIVA> e 1.4.1.2 <CodiceFiscale> non valorizzati (almeno uno dei due deve essere valorizzato)'
UNION ALL SELECT  N'00305', N'1.4.1.1.2 <IdCodice> non valido'
UNION ALL SELECT  N'00417', N'1.4.1.1 <IdFiscaleIVA> e 1.4.1.2 <CodiceFiscale> non valorizzati (almeno uno dei due deve essere valorizzato)'
UNION ALL SELECT  N'00306', N'1.4.1.2 <CodiceFiscale> non valido'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non sono valorizzati i campi <Nome> e <Cognome> seguenti
- è valorizzato ma lo sono pure i campi <Nome> e/o <Cognome> seguenti)'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00303', N'1.3.1.1.2 <IdCodice> o 1.4.4.1.2 <IdCodice> non valido'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non sono valorizzati i campi <Nome> e <Cognome> seguenti
- è valorizzato ma lo sono pure i campi <Nome> e/o <Cognome> seguenti)'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente"'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non sono valorizzati i campi <Nome> e <Cognome> seguenti
- è valorizzato ma lo sono pure i campi <Nome> e/o <Cognome> seguenti)'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00403', N'1.1.1.3 <Data> successiva alla data di ricezione'
UNION ALL SELECT  N'00418', N'1.1.1.3 <Data> antecedente a 2.1.6.3 <Data>'
UNION ALL SELECT  N'00425', N'1.1.1.4 <Numero> non contenente caratteri numerici'
UNION ALL SELECT  N'00411', N'1.1.1.5 <DatiRitenuta> non presente a fronte di almeno un blocco 2.2.1 <DettaglioLinee> con 2.2.1.13 <Ritenuta> uguale a SI'
UNION ALL SELECT  N'00415', N'2.1.1.5 <DatiRitenuta> non presente a fronte di 2.1.1.7.6 <Ritenuta> uguale a SI'
UNION ALL SELECT  N'00424', N'2.2.1.12 <AliquotaIVA> o 2.2.2.1< AliquotaIVA> o 2.1.1.7.5 <AliquotaIVA> non indicata in termini percentuali'
UNION ALL SELECT  N'00415', N'2.1.1.5 <DatiRitenuta> non presente a fronte di 2.1.1.7.6 <Ritenuta> uguale a SI'
UNION ALL SELECT  N'00413', N'2.1.1.7.7 <Natura> non presente a fronte di 2.1.1.7.5 <AliquotaIVA> pari a zero'
UNION ALL SELECT  N'00414', N'1.1.1.7.7 <Natura> presente a fronte di 2.1.1.7.5 <Aliquota IVA> diversa da zero'
UNION ALL SELECT  N'00437', N'2.1.1.8.2 <Percentuale>  e  2.1.1.8.3 <Importo> non presenti a fronte di 2.1.1.8.1 <Tipo> valorizzato'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non sono valorizzati i campi <Nome> e <Cognome> seguenti
- è valorizzato ma lo sono pure i campi <Nome> e/o <Cognome> seguenti)'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00200', N'file non conforme al formato (l''errore viene rilevato nei casi in cui:
- non è valorizzato e non è valorizzato il campo <Denominazione> precedente
- è valorizzato ma lo è pure il campo <Denominazione> precedente'
UNION ALL SELECT  N'00438', N'2.2.1.10.2 <Percentuale>  e  2.2.1.10.3 <Importo> non presenti a fronte di 2.2.1.10.1 <Tipo> valorizzato'
UNION ALL SELECT  N'00423', N'1.2.1.11 <PrezzoTotale> non calcolato secondo le regole definite nelle specifiche tecniche'
UNION ALL SELECT  N'00424', N'1.2.1.12 <AliquotaIVA> o 2.2.2.1< AliquotaIVA> o 2.1.1.7.5 <AliquotaIVA> non indicata in termini percentuali'
UNION ALL SELECT  N'00411', N'2.1.1.5 <DatiRitenuta> non presente a fronte di almeno un blocco 2.2.1 <DettaglioLinee> con 2.2.1.13 <Ritenuta> uguale a SI'
UNION ALL SELECT  N'00400', N'1.2.1.14 < Natura> non presente a fronte di 2.2.1.12 <AliquotaIVA> pari a zero'
UNION ALL SELECT  N'00401', N'1.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero'
UNION ALL SELECT  N'00419', N'1.2.2 <DatiRiepilogo> non presente in corrispondenza di almeno un valore di 2.1.1.7.5 <AliquotaIVA> o 2.2.1.12 <AliquotaIVA>'
UNION ALL SELECT  N'00424', N'1.2.1.12 <AliquotaIVA> o 2.2.2.1< AliquotaIVA> o 2.1.1.7.5 <AliquotaIVA> non indicata in termini percentuali'
UNION ALL SELECT  N'00420', N'1.2.2.2 <Natura> con valore N6 (inversione contabile) a fronte di 2.2.2.7 <EsigibilitaIVA> uguale a  S (scissione pagamenti)'
UNION ALL SELECT  N'00429', N'1.2.2.2 < Natura> non presente a fronte di 2.2.2.1 <AliquotaIVA> pari a zero'
UNION ALL SELECT  N'00430', N'1.2.2.2 <Natura> presente a fronte di 2.2.2.1 <AliquotaIVA> diversa da zero'
UNION ALL SELECT  N'00422', N'1.2.2.5 <ImponibileImporto> non calcolato secondo le regole definite nelle specifiche tecniche'
UNION ALL SELECT  N'00421', N'1.2.2.6 <Imposta> non calcolato secondo le regole definite nelle specifiche tecniche'
UNION ALL SELECT  N'00420', N'1.2.2.2 <Natura> con valore N6 (inversione contabile) a fronte di 2.2.2.7 <EsigibilitaIVA> uguale a  S (scissione pagamenti)'
ORDER BY IDCodiceErroreSDI;
GO

/* XMLCodifiche.CodiciErroreSDI: Fine */

----/**
---- * @stored_procedure XMLFatture.usp_VerificaConvalidaFattura
---- * @description Verifica esistenza fattura già convalidata

---- * @input_parameters: @codiceNumerico, @codiceAlfanumerico
---- * @output_parameters: @PKEsitoEvento, @PKEvento, @PKLanding_Fattura
----*/

----CREATE OR ALTER PROCEDURE XMLFatture.usp_VerificaConvalidaFattura (
----	@codiceNumerico BIGINT = NULL,
----	@codiceAlfanumerico NVARCHAR(40) = NULL,
----	@PKEsitoEvento SMALLINT OUTPUT,
----	@PKEvento BIGINT OUTPUT,
----	@PKFatturaElettronicaHeader BIGINT OUTPUT
----)
----AS
----BEGIN
	
----	SET NOCOUNT ON;

----	DECLARE @sp_name sysname = OBJECT_NAME(@@PROCID);

----	EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = @sp_name,
----	                                             @codiceNumerico = @codiceNumerico,
----	                                             @codiceAlfanumerico = @codiceAlfanumerico,
----	                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,
----	                                             @PKEvento = @PKEvento OUTPUT;
	
----	IF (@PKEsitoEvento < 0)
----	BEGIN

----		SELECT
----			@PKFatturaElettronicaHeader = FEH.PKFatturaElettronicaHeader

----		FROM XMLFatture.FatturaElettronicaHeader FEH
----		INNER JOIN XMLFatture.Landing_Fattura LF ON LF.PKLanding_Fattura = FEH.PKLanding_Fattura
----			AND (
----				@codiceNumerico IS NULL
----				OR LF.ChiaveGestionale_CodiceNumerico = @codiceNumerico
----			)
----			AND (
----				@codiceAlfanumerico IS NULL
----				OR LF.ChiaveGestionale_CodiceAlfanumerico = @codiceAlfanumerico
----			);

----	END;

----END;
----GO

----DECLARE @PKEsitoEvento SMALLINT,
----        @PKEvento BIGINT,
----        @PKFatturaElettronicaHeader BIGINT;
----EXEC XMLFatture.usp_VerificaConvalidaFattura @codiceNumerico = NULL,                                          -- bigint
----                                             @codiceAlfanumerico = NULL,                                      -- nvarchar(40)
----                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,                                      -- smallint
----                                             @PKEvento = @PKEvento OUTPUT,                                    -- bigint
----                                             @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT -- bigint
----SELECT @PKEsitoEvento, @PKEvento, @PKFatturaElettronicaHeader;
----EXEC XMLAudit.ssp_LeggiLogEvento @PKEvento = @PKEvento,                              -- bigint
----								 @LivelloLog = 0                             -- tinyint
----GO

----DECLARE @PKEsitoEvento SMALLINT,
----        @PKEvento BIGINT,
----        @PKFatturaElettronicaHeader BIGINT;
----EXEC XMLFatture.usp_VerificaConvalidaFattura @codiceNumerico = 0,                                             -- bigint
----                                             @codiceAlfanumerico = NULL,                                      -- nvarchar(40)
----                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,                                      -- smallint
----                                             @PKEvento = @PKEvento OUTPUT,                                    -- bigint
----                                             @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT -- bigint
----SELECT @PKEsitoEvento, @PKEvento, @PKFatturaElettronicaHeader;
----EXEC XMLAudit.ssp_LeggiLogEvento @PKEvento = @PKEvento,                      -- bigint
----								 @LivelloLog = 0                             -- tinyint
----GO

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronica_Campi;
GO

SELECT
	T.name AS table_name,
	C.column_id,
	C.name AS column_name,
	TYPE_NAME(C.system_type_id) AS column_type,
	CAST(0 AS BIT) AS IsObbligatorio,
	CAST(NULL AS TINYINT) AS LunghezzaMassima

INTO XMLFatture.FatturaElettronica_Campi

FROM sys.columns C
INNER JOIN sys.tables T ON T.object_id = C.object_id
	AND T.name LIKE N'Staging%'
	AND T.schema_id = SCHEMA_ID('XMLFatture')
ORDER BY table_name,
	C.column_id;
GO

UPDATE XMLFatture.FatturaElettronica_Campi
SET IsObbligatorio = CAST(1 AS BIT)
WHERE table_name = N'Staging_FatturaElettronicaHeader'
	AND column_name IN (
		N'DatiTrasmissione_IdTrasmittente_IdPaese',
		N'DatiTrasmissione_IdTrasmittente_IdCodice',
		N'DatiTrasmissione_ProgressivoInvio',
		N'DatiTrasmissione_FormatoTrasmissione',
		N'DatiTrasmissione_CodiceDestinatario',
		N'DatiTrasmissione_PECDestinatario',
		N'CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese',
		N'CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice',
		N'CedentePrestatore_DatiAnagrafici_CodiceFiscale',
		N'CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione',
		N'CedentePrestatore_DatiAnagrafici_RegimeFiscale',
		N'CedentePrestatore_Sede_Indirizzo',
		N'CedentePrestatore_Sede_CAP',
		N'CedentePrestatore_Sede_Comune',
		N'CedentePrestatore_Sede_Provincia',
		N'CedentePrestatore_Sede_Nazione',
		N'RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese',
		N'RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice',
		N'RappresentanteFiscale_DatiAnagrafici_CodiceFiscale',
		N'RappresentanteFiscale_Anagrafica_Denominazione',
		N'CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese',
		N'CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice',
		N'CessionarioCommittente_DatiAnagrafici_CodiceFiscale',
		N'CessionarioCommittente_Anagrafica_Denominazione',
		N'CessionarioCommittente_Sede_Indirizzo',
		N'CessionarioCommittente_Sede_CAP',
		N'CessionarioCommittente_Sede_Comune',
		N'CessionarioCommittente_Sede_Provincia',
		N'CessionarioCommittente_Sede_Nazione'
	);
GO




CREATE OR ALTER FUNCTION XMLFatture.ufn_VerificaEsistenzaValiditaCampoTesto (
	@PKValidazione BIGINT,
	@PKStaging_FatturaElettronicaHeader BIGINT,
	@schema_name sysname,
	@table_name sysname,
	@column_name NVARCHAR(100),
	@isObbligatorio BIT = 0,
	@lunghezzaMassima TINYINT = NULL
)
RETURNS BIT
AS
BEGIN

	DECLARE @ret BIT = 1;
	DECLARE @Messaggio NVARCHAR(500);

	DECLARE @valore NVARCHAR(100);
	DECLARE @sql_statement NVARCHAR(1000) = N'SELECT TOP 1 @valore = T.%COLUMN_NAME% FROM %SCHEMA_NAME%.%TABLE_NAME% T WHERE T.PKStaging_FatturaElettronicaHeader = ' + CONVERT(NVARCHAR(10), @PKStaging_FatturaElettronicaHeader) + N';';

	SET @sql_statement = REPLACE(REPLACE(REPLACE(@sql_statement, N'%COLUMN_NAME%', @column_name), N'%SCHEMA_NAME%', @schema_name), N'%TABLE_NAME%', @table_name);

	EXEC @sql_statement;

	IF (@isObbligatorio = CAST(1 AS BIT))
	BEGIN

		IF (@valore IS NULL OR @valore = N'')
		BEGIN
			
			SET @ret = 0;
			SET @Messaggio = REPLACE(N'Campo %CAMPO% obbligatorio: validazione fallita', N'%CAMPO%', @valore);

			EXEC XMLFatture.ssp_ScriviLogEventoValidazione @PKValidazione = @PKValidazione,
			                                         @campo = @column_name,
			                                         @valoreTesto = @valore,
			                                         @valoreIntero = NULL,
			                                         @valoreDecimale = NULL,
			                                         @Messaggio = @Messaggio,
			                                         @LivelloLog = 4; -- 4: errore

		END;

	END;

	IF (@lunghezzaMassima IS NOT NULL)
	BEGIN

		IF (LEN(@valore) > @lunghezzaMassima)
		BEGIN
			
			SET @ret = 0;
			SET @Messaggio = REPLACE(REPLACE(N'Campo %CAMPO% eccedente la lunghezza massima (%LUNGHEZZA_MASSIMA%)', N'%CAMPO%', @valore), N'%LUNGHEZZA_MASSIMA%', CONVERT(NVARCHAR(10), @lunghezzaMassima));

			EXEC XMLFatture.ssp_ScriviLogEventoValidazione @PKValidazione = @PKValidazione,
			                                         @campo = @column_name,
			                                         @valoreTesto = @valore,
			                                         @valoreIntero = NULL,
			                                         @valoreDecimale = NULL,
			                                         @Messaggio = @Messaggio,
			                                         @LivelloLog = 4; -- 4: errore

		END;

	END;

	RETURN @ret;

END;
GO

DECLARE @PKValidazione BIGINT;
DECLARE @PKStaging_FatturaElettronicaHeader BIGINT = 26;
EXEC XMLAudit.ssp_GeneraValidazione @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader, -- bigint
                                      @PKValidazione = @PKValidazione OUTPUT   -- bigint

SELECT XMLFatture.ufn_VerificaEsistenzaValiditaCampoTesto(
	@PKValidazione,
	@PKStaging_FatturaElettronicaHeader,
	'XMLFatture',
	'Staging_FatturaElettronicaHeader',
	'DatiTrasmissione_IdTrasmittente_IdPaese',
	1,
	NULL
);

EXEC XMLAudit.usp_LeggiLogEventoValidazione @PKValidazione = @PKValidazione, -- bigint
                                      @LivelloLog = 0     -- tinyint
GO



	--------				SELECT
	--------					C.name,
	--------					TYPE_NAME(C.system_type_id) AS column_type

	--------				FROM sys.columns C
	--------				INNER JOIN sys.tables T ON T.object_id = C.object_id
	--------					AND T.name = N'Staging_FatturaElettronicaHeader'
	--------					AND T.schema_id = SCHEMA_ID('XMLFatture')
	--------				WHERE C.name IN (
	--------					N'DatiTrasmissione_IdTrasmittente_IdPaese',
	--------					N'DatiTrasmissione_IdTrasmittente_IdCodice',
	--------					N'DatiTrasmissione_ProgressivoInvio',
	--------					N'DatiTrasmissione_FormatoTrasmissione',
	--------					N'DatiTrasmissione_CodiceDestinatario',
	--------					N'DatiTrasmissione_PECDestinatario',
	--------					N'CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese',
	--------					N'CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice',
	--------					N'CedentePrestatore_DatiAnagrafici_CodiceFiscale',
	--------					N'CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione',
	--------					N'CedentePrestatore_DatiAnagrafici_RegimeFiscale',
	--------					N'CedentePrestatore_Sede_Indirizzo',
	--------					N'CedentePrestatore_Sede_CAP',
	--------					N'CedentePrestatore_Sede_Comune',
	--------					N'CedentePrestatore_Sede_Provincia',
	--------					N'CedentePrestatore_Sede_Nazione',
	--------					N'RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese',
	--------					N'RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice',
	--------					N'RappresentanteFiscale_DatiAnagrafici_CodiceFiscale',
	--------					N'RappresentanteFiscale_Anagrafica_Denominazione',
	--------					N'CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese',
	--------					N'CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice',
	--------					N'CessionarioCommittente_DatiAnagrafici_CodiceFiscale',
	--------					N'CessionarioCommittente_Anagrafica_Denominazione',
	--------					N'CessionarioCommittente_Sede_Indirizzo',
	--------					N'CessionarioCommittente_Sede_CAP',
	--------					N'CessionarioCommittente_Sede_Comune',
	--------					N'CessionarioCommittente_Sede_Provincia',
	--------					N'CessionarioCommittente_Sede_Nazione'
	--------				);

	--------				INSERT INTO XMLAudit.Validazione_Riga
	--------				(
	--------				    --PKValidazione_Riga,
	--------				    PKValidazione,
	--------				    Campo,
	--------				    ValoreTesto,
	--------				    ValoreIntero,
	--------				    ValoreDecimale,
	--------				    Messaggio,
	--------				    LivelloLog
	--------				)
	--------				-- Verifiche DatiTrasmissione_IdTrasmittente_IdPaese
	--------				SELECT
	--------					@PKValidazione,
	--------					N'DatiTrasmissione_IdTrasmittente_IdPaese' AS Campo,
	--------					SFEH.DatiTrasmissione_IdTrasmittente_IdPaese AS ValoreTesto,
	--------					NULL AS ValoreIntero,
	--------					NULL AS ValoreDecimale,
	--------					N'00300: 1.1.1.2 <IdCodice> non valido' AS Messaggio,
	--------					4 AS LivelloLog

	--------				FROM XMLFatture.Staging_FatturaElettronicaHeader SFEH
	--------				LEFT JOIN XMLCodifiche.Nazione N ON N.IDNazione = SFEH.DatiTrasmissione_IdTrasmittente_IdPaese
	--------				WHERE SFEH.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
	--------					AND N.IDNazione IS NULL

/* procedure complete: Inizio */

--USE FatturaXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

-- Verifica parametri fattura
DECLARE @PKEvento BIGINT,
        @PKEsitoEvento SMALLINT;
EXEC XMLFatture.ssp_VerificaParametriFattura @sp_name = NULL,             -- sysname
                                             @codiceNumerico = 0,      -- bigint
                                             @codiceAlfanumerico = NULL,  -- nvarchar(40)
                                             @PKEvento = @PKEvento OUTPUT, -- bigint
                                             @PKEsitoEvento = @PKEsitoEvento OUTPUT  -- smallint

SELECT @PKEvento AS PKEvento, @PKEsitoEvento AS PKEsitoEvento;

EXEC XMLAudit.usp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint
GO

-- Importazione fattura
DECLARE @PKEvento BIGINT,
        @PKEsitoEvento SMALLINT,
        @PKLanding_Fattura BIGINT;
EXEC XMLFatture.usp_ImportaFattura --@codiceNumerico = 0,                                             -- bigint
                                   @codiceAlfanumerico = N'046D990E-0D55-4075-8D08-001B657EFF7E',                     -- nvarchar(40)
                                   @PKEvento = @PKEvento OUTPUT,                  -- bigint
                                   @PKEsitoEvento = @PKEsitoEvento OUTPUT,                    -- smallint
                                   @PKLanding_Fattura = @PKLanding_Fattura OUTPUT -- bigint

SELECT @PKEvento AS PKEvento, @PKEsitoEvento AS PKEsitoEvento, @PKLanding_Fattura AS PKLanding_Fattura;

EXEC XMLAudit.usp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint
GO

-- Convalida fattura
DECLARE @PKEvento BIGINT,
        @PKEsitoEvento SMALLINT,
		@IsValida BIT,
		@PKValidazione BIGINT,
        @PKStaging_FatturaElettronicaHeader BIGINT = 23,
        @PKFatturaElettronicaHeader BIGINT;
EXEC XMLFatture.usp_ConvalidaFattura --@codiceNumerico = 0,                                             -- bigint
                                     @codiceAlfanumerico = N'046D990E-0D55-4075-8D08-001B657EFF7E',                                       -- nvarchar(40)
                                     @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,                         -- bigint
                                     @PKEvento = @PKEvento OUTPUT,                                    -- bigint
                                     @PKEsitoEvento = @PKEsitoEvento OUTPUT,                                      -- smallint
									 @IsValida = @IsValida OUTPUT,
                                     @PKValidazione = @PKValidazione OUTPUT,                                    -- bigint
                                     @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT -- bigint

SELECT @PKEvento AS PKEvento, @PKEsitoEvento AS PKEsitoEvento, @IsValida AS IsValida, @PKValidazione AS PKValidazione, @PKFatturaElettronicaHeader AS PKFatturaElettronicaHeader;

EXEC XMLAudit.usp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint

EXEC XMLAudit.ssp_LeggiLogValidazione @PKValidazione = @PKValidazione, -- bigint
                                      @LivelloLog = 0     -- tinyint

SELECT * FROM XMLFatture.Staging_FatturaElettronicaHeader WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
SELECT * FROM XMLFatture.FatturaElettronicaHeader WHERE PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;
GO

-- Genera XML fattura
DECLARE @PKEvento BIGINT,
		@PKEsitoEvento SMALLINT,
        @PKFatturaElettronicaHeader BIGINT = 1,
		@XMLOutput XML;

EXEC XMLFatture.usp_GeneraXMLFattura --@codiceNumerico = 0,                     -- bigint
                                     @codiceAlfanumerico = N'046D990E-0D55-4075-8D08-001B657EFF7E',                                       -- nvarchar(40)
                                     @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,                         -- bigint
                                     @PKEvento = @PKEvento OUTPUT,           -- bigint
                                     @PKEsitoEvento = @PKEsitoEvento OUTPUT, -- smallint
                                     @XMLOutput = @XMLOutput OUTPUT                      -- text

SELECT @PKEvento AS PKEvento, @PKEsitoEvento AS PKEsitoEvento, @XMLOutput AS XMLOutput;

EXEC XMLAudit.usp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint
GO

/* procedure complete: Fine */
