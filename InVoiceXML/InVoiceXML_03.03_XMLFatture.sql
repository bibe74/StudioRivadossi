USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'XMLFatture')
BEGIN
	EXEC ('CREATE SCHEMA XMLFatture AUTHORIZATION dbo;');
END;
GO

DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_Allegati;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiPagamento;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiRiepilogo;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiDDT;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiSAL;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DocumentoEsterno;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_Causale;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody;
DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaHeader;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_Allegati;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiDDT;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiSAL;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_Causale;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_ScontoMaggiorazione;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody;
DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaHeader;
DROP TABLE IF EXISTS XMLFatture.Landing_Fattura;
GO

/**
 * @table XMLFatture.Landing_Fattura
 * @description Tabella di trascodifica tra i documenti del gestionale di origine e il documento di <modulo_fattura_elettronica>
*/

IF OBJECT_ID(N'XMLFatture.seq_Landing_Fattura', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Landing_Fattura
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Landing_Fattura', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Landing_Fattura (
	PKLanding_Fattura BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Landing_Fattura_PKLanding_Fattura DEFAULT (NEXT VALUE FOR XMLFatture.seq_Landing_Fattura),
	ChiaveGestionale_CodiceNumerico BIGINT NOT NULL,
	ChiaveGestionale_CodiceAlfanumerico NVARCHAR(40) NOT NULL,
	IsUltimaRevisione BIT NOT NULL,

	CONSTRAINT PK_XMLFatture_Landing_Fattura PRIMARY KEY CLUSTERED (PKLanding_Fattura)

);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaHeader
 * @description Dati di testata della fattura elettronica (tabella di staging)

 * @references XMLFatture.Landing_Fattura
