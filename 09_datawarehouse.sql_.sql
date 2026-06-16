
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dw')
    EXEC('CREATE SCHEMA dw');
GO

DROP TABLE IF EXISTS dw.fact_loan;
DROP TABLE IF EXISTS dw.dim_book;
DROP TABLE IF EXISTS dw.dim_author;
DROP TABLE IF EXISTS dw.dim_member;
DROP TABLE IF EXISTS dw.dim_date;
GO

CREATE TABLE dw.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year_no INT,
    month_no INT,
    month_name NVARCHAR(20),
    quarter_no INT);

CREATE TABLE dw.dim_member (
    member_key INT PRIMARY KEY,
    member_id INT,
    member_name NVARCHAR(100),
    membership_type NVARCHAR(50));


CREATE TABLE dw.dim_author (
    author_key INT PRIMARY KEY,
    author_id INT,
    author_name NVARCHAR(100),
    birth_date INT);

CREATE TABLE dw.dim_book (
    book_key INT PRIMARY KEY,
    book_id INT,
    title NVARCHAR(200),
    genre NVARCHAR(100),
    author_key INT);

CREATE TABLE dw.fact_loan (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    loan_id INT,
    date_key INT,
    member_key INT,
    book_key INT,
    loan_days INT,
    overdue_days INT,
    penalty_amount DECIMAL(10,2),
    is_returned BIT);
GO

INSERT INTO dw.dim_date
SELECT DISTINCT
    CAST(CONVERT(CHAR(8), loan_date, 112) AS INT),
    loan_date,
    YEAR(loan_date),
    MONTH(loan_date),
    DATENAME(MONTH, loan_date),
    DATEPART(QUARTER, loan_date)
FROM dbo.Loan;

INSERT INTO dw.dim_member
SELECT member_id, member_id, first_name + N' ' + last_name, membership_type
FROM dbo.Member;

INSERT INTO dw.dim_author
SELECT author_id, author_id, first_name + N' ' + last_name, birth_year
FROM dbo.Author;

INSERT INTO dw.dim_book
SELECT book_id, book_id, title, genre, author_id
FROM dbo.Book;

INSERT INTO dw.fact_loan (loan_id, date_key, member_key, book_key, loan_days, overdue_days, penalty_amount, is_returned)
SELECT 
    l.loan_id,
    CAST(CONVERT(CHAR(8), l.loan_date, 112) AS INT),
    l.member_id,
    l.book_id,
    DATEDIFF(DAY, l.loan_date, ISNULL(l.return_date, l.due_date)),
    CAST(CASE 
        WHEN l.return_date IS NULL AND l.due_date < GETDATE() THEN DATEDIFF(DAY, l.due_date, GETDATE()) 
        ELSE 0 
    END AS INT),
    ISNULL(p.amount, 0),
    CASE WHEN l.return_date IS NULL THEN 0 ELSE 1 END
FROM dbo.Loan l
LEFT JOIN dbo.Penalty p ON l.loan_id = p.loan_id;
GO
