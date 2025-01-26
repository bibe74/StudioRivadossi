--USE InVoice3;
GO

/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

--SELECT * FROM dbo.Documenti_Tipi;
GO

UPDATE dbo.Documenti_Tipi
SET SDI_TipoDocumento = CASE ID
	  WHEN N'Cli_Fattura' THEN 'TD01'
	  WHEN N'Cli_Fatt_RA' THEN 'TD01'
	  WHEN N'Cli_fatturaElettr' THEN 'TD01'
	  WHEN N'Cli_NotaCredito' THEN N'TD04'
	  ELSE N''
	END,
	SDI_IsValido = CASE ID
	  WHEN N'Cli_Fattura' THEN 1
	  WHEN N'Cli_fatturaElettr' THEN 1
	  WHEN N'Cli_Fatt_RA' THEN 1
	  WHEN N'Cli_NotaCredito' THEN 1
	ELSE 0
	END

WHERE ID IN (
	N'Cli_Fattura',
	N'Cli_fatturaElettr',
	N'Cli_Fatt_RA',
	N'Cli_NotaCredito'
);
GO

--SELECT * FROM dbo.CodiciIva;
GO

UPDATE dbo.CodiciIva SET SDI_EsigibilitaIVA = 'I' WHERE Perc > 0.0;
GO

-- Compilare SDI_Natura e SDI_RiferimentoNormativo per le aliquote a zero

--SELECT * FROM dbo.CodiciIva WHERE COALESCE(Perc, 0.0) = 0.0;
GO

BEGIN TRANSACTION

UPDATE dbo.CodiciIva
SET SDI_RiferimentoNormativo = Descrizione
WHERE COALESCE(Perc, 0.0) = 0.0;

ROLLBACK TRANSACTION 

SELECT 
	CIva.ID,
	CIva.Descrizione,
	COUNT(1) AS NumeroRighe,
	MIN(D.Data) AS DataPrimoDocumento,
	MAX(D.Data) AS DataUltimoDocumento

FROM dbo.Documenti_Righe DR
INNER JOIN dbo.CodiciIva CIva ON CIva.ID = DR.CodIva
	AND COALESCE(CIva.Perc, 0.0) = 0.0
INNER JOIN dbo.Documenti D ON D.ID = DR.IDDocumento
GROUP BY CIva.ID, CIva.Descrizione
ORDER BY CIva.ID;
GO

--SELECT * FROM dbo.ModalitaPagamento_Tipi;
GO

UPDATE dbo.ModalitaPagamento_Tipi
SET
	SDI_ModalitaPagamento = CASE ID
	  WHEN N'ASS' THEN 'MP02'
	  WHEN N'BAN' THEN 'MP08'
	  WHEN N'BB' THEN 'MP05'
	  WHEN N'C/A' THEN 'MP01'
	  WHEN N'CC' THEN 'MP08'
	  WHEN N'CON' THEN 'MP01'
	  WHEN N'FIN' THEN 'MP01'
	  WHEN N'MAV' THEN 'MP13'
	  WHEN N'RB' THEN 'MP12'
	  WHEN N'RD' THEN 'MP01'
	  WHEN N'RID' THEN 'MP09'
	END,
	SDI_HasDataScadenza = CASE ID
	  WHEN N'ASS' THEN 0
	  WHEN N'BAN' THEN 0
	  WHEN N'BB' THEN 1
	  WHEN N'C/A' THEN 0
	  WHEN N'CC' THEN 0
	  WHEN N'CON' THEN 0
	  WHEN N'FIN' THEN 1
	  WHEN N'MAV' THEN 1
	  WHEN N'RB' THEN 1
	  WHEN N'RD' THEN 0
	  WHEN N'RID' THEN 1
	END,
	SDI_HasDatiIstitutoFinanziario = CASE ID
	  WHEN N'ASS' THEN 0
	  WHEN N'BAN' THEN 1
	  WHEN N'BB' THEN 1
	  WHEN N'C/A' THEN 0
	  WHEN N'CC' THEN 1
	  WHEN N'CON' THEN 0
	  WHEN N'FIN' THEN 0
	  WHEN N'MAV' THEN 1
	  WHEN N'RB' THEN 1
	  WHEN N'RD' THEN 0
	  WHEN N'RID' THEN 1
	END;
GO