*/

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaHeader', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaHeader
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaHeader', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaHeader (
	PKStaging_FatturaElettronicaHeader BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaHeader DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaHeader),
	PKLanding_Fattura BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaHeader_PKLanding_Fattura FOREIGN KEY REFERENCES XMLFatture.Landing_Fattura (PKLanding_Fattura),

	DataOraInserimento DATETIME2 NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaHeader_DataOraInserimento DEFAULT (CURRENT_TIMESTAMP),
	IsValida BIT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaHeader_IsValida DEFAULT (0),
	DataOraUltimaValidazione DATETIME2 NULL,

	-- 1.1 DatiTrasmissione_
	-- 1.1.1 IdTrasmittente_
	DatiTrasmissione_IdTrasmittente_IdPaese CHAR(2) NULL,
	DatiTrasmissione_IdTrasmittente_IdCodice NVARCHAR(28) NULL,

	DatiTrasmissione_ProgressivoInvio NVARCHAR(10) NULL,
	DatiTrasmissione_FormatoTrasmissione CHAR(5) NULL,
	DatiTrasmissione_CodiceDestinatario NVARCHAR(7) NULL,

	-- 1.1.5	 ContattiTrasmittente
	DatiTrasmissione_ContattiTrasmittente_Telefono NVARCHAR(12) NULL,
	DatiTrasmissione_ContattiTrasmittente_Email NVARCHAR(256) NULL,

	DatiTrasmissione_PECDestinatario NVARCHAR(256) NULL,

	-- 1.2 CedentePrestatore_
	-- 1.2.1 DatiAnagrafici_
	-- 1.2.1.1 IdFiscaleIVA_
	CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NULL,
	CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	CedentePrestatore_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.2.1.3 Anagrafica_
	CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,
	CedentePrestatore_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	CedentePrestatore_DatiAnagrafici_AlboProfessionale NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_ProvinciaAlbo CHAR(2) NULL,
	CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo DATE NULL,	
	CedentePrestatore_DatiAnagrafici_RegimeFiscale CHAR(4) NULL,

	-- 1.2.2 Sede_
	CedentePrestatore_Sede_Indirizzo NVARCHAR(60) NULL,	
	CedentePrestatore_Sede_NumeroCivico NVARCHAR(8) NULL,	
	CedentePrestatore_Sede_CAP CHAR(5) NULL,	
	CedentePrestatore_Sede_Comune NVARCHAR(60) NULL,	
	CedentePrestatore_Sede_Provincia CHAR(2) NULL,
	CedentePrestatore_Sede_Nazione CHAR(2) NULL,
	
	-- 1.2.3 StabileOrganizzazione_
	CedentePrestatore_StabileOrganizzazione_Indirizzo NVARCHAR(60) NULL,	
	CedentePrestatore_StabileOrganizzazione_NumeroCivico NVARCHAR(8) NULL,	
	CedentePrestatore_StabileOrganizzazione_CAP CHAR(5) NULL,	
	CedentePrestatore_StabileOrganizzazione_Comune NVARCHAR(60) NULL,	
	CedentePrestatore_StabileOrganizzazione_Provincia CHAR(2) NULL,
	CedentePrestatore_StabileOrganizzazione_Nazione CHAR(2) NULL,
	
	-- 1.2.4 IscrizioneREA_
	CedentePrestatore_IscrizioneREA_Ufficio CHAR(2) NULL,
	CedentePrestatore_IscrizioneREA_NumeroREA NVARCHAR(20) NULL,	
	CedentePrestatore_IscrizioneREA_CapitaleSociale DECIMAL(14, 2) NULL,	
	CedentePrestatore_IscrizioneREA_SocioUnico CHAR(2) NULL,
	CedentePrestatore_IscrizioneREA_StatoLiquidazione CHAR(2) NULL,
	
	-- 1.2.5 Contatti_
	CedentePrestatore_Contatti_Telefono NVARCHAR(12) NULL,	
	CedentePrestatore_Contatti_Fax NVARCHAR(12) NULL,	
	CedentePrestatore_Contatti_Email NVARCHAR(256) NULL,	
	CedentePrestatore_RiferimentoAmministrazione NVARCHAR(20) NULL,	

	-- 1.3 RappresentanteFiscale_
	-- 1.3.1 DatiAnagrafici_
	-- 1.3.1.1 IdFiscaleIVA_
	RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NULL,
	RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	RappresentanteFiscale_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.3.1.3 Anagrafica_
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	-- 1.4 CessionarioCommittente_
	-- 1.4.1 DatiAnagrafici_
	-- 1.4.1.1 IdFiscaleIVA_
	CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NULL,
	CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	CessionarioCommittente_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.4.1.3 Anagrafica_
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	-- 1.4.2 Sede_
	CessionarioCommittente_Sede_Indirizzo NVARCHAR(60) NULL,	
	CessionarioCommittente_Sede_NumeroCivico NVARCHAR(8) NULL,	
	CessionarioCommittente_Sede_CAP CHAR(5) NULL,	
	CessionarioCommittente_Sede_Comune NVARCHAR(60) NULL,
	CessionarioCommittente_Sede_Provincia CHAR(2) NULL,
	CessionarioCommittente_Sede_Nazione CHAR(2) NULL,

	-- 1.4.3 StabileOrganizzazione_
	CessionarioCommittente_StabileOrganizzazione_Indirizzo NVARCHAR(60) NULL,	
	CessionarioCommittente_StabileOrganizzazione_NumeroCivico NVARCHAR(8) NULL,	
	CessionarioCommittente_StabileOrganizzazione_CAP CHAR(5) NULL,	
	CessionarioCommittente_StabileOrganizzazione_Comune NVARCHAR(60) NULL,	
	CessionarioCommittente_StabileOrganizzazione_Provincia CHAR(2) NULL,
	CessionarioCommittente_StabileOrganizzazione_Nazione CHAR(2) NULL,

	-- 1.4.4 RappresentanteFiscale_
	-- 1.4.4.1 IdFiscaleIVA_
	CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese CHAR(2) NULL,
	CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	CessionarioCommittente_RappresentanteFiscale_Denominazione NVARCHAR(80) NULL,
	CessionarioCommittente_RappresentanteFiscale_Nome NVARCHAR(60) NULL,	
	CessionarioCommittente_RappresentanteFiscale_Cognome NVARCHAR(60) NULL,	

	-- 1.5 TerzoIntermediarioOSoggettoEmittente_
	-- 1.5.1 DatiAnagrafici_
	-- 1.5.1.1 IdFiscaleIVA_
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NULL,
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.5.2 Anagrafica_
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	SoggettoEmittente CHAR(2) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaHeader PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaHeader)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaHeader
 * @description Dati di testata della fattura elettronica (tabella ufficiale)

 * @references XMLFatture.Landing_Fattura
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaHeader;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaHeader', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaHeader
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaHeader', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaHeader (
	PKFatturaElettronicaHeader BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaHeader),
	PKLanding_Fattura BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_PKLanding_Fattura FOREIGN KEY REFERENCES XMLFatture.Landing_Fattura (PKLanding_Fattura),
	PKStaging_FatturaElettronicaHeader BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_PKStaging_FatturaElettronicaHeader FOREIGN KEY REFERENCES XMLFatture.Staging_FatturaElettronicaHeader (PKStaging_FatturaElettronicaHeader),

	DataOraInserimento DATETIME2 NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_DataOraInserimento DEFAULT (CURRENT_TIMESTAMP),
	IsEsportata BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_IsEsportata DEFAULT (0),
	DataOraUltimaEsportazione DATETIME2 NULL,
	IsValidataDaSDI BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_IsValidataDaSDI DEFAULT (0),

	-- 1.1 DatiTrasmissione_
	-- 1.1.1 IdTrasmittente_
	DatiTrasmissione_IdTrasmittente_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_111_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	DatiTrasmissione_IdTrasmittente_IdCodice NVARCHAR(28) NOT NULL,

	DatiTrasmissione_ProgressivoInvio NVARCHAR(10) NOT NULL,
	DatiTrasmissione_FormatoTrasmissione CHAR(5) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_11_FormatoTrasmissione REFERENCES XMLCodifiche.FormatoTrasmissione (IDFormatoTrasmissione),
	DatiTrasmissione_CodiceDestinatario NVARCHAR(7) NOT NULL,

	-- 1.1.5	 ContattiTrasmittente
	DatiTrasmissione_HasContattiTrasmittente BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_115_HasContattiTrasmittente DEFAULT (0),
	DatiTrasmissione_ContattiTrasmittente_Telefono NVARCHAR(12) NULL,
	DatiTrasmissione_ContattiTrasmittente_Email NVARCHAR(256) NULL,

	DatiTrasmissione_PECDestinatario NVARCHAR(256) NULL,

	-- 1.2 CedentePrestatore_
	-- 1.2.1 DatiAnagrafici_
	-- 1.2.1.1 IdFiscaleIVA_
	CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_1211_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NOT NULL,

	CedentePrestatore_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.2.1.3 Anagrafica_
	CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,
	CedentePrestatore_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	CedentePrestatore_DatiAnagrafici_AlboProfessionale NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_ProvinciaAlbo CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_121_ProvinciaAlbo REFERENCES XMLCodifiche.Provincia (IDProvincia),
	CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo NVARCHAR(60) NULL,	
	CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo DATE NULL,	
	CedentePrestatore_DatiAnagrafici_RegimeFiscale CHAR(4) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_RegimeFiscale FOREIGN KEY REFERENCES XMLCodifiche.RegimeFiscale (IDRegimeFiscale),	

	-- 1.2.2 Sede_
	CedentePrestatore_Sede_Indirizzo NVARCHAR(60) NOT NULL,	
	CedentePrestatore_Sede_NumeroCivico NVARCHAR(8) NULL,	
	CedentePrestatore_Sede_CAP CHAR(5) NOT NULL,	
	CedentePrestatore_Sede_Comune NVARCHAR(60) NULL,	
	CedentePrestatore_Sede_Provincia CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_122_Provincia REFERENCES XMLCodifiche.Provincia (IDProvincia),
	CedentePrestatore_Sede_Nazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_122_Nazione FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	
	-- 1.2.3 StabileOrganizzazione_
	CedentePrestatore_HasStabileOrganizzazione BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_123_HasStabileOrganizzazione DEFAULT (0),
	CedentePrestatore_StabileOrganizzazione_Indirizzo NVARCHAR(60) NULL,	
	CedentePrestatore_StabileOrganizzazione_NumeroCivico NVARCHAR(8) NULL,	
	CedentePrestatore_StabileOrganizzazione_CAP CHAR(5) NULL,	
	CedentePrestatore_StabileOrganizzazione_Comune NVARCHAR(60) NULL,	
	CedentePrestatore_StabileOrganizzazione_Provincia CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_123_Provincia REFERENCES XMLCodifiche.Provincia (IDProvincia),
	CedentePrestatore_StabileOrganizzazione_Nazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_123_Nazione FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	
	-- 1.2.4 IscrizioneREA_
	CedentePrestatore_HasIscrizioneREA BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_124_HasIscrizioneREA DEFAULT (0),
	CedentePrestatore_IscrizioneREA_Ufficio CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_124_Ufficio REFERENCES XMLCodifiche.Provincia (IDProvincia),
	CedentePrestatore_IscrizioneREA_NumeroREA NVARCHAR(20) NULL,	
	CedentePrestatore_IscrizioneREA_CapitaleSociale DECIMAL(14, 2) NULL,	
	CedentePrestatore_IscrizioneREA_SocioUnico CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_124_SocioUnico REFERENCES XMLCodifiche.SocioUnico (IDSocioUnico),
	CedentePrestatore_IscrizioneREA_StatoLiquidazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_124_StatoLiquidazione REFERENCES XMLCodifiche.StatoLiquidazione (IDStatoLiquidazione),
	
	-- 1.2.5 Contatti_
	CedentePrestatore_HasContatti BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_125_HasContatti DEFAULT (0),
	CedentePrestatore_Contatti_Telefono NVARCHAR(12) NULL,	
	CedentePrestatore_Contatti_Fax NVARCHAR(12) NULL,	
	CedentePrestatore_Contatti_Email NVARCHAR(256) NULL,	
	CedentePrestatore_RiferimentoAmministrazione NVARCHAR(20) NULL,	

	-- 1.3 RappresentanteFiscale_
	-- 1.3.1 DatiAnagrafici_
	-- 1.3.1.1 IdFiscaleIVA_
	HasRappresentanteFiscale BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_13_HasRappresentanteFiscale DEFAULT (0),
	RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_1311_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	RappresentanteFiscale_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.3.1.3 Anagrafica_
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	-- 1.4 CessionarioCommittente_
	-- 1.4.1 DatiAnagrafici_
	-- 1.4.1.1 IdFiscaleIVA_
	CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_1411_HasIdFiscaleIVA DEFAULT (0),
	CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_1411_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	CessionarioCommittente_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.4.1.3 Anagrafica_
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	-- 1.4.2 Sede_
	CessionarioCommittente_Sede_Indirizzo NVARCHAR(60) NULL,	
	CessionarioCommittente_Sede_NumeroCivico NVARCHAR(8) NULL,	
	CessionarioCommittente_Sede_CAP CHAR(5) NULL,	
	CessionarioCommittente_Sede_Comune NVARCHAR(60) NULL,
	CessionarioCommittente_Sede_Provincia CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_142_Provincia REFERENCES XMLCodifiche.Provincia (IDProvincia),
	CessionarioCommittente_Sede_Nazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_142_Nazione FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),

	-- 1.4.3 StabileOrganizzazione_
	CessionarioCommittente_HasStabileOrganizzazione BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_143_HasStabileOrganizzazione DEFAULT (0),
	CessionarioCommittente_StabileOrganizzazione_Indirizzo NVARCHAR(60) NULL,	
	CessionarioCommittente_StabileOrganizzazione_NumeroCivico NVARCHAR(8) NULL,	
	CessionarioCommittente_StabileOrganizzazione_CAP CHAR(5) NULL,	
	CessionarioCommittente_StabileOrganizzazione_Comune NVARCHAR(60) NULL,	
	CessionarioCommittente_StabileOrganizzazione_Provincia CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_143_Provincia REFERENCES XMLCodifiche.Provincia (IDProvincia),
	CessionarioCommittente_StabileOrganizzazione_Nazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_143_Nazione FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),

	-- 1.4.4 RappresentanteFiscale_
	CessionarioCommittente_HasRappresentanteFiscale BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_144_HasRappresentanteFiscale DEFAULT (0),
	-- 1.4.4.1 IdFiscaleIVA_
	CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_1441_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	CessionarioCommittente_RappresentanteFiscale_Denominazione NVARCHAR(80) NULL,
	CessionarioCommittente_RappresentanteFiscale_Nome NVARCHAR(60) NULL,	
	CessionarioCommittente_RappresentanteFiscale_Cognome NVARCHAR(60) NULL,	

	-- 1.5 TerzoIntermediarioOSoggettoEmittente_
	HasTerzoIntermediarioOSoggettoEmittente BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_15_HasTerzoIntermediarioOSoggettoEmittente DEFAULT (0),
	-- 1.5.1 DatiAnagrafici_
	-- 1.5.1.1 IdFiscaleIVA_
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_1511_HasIdFiscaleIVA DEFAULT (0),
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_1511_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale NVARCHAR(16) NULL,

	-- 1.5.2 Anagrafica_
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione NVARCHAR(80) NULL,
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome NVARCHAR(60) NULL,	
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome NVARCHAR(60) NULL,	
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo NVARCHAR(10) NULL,	
	TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	SoggettoEmittente CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaHeader_1_SoggettoEmittente REFERENCES XMLCodifiche.SoggettoEmittente (IDSoggettoEmittente),

	XMLOutput XML NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaHeader PRIMARY KEY CLUSTERED (PKFatturaElettronicaHeader)
);

