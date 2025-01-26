USE InVoiceXML;
GO

--/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento WHERE PKFatturaElettronicaBody_DatiPagamento_DettaglioPagamento > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiPagamento WHERE PKFatturaElettronicaBody_DatiPagamento > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiRiepilogo WHERE PKFatturaElettronicaBody_DatiRiepilogo > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione WHERE PKFatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo WHERE PKFatturaElettronicaBody_DettaglioLinee_CodiceArticolo > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee WHERE PKFatturaElettronicaBody_DettaglioLinee > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea WHERE PKFatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiDDT WHERE PKFatturaElettronicaBody_DatiDDT > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea WHERE PKFatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DocumentoEsterno WHERE PKFatturaElettronicaBody_DocumentoEsterno > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_Causale WHERE PKFatturaElettronicaBody_Causale > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale WHERE PKFatturaElettronicaBody_DatiCassaPrevidenziale > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaBody WHERE PKFatturaElettronicaBody > 0;
DELETE FROM InVoiceXML.XMLFatture.FatturaElettronicaHeader WHERE PKFatturaElettronicaHeader > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento WHERE PKStaging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento WHERE PKStaging_FatturaElettronicaBody_DatiPagamento > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo WHERE PKStaging_FatturaElettronicaBody_DatiRiepilogo > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione WHERE PKStaging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo WHERE PKStaging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee WHERE PKStaging_FatturaElettronicaBody_DettaglioLinee > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea WHERE PKStaging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT WHERE PKStaging_FatturaElettronicaBody_DatiDDT > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea WHERE PKStaging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno WHERE PKStaging_FatturaElettronicaBody_DocumentoEsterno > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_Causale WHERE PKStaging_FatturaElettronicaBody_Causale > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale WHERE PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody WHERE PKStaging_FatturaElettronicaBody > 0;
DELETE FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaHeader WHERE PKStaging_FatturaElettronicaHeader > 0;
GO

SELECT
	D.ID,
	D.Data,
	D.Numero,
	D.IDCliFor,
	CF.Codice,
	CF.Intestazione,
	D.IDTipo,
	COUNT(1) AS NumeroRighe

FROM InVoiceMarianini.dbo.Documenti D
INNER JOIN InVoiceMarianini.dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
	AND DT.SDI_IsValido = CAST(1 AS BIT)
INNER JOIN InVoiceMarianini.dbo.Documenti_Righe DR ON DR.IDDocumento = D.ID
	AND DR.Qta IS NOT NULL
INNER JOIN InVoiceMarianini.dbo.CliFor CF ON CF.ID = D.IDCliFor
WHERE D.Data >= CAST('20180101' AS DATETIME)

	--AND D.Numero = N'39' -- FT 39/2018, Ieci srl
	--AND D.Numero = N'1R.A.' -- FT 1R.A./2018, ATENA  spa
	--AND D.Numero = N'19R.A.' -- FT 19R.A./2018, Scuola delle arti e della formazione professionale R.Vantini
	--AND D.NumeroInt = 27 -- FT 27/2019, BISICUR S.r.L.
	AND D.NumeroInt = 86 -- FT 27/2019, BISICUR S.r.L.

GROUP BY D.ID,
	D.Data,
	D.Numero,
	D.IDCliFor,
	CF.Codice,
	CF.Intestazione,
	D.IDTipo
ORDER BY D.Data, D.Numero;

SELECT
	D.ID,
	D.Data,
	D.Numero,
	D.IDCliFor,
	CF.Codice,
	CF.Intestazione,
	D.IDTipo,
	DR.ID,
    DR.IDDocumento,
    DR.IDArticolo,
    DR.IDFamiglia,
    DR.IDUnitaMisura,
    DR.IDDocumento_Origine,
    DR.IDDocumento_RigaOrigine,
    DR.IDStato,
    DR.Posizione,
    DR.Qta,
    DR.QtaEvasa,
    DR.Codice,
    DR.Descrizione1,
    DR.Descrizione2,
    DR.Descrizione3,
    DR.Descrizione4,
    DR.ImpUnitario,
    DR.ImpNetto,
    DR.Sconto,
    DR.ImpSconto,
    DR.ImpUnitarioScontato,
    DR.ImpNettoScontato,
    DR.CodIva,
    DR.ImpIva,
    DR.ImpLordo,
    DR.NoteRiga,
    DR.Lock_Delete,
    DR.Lock_Qta,
    DR.Lock_Codice,
    DR.Lock_Descrizione1,
    DR.Lock_Descrizione2,
    DR.Lock_Descrizione3,
    DR.Lock_Descrizione4,
    DR.Nascondi,
    DR.DisegnoNumero,
    DR.CommessaNumero,
    DR.CommessaDataConsegna,
    DR.IDPreventivoPrevio,
    DR.DdtEntrataNumero,
    DR.DdtEntrataData,
    DR.OrdCliNumero,
    DR.OrdCliData,
    DR.SDI_NumeroLinea

