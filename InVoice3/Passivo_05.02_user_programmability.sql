--USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

/**
 * @stored_procedure FXML.usp_ImportaXMLPassivo
 * @description

 * @param_input @PKImportXML

 * @param_output @IDDocumento
*/

IF OBJECT_ID('FXML.usp_ImportaXMLPassivo', N'P') IS NULL EXEC('CREATE PROCEDURE FXML.usp_ImportaXMLPassivo AS RETURN 0;');
GO

ALTER PROCEDURE FXML.usp_ImportaXMLPassivo (
    @PKImportXML BIGINT,
    @IDDocumento UNIQUEIDENTIFIER OUTPUT
)
AS
BEGIN

SET NOCOUNT ON;

EXEC FXML.ssp_ImportaXMLPassivo_Documenti @PKImportXML = @PKImportXML,
                                          @IDDocumento = @IDDocumento OUTPUT;

EXEC FXML.ssp_ImportaXMLPassivo_SetModalitaPagamento @IDDocumento = @IDDocumento;

END;
GO

-- OK fin qui

SELECT * FROM FXML.ImportXML

DECLARE @PKImportXML BIGINT = 284;
DECLARE @IDDocumento UNIQUEIDENTIFIER;

EXEC FXML.usp_ImportaXMLPassivo @PKImportXML = @PKImportXML,
                                @IDDocumento = @IDDocumento OUTPUT;

SELECT * FROM dbo.Documenti_Scadenze WHERE IDDocumento = @IDDocumento;

SELECT REPLACE(REPLACE(N'PKImportXML %PKImportXML% > IDDocumento %IDDocumento%', N'%PKImportXML%', CONVERT(NVARCHAR(20), @PKImportXML)), N'%IDDocumento%', @IDDocumento) AS LogMessage;
GO