-- Default per referenze a XMLCodifiche.Nazione.IDNazione
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_DatiTrasmissione_IdTrasmittente_IdPaese DEFAULT('') FOR DatiTrasmissione_IdTrasmittente_IdPaese;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese DEFAULT('') FOR CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_Sede_Nazione DEFAULT('') FOR CedentePrestatore_Sede_Nazione;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_StabileOrganizzazione_Nazione DEFAULT('') FOR CedentePrestatore_StabileOrganizzazione_Nazione;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese DEFAULT('') FOR RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese DEFAULT('') FOR CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CessionarioCommittente_Sede_Nazione DEFAULT('') FOR CessionarioCommittente_Sede_Nazione;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CessionarioCommittente_StabileOrganizzazione_Nazione DEFAULT('') FOR CessionarioCommittente_StabileOrganizzazione_Nazione;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese DEFAULT('') FOR CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese DEFAULT('') FOR TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese;

-- Default per referenze a XMLCodifiche.Provincia.IDProvincia
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_DatiAnagrafici_ProvinciaAlbo DEFAULT('') FOR CedentePrestatore_DatiAnagrafici_ProvinciaAlbo;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_IscrizioneREA_Ufficio DEFAULT('') FOR CedentePrestatore_IscrizioneREA_Ufficio;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_Sede_Provincia DEFAULT('') FOR CedentePrestatore_Sede_Provincia;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_StabileOrganizzazione_Provincia DEFAULT('') FOR CedentePrestatore_StabileOrganizzazione_Provincia;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CessionarioCommittente_Sede_Provincia DEFAULT('') FOR CessionarioCommittente_Sede_Provincia;
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CessionarioCommittente_StabileOrganizzazione_Provincia DEFAULT('') FOR CessionarioCommittente_StabileOrganizzazione_Provincia;

-- Default per referenze a XMLCodifiche.FormatoTrasmissione.IDFormatoTrasmissione
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_DatiTrasmissione_FormatoTrasmissione DEFAULT('') FOR DatiTrasmissione_FormatoTrasmissione;

-- Default per referenze a XMLCodifiche.RegimeFiscale.IDRegimeFiscale
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_CedentePrestatore_DatiAnagrafici_RegimeFiscale DEFAULT('') FOR CedentePrestatore_DatiAnagrafici_RegimeFiscale;

-- Default per referenze a XMLCodifiche.SocioUnico.IDSocioUnico
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_CedentePrestatore_IscrizioneREA_SocioUnico DEFAULT('') FOR CedentePrestatore_IscrizioneREA_SocioUnico;

-- Default per referenze a XMLCodifiche.StatoLiquidazione.IDStatoLiquidazione
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_CedentePrestatore_IscrizioneREA_StatoLiquidazione DEFAULT('') FOR CedentePrestatore_IscrizioneREA_StatoLiquidazione;

-- Default per referenze a XMLCodifiche.SoggettoEmittente.IDSoggettoEmittente
ALTER TABLE XMLFatture.FatturaElettronicaHeader ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaHeader_CedentePrestatore_SoggettoEmittente DEFAULT('') FOR SoggettoEmittente;

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale)

 * @references XMLFatture.Landing_Fattura
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody (
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody),
	PKStaging_FatturaElettronicaHeader BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_PKStaging_FatturaElettronicaHeader REFERENCES XMLFatture.Staging_FatturaElettronicaHeader (PKStaging_FatturaElettronicaHeader),

	-- 2.1 DatiGenerali_
	-- 2.1.1 DatiGeneraliDocumento_
	DatiGenerali_DatiGeneraliDocumento_TipoDocumento CHAR(4) NULL,
	DatiGenerali_DatiGeneraliDocumento_Divisa CHAR(3) NULL,
	DatiGenerali_DatiGeneraliDocumento_Data DATE NULL,
	DatiGenerali_DatiGeneraliDocumento_Numero NVARCHAR(20) NULL,

	-- 2.1.1.5 DatiRitenuta_
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta CHAR(4) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta DECIMAL(14, 2) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta DECIMAL(5, 2) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento CHAR(2) NULL,

	-- 2.1.1.6 DatiBollo_
	DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale CHAR(2) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo DECIMAL(14, 2) NULL,

	DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento DECIMAL(14, 2) NULL,
	DatiGenerali_DatiGeneraliDocumento_Arrotondamento DECIMAL(14, 2) NULL,

	DatiGenerali_DatiGeneraliDocumento_Art73 CHAR(2) NULL,

	-- 2.1.9 DatiTrasporto_
	-- 2.1.9.1 DatiAnagraficiVettore_
	-- 2.1.9.1.1 IdFiscaleIVA_
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese CHAR(2) NULL,
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale NVARCHAR(16) NULL,

	-- 2.1.9.1.3 Anagrafica_
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione NVARCHAR(80) NULL,
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo NVARCHAR(10) NULL,	
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida NVARCHAR(20) NULL,

	DatiGenerali_DatiTrasporto_MezzoTrasporto NVARCHAR(80) NULL,
	DatiGenerali_DatiTrasporto_CausaleTrasporto NVARCHAR(100) NULL,
	DatiGenerali_DatiTrasporto_NumeroColli INT NULL,
	DatiGenerali_DatiTrasporto_Descrizione NVARCHAR(100) NULL,
	DatiGenerali_DatiTrasporto_UnitaMisuraPeso NVARCHAR(10) NULL,
	DatiGenerali_DatiTrasporto_PesoLordo DECIMAL(6,2) NULL,
	DatiGenerali_DatiTrasporto_PesoNetto DECIMAL(6,2) NULL,
	DatiGenerali_DatiTrasporto_DataOraRitiro DATETIME NULL,
	DatiGenerali_DatiTrasporto_DataInizioTrasporto DATE NULL,
	DatiGenerali_DatiTrasporto_TipoResa CHAR(3) NULL,

	-- 2.1.9.12 IndirizzoResa_
	DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico NVARCHAR(8) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_CAP CHAR(5) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_Comune NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia CHAR(2) NULL,
	DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione CHAR(2) NULL,

	DatiGenerali_DatiTrasporto_DataOraConsegna DATETIME NULL,

	-- 2.1.10 FatturaPrincipale_
	DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale NVARCHAR(20) NULL,
	DatiGenerali_FatturaPrincipale_DataFatturaPrincipale DATE NULL,

	-- 2.3 DatiVeicoli_
	DatiVeicoli_Data DATE NULL,
	DatiVeicoli_TotalePercorso NVARCHAR(15) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiCassaPrevidenziale
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiCassaPrevidenziale (
	PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	TipoCassa CHAR(4) NULL,
	AlCassa DECIMAL(5, 2) NULL,
	ImportoContributoCassa DECIMAL(14, 2) NULL,
	ImponibileCassa DECIMAL(14, 2) NULL,
	AliquotaIVA DECIMAL(5, 2) NULL,
	Ritenuta CHAR(2) NULL,
	Natura CHAR(2) NULL,
	RiferimentoAmministrazione NVARCHAR(20) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiCassaPrevidenziale PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiCassaPrevidenziale)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_ScontoMaggiorazione
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): ScontoMaggiorazione
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_ScontoMaggiorazione;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_ScontoMaggiorazione', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_ScontoMaggiorazione
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_ScontoMaggiorazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_ScontoMaggiorazione (
	PKStaging_FatturaElettronicaBody_ScontoMaggiorazione BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_ScontoMaggiorazione DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_ScontoMaggiorazione),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_ScontoMaggiorazione_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	Tipo CHAR(2) NULL,
	Percentuale DECIMAL(5, 2) NULL,
	Importo DECIMAL(14, 2) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_ScontoMaggiorazione PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_ScontoMaggiorazione)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_Causale
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): Causale
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_Causale;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_Causale', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_Causale
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_Causale', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_Causale (
	PKStaging_FatturaElettronicaBody_Causale BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_Causale DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_Causale),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_Causale_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	DatiGenerali_Causale NVARCHAR(200) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_Causale PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_Causale)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DocumentoEsterno (ordine, DDT, ecc.)
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DocumentoEsterno', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DocumentoEsterno
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno (
	PKStaging_FatturaElettronicaBody_DocumentoEsterno BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DocumentoEsterno DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DocumentoEsterno),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DocumentoEsterno_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	TipoDocumentoEsterno CHAR(4) NULL, -- OACQ: OrdineAcquisto, CNTR: Contratto; CNVN: Convenzione, RCZN: Ricezione, FTCL: FattureCollegate
	IdDocumento NVARCHAR(20) NULL,
	Data DATE NULL,
	NumItem NVARCHAR(20) NULL,
	CodiceCommessaConvenzione NVARCHAR(100) NULL,
	CodiceCUP NVARCHAR(15) NULL,
	CodiceCIG NVARCHAR(15) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DocumentoEsterno PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DocumentoEsterno)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DocumentoEsterno - RiferimentoNumeroLinea
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea (
	PKStaging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea),
	PKStaging_FatturaElettronicaBody_DocumentoEsterno BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea_DocumentoEsterno REFERENCES XMLFatture.Staging_FatturaElettronicaBody_DocumentoEsterno (PKStaging_FatturaElettronicaBody_DocumentoEsterno),

	RiferimentoNumeroLinea INT NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiSAL
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiSAL
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiSAL;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiSAL', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiSAL
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiSAL', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiSAL (
	PKStaging_FatturaElettronicaBody_DatiSAL BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiSAL DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiSAL),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DatiSAL_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	RiferimentoFase INT NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiSAL PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiSAL)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiDDT
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiDDT
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiDDT;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiDDT', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiDDT
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiDDT', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiDDT (
	PKStaging_FatturaElettronicaBody_DatiDDT BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiDDT DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiDDT),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DatiDDT_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	NumeroDDT NVARCHAR(20) NULL,
	DataDDT DATE NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiDDT PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiDDT)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiDDT - RiferimentoNumeroLinea
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea (
	PKStaging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea),
	PKStaging_FatturaElettronicaBody_DatiDDT BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea_PKStaging_FatturaElettronicaBody_DatiDDT REFERENCES XMLFatture.Staging_FatturaElettronicaBody_DatiDDT (PKStaging_FatturaElettronicaBody_DatiDDT),

	RiferimentoNumeroLinea INT NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee (
	PKStaging_FatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	-- 2.2.1 DettaglioLinee_
	NumeroLinea INT NULL,
	TipoCessionePrestazione CHAR(2) NULL,

	Descrizione NVARCHAR(1000) NULL,
	Quantita DECIMAL(20, 5) NULL,
	UnitaMisura NVARCHAR(10) NULL,
	DataInizioPeriodo DATE NULL,
	DataFinePeriodo DATE NULL,
	PrezzoUnitario DECIMAL(20, 5) NULL,

	PrezzoTotale DECIMAL(20, 5) NULL,
	AliquotaIVA DECIMAL(5, 2) NULL,
	Ritenuta CHAR(2) NULL,
	Natura CHAR(2) NULL,
	RiferimentoAmministrazione NVARCHAR(20) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DettaglioLinee)
);