FROM InVoiceFrancesco.dbo.Documenti D
INNER JOIN InVoiceFrancesco.dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
	AND DT.SDI_IsValido = CAST(1 AS BIT)
INNER JOIN InVoiceFrancesco.dbo.Documenti_Righe DR ON DR.IDDocumento = D.ID
	AND DR.Qta IS NOT NULL
INNER JOIN InVoiceFrancesco.dbo.CliFor CF ON CF.ID = D.IDCliFor
WHERE D.Data >= CAST('20180101' AS DATETIME)

	--AND D.Numero = N'39' -- FT 39/2018, Ieci srl
	--AND D.Numero = N'1R.A.' -- FT 1R.A./2018, ATENA  spa
	AND D.IDTipo = N'Cli_NotaCredito'

ORDER BY D.Data, D.Numero, DR.SDI_NumeroLinea;

DECLARE @IDDocumento UNIQUEIDENTIFIER;
--SET @IDDocumento = '16667724-D889-4F5B-9EC9-7898F20115DA'; -- FT 28/2018, PEDROLLO SPA, 15 (o 17?) righe articolo, 2 DDT
--SET @IDDocumento = 'EC3C3072-B6B4-4D1D-95FF-89B634D80490'; -- FT 95/2018, PEDROLLO SPA, 3 righe articolo, 1 DDT
--SET @IDDocumento = '046D990E-0D55-4075-8D08-001B657EFF7E'; -- FT 153/2018, PEDROLLO SPA, 2 righe articolo, 1 DDT
--SET @IDDocumento = '2E3BB294-ECF4-4997-8A9E-3AD655F9CA40'; -- FT 39/2018, Ieci srl, 1 riga articolo, 1 DDT
--SET @IDDocumento = '06D905FE-3F05-430F-A0EC-E0F4F7F8B406'; -- FT 1R.A./2018, ATENA  spa, 1 righe articolo*
--SET @IDDocumento = '6491CAE6-DB13-4CFA-8880-BC9F0933605F'; -- FT 19R.A./2018, Scuola delle arti e della formazione professionale R.Vantini, 1 righe articolo*
--SET @IDDocumento = 'AC5AB69C-E290-44A2-879B-BC72A6989927'; -- NC 
--SET @IDDocumento = '1352EB83-171A-427F-A116-8FA78789370C';
--SET @IDDocumento = '80D3D3CF-AC52-4970-B30E-002250B1A255';
--SET @IDDocumento = '{52D0DFC9-BA35-4345-924C-14161C076E21}';
SET @IDDocumento = '{45478B47-6256-4AEA-91CF-A3267B311F3E}';

/*

SELECT * FROM InVoiceFrancesco.dbo.CliFor WHERE Codice = N'IEC1'

CF: 03678570981
PI: 03678570981
SDI_CodiceDestinatarioCliente: 7654321
SDI_PECDestinararioCliente: vuota

*/

--UPDATE InVoiceFrancesco.dbo.CliFor SET SDI_CodiceDestinatarioCliente = N'7654321', SDI_PECDestinatarioCliente = N'' WHERE Codice = N'IEC1';
--UPDATE InVoiceFrancesco.dbo.CliFor SET SDI_CodiceDestinatarioCliente = N'7654321', SDI_PECDestinatarioCliente = N'iec1_pec@libero.it' WHERE Codice = N'IEC1';
--UPDATE InVoiceFrancesco.dbo.CliFor SET SDI_CodiceDestinatarioCliente = N'', SDI_PECDestinatarioCliente = N'iec1_pec@libero.it' WHERE Codice = N'IEC1';

