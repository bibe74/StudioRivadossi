--USE InVoice3;
GO

--/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;
GO

CREATE OR ALTER VIEW FXML.DatabaseSchemaView
AS
WITH SchemaTableColumn
AS (
	SELECT
		N'dbo' AS schema_name,
		N'Documenti_Tipi' AS table_name,
		N'SDI_TipoDocumento' AS column_name

	UNION ALL SELECT N'dbo', N'Documenti_Tipi', N'SDI_IsValido'

	UNION ALL SELECT N'dbo', N'CodiciIva', N'SDI_Natura'
	UNION ALL SELECT N'dbo', N'CodiciIva', N'SDI_RiferimentoNormativo'
	UNION ALL SELECT N'dbo', N'CodiciIva', N'SDI_EsigibilitaIVA'
	UNION ALL SELECT N'dbo', N'ModalitaPagamento_Tipi', N'SDI_ModalitaPagamento'
	UNION ALL SELECT N'dbo', N'ModalitaPagamento_Tipi', N'SDI_HasDataScadenza'
	UNION ALL SELECT N'dbo', N'ModalitaPagamento_Tipi', N'SDI_HasDatiIstitutoFinanziario'
	UNION ALL SELECT N'dbo', N'CliFor', N'SDI_CodiceDestinatarioCliente'
	UNION ALL SELECT N'dbo', N'CliFor', N'SDI_PECDestinatarioCliente'
	UNION ALL SELECT N'dbo', N'Nazioni', N'SDI_IDNazione'
	UNION ALL SELECT N'dbo', N'Documenti_Righe', N'SDI_NumeroLinea'
)
SELECT
	STC.schema_name,
    STC.table_name,
    STC.column_name,

	REPLACE(REPLACE(N'Tabella %FULL_TABLE_NAME%: campo %COLUMN_NAME% mancante', N'%FULL_TABLE_NAME%', STC.schema_name + N'.' + STC.table_name), N'%COLUMN_NAME%', STC.column_name) AS Note

FROM SchemaTableColumn STC
LEFT JOIN sys.columns C ON C.name = STC.column_name
LEFT JOIN sys.tables T ON T.object_id = C.object_id AND T.name = STC.table_name
LEFT JOIN sys.schemas S ON S.schema_id = T.schema_id AND C.name = STC.column_name
WHERE C.object_id IS NULL;
GO

SELECT * FROM FXML.DatabaseSchemaView ORDER BY schema_name, table_name, column_name;
GO

CREATE OR ALTER VIEW FXML.Conf_ParametriView
AS
WITH SDIParameters
AS (
	SELECT
		N'Company.SDI_DataInizioFatturazioneElettronica' AS parameter,
		CAST(0 AS BIT) AS is_mandatory

	UNION ALL SELECT N'Company.Cap', 1
	UNION ALL SELECT N'Company.CF', 0
	UNION ALL SELECT N'Company.CodiceIvaCassa', 0
	UNION ALL SELECT N'Company.Comune', 1
	UNION ALL SELECT N'Company.Indirizzo', 1
	UNION ALL SELECT N'Company.Name', 1
	UNION ALL SELECT N'Company.Nazione', 1
	UNION ALL SELECT N'Company.PI', 0
	UNION ALL SELECT N'Company.Provincia', 1
	UNION ALL SELECT N'Company.RitenutaCassa', 0
	UNION ALL SELECT N'Company.SDI_CausalePagamentoRitenuta', 0
	UNION ALL SELECT N'Company.SDI_RegimeFiscale', 1
	UNION ALL SELECT N'Company.SDI_TipoCassa', 0
	UNION ALL SELECT N'Company.SDI_TipoRitenuta', 0
	UNION ALL SELECT N'Documents.Inps', 0
	UNION ALL SELECT N'Documents.RitAcc', 0
)
SELECT
	SDIP.parameter AS Parametro,
    CASE WHEN SDIP.is_mandatory = CAST(1 AS BIT) THEN N'Sì' ELSE N'No' END AS Obbligatorio

FROM SDIParameters SDIP
LEFT JOIN dbo.Conf_Parametri CP ON CP.ID = SDIP.parameter
WHERE CP.ID IS NULL;
GO

SELECT * FROM FXML.Conf_ParametriView ORDER BY Parametro;
GO

CREATE OR ALTER VIEW FXML.DatabaseSchemaValueView
AS
SELECT
	N'dbo' AS schema_name,
	N'Documenti_Tipi' AS table_name,
	N'SDI_TipoDocumento' AS column_name,
	DT.SDI_TipoDocumento AS value,
	N'' AS Note

FROM dbo.Documenti_Tipi DT
LEFT JOIN InVoiceXML.XMLCodifiche.TipoDocumento XMLTD ON XMLTD.IDTipoDocumento = DT.SDI_TipoDocumento COLLATE DATABASE_DEFAULT
WHERE COALESCE(DT.SDI_TipoDocumento, '') <> ''
	AND XMLTD.IDTipoDocumento IS NULL
	
UNION ALL