CREATE UNIQUE NONCLUSTERED INDEX IX_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_PKStaging_FatturaElettronicaBody_NumeroLinea ON XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee (PKStaging_FatturaElettronicaBody, NumeroLinea);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee - CodiceArticolo
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo (
	PKStaging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo),
	PKStaging_FatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo_PKStaging_FatturaElettronicaBody_DettaglioLinee REFERENCES XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee (PKStaging_FatturaElettronicaBody_DettaglioLinee),

	-- 2.2.1.3 CodiceArticolo_
	CodiceArticolo_CodiceTipo NVARCHAR(35) NULL,
	CodiceArticolo_CodiceValore NVARCHAR(35) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee - ScontoMaggiorazione
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione (
	PKStaging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione),
	PKStaging_FatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione_PKStaging_FatturaElettronicaBody_DettaglioLinee REFERENCES XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee (PKStaging_FatturaElettronicaBody_DettaglioLinee),

	-- 2.2.1.10 ScontoMaggiorazione_
	ScontoMaggiorazione_Tipo CHAR(2) NULL,
	ScontoMaggiorazione_Percentuale DECIMAL(5, 2) NULL,
	ScontoMaggiorazione_Importo DECIMAL(14, 2) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee - AltriDatiGestionali
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali (
	PKStaging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali),
	PKStaging_FatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali_PKStaging_FatturaElettronicaBody_DettaglioLinee REFERENCES XMLFatture.Staging_FatturaElettronicaBody_DettaglioLinee (PKStaging_FatturaElettronicaBody_DettaglioLinee),

	-- 2.2.1.16 AltriDatiGestionali_
	AltriDatiGestionali_TipoDato NVARCHAR(10) NULL,
	AltriDatiGestionali_RiferimentoTesto NVARCHAR(60) NULL,
	AltriDatiGestionali_RiferimentoNumero DECIMAL(20, 5) NULL,
	AltriDatiGestionali_RiferimentoData DATE NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiRiepilogo
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiRiepilogo', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiRiepilogo
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiRiepilogo (
	PKStaging_FatturaElettronicaBody_DatiRiepilogo BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiRiepilogo DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiRiepilogo),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DatiRiepilogo_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	AliquotaIVA DECIMAL(5, 2) NULL,
	Natura CHAR(2) NULL,
	SpeseAccessorie DECIMAL(14, 2) NULL,
	Arrotondamento DECIMAL(20, 2) NULL,
	ImponibileImporto DECIMAL(14, 2) NULL,
	Imposta DECIMAL(14, 2) NULL,
	EsigibilitaIVA CHAR(1) NULL,
	RiferimentoNormativo NVARCHAR(100) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiRiepilogo PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiRiepilogo)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiPagamento
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiPagamento', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiPagamento
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento (
	PKStaging_FatturaElettronicaBody_DatiPagamento BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiPagamento DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiPagamento),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DatiPagamento_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	-- 2.4 DatiPagamento_
	CondizioniPagamento CHAR(4) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiPagamento PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiPagamento)
);

-- Default per referenze a XMLCodifiche.CondizioniPagamento.IDCondizioniPagamento
ALTER TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento ADD CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiPagamento_CondizioniPagamento DEFAULT('') FOR CondizioniPagamento;

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiPagamento - DettaglioPagamento
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento (
	PKStaging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento),
	PKStaging_FatturaElettronicaBody_DatiPagamento BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_DettaglioPagamento_PKStaging_FatturaElettronicaBody_DatiPagamento REFERENCES XMLFatture.Staging_FatturaElettronicaBody_DatiPagamento (PKStaging_FatturaElettronicaBody_DatiPagamento),

	Beneficiario NVARCHAR(200) NULL,
	ModalitaPagamento CHAR(4) NULL,
	DataRiferimentoTerminiPagamento DATE NULL,
	GiorniTerminiPagamento INT NULL,
	DataScadenzaPagamento DATE NULL,
	ImportoPagamento DECIMAL(14, 2) NULL,
	CodUfficioPostale NVARCHAR(20) NULL,
	CognomeQuietanzante NVARCHAR(60) NULL,
	NomeQuietanzante NVARCHAR(60) NULL,
	CFQuietanzante NVARCHAR(16) NULL,
	TitoloQuietanzante NVARCHAR(10) NULL,
	IstitutoFinanziario NVARCHAR(80) NULL,
	IBAN NVARCHAR(34) NULL,
	ABI INT NULL,
	CAB INT NULL,
	BIC NVARCHAR(11) NULL,
	ScontoPagamentoAnticipato DECIMAL(14, 2) NULL,
	DataLimitePagamentoAnticipato DATE NULL,
	PenalitaPagamentiRitardati DECIMAL(14, 2) NULL,
	DataDecorrenzaPenale DATE NULL,
	CodicePagamento NVARCHAR(60) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento)
);

END;
GO

/**
 * @table XMLFatture.Staging_FatturaElettronicaBody_Allegati
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): Allegati
*/

--DROP TABLE IF EXISTS XMLFatture.Staging_FatturaElettronicaBody_Allegati;
GO