--SELECT * FROM dbo.Nazioni;
GO

UPDATE dbo.Nazioni SET SDI_IDNazione = 'IT', SDI_Esportazione = CAST(1 AS BIT) WHERE ID = N'ITALIA';
GO

--UPDATE dbo.Conf_Parametri SET Valore = N'via Roma 1' WHERE ID = N'Company.Indirizzo';
--UPDATE dbo.Conf_Parametri SET Valore = N'03666770981' WHERE ID = N'Company.PI';
--UPDATE dbo.Conf_Parametri SET Valore = N'03666770981' WHERE ID = N'Company.CF';
GO

--SELECT * FROM dbo.Conf_Parametri WHERE ID LIKE N'Company.%' ORDER BY ID;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.Nazione')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.Nazione', -- ID - nvarchar(100)
		N'ITALIA', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.SDI_RegimeFiscale')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.SDI_RegimeFiscale', -- ID - nvarchar(100)
		N'RF01', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.SDI_TipoRitenuta')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.SDI_TipoRitenuta', -- ID - nvarchar(100)
		N'RT01', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.SDI_CausalePagamentoRitenuta')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.SDI_CausalePagamentoRitenuta', -- ID - nvarchar(100)
		N'A', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.SDI_TipoCassa')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.SDI_TipoCassa', -- ID - nvarchar(100)
		N'TC22', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.CodiceIvaCassa')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.CodiceIvaCassa', -- ID - nvarchar(100)
		N'22', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.RitenutaCassa')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.RitenutaCassa', -- ID - nvarchar(100)
		N'SI', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

IF NOT EXISTS(SELECT Valore FROM dbo.Conf_Parametri WHERE ID = N'Company.SDI_DataInizioFatturazioneElettronica')
BEGIN

	INSERT INTO dbo.Conf_Parametri
	(
		ID,
		Valore,
		Immagine
	)
	VALUES
	(   N'Company.SDI_DataInizioFatturazioneElettronica', -- ID - nvarchar(100)
		N'01/01/2019', -- Valore - nvarchar(255)
		NULL -- Immagine - image
	);

END;
GO

BEGIN TRANSACTION 

;WITH RigheDaTrasmettere
AS (
	SELECT
		DR.ID,
		ROW_NUMBER() OVER (PARTITION BY D.ID ORDER BY DR.Posizione) AS SDI_NumeroLinea

	FROM dbo.Documenti D
	INNER JOIN dbo.Documenti_Tipi DT ON DT.ID = D.IDTipo
		AND DT.SDI_IsValido = CAST(1 AS BIT)
	INNER JOIN dbo.Documenti_Righe DR ON DR.IDDocumento = D.ID
	WHERE COALESCE(DR.Qta, 0.0) <> 0.0
		AND COALESCE(DR.ImpUnitario, 0.0) <> 0.0
)
UPDATE DR
SET DR.SDI_NumeroLinea = COALESCE(RDT.SDI_NumeroLinea, NULL)

FROM dbo.Documenti_Righe DR
LEFT JOIN RigheDaTrasmettere RDT ON RDT.ID = DR.ID;

ROLLBACK TRANSACTION 
GO

/* TODO

dbo.CodiciIva
	compilare SDI_Natura per le aliquote a 0.00

dbo.Conf_Parametri
	+Company.Nazione > DatiTrasmissione_IdTrasmittente_IdPaese, CedentePrestatore_Sede_Nazione
	+Company.SDI_Codice > 
	+Company.SDI_Denominazione (in alternativa, SDI_Nome e SDI_Cognome) > CedentePrestatore_DatiAnagrafici_Anagrafica_{Denominazione/Nome/Cognome)
    +Company.SDI_RegimeFiscale > CedentePrestatore_DatiAnagrafici_RegimeFiscale

*/

ALTER TABLE dbo.CliFor ADD SDI_CodiceDestinatarioCliente NVARCHAR(7) NULL;
ALTER TABLE dbo.CliFor ADD SDI_PECDestinatarioCliente NVARCHAR(256) NULL;
GO

UPDATE dbo.CliFor
SET SDI_CodiceDestinatarioCliente = N'123TEST',
	SDI_PECDestinatarioCliente = NULL,
	Nazione = N'ITALIA'

WHERE ID = '7824C0E7-1620-49BB-BADD-B03FF2D0EB3E';
GO

