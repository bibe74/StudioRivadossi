USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

ALTER TABLE dbo.Documenti_Tipi ADD SDI_TipoDocumentoPassivo CHAR(4) NULL;
GO

UPDATE dbo.Documenti_Tipi SET SDI_TipoDocumentoPassivo = 'TD01' WHERE ID = N'For_Fattura';
UPDATE dbo.Documenti_Tipi SET SDI_TipoDocumentoPassivo = 'TD04' WHERE ID = N'For_NotaCredito';
GO

