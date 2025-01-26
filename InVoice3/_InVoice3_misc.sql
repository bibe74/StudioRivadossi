/*
SELECT * FROM dbo.Conf_Parametri;
SELECT * FROM dbo.Documenti D WHERE D.IDTipo = N'Cli_Fattura';
SELECT * FROM dbo.Causali;
SELECT * FROM dbo.Documenti_Scadenze WHERE Tipo != 1; -- 1: Scadenze. -1: Pagamenti
SELECT * FROM dbo.Documenti_Righe;
SELECT * FROM dbo.CliFor WHERE Cliente = CAST(1 AS BIT);
*/

DECLARE @documentID UNIQUEIDENTIFIER = '36F5EAA2-AF10-47A0-9014-8F033D74B7D1';

DECLARE @idPaese CHAR(2);
DECLARE @idCodice NVARCHAR(28);
DECLARE @progressivoInvio NVARCHAR(10);
DECLARE @formatoTrasmissione NVARCHAR(5);
DECLARE @codiceDestinatario NVARCHAR(7);

SELECT @idPaese = 'IT'; -- TODO: parametro in Conf_Parametri
SELECT @idCodice = Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.PI';
SELECT @progressivoInvio = N'' -- TODO: numerazione univoca?

SELECT @formatoTrasmissione = 'FPR12'; -- FPR12: fattura verso privati. TODO: gestire fatture verso PA

SELECT * FROM dbo.Conf_Parametri;

SELECT * 
FROM dbo.Documenti D 
WHERE D.IDTipo = N'Cli_Fattura'
	AND D.ID = @documentID;

SELECT CF.*
FROM dbo.Documenti D 
INNER JOIN dbo.CliFor CF ON CF.ID = D.IDCliFor
	AND CF.Cliente = CAST(1 AS BIT)
WHERE D.IDTipo = N'Cli_Fattura'
	AND D.ID = @documentID;

-- OK fin qui

SELECT * FROM FatturaXML.XMLFatture.Landing_Fattura
SELECT * FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaHeader ORDER BY PKStaging_FatturaElettronicaHeader DESC;


SELECT TOP 1
	*
FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaHeader
FOR XML AUTO

SELECT
	D.ID,
	COUNT(1) AS NumeroRighe

FROM dbo.Documenti D
INNER JOIN dbo.Documenti_Righe DR ON DR.IDDocumento = D.ID
WHERE D.IDTipo = N'Cli_Fattura'
GROUP BY D.ID;



/* Inserimento testata fattura: Inizio */

DECLARE @PKLanding_Fattura BIGINT;
DECLARE @PKStaging_FatturaElettronicaHeader BIGINT;