SELECT N'dbo', N'CodiciIva', N'SDI_Natura', CI.SDI_Natura, N''
FROM dbo.CodiciIva CI
LEFT JOIN InVoiceXML.XMLCodifiche.Natura XMLN ON XMLN.IDNatura = CI.SDI_Natura COLLATE DATABASE_DEFAULT
WHERE COALESCE(CI.SDI_Natura, '') <> ''
	AND XMLN.IDNatura IS NULL
	
UNION ALL

SELECT N'dbo', N'CodiciIva', N'SDI_EsigibilitaIVA', CI.SDI_EsigibilitaIVA, N''
FROM dbo.CodiciIva CI
LEFT JOIN InVoiceXML.XMLCodifiche.EsigibilitaIVA XMLEI ON XMLEI.IDEsigibilitaIVA = CI.SDI_EsigibilitaIVA COLLATE DATABASE_DEFAULT
WHERE COALESCE(CI.SDI_EsigibilitaIVA, '') <> ''
	AND XMLEI.IDEsigibilitaIVA IS NULL
	
UNION ALL

SELECT N'dbo', N'CodiciIva', N'SDI_Natura', CI.ID, N'Natura non compilata a fronte di IVA a zero'
FROM dbo.CodiciIva CI
WHERE COALESCE(CI.Perc, 0.0) = 0.0
	AND COALESCE(CI.SDI_Natura, '') = ''

UNION ALL

SELECT N'dbo', N'CodiciIva', N'SDI_Natura', CI.ID, N'Riferimento normativo non compilato a fronte di IVA a zero'
FROM dbo.CodiciIva CI
WHERE COALESCE(CI.Perc, 0.0) = 0.0
	AND COALESCE(CI.SDI_RiferimentoNormativo, N'') = N''

UNION ALL

SELECT N'dbo', N'CodiciIva', N'SDI_ModalitaPagamento', MPT.SDI_ModalitaPagamento, N''
FROM dbo.ModalitaPagamento_Tipi MPT
LEFT JOIN InVoiceXML.XMLCodifiche.ModalitaPagamento XMLMP ON XMLMP.IDModalitaPagamento = MPT.SDI_ModalitaPagamento COLLATE DATABASE_DEFAULT
WHERE COALESCE(MPT.SDI_ModalitaPagamento, '') <> ''
	AND XMLMP.IDModalitaPagamento IS NULL

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'Valore', CP.Valore, N''
FROM dbo.Conf_Parametri CP
LEFT JOIN dbo.Nazioni N ON N.ID = CP.Valore
LEFT JOIN InVoiceXML.XMLCodifiche.Nazione XMLCN ON XMLCN.IDNazione = N.SDI_IDNazione COLLATE DATABASE_DEFAULT
WHERE CP.ID = N'Company.Nazione'
	AND XMLCN.IDNazione IS NULL

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'Valore', CP.Valore, N''
FROM dbo.Conf_Parametri CP
LEFT JOIN InVoiceXML.XMLCodifiche.RegimeFiscale XMLRF ON XMLRF.IDRegimeFiscale = CP.Valore COLLATE DATABASE_DEFAULT
WHERE CP.ID = N'Company.SDI_RegimeFiscale'
	AND XMLRF.IDRegimeFiscale IS NULL

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'Valore', CP.Valore, N''
FROM dbo.Conf_Parametri CP
LEFT JOIN InVoiceXML.XMLCodifiche.TipoRitenuta XMLTR ON XMLTR.IDTipoRitenuta = CP.Valore COLLATE DATABASE_DEFAULT
WHERE CP.ID = N'Company.SDI_TipoRitenuta'
	AND XMLTR.IDTipoRitenuta IS NULL

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'Valore', CP.Valore, N''
FROM dbo.Conf_Parametri CP
LEFT JOIN InVoiceXML.XMLCodifiche.CausalePagamento XMLCP ON XMLCP.IDCausalePagamento = CP.Valore COLLATE DATABASE_DEFAULT
WHERE CP.ID = N'Company.SDI_CausalePagamentoRitenuta'
	AND XMLCP.IDCausalePagamento IS NULL

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'Valore', CP.Valore, N''
FROM dbo.Conf_Parametri CP
LEFT JOIN InVoiceXML.XMLCodifiche.TipoCassa XMLTC ON XMLTC.IDTipoCassa = CP.Valore COLLATE DATABASE_DEFAULT
WHERE CP.ID = N'Company.SDI_TipoCassa'
	AND XMLTC.IDTipoCassa IS NULL

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'Valore', CP.Valore, N'Valore non numerico'
FROM dbo.Conf_Parametri CP
WHERE CP.ID = N'Company.SDI_CodiceIvaCassa'
	AND ISNUMERIC(COALESCE(CP.Valore, N'AAA')) = 0

UNION ALL

SELECT N'dbo', N'Conf_Parametri', N'', N'', N'Codice Fiscale e Partita IVA mancanti'
WHERE NOT EXISTS (
	SELECT CP.Valore
	FROM dbo.Conf_Parametri CP
	WHERE CP.ID IN (N'Company.PI', N'Company.CF')
		AND COALESCE(CP.Valore, N'') <> N''
);
GO

SELECT * FROM FXML.DatabaseSchemaValueView
ORDER BY schema_name, table_name, column_name;
GO
