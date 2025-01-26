--USE InVoice3;
GO

--/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

--DROP TABLE FXML.TipoDocumentoIngresso;
GO

IF OBJECT_ID('FXML.TipoDocumentoIngresso') IS NULL
BEGIN

    CREATE TABLE FXML.TipiDocumentoIngresso (
        IDTipoDocumento_SDI CHAR(4) NOT NULL CONSTRAINT PK_FXML_TipiDocumentoIngresso PRIMARY KEY CLUSTERED,
        IDTipoDocumento_InVoice NVARCHAR(20) NOT NULL
    );

    INSERT INTO FXML.TipiDocumentoIngresso (
        IDTipoDocumento_SDI,
        IDTipoDocumento_InVoice
    )
    VALUES ('TD01', N'For_Fattura'),
        ('TD02', N'Cli_Fattura'),
        ('TD04', N'For_NotaCredito'),
        ('TD24', N'For_Fattura');

END;
GO

--DROP TABLE FXML.TipoDocumentoUscita;
GO

IF OBJECT_ID('FXML.TipoDocumentoUscita') IS NULL
BEGIN

    CREATE TABLE FXML.TipiDocumentoUscita (
        IDTipoDocumento_InVoice NVARCHAR(20) NOT NULL,
        IDTipoDocumento_SDI CHAR(4) NOT NULL,

        CONSTRAINT PK_FXML_TipiDocumentoUscita PRIMARY KEY CLUSTERED (IDTipoDocumento_InVoice, IDTipoDocumento_SDI)
    );

    INSERT INTO FXML.TipiDocumentoUscita (
        IDTipoDocumento_InVoice,
        IDTipoDocumento_SDI
    )
    VALUES ('Cli_Fattura', N'TD01'),
        ('Cli_Fattura', N'TD24'),
        ('Cli_NotaCredito', N'TD04');

END;
GO
