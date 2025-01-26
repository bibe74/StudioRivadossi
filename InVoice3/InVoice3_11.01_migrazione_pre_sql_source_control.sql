--USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

-- Verifica integrità referenziale

SELECT
	DR.*
FROM dbo.Documenti_Righe DR
LEFT JOIN dbo.Documenti DO ON DO.ID = DR.IDDocumento_Origine
WHERE DR.IDDocumento_Origine IS NOT NULL
	AND DO.ID IS NULL;

SELECT
	DR.*
FROM dbo.Documenti_Righe DR
LEFT JOIN dbo.Documenti_Righe DRO ON DRO.ID = DR.IDDocumento_RigaOrigine
WHERE DR.IDDocumento_RigaOrigine IS NOT NULL
	AND DRO.ID IS NULL;