IF OBJECT_ID(N'XMLFatture.seq_Staging_FatturaElettronicaBody_Allegati', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_Staging_FatturaElettronicaBody_Allegati
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.Staging_FatturaElettronicaBody_Allegati', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.Staging_FatturaElettronicaBody_Allegati (
	PKStaging_FatturaElettronicaBody_Allegati BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_Staging_FatturaElettronicaBody_Allegati DEFAULT (NEXT VALUE FOR XMLFatture.seq_Staging_FatturaElettronicaBody_Allegati),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_Staging_FatturaElettronicaBody_Allegati_PKStaging_FatturaElettronicaBody REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	NomeAttachment NVARCHAR(60) NULL,
	AlgoritmoCompressione NVARCHAR(10) NULL,
	FormatoAttachment NVARCHAR(10) NULL,
	DescrizioneAttachment NVARCHAR(100) NULL,
	Attachment VARCHAR(MAX) NULL,

	CONSTRAINT PK_XMLFatture_Staging_FatturaElettronicaBody_Allegati PRIMARY KEY CLUSTERED (PKStaging_FatturaElettronicaBody_Allegati)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale)

 * @references XMLFatture.Landing_Fattura
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody (
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody),
	PKFatturaElettronicaHeader BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_PKFatturaElettronicaHeader REFERENCES XMLFatture.FatturaElettronicaHeader (PKFatturaElettronicaHeader),
	PKStaging_FatturaElettronicaBody BIGINT NOT NULL , --CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_PKStaging_FatturaElettronicaBody FOREIGN KEY REFERENCES XMLFatture.Staging_FatturaElettronicaBody (PKStaging_FatturaElettronicaBody),

	-- 2.1 DatiGenerali_
	-- 2.1.1 DatiGeneraliDocumento_
	DatiGenerali_DatiGeneraliDocumento_TipoDocumento CHAR(4) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_211_TipoDocumento REFERENCES XMLCodifiche.TipoDocumento (IDTipoDocumento),
	DatiGenerali_DatiGeneraliDocumento_Divisa CHAR(3) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_211_Divisa FOREIGN KEY REFERENCES XMLCodifiche.Valuta (IDValuta),
	DatiGenerali_DatiGeneraliDocumento_Data DATE NOT NULL,
	DatiGenerali_DatiGeneraliDocumento_Numero NVARCHAR(20) NOT NULL,

	-- 2.1.1.5 DatiRitenuta_
	DatiGenerali_DatiGeneraliDocumento_HasDatiRitenuta BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_2115_DatiRitenuta DEFAULT (0),
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta CHAR(4) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_2115_TipoRitenuta FOREIGN KEY REFERENCES XMLCodifiche.TipoRitenuta (IDTipoRitenuta),
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_ImportoRitenuta DECIMAL(14, 2) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_AliquotaRitenuta DECIMAL(5, 2) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_2115_CausalePagamento FOREIGN KEY REFERENCES XMLCodifiche.CausalePagamento (IDCausalePagamento),

	-- 2.1.1.6 DatiBollo_
	DatiGenerali_DatiGeneraliDocumento_HasDatiBollo BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_2116_DatiBollo DEFAULT (0),
	DatiGenerali_DatiGeneraliDocumento_DatiBollo_BolloVirtuale CHAR(2) NULL,
	DatiGenerali_DatiGeneraliDocumento_DatiBollo_ImportoBollo DECIMAL(14, 2) NULL,

	DatiGenerali_DatiGeneraliDocumento_ImportoTotaleDocumento DECIMAL(14, 2) NULL,
	DatiGenerali_DatiGeneraliDocumento_Arrotondamento DECIMAL(14, 2) NULL,

	DatiGenerali_DatiGeneraliDocumento_Art73 CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_21_Art73 FOREIGN KEY REFERENCES XMLCodifiche.RispostaSI (IDRispostaSI),

	-- 2.1.9 DatiTrasporto_
	DatiGenerali_HasDatiTrasporto BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_219_DatiTrasporto DEFAULT (0),
	-- 2.1.9.1 DatiAnagraficiVettore_
	-- 2.1.9.1.1 IdFiscaleIVA_
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_21911_IdPaese FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdCodice NVARCHAR(28) NULL,

	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_CodiceFiscale NVARCHAR(16) NULL,

	-- 2.1.9.1.3 Anagrafica_
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Denominazione NVARCHAR(80) NULL,
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Nome NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Cognome NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_Titolo NVARCHAR(10) NULL,	
	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_Anagrafica_CodEORI NVARCHAR(17) NULL,	

	DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_NumeroLicenzaGuida NVARCHAR(20) NULL,

	DatiGenerali_DatiTrasporto_MezzoTrasporto NVARCHAR(80) NULL,
	DatiGenerali_DatiTrasporto_CausaleTrasporto NVARCHAR(100) NULL,
	DatiGenerali_DatiTrasporto_NumeroColli INT NULL,
	DatiGenerali_DatiTrasporto_Descrizione NVARCHAR(100) NULL,
	DatiGenerali_DatiTrasporto_UnitaMisuraPeso NVARCHAR(10) NULL,
	DatiGenerali_DatiTrasporto_PesoLordo DECIMAL(6,2) NULL,
	DatiGenerali_DatiTrasporto_PesoNetto DECIMAL(6,2) NULL,
	DatiGenerali_DatiTrasporto_DataOraRitiro DATETIME NULL,
	DatiGenerali_DatiTrasporto_DataInizioTrasporto DATE NULL,
	DatiGenerali_DatiTrasporto_TipoResa CHAR(3) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_219_TipoResa FOREIGN KEY REFERENCES XMLCodifiche.TipoResa (IDTipoResa),

	-- 2.1.9.12 IndirizzoResa_
	DatiGenerali_DatiTrasporto_HasIndirizzoResa BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_21912_IndirizzoResa DEFAULT (0),
	DatiGenerali_DatiTrasporto_IndirizzoResa_Indirizzo NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_NumeroCivico NVARCHAR(8) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_CAP CHAR(5) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_Comune NVARCHAR(60) NULL,	
	DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_21912_Provincia REFERENCES XMLCodifiche.Provincia (IDProvincia),
	DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronica_21912_Nazione FOREIGN KEY REFERENCES XMLCodifiche.Nazione (IDNazione),

	DatiGenerali_DatiTrasporto_DataOraConsegna DATETIME NULL,

	-- 2.1.10 FatturaPrincipale_
	DatiGenerali_HasFatturaPrincipale BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_2110_FatturaPrincipale DEFAULT (0),
	DatiGenerali_FatturaPrincipale_NumeroFatturaPrincipale NVARCHAR(20) NULL,
	DatiGenerali_FatturaPrincipale_DataFatturaPrincipale DATE NULL,

	-- 2.3 DatiVeicoli_
	DatiGenerali_HasDatiVeicoli BIT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_23_DatiVeicoli DEFAULT (0),
	DatiVeicoli_Data DATE NULL,
	DatiVeicoli_TotalePercorso NVARCHAR(15) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody)
);

-- Default per referenze a XMLCodifiche.Nazione.IDNazione
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese DEFAULT('') FOR DatiGenerali_DatiTrasporto_DatiAnagraficiVettore_IdFiscaleIVA_IdPaese;
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione DEFAULT('') FOR DatiGenerali_DatiTrasporto_IndirizzoResa_Nazione;
-- Default per referenze a XMLCodifiche.Provincia.IDProvincia
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia DEFAULT('') FOR DatiGenerali_DatiTrasporto_IndirizzoResa_Provincia;
-- Default per referenze a XMLCodifiche.TipoDocumento.IDTipoDocumento
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiGeneraliDocumento_TipoDocumento DEFAULT('') FOR DatiGenerali_DatiGeneraliDocumento_TipoDocumento;
-- Default per referenze a XMLCodifiche.Divisa.IDDivisa
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiGeneraliDocumento_Divisa DEFAULT('') FOR DatiGenerali_DatiGeneraliDocumento_Divisa;
-- Default per referenze a XMLCodifiche.TipoRitenuta.IDTipoRitenuta
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta DEFAULT('') FOR DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_TipoRitenuta;
-- Default per referenze a XMLCodifiche.CausalePagamento.IDCausalePagamento
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento DEFAULT('') FOR DatiGenerali_DatiGeneraliDocumento_DatiRitenuta_CausalePagamento;
-- Default per referenze a XMLCodifiche.RispostaSI.IDRispostaSI
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiGeneraliDocumento_Art73 DEFAULT('') FOR DatiGenerali_DatiGeneraliDocumento_Art73;
-- Default per referenze a XMLCodifiche.TipoResa.IDTipoResa
ALTER TABLE XMLFatture.FatturaElettronicaBody ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiGenerali_DatiTrasporto_TipoResa DEFAULT('') FOR DatiGenerali_DatiTrasporto_TipoResa;

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiCassaPrevidenziale
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiCassaPrevidenziale', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiCassaPrevidenziale
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale (
	PKFatturaElettronicaBody_DatiCassaPrevidenziale BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiCassaPrevidenziale),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	TipoCassa CHAR(4) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_TipoCassa REFERENCES XMLCodifiche.TipoCassa (IDTipoCassa),
	AlCassa DECIMAL(5, 2) NOT NULL,
	ImportoContributoCassa DECIMAL(14, 2) NOT NULL,
	ImponibileCassa DECIMAL(14, 2) NULL,
	AliquotaIVA DECIMAL(5, 2) NOT NULL,
	Ritenuta CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_Ritenuta FOREIGN KEY REFERENCES XMLCodifiche.RispostaSI (IDRispostaSI),
	Natura CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_Natura REFERENCES XMLCodifiche.Natura (IDNatura),
	RiferimentoAmministrazione NVARCHAR(20) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiCassaPrevidenziale)
);