DECLARE @PKEsitoEvento SMALLINT,
        @PKEvento BIGINT,
        @PKLanding_Fattura BIGINT,
        @PKStaging_FatturaElettronicaHeader BIGINT,
		@IsValida BIT,
		@PKValidazione BIGINT,
        @PKFatturaElettronicaHeader BIGINT,
		@XMLOutput XML;

EXEC InVoice3.FXML.usp_EsportaFattura @IDDocumento = @IDDocumento,
                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                             @PKEvento = @PKEvento OUTPUT,
                             @PKLanding_Fattura = @PKLanding_Fattura OUTPUT;

SELECT @PKEsitoEvento AS PKEsito,
	   @PKEvento AS PKEvento,
	   @PKLanding_Fattura AS PKLanding_Fattura;

SET @PKEsitoEvento = NULL;
SET @PKEvento = NULL;

EXEC InVoice3.FXML.usp_EsportaDatiFattura @IDDocumento = @IDDocumento,
                                 @PKLanding_Fattura = @PKLanding_Fattura,
                                 @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                                 @PKEvento = @PKEvento OUTPUT,
                                 @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader OUTPUT;

SELECT DP.*
FROM XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento DP
INNER JOIN XMLFatture.Staging_FatturaElettronicaBody B ON B.PKStaging_FatturaElettronicaBody = DP.PKStaging_FatturaElettronicaBody
WHERE B.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT @PKEsitoEvento AS PKEsito,
	   @PKEvento AS PKEvento,
	   @PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader;

EXEC XMLAudit.ssp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint

SET @PKEsitoEvento = NULL;
SET @PKEvento = NULL;



DECLARE @codiceAlfanumerico NVARCHAR(40) = CONVERT(NVARCHAR(40), @IDDocumento);

EXEC XMLFatture.usp_ConvalidaFattura @codiceNumerico = NULL,                                             -- bigint
                                     @codiceAlfanumerico = @codiceAlfanumerico,                                       -- nvarchar(40)
                                     @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,                         -- bigint
                                     @PKEvento = @PKEvento OUTPUT,                                    -- bigint
                                     @PKEsitoEvento = @PKEsitoEvento OUTPUT,                          -- smallint
                                     @IsValida = @IsValida OUTPUT,                                    -- bit
                                     @PKValidazione = @PKValidazione OUTPUT,                          -- bigint
                                     @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT -- bigint

SELECT
	@PKEvento AS PKEvento,
	@PKEsitoEvento AS PKEsitoEvento,
	@IsValida AS IsValida,
	@PKValidazione AS PKValidazione,
	@PKFatturaElettronicaHeader AS PKFatturaElettronicaHeader;

EXEC XMLAudit.ssp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint

EXEC XMLAudit.ssp_LeggiLogValidazione @PKValidazione = @PKValidazione, -- bigint
                                      @LivelloLog = 0     -- tinyint

SELECT * FROM InVoiceXML.XMLFatture.FatturaElettronicaHeader WHERE PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT * FROM InVoiceXML.XMLFatture.FatturaElettronicaBody WHERE PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT DE.* FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DocumentoEsterno DE
INNER JOIN XMLFatture.FatturaElettronicaBody B ON B.PKFatturaElettronicaBody = DE.PKFatturaElettronicaBody
    AND B.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT DERNL.* FROM InVoiceXML.XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea DERNL
INNER JOIN XMLFatture.FatturaElettronicaBody_DocumentoEsterno DE ON DE.PKFatturaElettronicaBody_DocumentoEsterno = DERNL.PKFatturaElettronicaBody_DocumentoEsterno
INNER JOIN XMLFatture.FatturaElettronicaBody B ON B.PKFatturaElettronicaBody = DE.PKFatturaElettronicaBody
    AND B.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBDCP.PKFatturaElettronicaBody_DatiCassaPrevidenziale,
    FEBDCP.PKFatturaElettronicaBody,
    FEBDCP.TipoCassa,
    FEBDCP.AlCassa,
    FEBDCP.ImportoContributoCassa,
    FEBDCP.ImponibileCassa,
    FEBDCP.AliquotaIVA,
    FEBDCP.Ritenuta,
    FEBDCP.Natura,
    FEBDCP.RiferimentoAmministrazione

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale FEBDCP ON FEBDCP.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBC.PKFatturaElettronicaBody_Causale,
    FEBC.PKFatturaElettronicaBody,
    FEBC.DatiGenerali_Causale

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_Causale FEBC ON FEBC.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBDDDT.PKFatturaElettronicaBody_DatiDDT,
    FEBDDDT.PKFatturaElettronicaBody,
    FEBDDDT.NumeroDDT,
    FEBDDDT.DataDDT

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiDDT FEBDDDT ON FEBDDDT.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBDDTRNL.PKFatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea,
    FEBDDTRNL.PKFatturaElettronicaBody_DatiDDT,
    FEBDDTRNL.RiferimentoNumeroLinea

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiDDT FEBDDDT ON FEBDDDT.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea FEBDDTRNL ON FEBDDTRNL.PKFatturaElettronicaBody_DatiDDT = FEBDDDT.PKFatturaElettronicaBody_DatiDDT
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBDL.PKFatturaElettronicaBody_DettaglioLinee,
    FEBDL.PKFatturaElettronicaBody,
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

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
	ORDER BY FEBDL.NumeroLinea;

