CREATE OR ALTER PROCEDURE XMLFatture.usp_ProcessaXML (
    @PKImportXML BIGINT
)
AS
BEGIN

SET NOCOUNT ON;

DECLARE @XML XML;

SELECT TOP 1 @XML = XMLContent
FROM XMLFatture.ImportXML
WHERE PKImportXML = @PKImportXML;

/*
SELECT
    xmlData.Col.value('.', 'CHAR(2)') AS IdPaese 
    
FROM @XML.nodes('//FatturaElettronicaHeader/DatiTrasmissione/IdTrasmittente/IdPaese') xmlData(Col);
*/

--SELECT TOP 1 * FROM XMLFatture.Staging_FatturaElettronicaHeader;

DECLARE @PKStaging_FatturaElettronicaHeader BIGINT;

--SET @PKStaging_FatturaElettronicaHeader = NEXT VALUE FOR XMLFatture.seq_FatturaElettronicaHeader;

SELECT
    --@PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader,
    CAST(-1 AS BIGINT) AS PKLanding_Fattura,
    FatturaElettronicaHeader.XML.query('DatiTrasmissione/IdTrasmittente/IdPaese').value('.', 'CHAR(2)') AS DatiTrasmissione_IdTrasmittente_IdPaese,
    FatturaElettronicaHeader.XML.query('DatiTrasmissione/IdTrasmittente/IdCodice').value('.', 'NVARCHAR(28)') AS DatiTrasmissione_IdTrasmittente_IdCodice,
    FatturaElettronicaHeader.XML.query('DatiTrasmissione/ProgressivoInvio').value('.', N'NVARCHAR(10)') AS DatiTrasmissione_ProgressivoInvio

FROM XMLFatture.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaHeader') AS FatturaElettronicaHeader (XML)
WHERE IXML.PKImportXML = @PKImportXML;

SELECT
    --@PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/TipoDocumento').value('.', 'CHAR(4)') AS DatiGenerali_DatiGeneraliDocumento_TipoDocumento,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Divisa').value('.', 'CHAR(3)') AS DatiGenerali_DatiGeneraliDocumento_Divisa,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Data').value('.', N'DATE') AS DatiGenerali_DatiGeneraliDocumento_Data,
    FatturaElettronicaBody.XML.query('DatiGenerali/DatiGeneraliDocumento/Numero').value('.', N'NVARCHAR(20)') AS DatiGenerali_DatiGeneraliDocumento_Numero

FROM XMLFatture.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody') AS FatturaElettronicaBody (XML)
WHERE IXML.PKImportXML = @PKImportXML;

SELECT
    --@PKStaging_FatturaElettronicaHeader AS PKStaging_FatturaElettronicaHeader,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('NumeroLinea').value('.', 'INT') AS NumeroLinea,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceTipo').value('.', 'NVARCHAR(35)') AS CodiceArticolo_CodiceTipo,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('CodiceArticolo/CodiceValore').value('.', 'NVARCHAR(35)') AS CodiceArticolo_CodiceValore,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Descrizione').value('.', 'NVARCHAR(1000)') AS Descrizione,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('Quantita').value('.', N'DECIMAL(20, 5)') AS Quantita,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('UnitaMisura').value('.', N'NVARCHAR(10)') AS UnitaMisura,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoUnitario').value('.', N'DECIMAL(20, 5)') AS PrezzoUnitario,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('PrezzoTotale').value('.', N'DECIMAL(20, 5)') AS PrezzoTotale,
    FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee.XML.query('AliquotaIVA').value('.', N'DECIMAL(5, 2)') AS AliquotaIVA

FROM XMLFatture.ImportXML IXML
CROSS APPLY @XML.nodes('//FatturaElettronicaBody/DatiBeniServizi/DettaglioLinee') AS FatturaElettronicaBody_DatiBeniServizi_DettaglioLinee (XML)
WHERE IXML.PKImportXML = @PKImportXML;

END;
GO

DECLARE @PKImportXML BIGINT = 2;

EXEC XMLFatture.usp_ProcessaXML @PKImportXML = @PKImportXML; -- bigint
GO
