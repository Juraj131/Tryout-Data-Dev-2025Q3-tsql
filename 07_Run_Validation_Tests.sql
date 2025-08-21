-- File: 07_Run_Validation_Tests.sql
-- Simple validation tests for the Account Balance Report
-- Based on the logic from PySpark implementation

USE HiringTryout_TSQL;
GO

PRINT '=======================================================';
PRINT 'STARTING VALIDATION TESTS';
PRINT '=======================================================';
PRINT '';

-- Test 1: Basic Data Integrity
PRINT '--- TEST 1: Basic Data Integrity ---';

-- Check if all accounts from AccountInformation appear in the report
DECLARE @MissingAccounts INT;
SELECT @MissingAccounts = COUNT(*)
FROM dbo.AccountInformation ai
LEFT JOIN vw_FinalReport fr ON ai.Account = fr.Account
WHERE fr.Account IS NULL;

IF @MissingAccounts > 0
BEGIN
    PRINT '❌ FAIL: Some accounts from AccountInformation are missing in the final report';
    SELECT ai.Account, ai.Customer 
    FROM dbo.AccountInformation ai
    LEFT JOIN vw_FinalReport fr ON ai.Account = fr.Account
    WHERE fr.Account IS NULL;
END
ELSE
BEGIN
    PRINT '✅ PASS: All accounts from AccountInformation appear in the final report';
END

PRINT '';

-- Test 2: Opening Balance Calculation
PRINT '--- TEST 2: Opening Balance Calculation ---';

-- Manual calculation of opening balance (sum of transactions with EffectiveDate < 2025)
WITH ManualOpeningBalance AS (
    SELECT 
        Account,
        SUM(CASE 
            WHEN [Text] = 'openingbalance' THEN Amount 
            WHEN YEAR([Date]) < 2025 THEN Amount 
            ELSE 0 
        END) AS ManualOpeningBalance2025
    FROM dbo.AccountEntries
    GROUP BY Account
)
SELECT 
    fr.Account,
    fr.Customer,
    fr.OpeningBalance2025 AS ReportValue,
    mob.ManualOpeningBalance2025 AS ExpectedValue,
    CASE 
        WHEN ABS(fr.OpeningBalance2025 - ISNULL(mob.ManualOpeningBalance2025, 0)) < 0.01 
        THEN '✅ PASS' 
        ELSE '❌ FAIL' 
    END AS ValidationResult
FROM vw_FinalReport fr
LEFT JOIN ManualOpeningBalance mob ON fr.Account = mob.Account
ORDER BY fr.Account;

PRINT '';

-- Test 3: YTD Transactions Validation
PRINT '--- TEST 3: YTD Transactions Validation ---';

-- Manual calculation of YTD (sum of 2025 transactions, excluding opening balance)
WITH ManualYTD AS (
    SELECT 
        Account,
        SUM(Amount) AS ManualYTD
    FROM dbo.AccountEntries
    WHERE YEAR([Date]) = 2025 AND [Text] != 'openingbalance'
    GROUP BY Account
)
SELECT 
    fr.Account,
    fr.Customer,
    fr.SumTransactionsYTD AS ReportValue,
    ISNULL(mytd.ManualYTD, 0) AS ExpectedValue,
    CASE 
        WHEN ABS(fr.SumTransactionsYTD - ISNULL(mytd.ManualYTD, 0)) < 0.01 
        THEN '✅ PASS' 
        ELSE '❌ FAIL' 
    END AS ValidationResult
FROM vw_FinalReport fr
LEFT JOIN ManualYTD mytd ON fr.Account = mytd.Account
ORDER BY fr.Account;

PRINT '';

-- Test 4: Special Logic for Accounts with 2025 Opening Balance
PRINT '--- TEST 4: Accounts with Opening Balance in 2025 ---';

-- Identify accounts that have "Opening balance" transactions in 2025
WITH AccountsWith2025OB AS (
    SELECT DISTINCT Account
    FROM dbo.AccountEntries
    WHERE [Text] = 'openingbalance' AND YEAR([Date]) = 2025
)
SELECT 
    ai.Account,
    ai.Customer,
    ai.OpeningDate,
    CASE 
        WHEN acc2025.Account IS NOT NULL THEN 'Has 2025 Opening Balance - Should ignore OpeningDate' 
        ELSE 'Normal account - Should respect OpeningDate' 
    END AS AccountType,
    fr.BalanceEndOf_Jan,
    fr.BalanceEndOf_Feb,
    fr.BalanceEndOf_Mar
FROM dbo.AccountInformation ai
LEFT JOIN AccountsWith2025OB acc2025 ON ai.Account = acc2025.Account
LEFT JOIN vw_FinalReport fr ON ai.Account = fr.Account
WHERE ai.OpeningDate IS NOT NULL AND YEAR(ai.OpeningDate) = 2025
ORDER BY ai.Account;