INSERT INTO FatturaXML.XMLFatture.Staging_FatturaElettronicaHeader
(
    PKStaging_FatturaElettronicaHeader,
    PKLanding_Fattura,
    DataInserimento,
    IsValida,
    DataUltimaValidazione,
    DatiTrasmissione_IdTrasmittente_IdPaese,
    DatiTrasmissione_IdTrasmittente_IdCodice,
    DatiTrasmissione_ProgressivoInvio,
    DatiTrasmissione_FormatoTrasmissione,
    DatiTrasmissione_CodiceDestinatario,
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
    CedentePrestatore_StabileOrganizzazione_Indirizzo,
    CedentePrestatore_StabileOrganizzazione_NumeroCivico,
    CedentePrestatore_StabileOrganizzazione_CAP,
    CedentePrestatore_StabileOrganizzazione_Comune,
    CedentePrestatore_StabileOrganizzazione_Provincia,
    CedentePrestatore_StabileOrganizzazione_Nazione,
    CedentePrestatore_IscrizioneREA_Ufficio,
    CedentePrestatore_IscrizioneREA_NumeroREA,
    CedentePrestatore_IscrizioneREA_CapitaleSociale,
    CedentePrestatore_IscrizioneREA_SocioUnico,
    CedentePrestatore_IscrizioneREA_StatoLiquidazione,
    CedentePrestatore_Contatti_Telefono,
    CedentePrestatore_Contatti_Fax,
    CedentePrestatore_Contatti_Email,
    CedentePrestatore_RiferimentoAmministrazione,
    RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    RappresentanteFiscale_DatiAnagrafici_CodiceFiscale,
    RappresentanteFiscale_Anagrafica_Denominazione,
    RappresentanteFiscale_Anagrafica_Nome,
    RappresentanteFiscale_Anagrafica_Cognome,
    RappresentanteFiscale_Anagrafica_Titolo,
    RappresentanteFiscale_Anagrafica_CodEORI,
    CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    CessionarioCommittente_DatiAnagrafici_CodiceFiscale,
    CessionarioCommittente_Anagrafica_Denominazione,
    CessionarioCommittente_Anagrafica_Nome,
    CessionarioCommittente_Anagrafica_Cognome,
    CessionarioCommittente_Anagrafica_Titolo,
    CessionarioCommittente_Anagrafica_CodEORI,
    CessionarioCommittente_Sede_Indirizzo,
    CessionarioCommittente_Sede_NumeroCivico,
    CessionarioCommittente_Sede_CAP,
    CessionarioCommittente_Sede_Comune,
    CessionarioCommittente_Sede_Provincia,
    CessionarioCommittente_Sede_Nazione,
    CessionarioCommittente_StabileOrganizzazione_Indirizzo,
    CessionarioCommittente_StabileOrganizzazione_NumeroCivico,
    CessionarioCommittente_StabileOrganizzazione_CAP,
    CessionarioCommittente_StabileOrganizzazione_Comune,
    CessionarioCommittente_StabileOrganizzazione_Provincia,
    CessionarioCommittente_StabileOrganizzazione_Nazione,
    CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese,
    CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice,
    CessionarioCommittente_RappresentanteFiscale_Denominazione,
    CessionarioCommittente_RappresentanteFiscale_Nome,
    CessionarioCommittente_RappresentanteFiscale_Cognome,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale,
    TerzoIntermediarioOSoggettoEmittente_Anagrafica_Denominazione,
    TerzoIntermediarioOSoggettoEmittente_Anagrafica_Nome,
    TerzoIntermediarioOSoggettoEmittente_Anagrafica_Cognome,
    TerzoIntermediarioOSoggettoEmittente_Anagrafica_Titolo,
    TerzoIntermediarioOSoggettoEmittente_Anagrafica_CodEORI,
    TerzoIntermediarioOSoggettoEmittente_SoggettoEmittente
)
SELECT
	@PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader,
    @PKLanding_Fattura AS PKLanding_Fattura,
    CURRENT_TIMESTAMP AS DataInserimento,
    CAST(0 AS BIT) AS IsValida,
    NULL AS DataUltimaValidazione,
    N.SDI_IDNazione AS DatiTrasmissione_IdTrasmittente_IdPaese,
    N'TODO dbo.Conf_Parametri' AS DatiTrasmissione_IdTrasmittente_IdCodice,
    N'TODO: regole definite dal trasmittente' AS DatiTrasmissione_ProgressivoInvio,
    'FPR12' AS DatiTrasmissione_FormatoTrasmissione, -- FPR12: fattura verso privati
    CASE
	  WHEN C.SDI_CodiceDestinatarioCliente IS NOT NULL THEN C.SDI_CodiceDestinatarioCliente
	  WHEN C.SDI_PECDestinatarioCliente IS NOT NULL THEN N'0000000'
	  ELSE N'<???>'
	END AS DatiTrasmissione_CodiceDestinatario,
    NULL AS DatiTrasmissione_ContattiTrasmittente_Telefono,
    NULL AS DatiTrasmissione_ContattiTrasmittente_Email,
    CASE
	  WHEN C.SDI_CodiceDestinatarioCliente IS NOT NULL THEN N''
	  WHEN C.SDI_PECDestinatarioCliente IS NOT NULL THEN C.SDI_PECDestinatarioCliente
	  ELSE N'<???>'
    END AS DatiTrasmissione_PECDestinatario,
    N.SDI_IDNazione AS CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_DatiAnagrafici_CodiceFiscale,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_DatiAnagrafici_Anagrafica_Nome,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome,
    NULL AS CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo,
    NULL AS CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI,
    NULL AS CedentePrestatore_DatiAnagrafici_AlboProfessionale,
    NULL AS CedentePrestatore_DatiAnagrafici_ProvinciaAlbo,
    NULL AS CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo,
    NULL AS CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_DatiAnagrafici_RegimeFiscale,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_Sede_Indirizzo,
    NULL AS CedentePrestatore_Sede_NumeroCivico,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_Sede_CAP,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_Sede_Comune,
    N'TODO dbo.Conf_Parametri' AS CedentePrestatore_Sede_Provincia,
    N.SDI_IDNazione AS CedentePrestatore_Sede_Nazione,
    NULL AS CedentePrestatore_StabileOrganizzazione_Indirizzo,
    NULL AS CedentePrestatore_StabileOrganizzazione_NumeroCivico,
    NULL AS CedentePrestatore_StabileOrganizzazione_CAP,
    NULL AS CedentePrestatore_StabileOrganizzazione_Comune,
    NULL AS CedentePrestatore_StabileOrganizzazione_Provincia,
    NULL AS CedentePrestatore_StabileOrganizzazione_Nazione,
    NULL AS CedentePrestatore_IscrizioneREA_Ufficio,
    NULL AS CedentePrestatore_IscrizioneREA_NumeroREA,
    NULL AS CedentePrestatore_IscrizioneREA_CapitaleSociale,
    NULL AS CedentePrestatore_IscrizioneREA_SocioUnico,
    NULL AS CedentePrestatore_IscrizioneREA_StatoLiquidazione,
    NULL AS CedentePrestatore_Contatti_Telefono,
    NULL AS CedentePrestatore_Contatti_Fax,
    NULL AS CedentePrestatore_Contatti_Email,
    NULL AS CedentePrestatore_RiferimentoAmministrazione,
    NULL AS RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    NULL AS RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    NULL AS RappresentanteFiscale_DatiAnagrafici_CodiceFiscale,
    NULL AS RappresentanteFiscale_Anagrafica_Denominazione,
    NULL AS RappresentanteFiscale_Anagrafica_Nome,
    NULL AS RappresentanteFiscale_Anagrafica_Cognome,
    NULL AS RappresentanteFiscale_Anagrafica_Titolo,
    NULL AS RappresentanteFiscale_Anagrafica_CodEORI,
    NC.SDI_IDNazione AS CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    C.PI AS CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    CASE WHEN COALESCE(C.CF, C.PI) = C.PI THEN NULL ELSE C.CF END AS CessionarioCommittente_DatiAnagrafici_CodiceFiscale,
	LEFT(RTRIM(LTRIM(C.Intestazione)) + N' ' + RTRIM(LTRIM(C.Intestazione2)), 80) AS CessionarioCommittente_Anagrafica_Denominazione,
    NULL AS CessionarioCommittente_Anagrafica_Nome,
    NULL AS CessionarioCommittente_Anagrafica_Cognome,
    NULL AS CessionarioCommittente_Anagrafica_Titolo,
    NULL AS CessionarioCommittente_Anagrafica_CodEORI,
    C.Indirizzo AS CessionarioCommittente_Sede_Indirizzo,
    NULL AS CessionarioCommittente_Sede_NumeroCivico,
    C.Cap AS CessionarioCommittente_Sede_CAP,
    C.Comune AS CessionarioCommittente_Sede_Comune,
    C.Provincia AS CessionarioCommittente_Sede_Provincia,
    NC.SDI_IDNazione AS CessionarioCommittente_Sede_Nazione,
    NULL AS CessionarioCommittente_StabileOrganizzazione_Indirizzo,
    NULL AS CessionarioCommittente_StabileOrganizzazione_NumeroCivico,
    NULL AS CessionarioCommittente_StabileOrganizzazione_CAP,
    NULL AS CessionarioCommittente_StabileOrganizzazione_Comune,
    NULL AS CessionarioCommittente_StabileOrganizzazione_Provincia,
    NULL AS CessionarioCommittente_StabileOrganizzazione_Nazione,
    NULL AS CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese,
    NULL AS CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice,
    NULL AS CessionarioCommittente_RappresentanteFiscale_Denominazione,
    NULL AS CessionarioCommittente_RappresentanteFiscale_Nome,
    NULL AS CessionarioCommittente_RappresentanteFiscale_Cognome,
    NULL AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    NULL AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    NULL AS TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale,
    NULL AS TerzoIntermediarioOSoggettoEmittente_Anagrafica_Denominazione,
    NULL AS TerzoIntermediarioOSoggettoEmittente_Anagrafica_Nome,
    NULL AS TerzoIntermediarioOSoggettoEmittente_Anagrafica_Cognome,
    NULL AS TerzoIntermediarioOSoggettoEmittente_Anagrafica_Titolo,
    NULL AS TerzoIntermediarioOSoggettoEmittente_Anagrafica_CodEORI,
    NULL AS TerzoIntermediarioOSoggettoEmittente_SoggettoEmittente

