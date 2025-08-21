# T-SQL Account Balance Report Implementation

*Hiring Tryout Data Dev - Q3 2025*  
*(c) 2025 uCloudify s.r.o*

## 📋 Overview

This repository contains a **T-SQL implementation** of an Account Balance Report system that generates monthly balance reports for financial accounts with sophisticated handling of mid-year account openings and special opening balance logic.

## 🎯 Task Requirements

**Goal:** Create a report providing:
- Account number
- Customer name  
- Opening balance 2025
- Monthly end-of-month balances (January through December)
- Sum of transactions Year-to-Date (YTD)

**Data Sources:**
1. **Account Entries** - Transaction data with dates, amounts, and descriptions
2. **Account Information** - Account metadata including opening/closing dates

## 🚀 Quick Start

### Prerequisites
- Microsoft SQL Server (2016+ recommended)
- SQL Server Management Studio or Azure Data Studio

### Installation & Execution
Run the scripts in sequential order:

```sql
-- 1. Create database
.\database_create.sql

-- 2. Setup tables and data
.\01_Setup_Tables.sql

-- 3. Create supporting views
.\02_Create_Views.sql

-- 4. Create final report view
.\03_Create_Final_Report.sql

-- 5. Run the report
.\04_Run_Report.sql

-- 6. Create stored procedure (optional)
.\05_Create_Report_Procedure.sql
.\06_Run_Stored_Procedure.sql

-- 7. Run validation tests
.\07_Run_Validation_Tests.sql
```

## 🏗️ Architecture & Design

### Key Design Decisions

1. **View-Based Architecture**
   - Modular design with building-block views
   - Easy to understand and maintain
   - Supports incremental development

2. **EffectiveDate Logic** 
   - "Opening balance" transactions treated as occurring on 2024-12-31
   - Unified logic for all calculations
   - Matches PySpark implementation behavior

3. **Special Opening Balance Handling**
   - Accounts with "Opening balance" entries in 2025 **ignore** `OpeningDate` constraints
   - Accounts without 2025 opening balance **respect** mid-year opening logic
   - NULL balances for months before account opening (when applicable)

### Performance Considerations
- Views cached in memory during execution
- Optimized JOINs and aggregations
- Minimal data scanning through effective filtering

## 📊 Business Logic

### Core Calculation Rules

1. **Opening Balance 2025**: Sum of all transactions with EffectiveDate < 2025
2. **YTD Transactions**: Sum of 2025 transactions (excluding "Opening balance" entries)
3. **Monthly Balances**: Opening balance + cumulative monthly transactions
4. **Forward-Fill**: Months with no activity inherit previous month's balance

### Special Cases Handled

- **Mid-year account opening**: NULL balances before opening month
- **2025 Opening Balance Exception**: Ignore opening date constraints for accounts with explicit 2025 opening balance
- **Historical accounts**: Include all historical transactions in opening balance

## ✅ Validation & Testing

The `07_Run_Validation_Tests.sql` script includes:

- ✅ Data integrity checks
- ✅ Opening balance calculation verification  
- ✅ YTD transaction validation
- ✅ Mid-year opening logic testing
- ✅ Special case scenario validation
- ✅ Summary statistics and reporting

## 📁 File Structure

```
├── database_create.sql           # Database creation
├── 01_Setup_Tables.sql          # Table creation and data loading
├── 02_Create_Views.sql          # Supporting views
├── 03_Create_Final_Report.sql   # Main report view
├── 04_Run_Report.sql            # Execute report
├── 05_Create_Report_Procedure.sql # Stored procedure
├── 06_Run_Stored_Procedure.sql  # Execute procedure
├── 07_Run_Validation_Tests.sql  # Validation tests
├── Data/                        # Data files
│   ├── dbo.AccountEntries.sql
│   ├── dbo.AccountEntries.data.sql
│   ├── dbo.AccountInformation.sql
│   └── dbo.AccountInformation.data.sql
└── README.md                    # This file
```

## 🔍 Assessment Criteria Coverage

- ✅ **Functional Requirements**: Complete implementation with all edge cases
- ✅ **Design Choices**: View-based modular architecture with clear reasoning
- ✅ **Performance**: Optimized queries with efficient data processing
- ✅ **Readability**: Clean SQL with comprehensive documentation
- ✅ **Validation**: Extensive unit testing and input validation
- ✅ **Bonus Features**: Comprehensive test suite with edge case coverage

## 🤝 Related Implementation

This T-SQL implementation mirrors the logic from the **PySpark implementation** available at:  
[Tryout-Data-Dev-2025Q3-PySpark](https://github.com/Juraj131/Tryout-Data-Dev-2025Q3-PySpark)

Both implementations handle identical business requirements with language-specific optimizations.

