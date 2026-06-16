USE KutuphaneDB;
GO
CREATE OR ALTER VIEW dbo.vw_ActiveMembers
AS
SELECT
    member_id,
    national_id,
    first_name,
    last_name,
    email,
    membership_type,
    is_active
FROM dbo.Member
WHERE is_active = 1;
GO

CREATE OR ALTER VIEW dbo.vw_BookDetails
AS
SELECT
    b.book_id,
    b.isbn,
    b.title,
    a.first_name + N' ' + a.last_name AS author_name,
    b.genre,
    b.publish_year,
    b.copy_count,        
    b.available_copies
FROM dbo.Book b
INNER JOIN dbo.Author a ON a.author_id = b.author_id;
GO

CREATE OR ALTER VIEW dbo.vw_MemberLoanSummary
AS
SELECT
    m.member_id,
    m.first_name + N' ' + m.last_name AS member_name,
    m.membership_type,
    COUNT(DISTINCT l.loan_id) AS total_loans,
    SUM(CASE WHEN l.loan_status = N'Aktif' THEN 1 ELSE 0 END) AS active_loans,
    SUM(CASE WHEN l.loan_status = N'Gecikmiş' THEN 1 ELSE 0 END) AS overdue_loans,
    ISNULL(SUM(p.amount), 0) AS total_penalty_amount,
    ISNULL(SUM(CASE WHEN p.paid = 0 THEN p.amount ELSE 0 END), 0) AS unpaid_penalty_amount
FROM dbo.Member m
LEFT JOIN dbo.Loan l ON l.member_id = m.member_id
LEFT JOIN dbo.Penalty p ON p.loan_id = l.loan_id
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type;
GO

PRINT N'--- VIEW 1: Aktif Üyeler Listesi ---';
SELECT * FROM dbo.vw_ActiveMembers;

PRINT N'--- VIEW 2: Yazarlarıyla Kitap Detayları ---';
SELECT * FROM dbo.vw_BookDetails;

PRINT N'--- VIEW 3: Üyelerin Ödünç ve Ceza Özet Raporu ---';
SELECT * FROM dbo.vw_MemberLoanSummary;
GO

