USE KutuphaneDB;
GO

CREATE OR ALTER TRIGGER trg_AfterLoanInsert
ON dbo.Loan
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.AuditLog (table_name, operation_type, record_id, detail)
    SELECT 
        N'Loan', 
        N'INSERT', 
        i.loan_id, 
        N'Yeni ödünç kaydı oluşturuldu. Kitap ID: ' + CAST(i.book_id AS NVARCHAR(10))
    FROM inserted i;
END;
GO

CREATE OR ALTER TRIGGER trg_BookUpdateAudit
ON dbo.Book
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.AuditLog (table_name, operation_type, record_id, detail)
    SELECT 
        N'Book', 
        N'UPDATE', 
        i.book_id, 
        N'Kitap stok bilgisi güncellendi. Eski kopya: ' + CAST(d.available_copies AS NVARCHAR(10)) + N' -> Yeni: ' + CAST(i.available_copies AS NVARCHAR(10))
    FROM inserted i
    INNER JOIN deleted d ON i.book_id = d.book_id;
END;
GO

CREATE OR ALTER TRIGGER trg_AutoReturnStatus
ON dbo.Loan
AFTER UPDATE
AS
BEGIN
    IF UPDATE(return_date)
    BEGIN
        UPDATE l
        SET l.loan_status = N'İade'
        FROM dbo.Loan l
        INNER JOIN inserted i ON l.loan_id = i.loan_id
        WHERE i.return_date IS NOT NULL AND l.loan_status != N'İade';
    END
END;
GO
