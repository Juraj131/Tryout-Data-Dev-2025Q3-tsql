-- File: 02_Create_Views.sql
-- This script creates all the necessary building-block views.

USE HiringTryout_TSQL;
GO

-- Drop views in reverse order of dependency to avoid errors
IF OBJECT_ID('vw_FinalReport', 'V') IS NOT NULL DROP VIEW vw_FinalReport;
IF OBJECT_ID('vw_MonthlyBalances', 'V') IS NOT NULL DROP VIEW vw_MonthlyBalances;
IF OBJECT_ID('vw_SumTransactionsYTD', 'V') IS NOT NULL DROP VIEW vw_SumTransactionsYTD;
IF OBJECT_ID('vw_OpeningBalance2025', 'V') IS NOT NULL DROP VIEW vw_OpeningBalance2025;
IF OBJECT_ID('vw_EntriesWithEffectiveDate', 'V') IS NOT NULL DROP VIEW vw_EntriesWithEffectiveDate;
GO

-- VIEW 1: EntriesWithEffectiveDate
CREATE VIEW vw_EntriesWithEffectiveDate AS
SELECT
    *,
    CASE
        WHEN [Text] = 'openingbalance' THEN CAST('2024-12-31' AS date)
        ELSE [Date]
    END AS EffectiveDate
FROM
    dbo.AccountEntries;
GO

-- VIEW 2: OpeningBalance2025
CREATE VIEW vw_OpeningBalance2025 AS
SELECT
    Account,
    SUM(Amount) AS OpeningBalance2025
FROM
    vw_EntriesWithEffectiveDate
WHERE
    YEAR(EffectiveDate) < 2025
GROUP BY
    Account;
GO

-- VIEW 3: SumTransactionsYTD
CREATE VIEW vw_SumTransactionsYTD AS
SELECT
    Account,
    SUM(Amount) AS SumTransactionsYTD
FROM
    vw_EntriesWithEffectiveDate
WHERE
    YEAR(EffectiveDate) = 2025
GROUP BY
    Account;
GO

-- VIEW 4: MonthlyBalances
CREATE VIEW vw_MonthlyBalances AS
WITH RunningTotals AS (
    SELECT
        Account,
        MONTH(EffectiveDate) AS MonthNumber,
        SUM(SUM(Amount)) OVER (PARTITION BY Account ORDER BY MONTH(EffectiveDate)) AS RunningTotal2025
    FROM
        vw_EntriesWithEffectiveDate
    WHERE
        YEAR(EffectiveDate) = 2025
    GROUP BY
        Account, MONTH(EffectiveDate)
)
SELECT
    Account,
    [1] AS RunningTotal_Jan, [2] AS RunningTotal_Feb, [3] AS RunningTotal_Mar, [4] AS RunningTotal_Apr,
    [5] AS RunningTotal_May, [6] AS RunningTotal_Jun, [7] AS RunningTotal_Jul, [8] AS RunningTotal_Aug,
    [9] AS RunningTotal_Sep, [10] AS RunningTotal_Oct, [11] AS RunningTotal_Nov, [12] AS RunningTotal_Dec
FROM
    RunningTotals
PIVOT (
    MAX(RunningTotal2025)
    FOR MonthNumber IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS PivotedData;
GO