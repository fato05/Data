DECLARE	@XTD				INT				=	0
DECLARE	@REPORTMONTH		INT				=	5
DECLARE	@REPORTYEAR			INT				=	2025
DECLARE	@FROMDATE			DATE			=	DATEFROMPARTS(@REPORTYEAR, CASE @XTD WHEN 0 THEN 1 ELSE @REPORTMONTH END, 1)
DECLARE	@TODATE				DATE			=	EOMONTH(DATEFROMPARTS(@REPORTYEAR, @REPORTMONTH, 1))

SELECT
		DATAAREAID							=	LGL.DATAAREA
	,	ACCOUNTID							=	ACC.MAINACCOUNTID
	,	ACCOUNTNAME							=	ACC.NAME
	,	OPENINGAMOUNT						=	SUM(CASE FCP.[TYPE] WHEN 0 THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END) + SUM(CASE WHEN FCP.[TYPE] = 1 AND GLE.ACCOUNTINGDATE < @FROMDATE THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END)
	,	DEBITAMOUNT							=	SUM(CASE WHEN FCP.[TYPE] = 1 AND GLE.ACCOUNTINGDATE BETWEEN @FROMDATE AND @TODATE AND GLX.ISCREDIT = 0 THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END)
	,	CREIDTAMOUNT						=	SUM(CASE WHEN FCP.[TYPE] = 1 AND GLE.ACCOUNTINGDATE BETWEEN @FROMDATE AND @TODATE AND GLX.ISCREDIT = 1 THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END)
	,	CLOSINGAMOUNT						=	SUM(GLX.ACCOUNTINGCURRENCYAMOUNT)
FROM
		GENERALJOURNALACCOUNTENTRY GLX
INNER JOIN
		GENERALJOURNALENTRY GLE
	ON	GLE.RECID = GLX.GENERALJOURNALENTRY
INNER JOIN
		FISCALCALENDARPERIOD FCP
	ON	FCP.[PARTITION] = GLE.[PARTITION]
	AND	FCP.RECID = GLE.FISCALCALENDARPERIOD
INNER JOIN
		LEDGER GLT
	ON	GLT.RECID = GLE.LEDGER
INNER JOIN
		DIRPARTYTABLE LGL
	ON	LGL.[PARTITION] = GLT.[PARTITION]
	AND	LGL.RECID = GLT.PRIMARYFORLEGALENTITY
INNER JOIN
		MAINACCOUNT ACC
	ON	ACC.[PARTITION] = GLX.[PARTITION]
	AND	ACC.RECID = GLX.MAINACCOUNT
WHERE
		1 = 1
	AND	LGL.DATAAREA IN ('16', '47', '15', '70', '71', '73', '72', '05ae', '01ae', '51', '06n', '03', '02', '23', '26', '21', '29t', '12')
	AND	GLE.ACCOUNTINGDATE BETWEEN DATEFROMPARTS(@REPORTYEAR, 1, 1) AND @TODATE
--	AND	ACC.MAINACCOUNTID = '110701001'
GROUP BY
		LGL.DATAAREA
	,	ACC.MAINACCOUNTID
	,	ACC.NAME
HAVING
		SUM(CASE FCP.[TYPE] WHEN 0 THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END) + SUM(CASE WHEN FCP.[TYPE] = 1 AND GLE.ACCOUNTINGDATE < @FROMDATE THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END) <> 0
	OR	SUM(CASE WHEN FCP.[TYPE] = 1 AND GLE.ACCOUNTINGDATE BETWEEN @FROMDATE AND @TODATE AND GLX.ISCREDIT = 0 THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END) <> 0
	OR	SUM(CASE WHEN FCP.[TYPE] = 1 AND GLE.ACCOUNTINGDATE BETWEEN @FROMDATE AND @TODATE AND GLX.ISCREDIT = 1 THEN GLX.ACCOUNTINGCURRENCYAMOUNT ELSE 0 END) <> 0
	OR	SUM(GLX.ACCOUNTINGCURRENCYAMOUNT) <> 0
ORDER BY
		LGL.DATAAREA
	,	ACC.MAINACCOUNTID