PRINT '';

-- Test 5: Mid-Year Account Opening Validation
PRINT '--- TEST 5: Mid-Year Account Opening Logic ---';

-- Check accounts opened mid-year WITHOUT 2025 opening balance
-- Should have NULL balances before opening month
WITH AccountsWith2025OB AS (
    SELECT DISTINCT Account
    FROM dbo.AccountEntries
    WHERE [Text] = 'openingbalance' AND YEAR([Date]) = 2025
),
MidYearAccounts AS (
    SELECT 
        ai.Account,
        ai.Customer,
        ai.OpeningDate,
        MONTH(ai.OpeningDate) AS OpeningMonth
    FROM dbo.AccountInformation ai
    LEFT JOIN AccountsWith2025OB acc2025 ON ai.Account = acc2025.Account
    WHERE ai.OpeningDate IS NOT NULL 
        AND YEAR(ai.OpeningDate) = 2025 
        AND acc2025.Account IS NULL  -- No 2025 opening balance
)
SELECT 
    mya.Account,
    mya.Customer,
    mya.OpeningDate,
    mya.OpeningMonth,
    fr.BalanceEndOf_Jan,
    fr.BalanceEndOf_Feb,
    fr.BalanceEndOf_Mar,
    fr.BalanceEndOf_Apr,
    fr.BalanceEndOf_May,
    fr.BalanceEndOf_Jun,
    CASE 
        WHEN (mya.OpeningMonth > 1 AND fr.BalanceEndOf_Jan IS NOT NULL) OR
             (mya.OpeningMonth > 2 AND fr.BalanceEndOf_Feb IS NOT NULL) OR
             (mya.OpeningMonth > 3 AND fr.BalanceEndOf_Mar IS NOT NULL) OR
             (mya.OpeningMonth > 4 AND fr.BalanceEndOf_Apr IS NOT NULL) OR
             (mya.OpeningMonth > 5 AND fr.BalanceEndOf_May IS NOT NULL) OR
             (mya.OpeningMonth > 6 AND fr.BalanceEndOf_Jun IS NOT NULL)
        THEN '❌ FAIL: Should have NULL before opening'
        ELSE '✅ PASS: Correct NULL handling'
    END AS ValidationResult
FROM MidYearAccounts mya
LEFT JOIN vw_FinalReport fr ON mya.Account = fr.Account
ORDER BY mya.Account;

PRINT '';

-- Test 6: Specific Test Cases (like unit tests in PySpark)
PRINT '--- TEST 6: Specific Test Cases ---';

-- Look for specific patterns similar to the PySpark test cases
SELECT 
    fr.Account,
    fr.Customer,
    ai.OpeningDate,
    CASE 
        WHEN EXISTS (SELECT 1 FROM dbo.AccountEntries ae WHERE ae.Account = fr.Account AND ae.[Text] = 'openingbalance' AND YEAR(ae.[Date]) = 2025)
        THEN 'Case: Opening Balance in 2025'
        WHEN ai.OpeningDate IS NOT NULL AND YEAR(ai.OpeningDate) = 2025 AND MONTH(ai.OpeningDate) > 1
        THEN 'Case: Mid-year account opening'
        WHEN ai.OpeningDate IS NULL OR YEAR(ai.OpeningDate) < 2025
        THEN 'Case: Historical account'
        ELSE 'Case: Other'
    END AS TestCaseType,
    fr.OpeningBalance2025,
    fr.BalanceEndOf_Jan,
    fr.BalanceEndOf_Feb,
    fr.BalanceEndOf_Mar,
    fr.SumTransactionsYTD
FROM vw_FinalReport fr
JOIN dbo.AccountInformation ai ON fr.Account = ai.Account
ORDER BY fr.Account;

PRINT '';

-- Test 7: Summary Statistics
PRINT '--- TEST 7: Summary Statistics ---';

SELECT 
    'Total Accounts' AS Metric,
    COUNT(*) AS Count
FROM vw_FinalReport

UNION ALL

SELECT 
    'Accounts with 2025 Opening Balance',
    COUNT(DISTINCT ae.Account)
FROM dbo.AccountEntries ae
WHERE ae.[Text] = 'openingbalance' AND YEAR(ae.[Date]) = 2025

UNION ALL

SELECT 
    'Mid-year opened accounts (2025)',
    COUNT(*)
FROM dbo.AccountInformation ai
WHERE ai.OpeningDate IS NOT NULL AND YEAR(ai.OpeningDate) = 2025 AND MONTH(ai.OpeningDate) > 1

UNION ALL

SELECT 
    'Accounts with non-zero YTD',
    COUNT(*)
FROM vw_FinalReport
WHERE SumTransactionsYTD != 0;

PRINT '';
PRINT '=======================================================';
PRINT 'VALIDATION TESTS COMPLETED';
PRINT '=======================================================';