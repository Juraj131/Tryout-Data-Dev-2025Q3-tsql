-- File: 01_Setup_Tables.sql
-- This script creates and populates the necessary tables.
-- It is designed to be re-runnable by dropping existing tables first.

USE HiringTryout_TSQL;
GO

-- Drop existing tables to ensure a clean start
IF OBJECT_ID('dbo.AccountEntries', 'U') IS NOT NULL DROP TABLE dbo.AccountEntries;
IF OBJECT_ID('dbo.AccountInformation', 'U') IS NOT NULL DROP TABLE dbo.AccountInformation;
GO

-- Create AccountInformation Table
CREATE TABLE [dbo].[AccountInformation](
    [ID] [int] NULL,
    [Account] [int] NULL,
    [Customer] [nvarchar](30) NULL,
    [OpeningDate] [date] NULL,
    [ClosingDate] [date] NULL
) ON [PRIMARY];
GO

-- Create AccountEntries Table
CREATE TABLE [dbo].[AccountEntries](
    [ID] [int] NULL,
    [Date] [date] NULL,
    [Account] [int] NULL,
    [Amount] [money] NULL,
    [Currency] [nvarchar](3) NULL,
    [Text] [nvarchar](100) NULL
) ON [PRIMARY];
GO

-- Insert Data into AccountInformation
INSERT INTO [dbo].[AccountInformation] ([ID], [Account], [Customer], [OpeningDate], [ClosingDate]) VALUES (1, 1000001, N'	John	', N'2024-11-30', N'1900-01-01');
INSERT INTO [dbo].[AccountInformation] ([ID], [Account], [Customer], [OpeningDate], [ClosingDate]) VALUES (2, 1000002, N'	Betty	', N'2023-08-24', N'1900-01-01');
INSERT INTO [dbo].[AccountInformation] ([ID], [Account], [Customer], [OpeningDate], [ClosingDate]) VALUES (3, 1000003, N'	Jessica	', N'2024-05-14', N'1900-01-01');
INSERT INTO [dbo].[AccountInformation] ([ID], [Account], [Customer], [OpeningDate], [ClosingDate]) VALUES (4, 1000004, N'	Josh	', N'2025-06-02', N'2025-06-02');
GO

-- Insert Data into AccountEntries
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (1, N'2025-03-23', 1000001, -1243.34, N'EUR', N'Rent');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (2, N'2025-03-12', 1000002, 5434.40, N'EUR', N'Services');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (3, N'2025-03-04', 1000003, -2323.40, N'EUR', N'Utilities');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (4, N'2025-03-11', 1000004, -3422.90, N'EUR', N'Salaries');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (5, N'2025-01-10', 1000001, 23423.40, N'EUR', N'Invoice343');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (6, N'2025-01-17', 1000002, -312.40, N'EUR', N'Fees');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (7, N'2025-01-28', 1000003, 12123.33, N'EUR', N'Inv#88');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (8, N'2025-01-30', 1000004, -2354.30, N'EUR', N'Travelcosts');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (9, N'2025-02-02', 1000001, 276747.40, N'EUR', N'Monthlyfees');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (10, N'2025-02-13', 1000002, 654.40, N'EUR', N'Costadjustment');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (11, N'2025-02-17', 1000003, -5645.40, N'EUR', N'Utilities');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (12, N'2025-02-28', 1000004, 476455.60, N'EUR', N'Transfer');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (13, N'2025-01-01', 1000001, 3322909.90, N'EUR', N'openingbalance');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (14, N'2025-01-01', 1000002, 38383992.40, N'EUR', N'openingbalance');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (15, N'2025-01-01', 1000003, 5584843.90, N'EUR', N'openingbalance');
INSERT INTO [dbo].[AccountEntries] ([ID], [Date], [Account], [Amount], [Currency], [Text]) VALUES (16, N'2025-01-01', 1000004, 988786.90, N'EUR', N'openingbalance');
GO