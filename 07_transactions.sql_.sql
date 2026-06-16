USE KutuphaneDB;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Book
    SET available_copies = available_copies - 1
    WHERE book_id = 3 
      AND available_copies > 0;

    IF @@ROWCOUNT = 0
        THROW 50001, N'Müsait kopya yok, ödünç verilemedi.', 1;

    INSERT INTO dbo.Loan (member_id, book_id, loan_date, due_date, return_date, loan_status)
    VALUES (1, 3, CAST(GETDATE() AS DATE), DATEADD(DAY, 14, GETDATE()), NULL, N'Aktif');

    COMMIT TRANSACTION;
    PRINT N'Transaction 1: COMMIT edildi.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'Transaction 1 HATA: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRANSACTION;
UPDATE dbo.Book SET available_copies = available_copies - 1 WHERE book_id = 3;
ROLLBACK TRANSACTION;
PRINT N'Transaction 2: ROLLBACK edildi (Stok değişikliği geri alındı).';
GO

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE dbo.Penalty
    SET paid = 1
    WHERE penalty_id = 5;

    COMMIT TRANSACTION;
    PRINT N'Transaction 3: COMMIT edildi (Ceza ödendi).';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'Transaction 3 HATA: ' + ERROR_MESSAGE();
END CATCH;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO dbo.Loan (member_id, book_id, loan_date, due_date, return_date, loan_status)
    VALUES (99999, 1, CAST(GETDATE() AS DATE), DATEADD(DAY, 7, GETDATE()), NULL, N'Aktif');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT N'Transaction 4: Hata yakalandı, işlem başarıyla geri alındı (ROLLBACK).';
    PRINT ERROR_MESSAGE();
END CATCH;
GO
