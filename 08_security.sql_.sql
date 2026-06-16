
USE KutuphaneDB;
GO

DECLARE @sql nvarchar(max) = N'';

IF DATABASE_PRINCIPAL_ID(N'db_readonly') IS NOT NULL
BEGIN
    SELECT @sql = @sql + N'ALTER ROLE db_readonly DROP MEMBER ' + QUOTENAME(dp.name) + N';'
    FROM sys.database_role_members drm
    JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    WHERE r.name = N'db_readonly';
    IF LEN(@sql) > 0 EXEC sp_executesql @sql;

    DROP ROLE db_readonly;
END
GO

DECLARE @sql nvarchar(max) = N'';

IF DATABASE_PRINCIPAL_ID(N'db_operator') IS NOT NULL
BEGIN
    SELECT @sql = @sql + N'ALTER ROLE db_operator DROP MEMBER ' + QUOTENAME(dp.name) + N';'
    FROM sys.database_role_members drm
    JOIN sys.database_principals dp ON drm.member_principal_id = dp.principal_id
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    WHERE r.name = N'db_operator';
    IF LEN(@sql) > 0 EXEC sp_executesql @sql;

    DROP ROLE db_operator;
END
GO

CREATE ROLE db_readonly;
CREATE ROLE db_operator;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'kutuphane_reader')
    CREATE USER kutuphane_reader WITHOUT LOGIN;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'kutuphane_writer')
    CREATE USER kutuphane_writer WITHOUT LOGIN;
GO

IF IS_ROLEMEMBER(N'db_readonly', N'kutuphane_reader') <> 1
    ALTER ROLE db_readonly ADD MEMBER kutuphane_reader;

IF IS_ROLEMEMBER(N'db_operator', N'kutuphane_writer') <> 1
    ALTER ROLE db_operator ADD MEMBER kutuphane_writer;
GO

GRANT SELECT ON dbo.Author TO db_readonly;
GRANT SELECT ON dbo.Shelf TO db_readonly;
GRANT SELECT ON dbo.Book TO db_readonly;
GRANT SELECT ON dbo.Member TO db_readonly;
GRANT SELECT ON dbo.Loan TO db_readonly;
GRANT SELECT ON dbo.Penalty TO db_readonly;
GRANT SELECT ON dbo.vw_ActiveMembers TO db_readonly;
GRANT SELECT ON dbo.vw_BookDetails TO db_readonly;
GRANT SELECT ON dbo.vw_MemberLoanSummary TO db_readonly;
GO

GRANT SELECT, INSERT, UPDATE ON dbo.Loan TO db_operator;
GRANT SELECT, INSERT, UPDATE ON dbo.Penalty TO db_operator;
GRANT SELECT, UPDATE ON dbo.Book TO db_operator;
GRANT EXECUTE ON dbo.sp_GetMemberLoans TO db_operator;
GRANT EXECUTE ON dbo.sp_CreateLoan TO db_operator;
GRANT EXECUTE ON dbo.sp_ReturnBook TO db_operator;
GO

GRANT SELECT, INSERT, UPDATE ON dbo.Member TO db_operator;
REVOKE INSERT, UPDATE ON dbo.Member FROM db_operator;
GO

DENY SELECT ON dbo.AuditLog TO db_readonly;
GO

PRINT N'Yetkilendirme tamamlandı.';
GO


