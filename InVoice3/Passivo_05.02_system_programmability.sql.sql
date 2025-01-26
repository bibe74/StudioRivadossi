--USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

/**
 * @stored_procedure FXML.ssp_ImportaXMLPassivo_Documenti_Righe
 * @description

 * @param_input @PKImportXML
 * @param_input @IDDocumento
*/

CREATE OR ALTER PROCEDURE FXML.ssp_ImportaXMLPassivo_Documenti_Righe (
    @PKImportXML BIGINT,
    @IDDocumento UNIQUEIDENTIFIER
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @XML XML;

SELECT TOP 1 @XML = XMLContent
FROM FXML.ImportXML
WHERE PKImportXML = @PKImportXML;

SELECT
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('NumeroLinea').value('.', 'INT') AS NumeroLinea,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceTipo').value('.', 'NVARCHAR(35)') AS CodiceArticolo_CodiceTipo,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceValore').value('.', 'NVARCHAR(35)') AS CodiceArticolo_CodiceValore,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Descrizione').value('.', 'NVARCHAR(1000)') AS Descrizione,
    --FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Quantita').value('.', N'DECIMAL(20, 5)') AS Quantita,
	FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Quantita').value('.', N'NVARCHAR(21)') AS Quantita,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('UnitaMisura').value('.', N'NVARCHAR(10)') AS UnitaMisura,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoUnitario').value('.', N'DECIMAL(20, 5)') AS PrezzoUnitario,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoTotale').value('.', N'DECIMAL(20, 5)') AS PrezzoTotale,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('AliquotaIVA').value('.', N'DECIMAL(5, 2)') AS AliquotaIVA

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiBeniServizi/DettaglioLinee') AS FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee (XML)
WHERE IXML.PKImportXML = @PKImportXML;

/*** Check preventivi: Inizio ***/

PRINT 'Codici iva';

DECLARE @SDI_MaxProgr INT;

SELECT @SDI_MaxProgr = MAX(TRY_CAST(SUBSTRING(CI.ID, 4, LEN(CI.ID)) AS INT))
FROM dbo.CodiciIva CI
WHERE CI.ID LIKE N'SDI%';

WITH TrascodificaAliquotaIVA
AS (
    SELECT
        Perc AS AliquotaIVA,
        COALESCE(SDI_Natura, '') AS SDI_Natura,
        ID AS CodIva,
        ROW_NUMBER() OVER (PARTITION BY Perc, COALESCE(SDI_Natura, '') ORDER BY ID) AS rn

    FROM dbo.CodiciIva
),
AliquotaNatura
AS (
    SELECT DISTINCT
        FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('AliquotaIVA').value('.', N'DECIMAL(5, 2)') AS AliquotaIVA,
        COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Natura').value('.', N'CHAR(2)'), '') AS SDI_Natura

    FROM FXML.ImportXML IXML
    CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiBeniServizi/DettaglioLinee') AS FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee (XML)
    LEFT JOIN TrascodificaAliquotaIVA TAIVA ON TAIVA.AliquotaIVA = FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('AliquotaIVA').value('.', N'DECIMAL(5, 2)') AND TAIVA.SDI_Natura = COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Natura').value('.', N'CHAR(2)'), '')
        AND TAIVA.rn = 1
    WHERE IXML.PKImportXML = @PKImportXML
        AND TAIVA.CodIva IS NULL
)
INSERT INTO dbo.CodiciIva
(
    ID,
    Descrizione,
    Perc,
    ImpEsigibile,
    IvaEsigibile,
    EsenzionePlafond,
    SDI_Natura,
    SDI_RiferimentoNormativo,
    SDI_EsigibilitaIVA,
    IsSoggettoBollo
)
SELECT
    'SDI' + RIGHT('000' + CONVERT(VARCHAR(3), COALESCE(@SDI_MaxProgr, 0) + ROW_NUMBER() OVER (ORDER BY AN.AliquotaIVA, AN.SDI_Natura)), 3),
    'Importato da SDI',
    AN.AliquotaIVA,
    CAST(1 AS BIT),
    CAST(1 AS BIT),
    CAST(0 AS BIT),
    AN.SDI_Natura,
    NULL,
    'I',
    CAST(0 AS BIT)

FROM AliquotaNatura AN;

/*** Check preventivi: Fine ***/

PRINT 'Pre insert Documenti_Righe';