-- Default per referenze a XMLCodifiche.TipoCassa.IDTipoCassa
ALTER TABLE XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_TipoCassa DEFAULT('') FOR TipoCassa;
-- Default per referenze a XMLCodifiche.TipoRitenuta.IDTipoRitenuta
ALTER TABLE XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_Ritenuta DEFAULT('') FOR Ritenuta;
-- Default per referenze a XMLCodifiche.Natura.IDNatura
ALTER TABLE XMLFatture.FatturaElettronicaBody_DatiCassaPrevidenziale ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiCassaPrevidenziale_Natura DEFAULT('') FOR Natura;

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): ScontoMaggiorazione
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_ScontoMaggiorazione', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_ScontoMaggiorazione
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione (
	PKFatturaElettronicaBody_ScontoMaggiorazione BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_ScontoMaggiorazione DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_ScontoMaggiorazione),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_ScontoMaggiorazione_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	Tipo CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_ FOREIGN KEY REFERENCES XMLCodifiche.TipoScontoMaggiorazione (IDTipoScontoMaggiorazione),
	Percentuale DECIMAL(5, 2) NULL,
	Importo DECIMAL(14, 2) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_ScontoMaggiorazione PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_ScontoMaggiorazione)
);

-- Default per referenze a XMLCodifiche.TipoScontoMaggiorazione.IDTipoScontoMaggiorazione
ALTER TABLE XMLFatture.FatturaElettronicaBody_ScontoMaggiorazione ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_ScontoMaggiorazione_Tipo DEFAULT('') FOR Tipo;

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_Causale
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): Causale
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_Causale;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_Causale', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_Causale
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_Causale', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_Causale (
	PKFatturaElettronicaBody_Causale BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_Causale DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_Causale),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_Causale_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	DatiGenerali_Causale NVARCHAR(200) NOT NULL CONSTRAINT DFT_PKFatturaElettronicaBody_Causale_DatiGenerali_Causale DEFAULT (''),

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_Causale PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_Causale)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DocumentoEsterno
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DocumentoEsterno (ordine, DDT, ecc.)
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DocumentoEsterno;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DocumentoEsterno', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DocumentoEsterno
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DocumentoEsterno', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DocumentoEsterno (
	PKFatturaElettronicaBody_DocumentoEsterno BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DocumentoEsterno DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DocumentoEsterno),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DocumentoEsterno_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	TipoDocumentoEsterno CHAR(4) NOT NULL CONSTRAINT FK_PKFatturaElettronicaBody_DocumentoEsterno_TipoDocumentoEsterno REFERENCES XMLCodifiche.TipoDocumentoEsterno (IDTipoDocumentoEsterno),
	IdDocumento NVARCHAR(20) NOT NULL,
	Data DATE NULL,
	NumItem NVARCHAR(20) NULL,
	CodiceCommessaConvenzione NVARCHAR(100) NULL,
	CodiceCUP NVARCHAR(15) NULL,
	CodiceCIG NVARCHAR(15) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DocumentoEsterno PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DocumentoEsterno)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DocumentoEsterno - RiferimentoNumeroLinea
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea (
	PKFatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea),
	PKFatturaElettronicaBody_DocumentoEsterno BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea_PKFatturaElettronicaBody_DocumentoEsterno REFERENCES XMLFatture.FatturaElettronicaBody_DocumentoEsterno (PKFatturaElettronicaBody_DocumentoEsterno),

	RiferimentoNumeroLinea INT NOT NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DocumentoEsterno_RiferimentoNumeroLinea)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiSAL
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiSAL
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiSAL;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiSAL', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiSAL
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiSAL', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiSAL (
	PKFatturaElettronicaBody_DatiSAL BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiSAL DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiSAL),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiSAL_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	RiferimentoFase INT NOT NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiSAL PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiSAL)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiDDT
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiDDT
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiDDT;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiDDT', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiDDT
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiDDT', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiDDT (
	PKFatturaElettronicaBody_DatiDDT BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiDDT DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiDDT),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiDDT_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	NumeroDDT NVARCHAR(20) NOT NULL,
	DataDDT DATE NOT NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiDDT PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiDDT)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiDDT - RiferimentoNumeroLinea
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea (
	PKFatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea),
	PKFatturaElettronicaBody_DatiDDT BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea_PKFatturaElettronicaBody_DatiDDT REFERENCES XMLFatture.FatturaElettronicaBody_DatiDDT (PKFatturaElettronicaBody_DatiDDT),

	RiferimentoNumeroLinea INT NOT NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiDDT_RiferimentoNumeroLinea)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DettaglioLinee
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DettaglioLinee', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DettaglioLinee (
	PKFatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DettaglioLinee DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	-- 2.2.1 DettaglioLinee_
	NumeroLinea INT NOT NULL,
	TipoCessionePrestazione CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_TipoCessionePrestazione REFERENCES XMLCodifiche.TipoCessionePrestazione (IDTipoCessionePrestazione),

	Descrizione NVARCHAR(1000) NOT NULL,
	Quantita DECIMAL(20, 5) NULL,
	UnitaMisura NVARCHAR(10) NULL,
	DataInizioPeriodo DATE NULL,
	DataFinePeriodo DATE NULL,
	PrezzoUnitario DECIMAL(20, 5) NOT NULL,

	PrezzoTotale DECIMAL(20, 5) NOT NULL,
	AliquotaIVA DECIMAL(5, 2) NOT NULL,
	Ritenuta CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_Ritenuta REFERENCES XMLCodifiche.RispostaSI (IDRispostaSI),
	Natura CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_Natura REFERENCES XMLCodifiche.Natura (IDNatura),
	RiferimentoAmministrazione NVARCHAR(20) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DettaglioLinee PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DettaglioLinee)
);

CREATE UNIQUE NONCLUSTERED INDEX IX_XMLFatture_FatturaElettronicaBody_DettaglioLinee_PKFatturaElettronicaBody_NumeroLinea ON XMLFatture.FatturaElettronicaBody_DettaglioLinee (PKFatturaElettronicaBody, NumeroLinea);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee - CodiceArticolo
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DettaglioLinee_CodiceArticolo (
	PKFatturaElettronicaBody_DettaglioLinee_CodiceArticolo BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo),
	PKFatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo_PKFatturaElettronicaBody_DettaglioLinee REFERENCES XMLFatture.FatturaElettronicaBody_DettaglioLinee (PKFatturaElettronicaBody_DettaglioLinee),

	-- 2.2.1.3 CodiceArticolo_
	CodiceArticolo_CodiceTipo NVARCHAR(35) NOT NULL,
	CodiceArticolo_CodiceValore NVARCHAR(35) NOT NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_CodiceArticolo PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DettaglioLinee_CodiceArticolo)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee - ScontoMaggiorazione
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione (
	PKFatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione),
	PKFatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione_PKFatturaElettronicaBody_DettaglioLinee REFERENCES XMLFatture.FatturaElettronicaBody_DettaglioLinee (PKFatturaElettronicaBody_DettaglioLinee),

	-- 2.2.1.10 ScontoMaggiorazione_
	ScontoMaggiorazione_Tipo CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione_ScontoMaggiorazione_Tipo REFERENCES XMLCodifiche.TipoScontoMaggiorazione (IDTipoScontoMaggiorazione),
	ScontoMaggiorazione_Percentuale DECIMAL(5, 2) NULL,
	ScontoMaggiorazione_Importo DECIMAL(14, 2) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DettaglioLinee_ScontoMaggiorazione)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DettaglioLinee - AltriDatiGestionali
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali (
	PKFatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali),
	PKFatturaElettronicaBody_DettaglioLinee BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali_PKFatturaElettronicaBody_DettaglioLinee REFERENCES XMLFatture.FatturaElettronicaBody_DettaglioLinee (PKFatturaElettronicaBody_DettaglioLinee),

	-- 2.2.1.16 AltriDatiGestionali_
	AltriDatiGestionali_TipoDato NVARCHAR(10) NOT NULL,
	AltriDatiGestionali_RiferimentoTesto NVARCHAR(60) NULL,
	AltriDatiGestionali_RiferimentoNumero DECIMAL(20, 5) NULL,
	AltriDatiGestionali_RiferimentoData DATE NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DettaglioLinee_AltriDatiGestionali)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiRiepilogo
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiRiepilogo
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiRiepilogo;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiRiepilogo', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiRiepilogo
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiRiepilogo', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiRiepilogo (
	PKFatturaElettronicaBody_DatiRiepilogo BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiRiepilogo DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiRiepilogo),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiRiepilogo_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	AliquotaIVA DECIMAL(5, 2) NOT NULL,
	Natura CHAR(2) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiRiepilogo_Natura REFERENCES XMLCodifiche.Natura(IDNatura),
	SpeseAccessorie DECIMAL(14, 2) NULL,
	Arrotondamento DECIMAL(20, 2) NULL,
	ImponibileImporto DECIMAL(14, 2) NOT NULL,
	Imposta DECIMAL(14, 2) NOT NULL,
	EsigibilitaIVA CHAR(1) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiRiepilogo_EsigibilitaIVA REFERENCES XMLCodifiche.EsigibilitaIVA (IDEsigibilitaIVA),
	RiferimentoNormativo NVARCHAR(100) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiRiepilogo PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiRiepilogo)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiPagamento
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiPagamento
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiPagamento;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiPagamento', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiPagamento
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiPagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiPagamento (
	PKFatturaElettronicaBody_DatiPagamento BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiPagamento DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiPagamento),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiPagamento_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	-- 2.4 DatiPagamento_
	CondizioniPagamento CHAR(4) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DatiPagamento_CondizioniPagamento FOREIGN KEY REFERENCES XMLCodifiche.CondizioniPagamento (IDCondizioniPagamento),

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiPagamento PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiPagamento)
);