FROM dbo.Documenti D
LEFT JOIN dbo.Conf_Parametri CPNazione ON CPNazione.ID = N'Company.Nazione'
LEFT JOIN dbo.Nazioni N ON N.ID = CPNazione.Valore
INNER JOIN dbo.CliFor C ON C.ID = D.IDCliFor
	AND C.Cliente = CAST(1 AS BIT)
INNER JOIN dbo.Nazioni NC ON NC.ID = C.Nazione
WHERE D.ID = '046D990E-0D55-4075-8D08-001B657EFF7E';
GO

/* Inserimento testata fattura: Fine */

-- FatturaElettronicaBody

SELECT
    DT.SDI_TipoDocumento,
	N'EUR' AS Divisa,
	D.Data,
	D.Numero,
	D.TotRighe, -- Totale merce
	D.Inps, -- Verificare TipoCassa TC22
	D.TotImp, -- merce - INPS
	D.TotIva, -- Totale IVA
	D.TotLordo, -- Totale lordo
	D.RitAcc, -- Totale ritenuta d'acconto
	D.TotDoc, -- Totale documento
	--D.IDCausale,
	C.Descrizione AS Causale

FROM dbo.Documenti D
INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
LEFT JOIN dbo.Causali C ON C.ID = D.IDCausale
WHERE D.ID = '046D990E-0D55-4075-8D08-001B657EFF7E';

