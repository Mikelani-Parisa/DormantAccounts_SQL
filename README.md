# Dormant Accounts SQL Project

## Overview
This project identifies dormant accounts in the accounting system.  
Accounts that were opened in a specific year but had no transactions in a given period (excluding opening/closing/classification documents) are listed with their total opening value.

## Business Use Case
- Detect inactive accounts for financial cleanup
- Reduce financial risk
- Help management decisions

## Technical Solution
- **Table-Valued Function**: fn_GetDormantAccounts
- **Parameters**:
  - @Year INT – Financial year
  - @OpeningEntry INT – Document for opening entry 
  - @StartDate INT – Start date (YYYYMMDD)
  - @EndDate INT – End date (YYYYMMDD)
  - @ExcludedDocs NVARCHAR(MAX) – CSV of EntryIds to exclude
- Uses CTE, JOIN, and NOT EXISTS for efficiency and readability

## Sample Usage
```sql
SELECT * 
FROM fn_GetDormantAccounts(
    1402,         -- Year
    1,            -- OpeningEntry
    14020101,     -- StartDate
    14040531,     -- EndDate
    '72550,81949,72549,81948,64380,72545,72551,64382,81844,81950' -- ExcludedDocs
);
```

## Sample Output
TotalVal  Account	AccountDsc  	Center  	CenterDsc      	AccountDtl	  AccountDtlDsc	 AccountGrp     AccountGrpDsc	





## Links
- [SQL Function](https://github.com/Mikelani-Parisa/DormantAccounts_SQL/tree/main/fn_GetDormantAccounts/fn_GetDormantAccounts.sql)
- [Sample Output CSV](https://github.com/Mikelani-Parisa/DormantAccounts_SQL/tree/main/SampleOutput/DormantAccounts_Sample.csv)

