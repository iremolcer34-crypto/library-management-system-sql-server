IF DB_ID(N'KutuphaneDB') IS NOT NULL
BEGIN
    ALTER DATABASE KutuphaneDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE KutuphaneDB;
END;
GO

CREATE DATABASE KutuphaneDB;
GO

USE KutuphaneDB;
GO
IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'Author' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.Author (
        author_id       INT             NOT NULL IDENTITY(1,1),
        first_name      NVARCHAR(50)    NOT NULL,
        last_name       NVARCHAR(50)    NOT NULL,
        birth_year      SMALLINT        NULL,
        nationality     NVARCHAR(40)    NOT NULL CONSTRAINT DF_Author_Nationality DEFAULT N'Türkiye',
        CONSTRAINT PK_Author PRIMARY KEY CLUSTERED (author_id),
        CONSTRAINT UQ_Author_Name UNIQUE (last_name, first_name, birth_year),
        CONSTRAINT CK_Author_BirthYear CHECK (birth_year IS NULL OR birth_year BETWEEN 1800 AND YEAR(GETDATE()))
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'Shelf' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.Shelf (
        shelf_id        INT             NOT NULL IDENTITY(1,1),
        shelf_code      NVARCHAR(20)    NOT NULL,
        section         NVARCHAR(60)    NOT NULL,
        floor_no        TINYINT         NOT NULL CONSTRAINT DF_Shelf_Floor DEFAULT 1,
        capacity        INT             NOT NULL CONSTRAINT DF_Shelf_Capacity DEFAULT 100,
        CONSTRAINT PK_Shelf PRIMARY KEY CLUSTERED (shelf_id),
        CONSTRAINT UQ_Shelf_Code UNIQUE (shelf_code),
        CONSTRAINT CK_Shelf_Floor CHECK (floor_no BETWEEN 0 AND 20),
        CONSTRAINT CK_Shelf_Capacity CHECK (capacity > 0)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'Book' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.Book (
        book_id             INT             NOT NULL IDENTITY(1,1),
        isbn                CHAR(13)        NOT NULL,
        title               NVARCHAR(200)   NOT NULL,
        author_id           INT             NOT NULL,
        shelf_id            INT             NOT NULL,
        publish_year        SMALLINT        NOT NULL,
        genre               NVARCHAR(40)    NOT NULL,
        copy_count          INT             NOT NULL CONSTRAINT DF_Book_CopyCount DEFAULT 1,
        available_copies    INT             NOT NULL CONSTRAINT DF_Book_Available DEFAULT 1,
        CONSTRAINT PK_Book PRIMARY KEY CLUSTERED (book_id),
        CONSTRAINT FK_Book_Author FOREIGN KEY (author_id) REFERENCES dbo.Author(author_id),
        CONSTRAINT FK_Book_Shelf FOREIGN KEY (shelf_id) REFERENCES dbo.Shelf(shelf_id),
        CONSTRAINT UQ_Book_ISBN UNIQUE (isbn),
        CONSTRAINT CK_Book_PublishYear CHECK (publish_year BETWEEN 1450 AND YEAR(GETDATE())),
        CONSTRAINT CK_Book_Copies CHECK (copy_count >= 1 AND available_copies >= 0 AND available_copies <= copy_count)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'Member' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.Member (
        member_id           INT             NOT NULL IDENTITY(1,1),
        national_id         CHAR(11)        NOT NULL,
        first_name          NVARCHAR(50)    NOT NULL,
        last_name           NVARCHAR(50)    NOT NULL,
        email               NVARCHAR(120)   NOT NULL,
        phone               NVARCHAR(20)    NULL,
        register_date       DATE            NOT NULL CONSTRAINT DF_Member_Register DEFAULT CAST(GETDATE() AS DATE),
        membership_type     NVARCHAR(20)    NOT NULL CONSTRAINT DF_Member_Type DEFAULT N'Standart',
        is_active           BIT             NOT NULL CONSTRAINT DF_Member_Active DEFAULT 1,
        CONSTRAINT PK_Member PRIMARY KEY CLUSTERED (member_id),
        CONSTRAINT UQ_Member_NationalId UNIQUE (national_id),
        CONSTRAINT UQ_Member_Email UNIQUE (email),
        CONSTRAINT CK_Member_Type CHECK (membership_type IN (N'Standart', N'Premium', N'Öğrenci', N'Personel'))
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'Loan' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.Loan (
        loan_id         INT             NOT NULL IDENTITY(1,1),
        member_id       INT             NOT NULL,
        book_id         INT             NOT NULL,
        loan_date       DATE            NOT NULL CONSTRAINT DF_Loan_Date DEFAULT CAST(GETDATE() AS DATE),
        due_date        DATE            NOT NULL,
        return_date     DATE            NULL,
        loan_status     NVARCHAR(20)    NOT NULL CONSTRAINT DF_Loan_Status DEFAULT N'Aktif',
        CONSTRAINT PK_Loan PRIMARY KEY CLUSTERED (loan_id),
        CONSTRAINT FK_Loan_Member FOREIGN KEY (member_id) REFERENCES dbo.Member(member_id),
        CONSTRAINT FK_Loan_Book FOREIGN KEY (book_id) REFERENCES dbo.Book(book_id),
        CONSTRAINT CK_Loan_DueDate CHECK (due_date >= loan_date),
        CONSTRAINT CK_Loan_ReturnDate CHECK (return_date IS NULL OR return_date >= loan_date),
        CONSTRAINT CK_Loan_Status CHECK (loan_status IN (N'Aktif', N'İade', N'Gecikmiş'))
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'Penalty' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.Penalty (
        penalty_id      INT             NOT NULL IDENTITY(1,1),
        loan_id         INT             NOT NULL,
        amount          DECIMAL(10,2)   NOT NULL,
        reason          NVARCHAR(200)   NOT NULL,
        paid            BIT             NOT NULL CONSTRAINT DF_Penalty_Paid DEFAULT 0,
        created_at      DATETIME2       NOT NULL CONSTRAINT DF_Penalty_Created DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Penalty PRIMARY KEY CLUSTERED (penalty_id),
        CONSTRAINT FK_Penalty_Loan FOREIGN KEY (loan_id) REFERENCES dbo.Loan(loan_id),
        CONSTRAINT UQ_Penalty_Loan UNIQUE (loan_id),
        CONSTRAINT CK_Penalty_Amount CHECK (amount >= 0)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = N'AuditLog' AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    CREATE TABLE dbo.AuditLog (
        audit_id        BIGINT          NOT NULL IDENTITY(1,1),
        table_name      NVARCHAR(128)   NOT NULL,
        operation_type  NVARCHAR(10)    NOT NULL,
        record_id       INT             NOT NULL,
        changed_at      DATETIME2       NOT NULL CONSTRAINT DF_AuditLog_Changed DEFAULT SYSUTCDATETIME(),
        detail          NVARCHAR(500)   NULL,
        CONSTRAINT PK_AuditLog PRIMARY KEY CLUSTERED (audit_id)
    );
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Book_Author_Genre'
      AND object_id = OBJECT_ID(N'dbo.Book')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Book_Author_Genre
        ON dbo.Book (author_id, genre)
        INCLUDE (title, available_copies);
END;
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'IX_Loan_Member_Status_Date'
      AND object_id = OBJECT_ID(N'dbo.Loan')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_Loan_Member_Status_Date
        ON dbo.Loan (member_id, loan_status, loan_date DESC)
        INCLUDE (book_id, due_date, return_date);
END;
GO