-- No riferimenti ordine acquisto

SELECT
	DDDT.Numero AS NumeroDDT,
	DDDT.Data AS DataDDT,
	DR.Posizione AS RiferimentoNumeroLinea

FROM Documenti_Righe DR
INNER JOIN dbo.Documenti D ON D.ID = DR.IDDocumento
INNER JOIN dbo.Documenti_Righe DRDDT ON DRDDT.ID = DR.IDDocumento_RigaOrigine
INNER JOIN dbo.Documenti DDDT ON DDDT.ID = DRDDT.IDDocumento
	AND DDDT.IDTipo = N'Cli_DDT'
WHERE D.ID = '046D990E-0D55-4075-8D08-001B657EFF7E';

-- No dati trasporto

SELECT
	DR.ID,
    DR.IDDocumento,
    DR.IDArticolo,
    DR.IDFamiglia,
    DR.IDUnitaMisura, -- UnitaMisura
    DR.IDDocumento_Origine,
    DR.IDDocumento_RigaOrigine,
    DR.IDStato,
    DR.Posizione, -- NumeroLinea
    DR.Qta, -- Quantita
    DR.QtaEvasa,
    DR.Codice, -- CodiceArticolo_CodiceValore
	N'ITEM' AS CodiceArticolo_CodiceTipo,
    DR.Descrizione1, -- Descrizione (1/4), verificare che sia sufficiente per la fattura
    DR.Descrizione2, -- Descrizione (2/4)
    DR.Descrizione3, -- Descrizione (3/4)
    DR.Descrizione4, -- Descrizione (4/4)
    DR.ImpUnitario, -- PrezzoUnitario
    DR.ImpNetto,
	CASE WHEN DR.Sconto <> N'' THEN N'SC' ELSE NULL END AS ScontoMaggiorazione_Tipo,
    DR.Sconto,
    DR.ImpSconto, -- ScontoMaggiorazione_Importo
	CASE WHEN DR.Sconto <> N'' AND DR.ImpNetto <> 0.0 THEN DR.ImpSconto / DR.ImpNetto ELSE NULL END AS ScontoMaggiorazione_Percentuale,
    DR.ImpUnitarioScontato,
    DR.ImpNettoScontato, -- ScontoMaggiorazione_PrezzoTotale
    DR.CodIva,
	COALESCE(CI.Perc, NULL) AS AliquotaIVA,
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
    DR.OrdCliData

FROM dbo.Documenti_Righe DR
LEFT JOIN dbo.CodiciIva CI ON CI.ID = DR.CodIva
WHERE DR.IDDocumento = '046D990E-0D55-4075-8D08-001B657EFF7E'
ORDER BY DR.Posizione;

SELECT
	CI.SDI_Natura,
	CI.SDI_RiferimentoNormativo,
	0.0 AS Arrotondamento,
    DI.ImpNetto, -- ImponibileImporto
    DI.CodIva,

	CI.Perc AS AliquotaIVA,
    DI.ImpIva AS Imposta,
    DI.ImpLordo

FROM dbo.Documenti_IVA DI
LEFT JOIN dbo.CodiciIva CI ON CI.ID = DI.CodIva
WHERE DI.IDDocumento = '046D990E-0D55-4075-8D08-001B657EFF7E';

-- CondizioniPagamento - Contare DS di Tipo 1: se 1, TP01; altrimenti, TP02 / oppure, modalitapagamento.NumeroRate

