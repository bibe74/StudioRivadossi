 USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

/**
 * @table FXML.ImportXML
 * @description Tabella di importazione file XML passivo
*/

IF OBJECT_ID(N'FXML.seq_ImportXML', 'SO') IS NULL
BEGIN

CREATE SEQUENCE FXML.seq_ImportXML
	AS BIGINT
	START WITH 1
	INCREMENT BY 1
	MINVALUE 1
	NO CYCLE
	CACHE 1000;

END;
GO

--DROP TABLE IF EXISTS FXML.ImportXML;
GO

IF OBJECT_ID(N'FXML.ImportXML', N'U') IS NULL
BEGIN

CREATE TABLE FXML.ImportXML (
    PKImportXML BIGINT NOT NULL CONSTRAINT DFT_FXML_ImportXML_PKImportXML DEFAULT (NEXT VALUE FOR FXML.seq_ImportXML),
    DataOraInserimento DATETIME2 NOT NULL CONSTRAINT DFT_FXML_ImportXML_DataOraInserimento DEFAULT (CURRENT_TIMESTAMP),
    IDStatoImportazione TINYINT NOT NULL CONSTRAINT DFT_FXML_ImportXML_IDStatoImportazione DEFAULT (0), -- 0: da importare, 1: importazione in corso, 2: importazione terminata correttamente, 99: importazione terminata con errori
    PKStaging_FatturaElettronicaHeader BIGINT NOT NULL CONSTRAINT DFT_FXML_ImportXML_PKStaging_FatturaElettronicaHeader DEFAULT (-1),

    XMLContent XML NULL,

    CedentePrestatore_DatiAnagrafici_IDFiscaleIVA_IdCodice NVARCHAR(28) NULL,
    DatiGenerali_DatiGeneraliDocumento_TipoDocumento CHAR(4) NULL,
    DatiGenerali_DatiGeneraliDocumento_Data DATE NULL,
    DatiGenerali_DatiGeneraliDocumento_Numero NVARCHAR(20) NULL,

    IDDocumento UNIQUEIDENTIFIER NULL,

    CONSTRAINT PK_FXML_ImportXML PRIMARY KEY CLUSTERED (PKImportXML)
);

END;
GO

/**
 * @table FXML.TrascodificaFornitoreArticolo
 * @description Tabella di trascodifica articoli per fornitore

*/

--DROP TABLE FXML.TrascodificaFornitoreArticolo;
GO

IF OBJECT_ID(N'FXML.TrascodificaFornitoreArticolo', N'U') IS NULL
BEGIN

    SELECT TOP 0
        CF.ID AS IDFornitore,
        CAST(N'' AS NVARCHAR(35)) AS CodiceValore,
        A.ID AS IDArticolo

    INTO FXML.TrascodificaFornitoreArticolo

    FROM dbo.CliFor CF
    CROSS JOIN dbo.Articoli A;

    ALTER TABLE FXML.TrascodificaFornitoreArticolo ALTER COLUMN CodiceValore NVARCHAR(35) NOT NULL;

    ALTER TABLE FXML.TrascodificaFornitoreArticolo ADD CONSTRAINT PK_FXML_TrascodificaFornitoreArticolo PRIMARY KEY CLUSTERED (IDFornitore, CodiceValore);

    ALTER TABLE FXML.TrascodificaFornitoreArticolo ADD CONSTRAINT FK_FML_TrascodificaFornitoreArticolo_IDFornitore FOREIGN KEY (IDFornitore) REFERENCES dbo.CliFor (ID);
    ALTER TABLE FXML.TrascodificaFornitoreArticolo ADD CONSTRAINT FK_FXML_TrascodificaFornitoreArticolo_IDArticolo FOREIGN KEY (IDArticolo) REFERENCES dbo.Articoli (ID);

END;
GO

-- OK fin qui

CREATE OR ALTER PROCEDURE FXML.DEL_usp_ImportaXML (
    @FullPath NVARCHAR(1000),
    @PKImportXML BIGINT OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;

SET @PKImportXML = NEXT VALUE FOR seq_ImportXML;

INSERT INTO FXML.ImportXML
(
    PKImportXML,
    XMLContent
)
SELECT
    @PKImportXML,
    CAST(BulkColumn AS XML) AS XMLContent

--FROM OPENROWSET(BULK 'C:\temp\InVoice\XMLPassivo\IT02703560983_19033.xml', SINGLE_BLOB) AS x;
FROM OPENROWSET(BULK 'C:\temp\InVoice\XMLPassivo\IT01641790702_abI9Q.xml', SINGLE_BLOB) AS x;

END;
GO

--TRUNCATE TABLE FXML.ImportXML;
GO

DECLARE @PKImportXML BIGINT;
EXEC FXML.DEL_usp_ImportaXML @FullPath = N'',                   -- nvarchar(1000)
                               @PKImportXML = @PKImportXML OUTPUT -- bigint

SELECT @PKImportXML;
GO

SELECT * FROM FXML.ImportXML;
GO