SELECT
    FEBDLCA.PKFatturaElettronicaBody_DettaglioLinee_CodiceArticolo,
    FEBDLCA.PKFatturaElettronicaBody_DettaglioLinee,
    FEBDLCA.CodiceArticolo_CodiceTipo,
    FEBDLCA.CodiceArticolo_CodiceValore

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo FEBDLCA ON FEBDLCA.PKFatturaElettronicaBody_DettaglioLinee = FEBDL.PKFatturaElettronicaBody_DettaglioLinee
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
	ORDER BY FEBDL.NumeroLinea;

SELECT
    FEBDLSM.PKFatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione,
    FEBDLSM.PKFatturaElettronicaBody_DettaglioLinee,
    FEBDLSM.ScontoMaggiorazione_Tipo,
    FEBDLSM.ScontoMaggiorazione_Percentuale,
    FEBDLSM.ScontoMaggiorazione_Importo

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione FEBDLSM ON FEBDLSM.PKFatturaElettronicaBody_DettaglioLinee = FEBDL.PKFatturaElettronicaBody_DettaglioLinee
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader
	ORDER BY FEBDL.NumeroLinea;

SELECT
	FEBDR.PKFatturaElettronicaBody_DatiRiepilogo,
    FEBDR.PKFatturaElettronicaBody,
    FEBDR.AliquotaIVA,
    FEBDR.Natura,
    FEBDR.SpeseAccessorie,
    FEBDR.Arrotondamento,
    FEBDR.ImponibileImporto,
    FEBDR.Imposta,
    FEBDR.EsigibilitaIVA,
    FEBDR.RiferimentoNormativo

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiRiepilogo FEBDR ON FEBDR.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBDP.PKFatturaElettronicaBody_DatiPagamento,
    FEBDP.PKFatturaElettronicaBody,
    FEBDP.CondizioniPagamento

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiPagamento FEBDP ON FEBDP.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SELECT
	FEBDPDP.PKFatturaElettronicaBody_DatiPagamento_DettaglioPagamento,
    FEBDPDP.PKFatturaElettronicaBody_DatiPagamento,
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

FROM InVoiceXML.XMLFatture.FatturaElettronicaBody FEB
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiPagamento FEBDP ON FEBDP.PKFatturaElettronicaBody = FEB.PKFatturaElettronicaBody
INNER JOIN InVoiceXML.XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento FEBDPDP ON FEBDPDP.PKFatturaElettronicaBody_DatiPagamento = FEBDP.PKFatturaElettronicaBody_DatiPagamento
WHERE FEB.PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;

SET @PKEvento = NULL;
SET @PKEsitoEvento = NULL;

EXEC XMLFatture.usp_GeneraXMLFattura @codiceNumerico = NULL,                    -- bigint
                                     @codiceAlfanumerico = @codiceAlfanumerico,              -- nvarchar(40)
                                     @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,        -- bigint
                                     @PKEvento = @PKEvento OUTPUT,           -- bigint
                                     @PKEsitoEvento = @PKEsitoEvento OUTPUT, -- smallint
                                     @XMLOutput = @XMLOutput OUTPUT          -- xml

EXEC XMLAudit.ssp_LeggiLogEvento @PKEvento = @PKEvento,  -- bigint
                                 @LivelloLog = 0 -- tinyint

SELECT PKFatturaElettronicaHeader, XMLOutput FROM XMLFatture.FatturaElettronicaHeader WHERE PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader;
GO