SELECT
	DS.ID,
    DS.IDDocumento,
    DS.BancaCassa,
    DS.Insoluto,
    DS.RbEsportata,
    DS.RbEsportataData,
    DS.RbBanca,
    DS.Descrizione,
    DS.Note,
    DS.Data, -- DataScadenzaPagamento
    DS.Numero,
    DS.Tipo,
    DS.Importo, -- ImportoPagamento
    DS.IDTipoPagamento,
	MPT.SDI_ModalitaPagamento,

	D.Pag_Banca AS IstitutoFinanziario,
	D.Pag_Iban AS IBAN,
	D.Pag_Abi AS ABI,
	D.Pag_Cab AS CAB,
	D.Pag_Bic AS BIC

FROM dbo.Documenti_Scadenze DS
INNER JOIN dbo.ModalitaPagamento_Tipi MPT ON MPT.ID = DS.IDTipoPagamento
INNER JOIN dbo.Documenti D ON D.ID = DS.IDDocumento
WHERE DS.IDDocumento = '046D990E-0D55-4075-8D08-001B657EFF7E'
	AND DS.Tipo = 1; -- 1: Scadenze previste

/* Esportazione fattura: Inizio */

USE StudioRivadossiInVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento WHERE PKFatturaElettronicaBody_DatiPagamento_DettaglioPagamento > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DatiPagamento WHERE PKFatturaElettronicaBody_DatiPagamento > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DatiRiepilogo WHERE PKFatturaElettronicaBody_DatiRiepilogo > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione WHERE PKFatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo WHERE PKFatturaElettronicaBody_DettaglioLinee_CodiceArticolo > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DettaglioLinee WHERE PKFatturaElettronicaBody_DettaglioLinee > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea WHERE PKFatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_DatiDDT WHERE PKFatturaElettronicaBody_DatiDDT > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody_Causale WHERE PKFatturaElettronicaBody_Causale > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaBody WHERE PKFatturaElettronicaBody > 0;
DELETE FROM FatturaXML.XMLFatture.FatturaElettronicaHeader WHERE PKFatturaElettronicaHeader > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento WHERE PKStaging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento WHERE PKStaging_FatturaElettronicaBody_DatiPagamento > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo WHERE PKStaging_FatturaElettronicaBody_DatiRiepilogo > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione WHERE PKStaging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo WHERE PKStaging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee WHERE PKStaging_FatturaElettronicaBody_DettaglioLinee > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea WHERE PKStaging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT WHERE PKStaging_FatturaElettronicaBody_DatiDDT > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_Causale WHERE PKStaging_FatturaElettronicaBody_Causale > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody WHERE PKStaging_FatturaElettronicaBody > 0;
DELETE FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaHeader WHERE PKStaging_FatturaElettronicaHeader > 0;
GO

DECLARE @IDDocumento UNIQUEIDENTIFIER = '45478B47-6256-4AEA-91CF-A3267B311F3E';
DECLARE @PKEsitoEvento SMALLINT,
        @PKEvento BIGINT,
        @PKLanding_Fattura BIGINT,
        @PKStaging_FatturaElettronicaHeader BIGINT,
		@IsValida BIT,
		@PKValidazione BIGINT,
        @PKFatturaElettronicaHeader BIGINT,
		@XMLOutput XML;

EXEC FXML.usp_EsportaFattura @IDDocumento = @IDDocumento,
                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                             @PKEvento = @PKEvento OUTPUT,
                             @PKLanding_Fattura = @PKLanding_Fattura OUTPUT;

SELECT @PKEsitoEvento AS PKEsito,
	   @PKEvento AS PKEvento,
	   @PKLanding_Fattura AS PKLanding_Fattura;

SET @PKEsitoEvento = NULL;
SET @PKEvento = NULL;

EXEC FXML.usp_EsportaDatiFattura @IDDocumento = @IDDocumento,
                                 @PKLanding_Fattura = @PKLanding_Fattura,
                                 @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                                 @PKEvento = @PKEvento OUTPUT,
                                 @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader OUTPUT;

SELECT * FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaHeader WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT * FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody WHERE PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT FEBDE.* FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno FEBDE
INNER JOIN InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody FEB ON FEB.PKStaging_FatturaElettronicaBody = FEBDE.PKStaging_FatturaElettronicaBody
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT
	FEBC.PKStaging_FatturaElettronicaBody_Causale,
    FEBC.PKStaging_FatturaElettronicaBody,
    FEBC.DatiGenerali_Causale

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_Causale FEBC ON FEBC.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT
	FEBDDDT.PKStaging_FatturaElettronicaBody_DatiDDT,
    FEBDDDT.PKStaging_FatturaElettronicaBody,
    FEBDDDT.NumeroDDT,
    FEBDDDT.DataDDT

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT FEBDDDT ON FEBDDDT.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT
	FEBDDTRNL.PKStaging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea,
    FEBDDTRNL.PKStaging_FatturaElettronicaBody_DatiDDT,
    FEBDDTRNL.RiferimentoNumeroLinea

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT FEBDDDT ON FEBDDDT.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea FEBDDTRNL ON FEBDDTRNL.PKStaging_FatturaElettronicaBody_DatiDDT = FEBDDDT.PKStaging_FatturaElettronicaBody_DatiDDT
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT
	FEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee,
    FEBDL.PKStaging_FatturaElettronicaBody,
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

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
	ORDER BY FEBDL.NumeroLinea;

