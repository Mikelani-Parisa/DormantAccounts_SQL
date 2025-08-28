/*
Function: fn_GetDormantAccounts
Purpose: Identify dormant accounts in the accounting system
Parameters:
  @OpeningEntry	 INT -The document code for opening entry
  @Year INT - Financial year opening entry
  @StartDate INT - Start date of the period (YYYYMMDD)
  @EndDate INT - End date of the period (YYYYMMDD)
  @ExcludedDocs NVARCHAR(MAX) - CSV list of EntryIds to exclude
Output: List of accounts with no transactions in the period, including:
  - Account
  - Account Description
  - Center
  - Center Description
  - AccountDtl
  - AccountDtl Description
  - AccountGrp
  - AccountGrp Description
  - Total Value
*/

CREATE FUNCTION fn_GetDormantAccounts
(
    @OpeningEntry INT,
    @Year INT,
    @StartDate INT,
    @EndDate INT,
    @ExcludedDocs NVARCHAR(MAX)
)
RETURNS TABLE
AS
RETURN
(
    WITH OpeningAccounts AS (
        SELECT 
            dtl.Account,
            dtl.Val,
            dtl.Center1,
            acc.AccountDsc,
            cent.CenterDsc,
            dtl.AccountDtl,
            acc_d.AccountDsc AS AccountDtlDsc,
            dtl.AccountGrp,
            acc_g.AccountDsc AS AccountGrpDsc
        FROM AcntAccDtl dtl
        JOIN Account acc   ON acc.Account = dtl.Account
        JOIN Account acc_d ON acc_d.Account = dtl.AccountDtl
        JOIN Account acc_g ON acc_g.Account = dtl.AccountGrp
        LEFT JOIN Center cent ON cent.Center = dtl.Center1
        WHERE dtl.Doc = @OpeningEntry
          AND dtl.Yr  = @Year
    )
    SELECT 
        o.Account,
        o.AccountDsc,
        o.Center1 AS Center,
        o.CenterDsc,
        o.AccountDtl,
        o.AccountDtlDsc,
        o.AccountGrp,
        o.AccountGrpDsc,
        SUM(dtl.Val) AS TotalVal
    FROM OpeningAccounts o
    JOIN AcntAccDtl dtl ON dtl.Account = o.Account
    JOIN AcntAccHdr hdr ON hdr.EntryId = dtl.EntryId
    WHERE NOT EXISTS (
        SELECT 1
        FROM AcntAccDtl dttl
        JOIN AcntAccHdr hdr2 ON hdr2.EntryId = dttl.EntryId
        WHERE dttl.Account  = o.Account
          AND dttl.Center1  = o.Center1
          AND hdr2.HdrDate BETWEEN @StartDate AND @EndDate
          AND hdr2.Doc <> @OpeningEntry
          AND hdr2.EntryId NOT IN (
              SELECT value FROM STRING_SPLIT(@ExcludedDocs, ',')
          )
    )
    GROUP BY 
        o.Account, o.AccountDsc, o.Center1, o.CenterDsc,
        o.AccountDtl, o.AccountDtlDsc, o.AccountGrp, o.AccountGrpDsc
);