-- Default per referenze a XMLCodifiche.CondizioniPagamento.IDCondizioniPagamento
ALTER TABLE XMLFatture.FatturaElettronicaBody_DatiPagamento ADD CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiPagamento_CondizioniPagamento DEFAULT('') FOR CondizioniPagamento;

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): DatiPagamento - DettaglioPagamento
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_DatiPagamento_DettaglioPagamento (
	PKFatturaElettronicaBody_DatiPagamento_DettaglioPagamento BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento),
	PKFatturaElettronicaBody_DatiPagamento BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioPagamento_PKFatturaElettronicaBody_DatiPagamento REFERENCES XMLFatture.FatturaElettronicaBody_DatiPagamento (PKFatturaElettronicaBody_DatiPagamento),

	Beneficiario NVARCHAR(200) NULL,
	ModalitaPagamento CHAR(4) NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_DettaglioPagamento_ModalitaPagamento REFERENCES XMLCodifiche.ModalitaPagamento (IDModalitaPagamento),
	DataRiferimentoTerminiPagamento DATE NULL,
	GiorniTerminiPagamento INT NULL,
	DataScadenzaPagamento DATE NULL,
	ImportoPagamento DECIMAL(14, 2) NOT NULL,
	CodUfficioPostale NVARCHAR(20) NULL,
	CognomeQuietanzante NVARCHAR(60) NULL,
	NomeQuietanzante NVARCHAR(60) NULL,
	CFQuietanzante NVARCHAR(16) NULL,
	TitoloQuietanzante NVARCHAR(10) NULL,
	IstitutoFinanziario NVARCHAR(80) NULL,
	IBAN NVARCHAR(34) NULL,
	ABI INT NULL,
	CAB INT NULL,
	BIC NVARCHAR(11) NULL,
	ScontoPagamentoAnticipato DECIMAL(14, 2) NULL,
	DataLimitePagamentoAnticipato DATE NULL,
	PenalitaPagamentiRitardati DECIMAL(14, 2) NULL,
	DataDecorrenzaPenale DATE NULL,
	CodicePagamento NVARCHAR(60) NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_DatiPagamento_DettaglioPagamento PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_DatiPagamento_DettaglioPagamento)
);

END;
GO

/**
 * @table XMLFatture.FatturaElettronicaBody_Allegati
 * @description Dati di dettaglio della fattura elettronica (tabella ufficiale): Allegati
*/

--DROP TABLE IF EXISTS XMLFatture.FatturaElettronicaBody_Allegati;
GO

IF OBJECT_ID(N'XMLFatture.seq_FatturaElettronicaBody_Allegati', 'SO') IS NULL
BEGIN

CREATE SEQUENCE XMLFatture.seq_FatturaElettronicaBody_Allegati
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

IF OBJECT_ID(N'XMLFatture.FatturaElettronicaBody_Allegati', N'U') IS NULL
BEGIN

CREATE TABLE XMLFatture.FatturaElettronicaBody_Allegati (
	PKFatturaElettronicaBody_Allegati BIGINT NOT NULL CONSTRAINT DFT_XMLFatture_FatturaElettronicaBody_Allegati DEFAULT (NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaBody_Allegati),
	PKFatturaElettronicaBody BIGINT NOT NULL CONSTRAINT FK_XMLFatture_FatturaElettronicaBody_Allegati_PKFatturaElettronicaBody REFERENCES XMLFatture.FatturaElettronicaBody (PKFatturaElettronicaBody),

	NomeAttachment NVARCHAR(60) NOT NULL,
	AlgoritmoCompressione NVARCHAR(10) NULL,
	FormatoAttachment NVARCHAR(10) NULL,
	DescrizioneAttachment NVARCHAR(100) NULL,
	Attachment VARCHAR(MAX) NOT NULL,

	CONSTRAINT PK_XMLFatture_FatturaElettronicaBody_Allegati PRIMARY KEY CLUSTERED (PKFatturaElettronicaBody_Allegati)
);

END;
GO

/*** Inserimento fatture di test (chiavi -1): Inizio ***/

DELETE FROM XMLFatture.FatturaElettronicaHeader WHERE PKLanding_Fattura = -1;
DELETE FROM XMLFatture.Staging_FatturaElettronicaHeader WHERE PKStaging_FatturaElettronicaHeader = -1;
DELETE FROM XMLFatture.Landing_Fattura WHERE PKLanding_Fattura = -1;

INSERT INTO XMLFatture.Landing_Fattura
(
    PKLanding_Fattura,
    ChiaveGestionale_CodiceNumerico,
    ChiaveGestionale_CodiceAlfanumerico,
    IsUltimaRevisione
)
VALUES
(   -1,   -- PKLanding_Fattura - bigint
    0,   -- ChiaveGestionale_CodiceNumerico - bigint
    N'', -- ChiaveGestionale_CodiceAlfanumerico - nvarchar(40)
    1 -- IsUltimaRevisione - bit
    );