SELECT
    FEBDLCA.PKStaging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo,
    FEBDLCA.PKStaging_FatturaElettronicaBody_DettaglioLinee,
    FEBDLCA.CodiceArticolo_CodiceTipo,
    FEBDLCA.CodiceArticolo_CodiceValore

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo FEBDLCA ON FEBDLCA.PKStaging_FatturaElettronicaBody_DettaglioLinee = FEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
	ORDER BY FEBDL.NumeroLinea;

SELECT
    FEBDLSM.PKStaging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione,
    FEBDLSM.PKStaging_FatturaElettronicaBody_DettaglioLinee,
    FEBDLSM.ScontoMaggiorazione_Tipo,
    FEBDLSM.ScontoMaggiorazione_Percentuale,
    FEBDLSM.ScontoMaggiorazione_Importo

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee FEBDL ON FEBDL.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione FEBDLSM ON FEBDLSM.PKStaging_FatturaElettronicaBody_DettaglioLinee = FEBDL.PKStaging_FatturaElettronicaBody_DettaglioLinee
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader
	ORDER BY FEBDL.NumeroLinea;

SELECT
	FEBDR.PKStaging_FatturaElettronicaBody_DatiRiepilogo,
    FEBDR.PKStaging_FatturaElettronicaBody,
    FEBDR.AliquotaIVA,
    FEBDR.Natura,
    FEBDR.SpeseAccessorie,
    FEBDR.Arrotondamento,
    FEBDR.ImponibileImporto,
    FEBDR.Imposta,
    FEBDR.EsigibilitaIVA,
    FEBDR.RiferimentoNormativo

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo FEBDR ON FEBDR.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT
	FEBDP.PKStaging_FatturaElettronicaBody_DatiPagamento,
    FEBDP.PKStaging_FatturaElettronicaBody,
    FEBDP.CondizioniPagamento

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento FEBDP ON FEBDP.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;

SELECT
	FEBDPDP.PKStaging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento,
    FEBDPDP.PKStaging_FatturaElettronicaBody_DatiPagamento,
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

FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaBody FEB
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento FEBDP ON FEBDP.PKStaging_FatturaElettronicaBody = FEB.PKStaging_FatturaElettronicaBody
INNER JOIN FatturaXML.XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento FEBDPDP ON FEBDPDP.PKStaging_FatturaElettronicaBody_DatiPagamento = FEBDP.PKStaging_FatturaElettronicaBody_DatiPagamento
WHERE FEB.PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader;
GO

/* Esportazione fattura: Fine */

/*
DECLARE @IDDocumento UNIQUEIDENTIFIER = '046D990E-0D55-4075-8D08-001B657EFF7E';
DECLARE @PKEvento BIGINT,
		@PKEsitoEvento SMALLINT,
        @PKLanding_Fattura BIGINT,
		@PKStaging_FatturaElettronicaHeader BIGINT;

EXEC FXML.usp_EsportaFattura @IDDocumento = @IDDocumento,
                             @PKEvento = @PKEvento OUTPUT,
                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                             @PKLanding_Fattura = @PKLanding_Fattura OUTPUT;

SELECT @PKEvento AS PKEvento,
	   @PKEsitoEvento AS PKEsito,
	   @PKLanding_Fattura AS PKLanding_Fattura;

SET @PKEvento = NULL;
SET @PKEsitoEvento = NULL;

EXEC FXML.usp_EsportaDatiFattura @IDDocumento = @IDDocumento,
                                 @PKLanding_Fattura = @PKLanding_Fattura,
                                 @PKEvento = @PKEvento OUTPUT,
                                 @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                                 @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader OUTPUT;

SELECT @PKEvento AS PKEvento,
	   @PKEsitoEvento AS PKEsito,
	   @PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader;

EXEC FXML.usp_LeggiLogEvento @IDDocumento = @IDDocumento,
                             @PKEvento = @PKEvento,
                             @LivelloLog = 0;
GO
*/

