-- File: 05_Create_Report_Procedure.sql
USE HiringTryout_TSQL;
GO

CREATE OR ALTER PROCEDURE sp_GetFinalAccountReport
AS
BEGIN
    SET NOCOUNT ON; -- Prevents sending 'xx rows affected' messages
    SELECT * FROM vw_FinalReport;
END;
GO

-- To run the report, you would then simply execute:
-- EXEC sp_GetFinalAccountReport;