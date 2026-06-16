USE KutuphaneDB;
GO

SELECT
    l.loan_id AS [Ödünç ID],
    m.first_name + N' ' + m.last_name AS [Üye Adı],
    b.title AS [Kitap Adı],
    a.first_name + N' ' + a.last_name AS [Yazar Adı],
    l.loan_date AS [Ödünç Tarihi],
    l.due_date AS [Son Teslim Tarihi],
    l.loan_status AS [Durum]
FROM dbo.Loan l
INNER JOIN dbo.Member m ON m.member_id = l.member_id
INNER JOIN dbo.Book b ON b.book_id = l.book_id
INNER JOIN dbo.Author a ON a.author_id = b.author_id
WHERE l.loan_status = N'Aktif'
ORDER BY l.due_date;
GO


SELECT
    b.book_id AS [Kitap ID],
    b.title AS [Kitap Başlığı],
    b.available_copies AS [Mevcut Kopya],
    l.loan_id AS [Ödünç ID],
    l.loan_status AS [Ödünç Durumu],
    m.first_name + N' ' + m.last_name AS [Ödünç Alan Üye]
FROM dbo.Book b
LEFT JOIN dbo.Loan l ON l.book_id = b.book_id AND l.loan_status = N'Aktif'
LEFT JOIN dbo.Member m ON m.member_id = l.member_id
ORDER BY b.title;
GO

SELECT
    p.penalty_id AS [Ceza ID],
    p.amount AS [Ceza Tutarı],
    p.paid AS [Ödenme Durumu],
    l.loan_id AS [Ödünç ID],
    l.loan_status AS [Ödünç Durumu],
    m.first_name + N' ' + m.last_name AS [Üye Adı]
FROM dbo.Loan l
RIGHT JOIN dbo.Penalty p ON p.loan_id = l.loan_id
LEFT JOIN dbo.Member m ON m.member_id = l.member_id
ORDER BY p.amount DESC;
GO

SELECT
    b1.title AS [Kitap 1],
    b2.title AS [Kitap 2],
    b1.genre AS [Kitap Türü]
FROM dbo.Book b1
INNER JOIN dbo.Book b2 ON b1.genre = b2.genre AND b1.book_id < b2.book_id
ORDER BY b1.genre;
GO

SELECT
    mt.membership_type AS [Üyelik Tipi],
    g.genre AS [Kitap Türü]
FROM (SELECT DISTINCT membership_type FROM dbo.Member) mt
CROSS JOIN (SELECT DISTINCT genre FROM dbo.Book) g
ORDER BY mt.membership_type, g.genre;
GO


SELECT
    title AS [Kitap Adı],
    copy_count AS [Toplam Kopya],
    available_copies AS [Mevcut Kopya]
FROM dbo.Book
WHERE copy_count = (
    SELECT MAX(copy_count)
    FROM dbo.Book
);
GO

SELECT
    m.member_id AS [Üye ID],
    m.first_name AS [Ad],
    m.last_name AS [Soyad],
    m.email AS [E-Posta]
FROM dbo.Member m
WHERE EXISTS (
    SELECT 1
    FROM dbo.Loan l
    INNER JOIN dbo.Penalty p ON p.loan_id = l.loan_id
    WHERE l.member_id = m.member_id
      AND p.amount > 0
      AND p.paid = 0
);
GO

SELECT
    genre AS [Kitap Türü],
    COUNT(*) AS [Kitap Çeşidi Sayısı],
    SUM(copy_count) AS [Toplam Kopya],
    AVG(CAST(available_copies AS DECIMAL(10,2))) AS [Ortalama Müsait Kopya],
    MIN(publish_year) AS [En Eski Basım Yılı],
    MAX(publish_year) AS [En Yeni Basım Yılı]
FROM dbo.Book
GROUP BY genre
HAVING COUNT(*) >= 2
ORDER BY [Toplam Kopya] DESC;
GO

SELECT
    m.member_id AS [Üye ID],
    m.first_name + N' ' + m.last_name AS [Üye],
    COUNT(l.loan_id) AS [Ödünç Alma Sayısı],
    SUM(CASE WHEN p.paid = 0 THEN p.amount ELSE 0 END) AS [Toplam Ödenmemiş Ceza]
FROM dbo.Member m
LEFT JOIN dbo.Loan l ON l.member_id = m.member_id
LEFT JOIN dbo.Penalty p ON p.loan_id = l.loan_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(l.loan_id) > 0
ORDER BY [Toplam Ödenmemiş Ceza] DESC;
GO

SELECT
    CASE WHEN GROUPING(genre) = 1 THEN N'GENEL TOPLAM' ELSE genre END AS [Kitap Türü],
    CASE WHEN GROUPING(yazar) = 1 THEN N'ALT TOPLAM' ELSE yazar END AS [Yazar],
    COUNT(*) AS [Kitap Sayısı]
FROM (
    SELECT 
        b.genre,
        a.first_name + N' ' + a.last_name AS yazar
    FROM dbo.Book b
    INNER JOIN dbo.Author a ON a.author_id = b.author_id
) x
GROUP BY ROLLUP (genre, yazar)
ORDER BY GROUPING(genre), genre, GROUPING(yazar), yazar;
GO