/* Convalida fattura: Inizio */

--USE FatturaXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

DECLARE @codiceAlfanumerico NVARCHAR(40) = N'046D990E-0D55-4075-8D08-001B657EFF7E';
DECLARE @PKStaging_FatturaElettronicaHeader BIGINT = 37;

DECLARE @PKEsitoEvento SMALLINT,
        @PKEvento BIGINT,
        @IsValida BIT,
        @PKValidazione BIGINT,
        @PKFatturaElettronicaHeader BIGINT;

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
GO

/* Convalida fattura: Fine */

/* Procedura completa: Inizio */

USE StudioRivadossiInVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

DECLARE @IDDocumento UNIQUEIDENTIFIER = '45478B47-6256-4AEA-91CF-A3267B311F3E';
DECLARE @PKEsitoEvento SMALLINT,
        @PKEvento BIGINT,
        @PKLanding_Fattura BIGINT,
        @PKStaging_FatturaElettronicaHeader BIGINT,
		@IsValida BIT,
		@PKValidazione BIGINT,
        @PKFatturaElettronicaHeader BIGINT,
		@XMLOutput XML;

EXEC FXML.usp_EsportaFattura @IDDocumento = @IDDocumento,
                             @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                             @PKEvento = @PKEvento OUTPUT,
                             @PKLanding_Fattura = @PKLanding_Fattura OUTPUT;

SELECT @PKEsitoEvento AS PKEsito,
	   @PKEvento AS PKEvento,
	   @PKLanding_Fattura AS PKLanding_Fattura;

SET @PKEsitoEvento = NULL;
SET @PKEvento = NULL;

EXEC FXML.usp_EsportaDatiFattura @IDDocumento = @IDDocumento,
                                 @PKLanding_Fattura = @PKLanding_Fattura,
                                 @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                                 @PKEvento = @PKEvento OUTPUT,
                                 @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader OUTPUT;

SELECT @PKEsitoEvento AS PKEsito,
	   @PKEvento AS PKEvento,
	   @PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader;

EXEC FXML.usp_LeggiLogEvento @IDDocumento = @IDDocumento,
                             @PKEvento = @PKEvento,
                             @LivelloLog = 0;

SET @PKEsitoEvento = NULL;
SET @PKEvento = NULL;

EXEC FXML.usp_ConvalidaFattura @IDDocumento = @IDDocumento,
                               @PKStaging_FatturaElettronicaHeader = @PKStaging_FatturaElettronicaHeader,
                               @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                               @PKEvento = @PKEvento OUTPUT,
                               @IsValida = @IsValida OUTPUT,
                               @PKValidazione = @PKValidazione OUTPUT,
                               @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader OUTPUT;
 
SELECT @PKEsitoEvento AS PKEsitoEvento, @PKEvento AS PKEvento, @IsValida AS IsValida, @PKValidazione AS PKValidazione, @PKFatturaElettronicaHeader AS PKFatturaElettronicaHeader;

EXEC FXML.usp_LeggiLogEvento @IDDocumento = @IDDocumento,
                             @PKEvento = @PKEvento,
                             @LivelloLog = 0;

EXEC FXML.usp_LeggiLogValidazione @IDDocumento = @IDDocumento,
                                  @PKValidazione = @PKValidazione,
                                  @LivelloLog = 0;

SET @PKEsitoEvento = NULL;
SET @PKEvento = NULL;

EXEC FXML.usp_GeneraXMLFattura @IDDocumento = @IDDocumento,
                               @PKFatturaElettronicaHeader = @PKFatturaElettronicaHeader,
                               @PKEsitoEvento = @PKEsitoEvento OUTPUT,
                               @PKEvento = @PKEvento OUTPUT,
                               @XMLOutput = @XMLOutput OUTPUT;

SELECT @PKEsitoEvento AS PKEsitoEvento, @PKEvento AS PKEvento, @XMLOutput AS XMLOutput;

EXEC FXML.usp_LeggiLogEvento @IDDocumento = @IDDocumento,
                             @PKEvento = @PKEvento,
                             @LivelloLog = 0;
GO

SELECT * FROM FatturaXML.XMLFatture.Landing_Fattura ORDER BY PKLanding_Fattura DESC;
SELECT * FROM FatturaXML.XMLFatture.Staging_FatturaElettronicaHeader ORDER BY PKStaging_FatturaElettronicaHeader DESC;
SELECT * FROM FatturaXML.XMLFatture.FatturaElettronicaHeader ORDER BY PKFatturaElettronicaHeader DESC;
GO