INSERT INTO XMLFatture.Staging_FatturaElettronicaHeader
(
    PKStaging_FatturaElettronicaHeader,
    PKLanding_Fattura,
    DataOraInserimento,
    IsValida,
    DataOraUltimaValidazione,
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
    RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione,
    RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome,
    RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome,
    RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo,
    RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI,
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
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo,
    TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI,
    SoggettoEmittente
)
VALUES
(   -1,         -- PKStaging_FatturaElettronicaHeader - bigint
    -1,         -- PKLanding_Fattura - bigint
    CURRENT_TIMESTAMP, -- DataInserimento - datetime2
    0,         -- IsValida - bit
    CURRENT_TIMESTAMP, -- DataUltimaValidazione - datetime2
    '',        -- DatiTrasmissione_IdTrasmittente_IdPaese - char(2)
    N'',       -- DatiTrasmissione_IdTrasmittente_IdCodice - nvarchar(28)
    N'',       -- DatiTrasmissione_ProgressivoInvio - nvarchar(10)
    '',        -- DatiTrasmissione_FormatoTrasmissione - char(5)
    N'',       -- DatiTrasmissione_CodiceDestinatario - nvarchar(7)
    N'',       -- DatiTrasmissione_ContattiTrasmittente_Telefono - nvarchar(12)
    N'',       -- DatiTrasmissione_ContattiTrasmittente_Email - nvarchar(256)
    N'',       -- DatiTrasmissione_PECDestinatario - nvarchar(256)
    '',        -- CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- CedentePrestatore_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    N'',       -- CedentePrestatore_DatiAnagrafici_AlboProfessionale - nvarchar(60)
    '',        -- CedentePrestatore_DatiAnagrafici_ProvinciaAlbo - char(2)
    N'',       -- CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo - nvarchar(60)
    GETDATE(), -- CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo - date
    '',        -- CedentePrestatore_DatiAnagrafici_RegimeFiscale - char(4)
    N'',       -- CedentePrestatore_Sede_Indirizzo - nvarchar(60)
    N'',       -- CedentePrestatore_Sede_NumeroCivico - nvarchar(8)
    '',        -- CedentePrestatore_Sede_CAP - char(5)
    N'',       -- CedentePrestatore_Sede_Comune - nvarchar(60)
    '',        -- CedentePrestatore_Sede_Provincia - char(2)
    '',        -- CedentePrestatore_Sede_Nazione - char(2)
    N'',       -- CedentePrestatore_StabileOrganizzazione_Indirizzo - nvarchar(60)
    N'',       -- CedentePrestatore_StabileOrganizzazione_NumeroCivico - nvarchar(8)
    '',        -- CedentePrestatore_StabileOrganizzazione_CAP - char(5)
    N'',       -- CedentePrestatore_StabileOrganizzazione_Comune - nvarchar(60)
    '',        -- CedentePrestatore_StabileOrganizzazione_Provincia - char(2)
    '',        -- CedentePrestatore_StabileOrganizzazione_Nazione - char(2)
    '',        -- CedentePrestatore_IscrizioneREA_Ufficio - char(2)
    N'',       -- CedentePrestatore_IscrizioneREA_NumeroREA - nvarchar(20)
    NULL,      -- CedentePrestatore_IscrizioneREA_CapitaleSociale - decimal(14, 2)
    '',        -- CedentePrestatore_IscrizioneREA_SocioUnico - char(2)
    '',        -- CedentePrestatore_IscrizioneREA_StatoLiquidazione - char(2)
    N'',       -- CedentePrestatore_Contatti_Telefono - nvarchar(12)
    N'',       -- CedentePrestatore_Contatti_Fax - nvarchar(12)
    N'',       -- CedentePrestatore_Contatti_Email - nvarchar(256)
    N'',       -- CedentePrestatore_RiferimentoAmministrazione - nvarchar(20)
    '',        -- RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    '',        -- CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- CessionarioCommittente_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    N'',       -- CessionarioCommittente_Sede_Indirizzo - nvarchar(60)
    N'',       -- CessionarioCommittente_Sede_NumeroCivico - nvarchar(8)
    '',        -- CessionarioCommittente_Sede_CAP - char(5)
    N'',       -- CessionarioCommittente_Sede_Comune - nvarchar(60)
    '',        -- CessionarioCommittente_Sede_Provincia - char(2)
    '',        -- CessionarioCommittente_Sede_Nazione - char(2)
    N'',       -- CessionarioCommittente_StabileOrganizzazione_Indirizzo - nvarchar(60)
    N'',       -- CessionarioCommittente_StabileOrganizzazione_NumeroCivico - nvarchar(8)
    '',        -- CessionarioCommittente_StabileOrganizzazione_CAP - char(5)
    N'',       -- CessionarioCommittente_StabileOrganizzazione_Comune - nvarchar(60)
    '',        -- CessionarioCommittente_StabileOrganizzazione_Provincia - char(2)
    '',        -- CessionarioCommittente_StabileOrganizzazione_Nazione - char(2)
    '',        -- CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_Denominazione - nvarchar(80)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_Nome - nvarchar(60)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_Cognome - nvarchar(60)
    '',        -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    ''         -- SoggettoEmittente - char(2)
    );

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
VALUES
(   -1,         -- PKFatturaElettronicaHeader - bigint
    -1,         -- PKLanding_Fattura - bigint
    -1,         -- PKStaging_FatturaElettronicaHeader - bigint
    '',        -- DatiTrasmissione_IdTrasmittente_IdPaese - char(2)
    N'',       -- DatiTrasmissione_IdTrasmittente_IdCodice - nvarchar(28)
    N'',       -- DatiTrasmissione_ProgressivoInvio - nvarchar(10)
    '',        -- DatiTrasmissione_FormatoTrasmissione - char(5)
    N'',       -- DatiTrasmissione_CodiceDestinatario - nvarchar(7)
    0,      -- DatiTrasmissione_HasContattiTrasmittente - bit
    N'',       -- DatiTrasmissione_ContattiTrasmittente_Telefono - nvarchar(12)
    N'',       -- DatiTrasmissione_ContattiTrasmittente_Email - nvarchar(256)
    N'',       -- DatiTrasmissione_PECDestinatario - nvarchar(256)
    '',        -- CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- CedentePrestatore_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- CedentePrestatore_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    N'',       -- CedentePrestatore_DatiAnagrafici_AlboProfessionale - nvarchar(60)
    '',        -- CedentePrestatore_DatiAnagrafici_ProvinciaAlbo - char(2)
    N'',       -- CedentePrestatore_DatiAnagrafici_NumeroIscrizioneAlbo - nvarchar(60)
    GETDATE(), -- CedentePrestatore_DatiAnagrafici_DataIscrizioneAlbo - date
    '',        -- CedentePrestatore_DatiAnagrafici_RegimeFiscale - char(4)
    N'',       -- CedentePrestatore_Sede_Indirizzo - nvarchar(60)
    N'',       -- CedentePrestatore_Sede_NumeroCivico - nvarchar(8)
    '',        -- CedentePrestatore_Sede_CAP - char(5)
    N'',       -- CedentePrestatore_Sede_Comune - nvarchar(60)
    '',        -- CedentePrestatore_Sede_Provincia - char(2)
    '',        -- CedentePrestatore_Sede_Nazione - char(2)
    0,      -- CedentePrestatore_HasStabileOrganizzazione - bit
    N'',       -- CedentePrestatore_StabileOrganizzazione_Indirizzo - nvarchar(60)
    N'',       -- CedentePrestatore_StabileOrganizzazione_NumeroCivico - nvarchar(8)
    '',        -- CedentePrestatore_StabileOrganizzazione_CAP - char(5)
    N'',       -- CedentePrestatore_StabileOrganizzazione_Comune - nvarchar(60)
    '',        -- CedentePrestatore_StabileOrganizzazione_Provincia - char(2)
    '',        -- CedentePrestatore_StabileOrganizzazione_Nazione - char(2)
    0,      -- CedentePrestatore_HasIscrizioneREA - bit
    '',        -- CedentePrestatore_IscrizioneREA_Ufficio - char(2)
    N'',       -- CedentePrestatore_IscrizioneREA_NumeroREA - nvarchar(20)
    0,      -- CedentePrestatore_IscrizioneREA_CapitaleSociale - decimal(14, 2)
    '',        -- CedentePrestatore_IscrizioneREA_SocioUnico - char(2)
    '',        -- CedentePrestatore_IscrizioneREA_StatoLiquidazione - char(2)
    0,      -- CedentePrestatore_HasContatti - bit
    N'',       -- CedentePrestatore_Contatti_Telefono - nvarchar(12)
    N'',       -- CedentePrestatore_Contatti_Fax - nvarchar(12)
    N'',       -- CedentePrestatore_Contatti_Email - nvarchar(256)
    N'',       -- CedentePrestatore_RiferimentoAmministrazione - nvarchar(20)
    0,      -- HasRappresentanteFiscale - bit
    '',        -- RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- RappresentanteFiscale_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    0,      -- CessionarioCommittente_DatiAnagrafici_HasIdFiscaleIVA - bit
    '',        -- CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- CessionarioCommittente_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- CessionarioCommittente_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- CessionarioCommittente_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    N'',       -- CessionarioCommittente_Sede_Indirizzo - nvarchar(60)
    N'',       -- CessionarioCommittente_Sede_NumeroCivico - nvarchar(8)
    '',        -- CessionarioCommittente_Sede_CAP - char(5)
    N'',       -- CessionarioCommittente_Sede_Comune - nvarchar(60)
    '',        -- CessionarioCommittente_Sede_Provincia - char(2)
    '',        -- CessionarioCommittente_Sede_Nazione - char(2)
    0,      -- CessionarioCommittente_HasStabileOrganizzazione - bit
    N'',       -- CessionarioCommittente_StabileOrganizzazione_Indirizzo - nvarchar(60)
    N'',       -- CessionarioCommittente_StabileOrganizzazione_NumeroCivico - nvarchar(8)
    '',        -- CessionarioCommittente_StabileOrganizzazione_CAP - char(5)
    N'',       -- CessionarioCommittente_StabileOrganizzazione_Comune - nvarchar(60)
    '',        -- CessionarioCommittente_StabileOrganizzazione_Provincia - char(2)
    '',        -- CessionarioCommittente_StabileOrganizzazione_Nazione - char(2)
    0,      -- CessionarioCommittente_HasRappresentanteFiscale - bit
    '',        -- CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_Denominazione - nvarchar(80)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_Nome - nvarchar(60)
    N'',       -- CessionarioCommittente_RappresentanteFiscale_Cognome - nvarchar(60)
    0,      -- HasTerzoIntermediarioOSoggettoEmittente - bit
    0,      -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_HasIdFiscaleIVA - bit
    '',        -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdPaese - char(2)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_IdFiscaleIVA_IdCodice - nvarchar(28)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_CodiceFiscale - nvarchar(16)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Denominazione - nvarchar(80)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Nome - nvarchar(60)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Cognome - nvarchar(60)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_Titolo - nvarchar(10)
    N'',       -- TerzoIntermediarioOSoggettoEmittente_DatiAnagrafici_Anagrafica_CodEORI - nvarchar(17)
    ''         -- SoggettoEmittente - char(2)
    );
GO

/*** Inserimento fatture di test (chiavi -1): Fine ***/
