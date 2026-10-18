-- Run once on an existing SQL Server database before deploying the PayOS code.
-- Fresh databases created with SQLQuery1.sql already have this column.
IF COL_LENGTH(N'dbo.payments', N'checkout_url') IS NULL
    ALTER TABLE dbo.payments ADD checkout_url NVARCHAR(2048) NULL;
