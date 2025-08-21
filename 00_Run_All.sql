-- =========================================================================
-- 00_Run_All.sql - Complete Account Balance Report Implementation
-- =========================================================================
-- This script provides instructions for executing all components in the 
-- correct order for a complete setup of the Account Balance Report system.
--
-- NOTE: Due to SQL Server limitations, this script shows the order.
-- Execute each script individually in SQL Server Management Studio.
-- =========================================================================

PRINT '=========================================================================';
PRINT 'ACCOUNT BALANCE REPORT - SETUP INSTRUCTIONS';
PRINT '=========================================================================';
PRINT 'Execute the following scripts IN ORDER:';
PRINT '';

PRINT '1. database_create.sql        -- Create database';
PRINT '2. 01_Setup_Tables.sql        -- Create tables and load data';  
PRINT '3. 02_Create_Views.sql        -- Create supporting views';
PRINT '4. 03_Create_Final_Report.sql -- Create final report view';
PRINT '5. 04_Run_Report.sql          -- Execute and view report';
PRINT '6. 05_Create_Report_Procedure.sql -- Create stored procedure';
PRINT '7. 06_Run_Stored_Procedure.sql    -- Test stored procedure';
PRINT '8. 07_Run_Validation_Tests.sql    -- Run validation tests';

PRINT '';
PRINT '=========================================================================';
PRINT 'QUICK TEST - Verify Setup';
PRINT '=========================================================================';

-- Quick verification if everything is set up
IF DB_ID('HiringTryout_TSQL') IS NOT NULL
BEGIN
    USE HiringTryout_TSQL;
    
    IF OBJECT_ID('vw_FinalReport', 'V') IS NOT NULL
    BEGIN
        PRINT '✅ Database and views are ready!';
        PRINT 'Sample data from final report:';
        SELECT TOP 4 Account, Customer, OpeningBalance2025, BalanceEndOf_Jan, SumTransactionsYTD 
        FROM vw_FinalReport 
        ORDER BY Account;
    END
    ELSE
    BEGIN
        PRINT '⚠️  Views not found. Please run scripts 01-03 first.';
    END
END
ELSE
BEGIN
    PRINT '⚠️  Database not found. Please run database_create.sql first.';
END

PRINT '';
PRINT '=========================================================================';
