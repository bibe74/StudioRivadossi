USE InVoiceXML;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

-- Importare dbo.stgCampiXML da file stgCampiXML.csv
-- Importare dbo.stgCodiceErroreEvento da file stgCodiceErroreEvento.csv
-- Importare dbo.stgCodiceErroreSDI da file stgCodiceErroreSDI.csv
-- Importare dbo.stgImport da file stgImport.csv

UPDATE dbo.stgImport SET IDEntita = N'', Entita = N'' WHERE IDEntita IS NULL AND Entita IS NULL;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'XMLCodifiche')
BEGIN
	EXEC ('CREATE SCHEMA XMLCodifiche AUTHORIZATION dbo;');
END;
GO

IF OBJECT_ID(N'XMLCodifiche.RegimeFiscale', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.RegimeFiscale (
	IDRegimeFiscale CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_RegimeFiscale PRIMARY KEY CLUSTERED,
	RegimeFiscale NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.RegimeFiscale
(
    IDRegimeFiscale,
    RegimeFiscale
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'RegimeFiscale'
ORDER BY IDEntita;

END;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoCassa', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoCassa (
	IDTipoCassa CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoCassa PRIMARY KEY CLUSTERED,
	TipoCassa NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoCassa
(
    IDTipoCassa,
    TipoCassa
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'TipoCassa'
ORDER BY IDEntita;

END;
GO

IF OBJECT_ID(N'XMLCodifiche.ModalitaPagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.ModalitaPagamento (
	IDModalitaPagamento CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_ModalitaPagamento PRIMARY KEY CLUSTERED,
	ModalitaPagamento NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.ModalitaPagamento
(
    IDModalitaPagamento,
    ModalitaPagamento
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'ModalitaPagamento'
ORDER BY IDEntita;

END;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoDocumento', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoDocumento (
	IDTipoDocumento CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoDocumento PRIMARY KEY CLUSTERED,
	TipoDocumento NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoDocumento
(
    IDTipoDocumento,
    TipoDocumento
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'TipoDocumento'
ORDER BY IDEntita;

END;
GO

-- Integrazioni valide dal 1/1/2021, utilizzabili già dal 1/10/2020
WITH Novita
AS (
    SELECT 'TD16' AS IDTipoDocumento, N'integrazione fattura reverse charge interno' AS TipoDocumento
    UNION ALL SELECT 'TD17', N'integrazione/autofattura per acquisto servizi dall''estero'
    UNION ALL SELECT 'TD18', N'integrazione per acquisto di beni intracomunitari'
    UNION ALL SELECT 'TD19', N'integrazione/autofattura per acquisto di beni ex art.17 c.2 DPR 633/72'
    UNION ALL SELECT 'TD20', N'autofattura per regolarizzazione e integrazione delle fatture (art.6 c.8 d.lgs. 471/97 o art.46 c.5 D.L. 331/93)'
    UNION ALL SELECT 'TD21', N'autofattura per splafonamento TD22 Estrazione beni da Deposito IVA'
    UNION ALL SELECT 'TD23', N'estrazione beni da Deposito IVA con versamento dell''IVA'
    UNION ALL SELECT 'TD24', N'fattura differita di cui all''art.21, comma 4, lett. a)'
    UNION ALL SELECT 'TD25', N'fattura differita di cui all''art.21, comma 4, terzo periodo lett. b)'
    UNION ALL SELECT 'TD26', N'cessione di beni ammortizzabili e per passaggi interni (ex art.36 DPR 633/72)'
    UNION ALL SELECT 'TD27', N'fattura per autoconsumo o per cessioni gratuite senza rivalsa'
)
MERGE INTO XMLCodifiche.TipoDocumento AS DST
USING Novita AS SRC ON SRC.IDTipoDocumento = DST.IDTipoDocumento
WHEN NOT MATCHED THEN INSERT (IDTipoDocumento, TipoDocumento) VALUES (SRC.IDTipoDocumento, SRC.TipoDocumento)
WHEN MATCHED AND DST.TipoDocumento <> SRC.TipoDocumento THEN UPDATE SET DST.TipoDocumento = SRC.TipoDocumento
OUTPUT $action, SRC.IDTipoDocumento, SRC.TipoDocumento;
GO

IF OBJECT_ID(N'XMLCodifiche.Natura', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.Natura (
	IDNatura CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_Natura PRIMARY KEY CLUSTERED,
	Natura NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.Natura
(
    IDNatura,
    Natura
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'Natura'
ORDER BY IDEntita;

END;
GO

-- Integrazioni valide dal 1/1/2021, utilizzabili già dal 1/10/2020
WITH Novita
AS (
    SELECT 'N2.1' AS IDNatura, 'non soggette ad IVA ai sensi degli articoli da 7 a 7- septies del D.P.R. n. 633/1972' AS Natura
    UNION ALL SELECT 'N2.2', 'non soggette - altri casi'
    UNION ALL SELECT 'N3.1', 'non imponibili - esportazioni'
    UNION ALL SELECT 'N3.2', 'non imponibili - cessioni intracomunitarie'
    UNION ALL SELECT 'N3.3', 'non imponibili - cessioni verso San Marino'
    UNION ALL SELECT 'N3.4', 'non imponibili - operazioni assimilate alle cessioni all''esportazione'
    UNION ALL SELECT 'N3.5', 'non imponibili - a seguito di dichiarazioni d''intento'
    UNION ALL SELECT 'N3.6', 'non imponibili - altre operazioni che non concorrono alla formazione del plafond'
    UNION ALL SELECT 'N6.1', 'inversione contabile - cessione di rottami e altri materiali di recupero'
    UNION ALL SELECT 'N6.2', 'inversione contabile - cessione di oro e argento puro'
    UNION ALL SELECT 'N6.3', 'inversione contabile - subappalto nel settore edile'
    UNION ALL SELECT 'N6.4', 'inversione contabile - cessione di fabbricati'
    UNION ALL SELECT 'N6.5', 'inversione contabile - cessione di telefoni cellulari'
    UNION ALL SELECT 'N6.6', 'inversione contabile - cessione di prodotti elettronici'
    UNION ALL SELECT 'N6.7', 'inversione contabile - prestazioni comparto edile e settori connessi'
    UNION ALL SELECT 'N6.8', 'inversione contabile - operazioni settore energetico'
    UNION ALL SELECT 'N6.9', 'inversione contabile - altri casi'
)
MERGE INTO XMLCodifiche.Natura AS DST
USING Novita AS SRC ON SRC.IDNatura = DST.IDNatura
WHEN NOT MATCHED THEN INSERT (IDNatura, Natura) VALUES (SRC.IDNatura, SRC.Natura)
WHEN MATCHED AND DST.Natura <> SRC.Natura THEN UPDATE SET DST.Natura = SRC.Natura
OUTPUT $action, SRC.IDNatura, SRC.Natura;
GO

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'XMLCodifiche' AND TABLE_NAME = 'Natura' AND COLUMN_NAME = 'IsObsoleta')
BEGIN
    ALTER TABLE XMLCodifiche.Natura ADD IsObsoleta BIT NOT NULL CONSTRAINT DFT_XMLCodifiche_Natura_IsObsoleta DEFAULT (0);
END;
GO

WITH Deprecate
AS (
    SELECT 'N2' AS IDNatura
    UNION ALL SELECT 'N3'
    UNION ALL SELECT 'N6'
)
UPDATE N
SET N.IsObsoleta = 1
FROM XMLCodifiche.Natura N
INNER JOIN Deprecate D ON D.IDNatura = N.IDNatura;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoRitenuta', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoRitenuta (
	IDTipoRitenuta CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoRitenuta PRIMARY KEY CLUSTERED,
	TipoRitenuta NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoRitenuta
(
    IDTipoRitenuta,
    TipoRitenuta
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE IDEntita LIKE N'RT%'
ORDER BY IDEntita;

END;
GO

WITH Novita
AS (
    SELECT
        'RT01' AS IDTipoRitenuta,
        N'ritenuta d''acconto (ritenuta persone fisiche)' AS TipoRitenuta
    UNION ALL SELECT 'RT02', N'ritenuta d''acconto (ritenuta persone giuridiche)'
    UNION ALL SELECT 'RT03', N'contributo INPS'
    UNION ALL SELECT 'RT04', N'contributo ENASARCO'
    UNION ALL SELECT 'RT05', N'contributo ENPAM'
    UNION ALL SELECT 'RT06', N'altro contributo previdenziale'
)
MERGE INTO XMLCodifiche.TipoRitenuta AS DST
USING Novita AS SRC ON SRC.IDTipoRitenuta = DST.IDTipoRitenuta
WHEN NOT MATCHED THEN INSERT (IDTipoRitenuta, TipoRitenuta) VALUES (SRC.IDTipoRitenuta, SRC.TipoRitenuta)
WHEN MATCHED AND DST.TipoRitenuta <> SRC.TipoRitenuta THEN UPDATE SET DST.TipoRitenuta = SRC.TipoRitenuta
OUTPUT $action, SRC.IDTipoRitenuta, SRC.TipoRitenuta;
GO

DROP TABLE IF EXISTS XMLCodifiche.FormatoTrasmissione;
GO

IF OBJECT_ID(N'XMLCodifiche.FormatoTrasmissione', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.FormatoTrasmissione (
	IDFormatoTrasmissione CHAR(5) NOT NULL CONSTRAINT PK_XMLCodifiche_FormatoTrasmissione PRIMARY KEY CLUSTERED,
	FormatoTrasmissione NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.FormatoTrasmissione
(
    IDFormatoTrasmissione,
    FormatoTrasmissione
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'FormatoTrasmissione'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.SocioUnico;
GO

IF OBJECT_ID(N'XMLCodifiche.SocioUnico', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.SocioUnico (
	IDSocioUnico CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_SocioUnico PRIMARY KEY CLUSTERED,
	SocioUnico NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.SocioUnico
(
    IDSocioUnico,
    SocioUnico
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'SocioUnico'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.StatoLiquidazione;
GO

IF OBJECT_ID(N'XMLCodifiche.StatoLiquidazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.StatoLiquidazione (
	IDStatoLiquidazione CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_StatoLiquidazione PRIMARY KEY CLUSTERED,
	StatoLiquidazione NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.StatoLiquidazione
(
    IDStatoLiquidazione,
    StatoLiquidazione
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'StatoLiquidazione'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.SoggettoEmittente;
GO

IF OBJECT_ID(N'XMLCodifiche.SoggettoEmittente', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.SoggettoEmittente (
	IDSoggettoEmittente CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_SoggettoEmittente PRIMARY KEY CLUSTERED,
	SoggettoEmittente NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.SoggettoEmittente
(
    IDSoggettoEmittente,
    SoggettoEmittente
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'SoggettoEmittente'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.TipoScontoMaggiorazione;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoScontoMaggiorazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoScontoMaggiorazione (
	IDTipoScontoMaggiorazione CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoScontoMaggiorazione PRIMARY KEY CLUSTERED,
	TipoScontoMaggiorazione NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoScontoMaggiorazione
(
    IDTipoScontoMaggiorazione,
    TipoScontoMaggiorazione
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'TipoScontoMaggiorazione'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.RispostaSI;
GO

IF OBJECT_ID(N'XMLCodifiche.RispostaSI', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.RispostaSI (
	IDRispostaSI CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_RispostaSI PRIMARY KEY CLUSTERED,
	RispostaSI NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.RispostaSI
(
    IDRispostaSI,
    RispostaSI
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'RispostaSI'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.TipoResa;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoResa', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoResa (
	IDTipoResa CHAR(3) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoResa PRIMARY KEY CLUSTERED,
	TipoResa NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoResa
(
    IDTipoResa,
    TipoResa
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'TipoResa'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.CondizioniPagamento;
GO

IF OBJECT_ID(N'XMLCodifiche.CondizioniPagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.CondizioniPagamento (
	IDCondizioniPagamento CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_CondizioniPagamento PRIMARY KEY CLUSTERED,
	CondizioniPagamento NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.CondizioniPagamento
(
    IDCondizioniPagamento,
    CondizioniPagamento
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'CondizioniPagamento'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.TipoDocumentoEsterno;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoDocumentoEsterno', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoDocumentoEsterno (
	IDTipoDocumentoEsterno CHAR(4) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoDocumentoEsterno PRIMARY KEY CLUSTERED,
	TipoDocumentoEsterno NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoDocumentoEsterno
(
    IDTipoDocumentoEsterno,
    TipoDocumentoEsterno
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'TipoDocumentoEsterno'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.TipoCessionePrestazione;
GO

IF OBJECT_ID(N'XMLCodifiche.TipoCessionePrestazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.TipoCessionePrestazione (
	IDTipoCessionePrestazione CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_TipoCessionePrestazione PRIMARY KEY CLUSTERED,
	TipoCessionePrestazione NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.TipoCessionePrestazione
(
    IDTipoCessionePrestazione,
    TipoCessionePrestazione
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'TipoCessionePrestazione'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.EsigibilitaIVA;
GO

IF OBJECT_ID(N'XMLCodifiche.EsigibilitaIVA', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.EsigibilitaIVA (
	IDEsigibilitaIVA CHAR(1) NOT NULL CONSTRAINT PK_XMLCodifiche_EsigibilitaIVA PRIMARY KEY CLUSTERED,
	EsigibilitaIVA NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.EsigibilitaIVA
(
    IDEsigibilitaIVA,
    EsigibilitaIVA
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'EsigibilitaIVA'
ORDER BY IDEntita;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.CausalePagamento;
GO

IF OBJECT_ID(N'XMLCodifiche.CausalePagamento', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.CausalePagamento (
	IDCausalePagamento CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_CausalePagamento PRIMARY KEY CLUSTERED,
	CausalePagamento NVARCHAR(512) NOT NULL
);

INSERT INTO XMLCodifiche.CausalePagamento
(
    IDCausalePagamento,
    CausalePagamento
)
SELECT
	IDEntita,
	Entita

FROM dbo.stgImport
WHERE Tabella = N'CausalePagamento'
ORDER BY IDEntita;

END;
GO

SELECT * FROM XMLCodifiche.ModalitaPagamento;
SELECT * FROM XMLCodifiche.Natura;
SELECT * FROM XMLCodifiche.RegimeFiscale;
SELECT * FROM XMLCodifiche.TipoCassa;
SELECT * FROM XMLCodifiche.TipoDocumento;
SELECT * FROM XMLCodifiche.TipoRitenuta;
SELECT * FROM XMLCodifiche.FormatoTrasmissione;
SELECT * FROM XMLCodifiche.SocioUnico;
SELECT * FROM XMLCodifiche.StatoLiquidazione;
SELECT * FROM XMLCodifiche.SoggettoEmittente;
SELECT * FROM XMLCodifiche.TipoScontoMaggiorazione;
SELECT * FROM XMLCodifiche.RispostaSI;
SELECT * FROM XMLCodifiche.TipoResa;
SELECT * FROM XMLCodifiche.CondizioniPagamento;
SELECT * FROM XMLCodifiche.TipoDocumentoEsterno;
SELECT * FROM XMLCodifiche.TipoCessionePrestazione;
SELECT * FROM XMLCodifiche.EsigibilitaIVA;
SELECT * FROM XMLCodifiche.CausalePagamento;
GO

DROP TABLE IF EXISTS XMLCodifiche.Nazione;
GO

IF OBJECT_ID(N'XMLCodifiche.Nazione', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.Nazione (
	IDNazione CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_Nazione PRIMARY KEY CLUSTERED,
	Nazione NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.Nazione
(
    IDNazione,
    Nazione
)
SELECT
	Code AS IDNazione,
	Name AS Nazione

FROM [.\SQL2017].tools.dbo.[country-codes-iso3166-2]

UNION ALL SELECT '', N''

ORDER BY Code;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.Provincia;
GO

IF OBJECT_ID(N'XMLCodifiche.Provincia', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.Provincia (
	IDProvincia CHAR(2) NOT NULL CONSTRAINT PK_XMLCodifiche_Provincia PRIMARY KEY CLUSTERED,
	Provincia NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.Provincia
(
    IDProvincia,
    Provincia
)
SELECT
	CodSiglaProvincia AS IDProvincia,
	DescrProvincia AS Provincia

FROM [.\SQL2017].tools.dbo.[province-inail]

UNION ALL SELECT '', N''

ORDER BY CodSiglaProvincia;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.Valuta;
GO

IF OBJECT_ID(N'XMLCodifiche.Valuta', N'U') IS NULL
BEGIN

CREATE TABLE XMLCodifiche.Valuta (
	IDValuta CHAR(3) NOT NULL CONSTRAINT PK_XMLCodifiche_Valuta PRIMARY KEY CLUSTERED,
	Valuta NVARCHAR(255) NOT NULL
);

INSERT INTO XMLCodifiche.Valuta
(
    IDValuta,
    Valuta
)
SELECT DISTINCT
	AlphabeticCode AS IDValuta,
	Currency AS Valuta

FROM [.\SQL2017].[tools].[dbo].[codes-all]
WHERE AlphabeticCode IS NOT NULL
	AND WithdrawalDate IS NULL

UNION ALL SELECT '', N''

ORDER BY IDValuta;

END;
GO

DROP TABLE IF EXISTS XMLCodifiche.CampiXML;
GO

SELECT
	CXML.NomeElementoRadice,
    CXML.IndiceElemento,
    CXML.NomeElemento,
	COALESCE(CXML.NomeElementoFull, N'') AS NomeElementoFull,
    CXML.TipoInfo,
	CAST(CASE WHEN CXML.TipoInfo IS NULL THEN 0 ELSE 1 END AS BIT) AS IsElementoXML,
	CASE CXML.TipoInfo
	  WHEN N'xs:base64Binary' THEN N'BLOB'
	  WHEN N'xs:date' THEN N'DATE'
	  WHEN N'xs:decimal' THEN N'DECIMAL'
	  WHEN N'xs:integer' THEN N'INT'
	  WHEN N'xs:normalizedString' THEN N'NVARCHAR'
	  WHEN N'xs:string' THEN N'NVARCHAR'
	  ELSE CASE WHEN CXML.TipoInfo IS NULL THEN NULL ELSE N'<???>' END
	END AS FormatoElemento,
	CAST(NULL AS sysname) AS FormatoEstesoElemento,
    CXML.DescrizioneFunzionale,
    CXML.FormatoEValoriAmmessi,
    CXML.ObbligatorietaEOccorrenze,
	CASE
	  WHEN CXML.TipoInfo IS NULL THEN NULL
	  ELSE CASE SUBSTRING(ObbligatorietaEOccorrenze, 1, 2)
		WHEN N'<0' THEN 0
		WHEN N'<1' THEN 1
		ELSE NULL
	  END
	END AS IsObbligatorio,
	CASE
	  WHEN CXML.TipoInfo IS NULL THEN NULL
	  ELSE CASE SUBSTRING(ObbligatorietaEOccorrenze, 4, 2)
		WHEN N'1>' THEN 0
		WHEN N'N>' THEN 1
		ELSE NULL
	  END
	END AS HasOccorrenzeMultiple,
    CXML.Dimensione,
    CXML.ControlliExtraSchema,
    CXML.CodiceDescrizioneErrore 

INTO XMLCodifiche.CampiXML
FROM dbo.stgCampiXML_New CXML;
GO

ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN NomeElementoRadice NVARCHAR(40) NOT NULL;
ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN IndiceElemento NVARCHAR(20) NOT NULL;
GO

ALTER TABLE XMLCodifiche.CampiXML ADD CONSTRAINT PK_XMLCodifiche_CampiXML PRIMARY KEY CLUSTERED (NomeElementoRadice, IndiceElemento);
GO

ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN NomeElemento NVARCHAR(40) NOT NULL;
ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN NomeElementoFull NVARCHAR(255) NOT NULL;
ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN FormatoElemento sysname NULL;
ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN IsObbligatorio BIT NULL;
ALTER TABLE XMLCodifiche.CampiXML ALTER COLUMN HasOccorrenzeMultiple BIT NULL;
GO

UPDATE XMLCodifiche.CampiXML SET FormatoEstesoElemento = FormatoElemento + CASE WHEN Dimensione IS NOT NULL THEN N'(' + Dimensione + N')' ELSE N'' END WHERE IsElementoXML = CAST(1 AS BIT);
GO

SELECT * FROM XMLCodifiche.CampiXML ORDER BY NomeElementoRadice DESC, IndiceElemento;
GO

DROP TABLE IF EXISTS XMLCodifiche.CodiceErroreSDI;
GO

SELECT
	IDCampo,
    CodiceErrore AS CodiceErroreSDI,
    DescrizioneErrore AS DescrizioneErroreSDI

INTO XMLCodifiche.CodiceErroreSDI

FROM dbo.stgCodiceErroreSDI
ORDER BY IDCampo,
	CodiceErrore;
GO

ALTER TABLE XMLCodifiche.CodiceErroreSDI ALTER COLUMN IDCampo NVARCHAR(20) NOT NULL;
ALTER TABLE XMLCodifiche.CodiceErroreSDI ALTER COLUMN CodiceErroreSDI SMALLINT NOT NULL;
ALTER TABLE XMLCodifiche.CodiceErroreSDI ALTER COLUMN DescrizioneErroreSDI NVARCHAR(255) NOT NULL;
GO

ALTER TABLE XMLCodifiche.CodiceErroreSDI ADD CONSTRAINT PK_XMLCodifiche_CodiceErroreSDI PRIMARY KEY CLUSTERED (IDCampo, CodiceErroreSDI);
GO

DROP TABLE IF EXISTS XMLCodifiche.CodiceErroreEvento;
GO

SELECT
	PKEsitoEvento,
    COALESCE(CodiceErrore, N'') AS CodiceErroreEvento,
    COALESCE(DescrizioneErrore, N'') AS DescrizioneErroreEvento

INTO XMLCodifiche.CodiceErroreEvento

FROM dbo.stgCodiceErroreEvento
ORDER BY PKEsitoEvento;
GO

ALTER TABLE XMLCodifiche.CodiceErroreEvento ALTER COLUMN PKEsitoEvento SMALLINT NOT NULL;
ALTER TABLE XMLCodifiche.CodiceErroreEvento ALTER COLUMN CodiceErroreEvento SMALLINT NOT NULL;
ALTER TABLE XMLCodifiche.CodiceErroreEvento ALTER COLUMN DescrizioneErroreEvento NVARCHAR(255) NOT NULL;
GO

ALTER TABLE XMLCodifiche.CodiceErroreEvento ADD CONSTRAINT PK_XMLCodifiche_CodiceErroreEvento PRIMARY KEY CLUSTERED (PKEsitoEvento);
GO

SELECT * FROM XMLCodifiche.CodiceErroreSDI;

WITH Novita
AS (
    SELECT
        N'1.2' AS IDCampo,
        471 AS CodiceErroreSDI,
        N'00471: per i tipi documento TD16, TD17, TD18, TD19, TD20 il cedente/prestatore non può essere uguale al cessionario/committente' AS DescrizioneErroreSDI

    UNION ALL SELECT N'1.2', 472, N'00472: per il tipo documento TD21 il cedente/prestatore deve essere uguale al cessionario/committente'
    UNION ALL SELECT N'1.2', 473, N'00473: per i tipi documento TD17, TD18, TD19 il cedente/prestatore non può avere Codice Paese IT'
    --UNION ALL SELECT N'', 474, N'00474: per il tipo documento TD21 tutte le righe di dettaglio devono avere IVA diversa da zero'
    UNION ALL SELECT N'2.1.1.7.7', 448, N'00448: per le fatture transfrontaliere non è più ammesso il valore generico N2, N3 o N6 come codice natura dell''operazione'
    UNION ALL SELECT N'2.2.1.14', 448, N'00448: per le fatture transfrontaliere non è più ammesso il valore generico N2, N3 o N6 come codice natura dell''operazione'
    UNION ALL SELECT N'2.2.2.2', 448, N'00448: per le fatture transfrontaliere non è più ammesso il valore generico N2, N3 o N6 come codice natura dell''operazione'
    --UNION ALL SELECT N'', 321, N'00321: per le fatture transfrontaliere, in presenza di una partita IVA di gruppo IVA del Cedente/Prestatore occorre valorizzare il Codice Fiscale del Cedente/Prestatore con quello del soggetto partecipante al gruppo'
    --UNION ALL SELECT N'', 325, N'00325: per le fatture transfrontaliere, in presenza di una partita IVA di gruppo IVA del Cessionario/Committente occorre valorizzare il Codice Fiscale del Cessionario/Committente con quello del soggetto partecipante al gruppo'
)
MERGE INTO XMLCodifiche.CodiceErroreSDI AS DST
USING Novita AS SRC
ON SRC.IDCampo = DST.IDCampo AND SRC.CodiceErroreSDI = DST.CodiceErroreSDI
WHEN NOT MATCHED THEN INSERT (IDCampo, CodiceErroreSDI, DescrizioneErroreSDI) VALUES (SRC.IDCampo, SRC.CodiceErroreSDI, SRC.DescrizioneErroreSDI)
WHEN MATCHED AND DST.DescrizioneErroreSDI <> SRC.DescrizioneErroreSDI THEN UPDATE SET DST.DescrizioneErroreSDI = SRC.DescrizioneErroreSDI
OUTPUT $action, SRC.IDCampo, SRC.CodiceErroreSDI, SRC.DescrizioneErroreSDI;
GO
