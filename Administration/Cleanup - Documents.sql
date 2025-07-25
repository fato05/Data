DECLARE	@YEAR		INT		=	2016
DECLARE	@FROMDATE	DATE	=	DATEFROMPARTS(@YEAR,		1, 1)
DECLARE	@BEFOREDATE	DATE	=	DATEFROMPARTS(@YEAR + 1,	1, 1)
DECLARE	@LIMITDATE	DATE	=	DATEFROMPARTS(2024,			1, 1)

DELETE
		JOB
FROM
		DOCUVALUE DOC
INNER JOIN
		DOCUREF REF
	ON	REF.VALUERECID = DOC.RECID
INNER JOIN
		PRINTJOBHEADER JOB
	ON	JOB.RECID = REF.REFRECID
WHERE
		1 = 1
	AND	REF.REFTABLEID = 65525
	AND	DOC.CREATEDDATETIME >= @FROMDATE
	AND	DOC.CREATEDDATETIME <  @BEFOREDATE
	AND	DOC.CREATEDDATETIME <  @LIMITDATE

---------------------------------------------------------------------

DELETE
		REF
FROM
		DOCUVALUE DOC
INNER JOIN
		DOCUREF REF
	ON	REF.VALUERECID = DOC.RECID
WHERE
		1 = 1
	AND	REF.REFTABLEID = 65525
	AND	DOC.CREATEDDATETIME >= @FROMDATE
	AND	DOC.CREATEDDATETIME <  @BEFOREDATE
	AND	DOC.CREATEDDATETIME <  @LIMITDATE

---------------------------------------------------------------------

DELETE
		DOC
FROM
		DOCUVALUE DOC
LEFT JOIN
		DOCUREF REF
	ON	REF.VALUERECID = DOC.RECID
WHERE
		1 = 1
	AND	REF.REFTABLEID IS NULL
	AND	DOC.CREATEDDATETIME >= @FROMDATE
	AND	DOC.CREATEDDATETIME <  @BEFOREDATE
	AND	DOC.CREATEDDATETIME <  @LIMITDATE
GO

---------------------------------------------------------------------

--SELECT
--		PARTITION		=	CASE WHEN YEAR(DOC.CREATEDDATETIME) < 2024 THEN 'CLEANUP' ELSE 'KEEP' END
--	,	SUM(DATALENGTH(DOC.FILE_)) / 1024 / 1024
--FROM
--		DOCUVALUE DOC
--INNER JOIN
--		DOCUREF REF
--	ON	REF.VALUERECID = DOC.RECID
--INNER JOIN
--		PRINTJOBHEADER JOB
--	ON	JOB.RECID = REF.REFRECID
--WHERE
--		1 = 1
--	AND	REF.REFTABLEID = 65525
--GROUP BY
--		CASE WHEN YEAR(DOC.CREATEDDATETIME) < 2024 THEN 'CLEANUP' ELSE 'KEEP' END
--ORDER BY
--		SUM(DATALENGTH(DOC.FILE_)) DESC


