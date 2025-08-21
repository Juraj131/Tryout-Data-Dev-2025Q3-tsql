-- File: 03_Create_Final_Report.sql
-- Creates the final comprehensive account balance report view
-- 
-- Key Features:
-- - Monthly end-of-month balances for all 12 months
-- - Special handling for accounts with "Opening balance" in 2025
-- - Mid-year account opening logic with appropriate NULL handling
-- - Forward-fill logic for months with no activity

USE HiringTryout_TSQL;
GO

IF OBJECT_ID('vw_FinalReport', 'V') IS NOT NULL DROP VIEW vw_FinalReport;
GO

CREATE VIEW vw_FinalReport AS
WITH AccountsWith2025OpeningBalance AS (
    -- CRITICAL BUSINESS RULE: Identify accounts that have "Opening balance" transactions in 2025
    -- These accounts IGNORE OpeningDate constraints and show balances for all months
    SELECT DISTINCT Account
    FROM dbo.AccountEntries
    WHERE [Text] = 'openingbalance' 
    AND YEAR([Date]) = 2025
)
SELECT
    ai.Account,
    TRIM(ai.Customer) AS Customer,
    ISNULL(ob.OpeningBalance2025, 0) AS OpeningBalance2025,
    
    -- MONTHLY BALANCE CALCULATION LOGIC:
    -- Formula: OpeningBalance2025 + RunningTotal (with forward-fill)
    -- 
    -- Two-tier logic per month:
    -- 1. IF account has 2025 Opening Balance → Show balance (ignore OpeningDate)
    -- 2. IF account opened mid-year → NULL for months before opening
    -- 3. ELSE → Normal calculation with forward-fill
    
    -- JANUARY
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(mb.RunningTotal_Jan, 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 1 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(mb.RunningTotal_Jan, 0) 
    END AS BalanceEndOf_Jan,
    
    -- FEBRUARY (forward-fills from January if no February activity)
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 2 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Feb,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 3 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Mar,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 4 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Apr,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 5 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_May,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 6 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Jun,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 7 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Jul,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 8 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Aug,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 9 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Sep,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Oct, mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 10 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Oct, mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Oct,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Nov, mb.RunningTotal_Oct, mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 11 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Nov, mb.RunningTotal_Oct, mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Nov,
    
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Dec, mb.RunningTotal_Nov, mb.RunningTotal_Oct, mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0)
        WHEN YEAR(ai.OpeningDate) > 2025 OR (YEAR(ai.OpeningDate) = 2025 AND 12 < MONTH(ai.OpeningDate)) THEN NULL 
        ELSE ISNULL(ob.OpeningBalance2025, 0) + ISNULL(COALESCE(mb.RunningTotal_Dec, mb.RunningTotal_Nov, mb.RunningTotal_Oct, mb.RunningTotal_Sep, mb.RunningTotal_Aug, mb.RunningTotal_Jul, mb.RunningTotal_Jun, mb.RunningTotal_May, mb.RunningTotal_Apr, mb.RunningTotal_Mar, mb.RunningTotal_Feb, mb.RunningTotal_Jan), 0) 
    END AS BalanceEndOf_Dec,

    ISNULL(ytd.SumTransactionsYTD, 0) AS SumTransactionsYTD
FROM
    dbo.AccountInformation AS ai
LEFT JOIN
    vw_OpeningBalance2025 AS ob ON ai.Account = ob.Account
LEFT JOIN
    vw_SumTransactionsYTD AS ytd ON ai.Account = ytd.Account
LEFT JOIN
    vw_MonthlyBalances AS mb ON ai.Account = mb.Account
LEFT JOIN
    AccountsWith2025OpeningBalance AS acc2025 ON ai.Account = acc2025.Account;
GO