WITH TrascodificaAliquotaIVA
AS (
    SELECT
        Perc AS AliquotaIVA,
        COALESCE(SDI_Natura, '') AS SDI_Natura,
        ID AS CodIva,
        ROW_NUMBER() OVER (PARTITION BY Perc, COALESCE(SDI_Natura, '') ORDER BY ID) AS rn

    FROM dbo.CodiciIva
)
INSERT INTO dbo.Documenti_Righe
(
    ID,
    IDDocumento,
    IDArticolo,
    IDFamiglia,
    IDUnitaMisura,
    IDDocumento_Origine,
    IDDocumento_RigaOrigine,
    IDStato,
    Posizione,
    Qta,
    QtaEvasa,
    Codice,
    Descrizione1,
    Descrizione2,
    Descrizione3,
    Descrizione4,
    ImpUnitario,
    ImpNetto,
    Sconto,
    ImpSconto,
    ImpUnitarioScontato,
    ImpNettoScontato,
    CodIva,
    ImpIva,
    ImpLordo,
    NoteRiga,
    Lock_Delete,
    Lock_Qta,
    Lock_Codice,
    Lock_Descrizione1,
    Lock_Descrizione2,
    Lock_Descrizione3,
    Lock_Descrizione4,
    Nascondi,
    DisegnoNumero,
    CommessaNumero,
    CommessaDataConsegna,
    IDPreventivoPrevio,
    DdtEntrataNumero,
    DdtEntrataData,
    OrdCliNumero,
    OrdCliData,
    SDI_NumeroLinea,
	CodiceEsterno,
	CodiceEsternoTipo
)
SELECT
    NEWID(),      -- ID - uniqueidentifier
    @IDDocumento,      -- IDDocumento - uniqueidentifier
    COALESCE(TFA.IDArticolo, NULL),      -- IDArticolo - uniqueidentifier
    NULL,       -- IDFamiglia - nvarchar(50)
    NULL,       -- IDUnitaMisura - nvarchar(5)
    NULL,      -- IDDocumento_Origine - uniqueidentifier
    NULL,      -- IDDocumento_RigaOrigine - uniqueidentifier
    NULL,       -- IDStato - nvarchar(10)
    --MP 24/11/2020: Aggiunta posizione
    --ERA: NULL,         -- Posizione - int
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('NumeroLinea').value('.', 'INT'),          -- Posizione - int
    --FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Quantita').value('.', N'DECIMAL(20, 5)'),      -- Qta - numeric(19, 6)
	CASE 
		WHEN FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Quantita').value('.', N'NVARCHAR(21)') = '' 
		THEN 0.0
		ELSE FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Quantita').value('.', N'DECIMAL(20, 5)') 
		END
	AS Quantita,
    NULL,      -- QtaEvasa - numeric(19, 6)

    NULL,       -- Codice - nvarchar(50)
    --CASE WHEN COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceTipo').value('.', 'NVARCHAR(35)'), N'') = N'' THEN N'' ELSE FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceTipo').value('.', 'NVARCHAR(35)') + N'.' END
    --+ COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceValore').value('.', 'NVARCHAR(35)'), N''),-- Codice - nvarchar(50)

    --NULL,       -- Descrizione1 - nvarchar(1000)
    COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Descrizione').value('.', 'NVARCHAR(1000)'), N''),       -- Descrizione1 - nvarchar(1000)

    NULL,       -- Descrizione2 - nvarchar(255)
    NULL,       -- Descrizione3 - nvarchar(255)
    NULL,       -- Descrizione4 - nvarchar(255)
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoUnitario').value('.', N'DECIMAL(20, 5)'),      -- ImpUnitario - numeric(19, 6)
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoTotale').value('.', N'DECIMAL(20, 5)'),      -- ImpNetto - numeric(19, 6)
    NULL,       -- Sconto - nvarchar(20)
    NULL,      -- ImpSconto - numeric(19, 6)
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoUnitario').value('.', N'DECIMAL(20, 5)'),      -- ImpUnitarioScontato - numeric(19, 6)
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoTotale').value('.', N'DECIMAL(20, 5)'),      -- ImpNettoScontato - numeric(19, 6)

    COALESCE(TAIVA.CodIva, N'> TODO <'),       -- CodIva - nvarchar(10)
    --NULL,       -- CodIva - nvarchar(10)

    NULL,      -- ImpIva - numeric(19, 6)
    NULL,      -- ImpLordo - numeric(19, 6)
    NULL,       -- NoteRiga - nvarchar(2500)
    NULL,      -- Lock_Delete - bit
    NULL,      -- Lock_Qta - bit
    NULL,      -- Lock_Codice - bit
    NULL,      -- Lock_Descrizione1 - bit
    NULL,      -- Lock_Descrizione2 - bit
    NULL,      -- Lock_Descrizione3 - bit
    NULL,      -- Lock_Descrizione4 - bit
    NULL,      -- Nascondi - bit
    NULL,       -- DisegnoNumero - nvarchar(20)
    NULL,       -- CommessaNumero - nvarchar(20)
    NULL, -- CommessaDataConsegna - datetime
    NULL,      -- IDPreventivoPrevio - uniqueidentifier
    NULL,       -- DdtEntrataNumero - nvarchar(20)
    NULL, -- DdtEntrataData - datetime
    NULL,       -- OrdCliNumero - nvarchar(20)
    NULL, -- OrdCliData - datetime
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('NumeroLinea').value('.', 'INT'),          -- SDI_NumeroLinea - int
    COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceValore').value('.', 'NVARCHAR(35)'), N''), -- CodiceEsterno - nvarchar(50)
	CASE WHEN COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceTipo').value('.', 'NVARCHAR(35)'), N'') = N'' THEN N'' ELSE FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceTipo').value('.', 'NVARCHAR(35)') END -- CodiceEsternoTipo - NVARCHAR(50)

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiBeniServizi/DettaglioLinee') AS FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee (XML)
INNER JOIN dbo.Documenti D ON D.ID = @IDDocumento
LEFT JOIN FXML.TrascodificaFornitoreArticolo TFA ON TFA.IDFornitore = D.IDCliFor AND TFA.CodiceValore = FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceValore').value('.', 'NVARCHAR(35)')
LEFT JOIN TrascodificaAliquotaIVA TAIVA ON TAIVA.AliquotaIVA = FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('AliquotaIVA').value('.', N'DECIMAL(5, 2)') AND TAIVA.SDI_Natura = COALESCE(FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Natura').value('.', N'CHAR(2)'), '')
    AND TAIVA.rn = 1
WHERE IXML.PKImportXML = @PKImportXML;

--Controllo codici

PRINT 'Codici articoli';

UPDATE
	DR
SET	
	DR.IDArticolo = A.ID,
	DR.Codice = A.Codice
FROM	
	dbo.Documenti_Righe DR 
	INNER JOIN dbo.Articoli A 
		ON A.Codice = DR.CodiceEsterno
WHERE DR.IDDocumento=@idDocumento
	AND COALESCE(DR.Codice,'') = '' AND DR.CodiceEsterno <> ''

--Controllo codici esterni

PRINT 'Codici esterni';

UPDATE
	DR
SET	
	DR.IDArticolo = A.ID,
	DR.Codice = A.Codice
FROM	
	dbo.Documenti D
	INNER JOIN dbo.Documenti_Righe DR 
		ON DR.IDDocumento = D.ID
	INNER JOIN dbo.Articoli_CodiciEsterni ACE 
		ON ACE.IDCliFor = D.IDCliFor
		AND ACE.CodiceEsterno = DR.CodiceEsterno
	INNER JOIN dbo.Articoli A 
		ON A.ID = ACE.IDArticolo
WHERE DR.IDDocumento=@idDocumento
	AND COALESCE(DR.Codice,'') = '' AND DR.CodiceEsterno <> ''

PRINT 'Post insert Documenti_Righe';

END;
GO

/**
 * @stored_procedure FXML.ssp_ImportaXMLPassivo_Documenti_Scadenze
 * @description

 * @param_input @PKImportXML
 * @param_input @IDDocumento
*/

IF OBJECT_ID('FXML.ssp_ImportaXMLPassivo_Documenti_Scadenze', N'P') IS NULL EXEC('CREATE PROCEDURE FXML.ssp_ImportaXMLPassivo_Documenti_Scadenze AS RETURN 0;');
GO

ALTER PROCEDURE FXML.ssp_ImportaXMLPassivo_Documenti_Scadenze (
    @PKImportXML BIGINT,
    @IDDocumento UNIQUEIDENTIFIER
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @XML XML;

SELECT TOP 1 @XML = XMLContent
FROM FXML.ImportXML
WHERE PKImportXML = @PKImportXML;

SELECT
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('ModalitaPagamento').value('.', 'CHAR(4)') AS ModalitaPagamento,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('DataScadenzaPagamento').value('.', 'DATE') AS DataScadenzaPagamento,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('ImportoPagamento').value('.', 'DECIMAL(15, 2)') AS ImportoPagamento,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('IstitutoFinanziario').value('.', 'NVARCHAR(80)') AS IstitutoFinanziario,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('IBAN').value('.', N'NVARCHAR(34)') AS IBAN,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('ABI').value('.', N'INT') AS ABI,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('CAB').value('.', N'INT') AS CAB,
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('BIC').value('.', N'NVARCHAR(11)') AS BIC

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiPagamento/DettaglioPagamento') AS FatturaElettronicaBody_DatiPagamento_DettaglioPagamento (XML)
WHERE IXML.PKImportXML = @PKImportXML;

/*** Check preventivi: Inizio ***/

/*** Check preventivi: Fine ***/

PRINT 'Pre insert Documenti_Scadenze';

WITH TrascodificaModalitaPagamento
AS (
    SELECT
        MPT.SDI_ModalitaPagamento,
        MPT.ID AS IDTipoPagamento,
        ROW_NUMBER() OVER (PARTITION BY MPT.SDI_ModalitaPagamento ORDER BY CASE WHEN MPT.ID = COALESCE(MPT.SDI_ModalitaPagamento, '') THEN 0 ELSE 1 END, MPT.ID) AS rn

    FROM dbo.ModalitaPagamento_Tipi MPT
    WHERE COALESCE(MPT.SDI_ModalitaPagamento, '') <> ''
)
INSERT INTO dbo.Documenti_Scadenze
(
    ID,
    IDDocumento,
    BancaCassa,
    Insoluto,
    RbEsportata,
    RbEsportataData,
    RbBanca,
    Descrizione,
    Note,
    Data,
    Numero,
    Tipo,
    Importo,
    IDTipoPagamento
)
SELECT
    NEWID(),      -- ID - uniqueidentifier
    @IDDocumento,      -- IDDocumento - uniqueidentifier
    NULL,       -- BancaCassa - nvarchar(5)
    NULL,      -- Insoluto - bit
    NULL,      -- RbEsportata - bit
    NULL, -- RbEsportataData - datetime
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('IstitutoFinanziario').value('.', 'NVARCHAR(80)'),       -- RbBanca - nvarchar(50)
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('IstitutoFinanziario').value('.', 'NVARCHAR(80)'),       -- Descrizione - nvarchar(100)
    NULL,       -- Note - nvarchar(100)
    CASE WHEN FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('DataScadenzaPagamento').value('.', 'DATE') = CAST('19000101' AS DATE) THEN CAST(D.Data AS DATE) ELSE FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('DataScadenzaPagamento').value('.', 'DATE') END AS Data, -- Data - datetime
    ROW_NUMBER() OVER (ORDER BY FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('DataScadenzaPagamento').value('.', 'DATE')),         -- Numero - int
    1 AS Tipo,         -- Tipo - int
    FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('ImportoPagamento').value('.', 'DECIMAL(15, 2)'),      -- Importo - numeric(19, 6)
    COALESCE(TMP.IDTipoPagamento, N'')        -- IDTipoPagamento - nvarchar(4)

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiPagamento/DettaglioPagamento') AS FatturaElettronicaBody_DatiPagamento_DettaglioPagamento (XML)
INNER JOIN dbo.Documenti D ON D.ID = @IDDocumento
LEFT JOIN TrascodificaModalitaPagamento TMP ON TMP.SDI_ModalitaPagamento = FatturaElettronicaBody_DatiPagamento_DettaglioPagamento.XML.query('ModalitaPagamento').value('.', 'CHAR(4)')
    AND TMP.rn = 1
WHERE IXML.PKImportXML = @PKImportXML;

IF (@@ROWCOUNT = 0)
BEGIN

    DECLARE @SDI_Passivo_ModalitaPagamentoTipoDefault CHAR(4) = NULL;

    SELECT TOP 1 @SDI_Passivo_ModalitaPagamentoTipoDefault = CP.Valore
    FROM dbo.Conf_Parametri CP
    WHERE CP.ID = N'SDI_Passivo_ModalitaPagamentoTipoDefault';

    IF (@SDI_Passivo_ModalitaPagamentoTipoDefault IS NULL) SET @SDI_Passivo_ModalitaPagamentoTipoDefault = N'MP01'; -- MP01: Contanti

    WITH TrascodificaModalitaPagamento
    AS (
        SELECT
            MPT.SDI_ModalitaPagamento,
            MPT.ID AS IDTipoPagamento,
            ROW_NUMBER() OVER (PARTITION BY MPT.SDI_ModalitaPagamento ORDER BY CASE WHEN MPT.ID = COALESCE(MPT.SDI_ModalitaPagamento, '') THEN 0 ELSE 1 END, MPT.ID) AS rn

        FROM dbo.ModalitaPagamento_Tipi MPT
        WHERE COALESCE(MPT.SDI_ModalitaPagamento, '') <> ''
    )
    INSERT INTO dbo.Documenti_Scadenze
    (
        ID,
        IDDocumento,
        BancaCassa,
        Insoluto,
        RbEsportata,
        RbEsportataData,
        RbBanca,
        Descrizione,
        Note,
        Data,
        Numero,
        Tipo,
        Importo,
        IDTipoPagamento
    )
    SELECT
        NEWID(),      -- ID - uniqueidentifier
        @IDDocumento,      -- IDDocumento - uniqueidentifier
        NULL,       -- BancaCassa - nvarchar(5)
        NULL,      -- Insoluto - bit
        NULL,      -- RbEsportata - bit
        NULL, -- RbEsportataData - datetime
        NULL,       -- RbBanca - nvarchar(50)
        NULL,       -- Descrizione - nvarchar(100)
        NULL,       -- Note - nvarchar(100)
        CAST(D.Data AS DATE) AS Data, -- Data - datetime
        1 AS Numero,         -- Numero - int
        1 AS Tipo,         -- Tipo - int
        D.TotDoc,      -- Importo - numeric(19, 6)
        N''        -- IDTipoPagamento - nvarchar(4)

    FROM FXML.ImportXML IXML
    INNER JOIN dbo.Documenti D ON D.ID = @IDDocumento
    LEFT JOIN TrascodificaModalitaPagamento TMP ON TMP.SDI_ModalitaPagamento = @SDI_Passivo_ModalitaPagamentoTipoDefault
        AND TMP.rn = 1
    WHERE IXML.PKImportXML = @PKImportXML;

END;

PRINT 'Post insert Documenti_Scadenze';

END;
GO

/**
 * @stored_procedure FXML.ssp_ImportaXMLPassivo_Documenti_Iva
 * @description

 * @param_input @PKImportXML
 * @param_input @IDDocumento
*/

CREATE OR ALTER PROCEDURE FXML.ssp_ImportaXMLPassivo_Documenti_Iva (
    @PKImportXML BIGINT,
    @IDDocumento UNIQUEIDENTIFIER
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @XML XML;

SELECT TOP 1 @XML = XMLContent
FROM FXML.ImportXML
WHERE PKImportXML = @PKImportXML;

PRINT 'Pre insert Documenti_Iva';

INSERT INTO dbo.Documenti_Iva
(
    ID,
    IDDocumento,
    IDPlafondEsenzione,
    ImpNetto,
    CodIva,
    ImpIva,
    ImpLordo
)
SELECT
   NEWID(),			-- ID - uniqueidentifier
    @IDDocumento,	-- IDDocumento - uniqueidentifier
    0,				-- IDPlafondEsenzione - int
    FatturaElettronicaBody_DatiBeniServizi_DatiRiepilogo.XML.query('ImponibileImporto').value('.', 'DECIMAL(15, 2)'),	-- ImpNetto - numeric(19, 6)
    FatturaElettronicaBody_DatiBeniServizi_DatiRiepilogo.XML.query('AliquotaIVA').value('.', 'NVARCHAR(10)'),			-- CodIva - nvarchar(10)
    FatturaElettronicaBody_DatiBeniServizi_DatiRiepilogo.XML.query('Imposta').value('.', 'DECIMAL(15, 2)'),				-- ImpIva - numeric(19, 6)
    FatturaElettronicaBody_DatiBeniServizi_DatiRiepilogo.XML.query('ImponibileImporto').value('.', 'DECIMAL(15, 2)')
    + FatturaElettronicaBody_DatiBeniServizi_DatiRiepilogo.XML.query('Imposta').value('.', 'DECIMAL(15, 2)')			-- ImpLordo - numeric(19, 6)
FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiBeniServizi/DatiRiepilogo') AS FatturaElettronicaBody_DatiBeniServizi_DatiRiepilogo (XML)
INNER JOIN dbo.Documenti D ON D.ID = @IDDocumento
WHERE IXML.PKImportXML = @PKImportXML;

WITH DI AS (
	SELECT	
		DI.IDDocumento,
		SUM(DI.ImpNetto) AS TotImpNetto,
		SUM(DI.ImpIva) AS TotImpIva,
		SUM(DI.ImpLordo) AS TotImpLordo
	FROM dbo.Documenti_Iva DI 
	WHERE DI.IDDocumento=@IDDocumento
	GROUP BY DI.IDDocumento
)
UPDATE D
SET
	D.TotRighe = ROUND(DI.TotImpNetto / (1.0 + COALESCE(D.Inps, 0.0) / 100.0), 2),
	D.TotImp = DI.TotImpNetto,
	D.TotIva = DI.TotImpIva,
	D.TotLordo = DI.TotImpLordo,
	D.TotDoc = DI.TotImpLordo - DI.TotImpNetto * COALESCE(D.RitAcc, 0.0) / 100.0
FROM 
	dbo.Documenti D INNER JOIN	
	DI ON DI.IDDocumento = D.ID
WHERE 
	D.ID=@IDDocumento;

END;
GO

/**
 * @stored_procedure FXML.ssp_ImportaXMLPassivo_Documenti
 * @description

 * @param_input @PKImportXML

 * @param_output @IDDocumento
*/

CREATE OR ALTER PROCEDURE FXML.ssp_ImportaXMLPassivo_Documenti (
    @PKImportXML BIGINT,
    @IDDocumento UNIQUEIDENTIFIER OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @XML XML;

SELECT TOP 1 @XML = XMLContent
FROM FXML.ImportXML
WHERE PKImportXML = @PKImportXML;

SELECT
    FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdPaese').value('.', 'CHAR(2)') AS CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdPaese,
    FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdCodice').value('.', 'NVARCHAR(28)') AS CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/CodiceFiscale').value('.', 'NVARCHAR(16)') AS CedentePrestatore_DatiAnagrafici_CodiceFiscale

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaHeader') AS FatturaElettronicaHeader (XML)
WHERE IXML.PKImportXML = @PKImportXML;

SELECT
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/TipoDocumento').value('.', 'CHAR(4)') AS DatiGenerali_DatiGeneraliDocumento_TipoDocumento,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Divisa').value('.', 'CHAR(3)') AS DatiGenerali_DatiGeneraliDocumento_Divisa,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Data').value('.', N'DATE') AS DatiGenerali_DatiGeneraliDocumento_Data,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Numero').value('.', N'NVARCHAR(20)') AS DatiGenerali_DatiGeneraliDocumento_Numero

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody') AS FatturaElettronicaBody (XML)
WHERE IXML.PKImportXML = @PKImportXML;

/*** Check preventivi: Inizio ***/

DECLARE @XML_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice NVARCHAR(28);
DECLARE @XML_CedentePrestatore_DatiAnagrafici_CodiceFiscale NVARCHAR(16);
DECLARE @XML_CedentePrestatore_Sede_Nazione CHAR(2);
DECLARE @XML_DatiGenerali_DatiGeneraliDocumento_TipoDocumento CHAR(4);
DECLARE @XML_DatiGenerali_DatiGeneraliDocumento_Data DATE;
DECLARE @XML_DatiGenerali_DatiGeneraliDocumento_Numero NVARCHAR(20);

DECLARE @IDCliFor UNIQUEIDENTIFIER;
DECLARE @Nazione NVARCHAR(50);

SELECT
    @XML_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice = FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdCodice').value('.', 'NVARCHAR(28)'),
    @XML_CedentePrestatore_DatiAnagrafici_CodiceFiscale = FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/CodiceFiscale').value('.', 'NVARCHAR(16)'),
    @XML_CedentePrestatore_Sede_Nazione = FatturaElettronicaHeader.XML.query('CedentePrestatore/Sede/Nazione').value('.', 'CHAR(2)')

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaHeader') AS FatturaElettronicaHeader (XML)
WHERE IXML.PKImportXML = @PKImportXML;

SELECT
    @XML_DatiGenerali_DatiGeneraliDocumento_TipoDocumento = FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/TipoDocumento').value('.', 'CHAR(4)'),
    @XML_DatiGenerali_DatiGeneraliDocumento_Data = FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Data').value('.', N'DATE'),
    @XML_DatiGenerali_DatiGeneraliDocumento_Numero = FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Numero').value('.', N'NVARCHAR(20)')

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody') AS FatturaElettronicaBody (XML)
WHERE IXML.PKImportXML = @PKImportXML;

SELECT TOP 1
    @IDCliFor = CF.ID
FROM dbo.CliFor CF
WHERE CF.Fornitore = CAST(1 AS BIT)
    AND (
        [PI] = @XML_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice
        --MP 24/11/2020: ERA: OR CF = @XML_CedentePrestatore_DatiAnagrafici_CodiceFiscale
        OR (COALESCE(CF, '') <> '' AND CF = @XML_CedentePrestatore_DatiAnagrafici_CodiceFiscale)
    );

SELECT
    @Nazione = N.Nazione

FROM InVoiceXML.XMLCodifiche.Nazione N
WHERE N.IDNazione = @XML_CedentePrestatore_Sede_Nazione;

SELECT @Nazione = COALESCE(@Nazione, N'Italia');

--MPI: 17/10/2019: Aggiungo nazione se non esiste : Begin
INSERT INTO dbo.Nazioni
(
    ID,
    SDI_IDNazione,
    SDI_Esportazione,
    BolloVirtuale
)

SELECT 
	N.Nazione,
	N.IDNazione,
	0,
	0
FROM
	inVoiceXml.XMLCodifiche.Nazione N
WHERE NOT EXISTS (SELECT N2.SDI_IDNazione 
				  FROM dbo.Nazioni N2 
				  WHERE N2.SDI_IDNazione COLLATE Latin1_General_CI_AS = N.IDNazione COLLATE Latin1_General_CI_AS
				  AND   N2.ID COLLATE Latin1_General_CI_AS = N.Nazione COLLATE Latin1_General_CI_AS)
	AND N.IDNazione = @XML_CedentePrestatore_Sede_Nazione;
--MPI: 17/10/2019: Aggiungo nazione se non esiste : End

SELECT
    @XML_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice AS XML_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice,
    @XML_CedentePrestatore_DatiAnagrafici_CodiceFiscale AS XML_CedentePrestatore_DatiAnagrafici_CodiceFiscale,
    @IDCliFor AS IDCliFor,
    @Nazione AS Nazione;

DECLARE @XML_TipoDocumento CHAR(4);
DECLARE @IDTipoDocumento NVARCHAR(20);
DECLARE @ModelloReport NVARCHAR(50);

SELECT
    @XML_TipoDocumento = FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/TipoDocumento').value('.', 'CHAR(4)')

FROM FXML.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody') AS FatturaElettronicaBody (XML)
WHERE IXML.PKImportXML = @PKImportXML;

-- #071 Richieste di modifica/integrazione - 28/11/2020 - BEGIN
/* Era:
SELECT TOP 1
    @IDTipoDocumento = DT.ID,
	@ModelloReport = DT.ModelloReport

FROM dbo.Documenti_Tipi DT
WHERE DT.SDI_TipoDocumentoPassivo = @XML_TipoDocumento;
*/

SELECT TOP 1
    @IDTipoDocumento = IDTipoDocumento_InVoice

FROM FXML.TipiDocumentoIngresso
WHERE IDTipoDocumento_SDI = @XML_TipoDocumento
ORDER BY IDTipoDocumento_InVoice;

IF @IDTipoDocumento IS NOT NULL
BEGIN

SELECT TOP 1
    @ModelloReport = DT.ModelloReport

FROM dbo.Documenti_Tipi DT
WHERE DT.ID = @IDTipoDocumento
ORDER BY DT.ID;

END;

IF @IDTipoDocumento IS NULL
BEGIN

    UPDATE FXML.ImportXML
    SET IDStatoImportazione = 99 -- 99: importazione terminata con errori
    WHERE PKImportXML = @PKImportXML;

    SET @IDDocumento = NULL;

END;
ELSE
BEGIN

-- #071 Richieste di modifica/integrazione - 28/11/2020 - END

SELECT
    @XML_TipoDocumento AS XML_IDTipoDocumento,
    @IDTipoDocumento AS IDTipoDocumento;

/*** Check preventivi: Fine ***/

BEGIN TRANSACTION 

BEGIN TRY

    SET @IDDocumento = NEWID();

    PRINT @IDDocumento;

    UPDATE FXML.ImportXML
    SET IDStatoImportazione = 1, -- 1: importazione in corso
        CedentePrestatore_DatiAnagrafici_IDFiscaleIVA_IdCodice = @XML_CedentePrestatore_DatiAnagrafici_IdFiscaleIVA_IdCodice,
        DatiGenerali_DatiGeneraliDocumento_TipoDocumento = @XML_DatiGenerali_DatiGeneraliDocumento_TipoDocumento,
        DatiGenerali_DatiGeneraliDocumento_Data = @XML_DatiGenerali_DatiGeneraliDocumento_Data,
        DatiGenerali_DatiGeneraliDocumento_Numero = @XML_DatiGenerali_DatiGeneraliDocumento_Numero,
        IDDocumento = @IDDocumento

    WHERE PKImportXML = @PKImportXML;

    PRINT 'Pre insert dbo.Documenti';

    INSERT INTO dbo.Documenti
    (
        ID,
        IDTipo,
        IDStato,
        IDCliFor,
        IDCliFor_Indirizzo,
        IDCausale,
        IDMagazzino,
        IDMagazzinoOpposto,
        Numero,
        NumeroPre,
        NumeroInt,
        NumeroPos,
        Data,
        DataConsegna,
        CF,
        PI,
        Intestazione,
        Intestazione2,
        Indirizzo,
        Cap,
        Comune,
        Provincia,
        Nazione,
        Pag_Modalita,
        Pag_CalcolaImporti,
        Pag_Banca,
        Pag_Cin,
        Pag_Abi,
        Pag_Cab,
        Pag_Cc,
        Pag_Iban,
        Pag_Bic,
        Pag_Spese,
        Pag_ExtraSconto,
        Pag_ExtraSconto_Perc,
        Dest_Intestazione,
        Dest_Intestazione2,
        Dest_Indirizzo,
        Dest_Cap,
        Dest_Comune,
        Dest_Provincia,
        Dest_Nazione,
        Note,
        TotRighe,
        Inps,
        TotImp,
        TotIva,
        TotLordo,
        RitAcc,
        TotDoc,
        Righe,
        RigheEvase,
        RigheEvaseParz,
        CondFor_Validita,
        CondFor_Tempi,
        CondFor_Trasporto,
        CondFor_Resa,
        CondFor_Note,
        Trasp_TsInizio,
        Trasp_Mezzo,
        Trasp_Aspetto,
        Trasp_Colli,
        Trasp_Peso,
        Trasp_Porto,
        Trasp_Vettore1,
        Trasp_Vettore2,
        Trasp_Vettore3,
        Trasp_IDVeicolo,
        Trasp_DistanzaKm,
        Trasp_MezzoCedente,
        Trasp_MezzoCessionario,
        NascondiTotali,
        SoggettoRitAcc,
        Pag_ModalitaSviluppata,
        Protocollo,
        DescrizioneRidottaSingolare,
        AllegatoModello,
        AllegatoFile,
        IDFornitura,
        IDBancaRB,
        Creazione_Ts,
        Creazione_IDUtente,
        Modifica_Ts,
        Modifica_IDUtente,
        Allegato,
        Rif_CodiceFornitore,
        Rif_Ordine,
        Rif_Magazzino,
        SitPag_TotPagato,
        SitPag_TotProvvigione,
        SitPag_TotProvvigionePagato,
        Pdf,
        Pdf_Ts,
        Riferimenti,
        Evaso,
        Evade,
        IDReferente,
        DataRichiesta,
        ModelloReport,
        Qta,
        QtaEvasa,
        SDI_Stato,
        SDI_StatoTs,
        SDI_LogEvento,
        SDI_LogValidazione,
        CodiceCIG,
        CodiceCUP,
        Sospeso,
        HasDatiBollo,
        ImportoBollo
        -- #071 Richieste di modifica/integrazione - 28/11/2020 - BEGIN
        , SDI_IDTipoDocumento
        -- #071 Richieste di modifica/integrazione - 28/11/2020 - END
    )
    SELECT
        @IDDocumento,      -- ID - uniqueidentifier
        @IDTipoDocumento,       -- IDTipo - nvarchar(20)
        NULL,       -- IDStato - nvarchar(10)
        @IDCliFor,      -- IDCliFor - uniqueidentifier
        NULL,      -- IDCliFor_Indirizzo - uniqueidentifier
        NULL,       -- IDCausale - nvarchar(3)
        NULL,       -- IDMagazzino - nvarchar(3)
        NULL,       -- IDMagazzinoOpposto - nvarchar(3)
        NULL,       -- Numero - nvarchar(20)
        NULL,       -- NumeroPre - nvarchar(10)
        NULL,         -- NumeroInt - int
        NULL,       -- NumeroPos - nvarchar(10)
        NULL, -- Data - datetime
        NULL, -- DataConsegna - datetime
        FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/CodiceFiscale').value('.', 'NVARCHAR(16)'),       -- CF - nvarchar(50)
        FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/IdFiscaleIVA/IdCodice').value('.', 'NVARCHAR(28)'),       -- PI - nvarchar(50)
        CASE WHEN COALESCE(FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/Anagrafica/Denominazione').value('.', 'NVARCHAR(80)'), N'') = N''
            THEN FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/Anagrafica/Cognome').value('.', 'NVARCHAR(80)')
                + N' ' + FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/Anagrafica/Nome').value('.', 'NVARCHAR(80)')
            ELSE FatturaElettronicaHeader.XML.query('CedentePrestatore/DatiAnagrafici/Anagrafica/Denominazione').value('.', 'NVARCHAR(80)')
        END,       -- Intestazione - nvarchar(100)
        NULL,       -- Intestazione2 - nvarchar(50)
        FatturaElettronicaHeader.XML.query('CedentePrestatore/Sede/Indirizzo').value('.', 'NVARCHAR(60)'),       -- Indirizzo - nvarchar(50)
        FatturaElettronicaHeader.XML.query('CedentePrestatore/Sede/CAP').value('.', 'NVARCHAR(5)'),       -- Cap - nvarchar(50)
        FatturaElettronicaHeader.XML.query('CedentePrestatore/Sede/Comune').value('.', 'NVARCHAR(60)'),       -- Comune - nvarchar(50)
        FatturaElettronicaHeader.XML.query('CedentePrestatore/Sede/Provincia').value('.', 'CHAR(2)'),       -- Provincia - nvarchar(50)
        @Nazione,       -- Nazione - nvarchar(50)
        NULL,       -- Pag_Modalita - nvarchar(100)
        NULL,      -- Pag_CalcolaImporti - bit
        NULL,       -- Pag_Banca - nvarchar(100)
        NULL,       -- Pag_Cin - nvarchar(1)
        NULL,       -- Pag_Abi - nvarchar(5)
        NULL,       -- Pag_Cab - nvarchar(5)
        NULL,       -- Pag_Cc - nvarchar(50)
        NULL,       -- Pag_Iban - nvarchar(50)
        NULL,       -- Pag_Bic - nvarchar(50)
        NULL,      -- Pag_Spese - bit
        NULL,       -- Pag_ExtraSconto - nvarchar(20)
        NULL,       -- Pag_ExtraSconto_Perc - float
        NULL,       -- Dest_Intestazione - nvarchar(100)
        NULL,       -- Dest_Intestazione2 - nvarchar(50)
        NULL,       -- Dest_Indirizzo - nvarchar(50)
        NULL,       -- Dest_Cap - nvarchar(50)
        NULL,       -- Dest_Comune - nvarchar(50)
        NULL,       -- Dest_Provincia - nvarchar(50)
        NULL,       -- Dest_Nazione - nvarchar(50)
        NULL,       -- Note - nvarchar(2500)
        NULL,      -- TotRighe - numeric(19, 6)
        NULL,      -- Inps - numeric(19, 6)
        NULL,      -- TotImp - numeric(19, 6)
        NULL,      -- TotIva - numeric(19, 6)
        NULL,      -- TotLordo - numeric(19, 6)
        NULL,      -- RitAcc - numeric(19, 6)
        NULL,      -- TotDoc - numeric(19, 6)
        NULL,         -- Righe - int
        NULL,         -- RigheEvase - int
        NULL,         -- RigheEvaseParz - int
        NULL,       -- CondFor_Validita - nvarchar(50)
        NULL,       -- CondFor_Tempi - nvarchar(50)
        NULL,       -- CondFor_Trasporto - nvarchar(50)
        NULL,       -- CondFor_Resa - nvarchar(50)
        NULL,       -- CondFor_Note - nvarchar(500)
        NULL,       -- Trasp_TsInizio - nvarchar(50)
        NULL,       -- Trasp_Mezzo - nvarchar(100)
        NULL,       -- Trasp_Aspetto - nvarchar(100)
        NULL,         -- Trasp_Colli - int
        NULL,      -- Trasp_Peso - numeric(19, 6)
        NULL,       -- Trasp_Porto - nvarchar(100)
        NULL,       -- Trasp_Vettore1 - nvarchar(200)
        NULL,       -- Trasp_Vettore2 - nvarchar(200)
        NULL,       -- Trasp_Vettore3 - nvarchar(200)
        NULL,       -- Trasp_IDVeicolo - nvarchar(50)
        NULL,         -- Trasp_DistanzaKm - int
        NULL,      -- Trasp_MezzoCedente - bit
        NULL,      -- Trasp_MezzoCessionario - bit
        NULL,      -- NascondiTotali - bit
        NULL,      -- SoggettoRitAcc - bit
        NULL,       -- Pag_ModalitaSviluppata - nvarchar(100)
        NULL,       -- Protocollo - nvarchar(50)
        NULL,       -- DescrizioneRidottaSingolare - nvarchar(50)
        NULL,       -- AllegatoModello - nvarchar(255)
        NULL,       -- AllegatoFile - nvarchar(255)
        NULL,       -- IDFornitura - nvarchar(20)
        NULL,       -- IDBancaRB - nvarchar(50)
        CURRENT_TIMESTAMP, -- Creazione_Ts - datetime
        NULL,       -- Creazione_IDUtente - nvarchar(20)
        CURRENT_TIMESTAMP, -- Modifica_Ts - datetime
        NULL,       -- Modifica_IDUtente - nvarchar(20)
        NULL,       -- Allegato - nvarchar(255)
        NULL,       -- Rif_CodiceFornitore - nvarchar(50)
        NULL,       -- Rif_Ordine - nvarchar(255)
        NULL,       -- Rif_Magazzino - nvarchar(50)
        NULL,      -- SitPag_TotPagato - numeric(19, 6)
        NULL,      -- SitPag_TotProvvigione - numeric(19, 6)
        NULL,      -- SitPag_TotProvvigionePagato - numeric(19, 6)
        NULL,      -- Pdf - bit
        NULL, -- Pdf_Ts - datetime
        NULL,       -- Riferimenti - nvarchar(2500)
        NULL,       -- Evaso - nvarchar(255)
        NULL,       -- Evade - nvarchar(255)
        NULL,       -- IDReferente - nvarchar(20)
        NULL, -- DataRichiesta - datetime
        @ModelloReport,       -- ModelloReport - nvarchar(50)
        NULL,      -- Qta - numeric(19, 6)
        NULL,      -- QtaEvasa - numeric(19, 6)
        -1,         -- SDI_Stato - int
        CURRENT_TIMESTAMP, -- SDI_StatoTs - datetime
        NULL,       -- SDI_LogEvento - nvarchar(500)
        NULL,       -- SDI_LogValidazione - nvarchar(1500)
        NULL,       -- CodiceCIG - nvarchar(15)
        NULL,       -- CodiceCUP - nvarchar(15)
        CAST(0 AS BIT),      -- Sospeso - bit
        CAST(0 AS BIT),      -- HasDatiBollo - bit
        0.0       -- ImportoBollo - decimal(14, 2)
        -- #071 Richieste di modifica/integrazione - 28/11/2020 - BEGIN
        , @XML_TipoDocumento
        -- #071 Richieste di modifica/integrazione - 28/11/2020 - END

    FROM FXML.ImportXML IXML
    CROSS APPLY @XML.nodes('//FatturaElettronicaHeader') AS FatturaElettronicaHeader (XML)
    WHERE IXML.PKImportXML = @PKImportXML;

    PRINT 'Post insert dbo.Documenti';

    PRINT 'Pre update dbo.Documenti';

    DECLARE @Numero NVARCHAR(20);
    DECLARE @Data DATETIME;
    DECLARE @HasDatiBollo BIT;
    DECLARE @ImportoBollo DECIMAL(14, 2);
    DECLARE @TotRighe DECIMAL(19, 6);
    DECLARE @Inps DECIMAL(19, 6);
    DECLARE @ImportoInps DECIMAL(19, 6);
    DECLARE @TotImp DECIMAL(19, 6);
    DECLARE @TotIva DECIMAL(19, 6);
    DECLARE @TotLordo DECIMAL(19, 6);
    DECLARE @RitAcc DECIMAL(19, 6);
    DECLARE @ImportoRitAcc DECIMAL(19, 6);
    --DECLARE @SoggettoRitAcc BIT;
    DECLARE @TotDoc DECIMAL(19, 6);

    SELECT
        @Numero = FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Numero').value('.', N'NVARCHAR(20)'),
        @Data = FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Data').value('.', N'DATE'),

        @HasDatiBollo = CASE WHEN COALESCE(FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiBollo/BolloVirtuale').value('.', N'CHAR(2)'), '') = '' THEN 0 ELSE 1 END,
        @ImportoBollo = CASE WHEN COALESCE(FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo').value('.', N'NVARCHAR(20)'), N'') = N'' THEN 0.0 ELSE CONVERT(DECIMAL(14, 2), FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiBollo/ImportoBollo').value('.', N'NVARCHAR(20)')) END,
        @Inps = CASE WHEN COALESCE(FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale/TipoCassa').value('.', N'NVARCHAR(20)'), N'') = N'TC22'
            THEN CONVERT(DECIMAL(19, 6), FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale/AlCassa').value('.', N'NVARCHAR(20)'))
            ELSE 0.0
        END,
        @ImportoInps = CASE WHEN COALESCE(FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale/TipoCassa').value('.', N'NVARCHAR(20)'), N'') = N'TC22'
            THEN CONVERT(DECIMAL(19, 6), FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiCassaPrevidenziale/ImportoContributoCassa').value('.', N'NVARCHAR(20)'))
            ELSE 0.0
        END,
        @RitAcc = CASE WHEN COALESCE(FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/AliquotaRitenuta').value('.', N'NVARCHAR(20)'), N'') = N'' THEN 0.0 ELSE CONVERT(DECIMAL(19, 6), FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/AliquotaRitenuta').value('.', N'NVARCHAR(20)')) END,
        @ImportoRitAcc = CASE WHEN COALESCE(FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/ImportoRitenuta').value('.', N'NVARCHAR(20)'), N'') = N'' THEN 0.0 ELSE CONVERT(DECIMAL(19, 6), FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/DatiRitenuta/ImportoRitenuta').value('.', N'NVARCHAR(20)')) END,
        @TotLordo = CONVERT(DECIMAL(19, 6), FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/ImportoTotaleDocumento').value('.', N'NVARCHAR(20)'))
    
	FROM dbo.Documenti D
    INNER JOIN FXML.ImportXML TXML ON TXML.PKImportXML = @PKImportXML
    CROSS APPLY @XML.nodes('//FatturaElettronicaBody') AS FatturaElettronicaBody (XML)
    WHERE D.ID = @IDDocumento;

    UPDATE D
    SET D.Numero = @Numero,
        D.[Data] = @Data,

        D.HasDatiBollo = @HasDatiBollo,
        D.ImportoBollo = @ImportoBollo,

        D.TotLordo = @TotLordo,
        D.TotDoc = @TotLordo - COALESCE(@ImportoRitAcc, 0.0),

        D.Inps = @Inps,

		D.SoggettoRitAcc = CASE WHEN COALESCE(@RitAcc, 0.0) = 0.0 THEN 0 ELSE 1 END,
        D.RitAcc = @RitAcc
    
	FROM dbo.Documenti D
    INNER JOIN FXML.ImportXML TXML ON TXML.PKImportXML = @PKImportXML
    CROSS APPLY @XML.nodes('//FatturaElettronicaBody') AS FatturaElettronicaBody (XML)
    WHERE D.ID = @IDDocumento;

    PRINT 'Post update dbo.Documenti';

    EXEC FXML.ssp_ImportaXMLPassivo_Documenti_Righe @PKImportXML = @PKImportXML, @IDDocumento = @IDDocumento;

    EXEC FXML.ssp_ImportaXMLPassivo_Documenti_Scadenze @PKImportXML = @PKImportXML, @IDDocumento = @IDDocumento;

	EXEC FXML.ssp_ImportaXMLPassivo_Documenti_Iva @PKImportXML = @PKImportXML, @IDDocumento = @IDDocumento;	

    UPDATE FXML.ImportXML
    SET IDStatoImportazione = 2, -- 2: importazione terminata correttamente
        IDDocumento = @IDDocumento
    WHERE PKImportXML = @PKImportXML;
    
    COMMIT TRANSACTION

    --SELECT * FROM dbo.Documenti WHERE ID = @IDDocumento;

    --SELECT * FROM dbo.Documenti_Righe WHERE IDDocumento = @IDDocumento ORDER BY SDI_NumeroLinea;

    --SELECT * FROM dbo.Documenti_Scadenze WHERE IDDocumento = @IDDocumento ORDER BY Numero;

END TRY
BEGIN CATCH

    PRINT 'Rollback!';

    ROLLBACK TRANSACTION

    UPDATE FXML.ImportXML
    SET IDStatoImportazione = 99 -- 99: importazione terminata con errori
    WHERE PKImportXML = @PKImportXML;

    SET @IDDocumento = NULL;

END CATCH

-- #071 Richieste di modifica/integrazione - 28/11/2020 - BEGIN
END;
-- #071 Richieste di modifica/integrazione - 28/11/2020 - END

END;
GO

/**
 * @stored_procedure FXML.ssp_ImportaXMLPassivo_SetModalitaPagamento
 * @description

 * @param_input @IDDocumento
*/

CREATE OR ALTER PROCEDURE FXML.ssp_ImportaXMLPassivo_SetModalitaPagamento (
	@IDDocumento UNIQUEIDENTIFIER = NULL
) AS
BEGIN
	--DECLARE @IDDocumento UNIQUEIDENTIFIER = '6B22DBDE-6E35-4755-9AC5-B4407068851F';
	DECLARE @Tmp TABLE (IDDocumento UNIQUEIDENTIFIER NOT NULL, ModalitaPagamento NVARCHAR(100) NOT NULL);

	--Modalità di pagamento per documento
	;WITH DS1 AS (
		SELECT
			DS.IDDocumento,
			DS.IDTipoPagamento,
			COUNT(1) AS NumScadenze
		FROM 
			dbo.Documenti D 
			INNER JOIN dbo.Documenti_Scadenze DS ON DS.IDDocumento = D.ID
		WHERE 
			D.ID = @IDDocumento
			OR
			(@IDDocumento IS NULL
			 AND D.IDTipo LIKE 'For_%'
			 AND D.SDI_Stato = -1
			 AND D.Pag_Modalita IS NULL
			 AND DS.Tipo=1
			 AND COALESCE(DS.IDTipoPagamento, '') <> '')
		GROUP BY DS.IDDocumento, DS.IDTipoPagamento)
	,DS2 AS (
	SELECT 
		t1.IDDocumento,
		SUBSTRING(
			(SELECT  ', ' + st1.IDTipoPagamento + ' (' + CONVERT(VARCHAR(10), st1.NumScadenze) + ')' AS  [text()]
				FROM DS1 st1
				WHERE st1.IDDocumento = t1.IDDocumento
				ORDER BY st1.IDTipoPagamento
				FOR XML PATH ('')
			) 
		, 3, 1000) ModalitaPagamento
	  FROM DS1 t1
	)
	INSERT INTO @Tmp 
		(IDDocumento, ModalitaPagamento)
	SELECT DISTINCT
		DS2.IDDocumento,
		DS2.ModalitaPagamento
	FROM DS2;

	--Aggiungo modalità se non esiste
	MERGE dbo.ModalitaPagamento AS TGT
	USING (SELECT DISTINCT T.ModalitaPagamento FROM @Tmp T) AS SRC
	ON TGT.ID = SRC.ModalitaPagamento
	WHEN NOT MATCHED THEN	
		INSERT (ID, Sospesa) 
		VALUES (SRC.ModalitaPagamento, 1);

	--Aggiorno modalità pagamento su documenti
	UPDATE D
	SET
		Pag_Modalita = T.ModalitaPagamento
	FROM 
		dbo.Documenti D
		INNER JOIN @Tmp T ON T.IDDocumento = D.ID;
END
GO