/* Procedura completa: Fine */

SELECT * FROM dbo.CliFor WHERE Intestazione LIKE N'%Rezzato%'; -- ID = 'B9E27C25-087E-4D20-A35C-3880F938833E'

SELECT
	D.ID,
	D.Data,
	D.NumeroInt,
	D.Numero

FROM dbo.Documenti D

WHERE D.IDTipo = N'Cli_Fattura'
	AND D.IDCliFor = 'B9E27C25-087E-4D20-A35C-3880F938833E'; -- ID = '1D332091-A2FD-439F-A315-5A6726A47573'

SELECT * FROM dbo.Documenti_Righe DR WHERE DR.IDDocumento = '1D332091-A2FD-439F-A315-5A6726A47573'

SELECT
	DR.IDDocumento,
	DT.DescrizioneSingolare,
	DT.SDI_TipoDocumento,
	D.Data,
	D.NumeroInt,
	D.Numero,
	CF.Intestazione,
	DR.Descrizione1 

FROM dbo.Documenti_Righe DR
INNER JOIN dbo.Documenti D ON D.ID = DR.IDDocumento
INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
	AND DT.SDI_IsValido = CAST(1 AS BIT)
INNER JOIN dbo.CliFor CF ON CF.ID = D.IDCliFor
WHERE DR.Descrizione1 LIKE N'%CIG%'
ORDER BY D.Data,
	D.NumeroInt;

SELECT * FROM dbo.Documenti WHERE ID = '1D332091-A2FD-439F-A315-5A6726A47573';

SELECT * FROM dbo.CliFor WHERE ID = 'B9E27C25-087E-4D20-A35C-3880F938833E';

SELECT
	D.ID,
	D.Numero,
	D.Data,
	D.NumeroInt,
	CF.Intestazione,
	DTO.DescrizioneSingolare,

	DR.SDI_NumeroLinea,
	DR.Descrizione1,
	DR.Qta,
	DR.ImpUnitario,

	'OACQ' AS TipoDocumentoEsterno,
	CASE
	  WHEN DO.IDTipo = 'Cli_Ordine' THEN DO.Numero
	  WHEN DOO.IDTipo = 'Cli_Ordine' THEN DOO.Numero
	  ELSE NULL
	END AS IdDocumento,
	CASE
	  WHEN DO.IDTipo = 'Cli_Ordine' THEN CAST(DO.Data AS DATE)
	  WHEN DOO.IDTipo = 'Cli_Ordine' THEN CAST(DOO.Data AS DATE)
	  ELSE NULL
	END AS Data,
	CASE
	  WHEN DO.IDTipo = 'Cli_Ordine' THEN COALESCE(DO.CodiceCIG, NULL)
	  WHEN DOO.IDTipo = 'Cli_Ordine' THEN COALESCE(DOO.CodiceCIG, NULL)
	  ELSE NULL
	END AS CodiceCIG,
	CASE
	  WHEN DO.IDTipo = 'Cli_Ordine' THEN COALESCE(DO.CodiceCUP, NULL)
	  WHEN DOO.IDTipo = 'Cli_Ordine' THEN COALESCE(DOO.CodiceCUP, NULL)
	  ELSE NULL
	END AS CodiceCUP

FROM dbo.Documenti D
INNER JOIN dbo.CliFor CF ON CF.ID = D.IDCliFor
INNER JOIN dbo.Documenti_Righe DR ON DR.IDDocumento = D.ID
	AND DR.Qta > 0.0
	AND DR.ImpUnitario > 0.0
INNER JOIN dbo.Documenti_Righe DRO ON DRO.ID = DR.IDDocumento_RigaOrigine
INNER JOIN dbo.Documenti DO ON DO.ID = DRO.IDDocumento
INNER JOIN dbo.Documenti_Tipi DTO ON DTO.ID = DO.IDTipo
LEFT JOIN dbo.Documenti_Righe DROO ON DROO.ID = DRO.IDDocumento_RigaOrigine
LEFT JOIN dbo.Documenti DOO ON DOO.ID = DROO.IDDocumento
LEFT JOIN dbo.Documenti_Tipi DTOO ON DTOO.ID = DOO.IDTipo
WHERE D.ID = '1D332091-A2FD-439F-A315-5A6726A47573'
	AND COALESCE(DOO.IDTipo, DO.IDTipo) = N'Cli_Ordine';
GO

SELECT * FROM InVoiceXML.XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno;
GO

SELECT * FROM InVoiceXML.XMLCodifiche.TipoDocumentoEsterno;
GO
