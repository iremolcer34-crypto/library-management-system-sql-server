
IF OBJECT_ID('dbo.sp_GetMemberLoans', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetMemberLoans;
GO


CREATE PROCEDURE dbo.sp_GetMemberLoans
    @MemberId INT,
    @StatusFilter NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.loan_id,
        m.first_name + N' ' + m.last_name AS uye,
        b.title AS kitap,
        l.loan_date,
        l.due_date,
        l.return_date,
        l.loan_status,
        DATEDIFF(
            DAY,
            l.due_date,
            ISNULL(l.return_date, CAST(GETDATE() AS DATE))
        ) AS gun_farki
    FROM dbo.Loan l
    INNER JOIN dbo.Member m ON l.member_id = m.member_id
    INNER JOIN dbo.Book b ON l.book_id = b.book_id
    WHERE l.member_id = @MemberId
      AND (@StatusFilter IS NULL OR l.loan_status = @StatusFilter)
    ORDER BY l.loan_date DESC;
END;
GO


IF OBJECT_ID('dbo.sp_CreateLoan', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateLoan;
GO

CREATE PROCEDURE dbo.sp_CreateLoan
    @MemberId INT,
    @BookId INT,
    @LoanDays INT = 14,
    @NewLoanId INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.Member WHERE member_id = @MemberId AND is_active = 1)
        BEGIN
            RAISERROR(N'Aktif üye bulunamadı.', 16, 1);
            RETURN;
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.Book WHERE book_id = @BookId AND available_copies > 0)
        BEGIN
            RAISERROR(N'Müsait kopya yok.', 16, 1);
            RETURN;
        END;

        BEGIN TRANSACTION;

            INSERT INTO dbo.Loan (member_id, book_id, loan_date, due_date, return_date, loan_status)
            VALUES (@MemberId, @BookId, CAST(GETDATE() AS DATE), DATEADD(DAY, @LoanDays, CAST(GETDATE() AS DATE)), NULL, N'Aktif');

            SET @NewLoanId = SCOPE_IDENTITY();

            UPDATE dbo.Book SET available_copies = available_copies - 1 WHERE book_id = @BookId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

IF OBJECT_ID('dbo.sp_ReturnBook', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ReturnBook;
GO

CREATE PROCEDURE dbo.sp_ReturnBook
    @LoanId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BookId INT;
    DECLARE @Status NVARCHAR(50);

    SELECT @BookId = book_id, @Status = loan_status FROM dbo.Loan WHERE loan_id = @LoanId;

    IF @BookId IS NULL
    BEGIN
        RAISERROR(N'Ödünç kaydı bulunamadı.', 16, 1);
        RETURN;
    END;

    IF @Status = N'İade'
    BEGIN
        RAISERROR(N'Kitap zaten iade edilmiş.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

            UPDATE dbo.Loan SET return_date = CAST(GETDATE() AS DATE), loan_status = N'İade' WHERE loan_id = @LoanId;
            UPDATE dbo.Book SET available_copies = available_copies + 1 WHERE book_id = @BookId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO