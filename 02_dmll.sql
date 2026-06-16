USE KutuphaneDB;
GO

DELETE FROM dbo.Penalty;
DELETE FROM dbo.Loan;
DELETE FROM dbo.Book;
DELETE FROM dbo.Member;
DELETE FROM dbo.Shelf;
DELETE FROM dbo.Author;

DBCC CHECKIDENT ('dbo.Penalty', RESEED, 0);
DBCC CHECKIDENT ('dbo.Loan',    RESEED, 0);
DBCC CHECKIDENT ('dbo.Book',    RESEED, 0);
DBCC CHECKIDENT ('dbo.Member',  RESEED, 0);
DBCC CHECKIDENT ('dbo.Shelf',   RESEED, 0);
DBCC CHECKIDENT ('dbo.Author',  RESEED, 0);
GO

INSERT INTO dbo.Author (first_name, last_name, birth_year) VALUES
(N'George',     N'Orwell',         1903),
(N'Fyodor',     N'Dostoyevski',    1821),
(N'Franz',      N'Kafka',          1883),
(N'Sabahattin', N'Ali',            1907),
(N'Orhan',      N'Pamuk',          1952),
(N'Lev',        N'Tolstoy',        1828),
(N'Stefan',     N'Zweig',          1881),
(N'Gabriel',    N'García Márquez', 1927),
(N'Albert',     N'Camus',          1913),
(N'Victor',     N'Hugo',           1802);
GO

INSERT INTO dbo.Shelf (shelf_code, section, floor_no, capacity) VALUES
(N'A01', N'Roman',       1, 100),
(N'A02', N'Roman',       1, 100),
(N'B01', N'Psikoloji',   1,  50),
(N'B02', N'Psikoloji',   1,  50),
(N'C01', N'Tarih',       2,  75),
(N'C02', N'Tarih',       2,  75),
(N'D01', N'Felsefe',     2,  40),
(N'E01', N'Bilim Kurgu', 3,  60),
(N'F01', N'Polisiye',    3,  60),
(N'G01', N'Siyaset',     3,  50);
GO

INSERT INTO dbo.Book (isbn, title, author_id, shelf_id, publish_year, genre, copy_count, available_copies) VALUES
('9789750718533', N'1984',                  1,  8, 1949, N'Bilim Kurgu', 5, 4),
('9786053320015', N'Suç ve Ceza',           2,  1, 1866, N'Roman',       4, 3),
('9789750719991', N'Dönüşüm',              3,  1, 1915, N'Roman',       6, 6),
('9789750738602', N'Kürk Mantolu Madonna',  4,  1, 1943, N'Roman',       8, 7),
('9789750719380', N'Benim Adım Kırmızı',    5,  5, 1998, N'Tarih',       3, 2),
('9786052981231', N'Anna Karenina',         6,  1, 1877, N'Roman',       4, 4),
('9786053323443', N'Satranç',              7,  3, 1942, N'Psikoloji',  10, 9),
('9789750721731', N'Yüzyıllık Yalnızlık',   8,  1, 1967, N'Roman',       5, 5),
('9789750724282', N'Yabancı',              9,  7, 1942, N'Felsefe',     4, 3),
('9786051856547', N'Sefiller',             10,  1, 1862, N'Roman',       3, 2);
GO

INSERT INTO dbo.Member (national_id, first_name, last_name, email, membership_type, is_active) VALUES
('10000000001', N'Melissa', N'Vargas',   'melissa.vargas@mail.com', N'Premium',  1),
('10000000002', N'Ebrar',   N'Karakurt', 'ebrar.karakurt@mail.com', N'Premium',  1),
('10000000003', N'Zehra',   N'Güneş',   'zehra.gunes@mail.com',    N'Standart', 1),
('10000000004', N'Eda',     N'Erdem',   'eda.erdem@mail.com',      N'Standart', 1),
('10000000005', N'Hande',   N'Baladın', 'hande.baladin@mail.com',  N'Standart', 1),
('10000000006', N'Cansu',   N'Özbay',   'cansu.ozbay@mail.com',    N'Öğrenci',  1),
('10000000007', N'Aslı',    N'Kalaç',   'asli.kalac@mail.com',     N'Standart', 1),
('10000000008', N'Simge',   N'Aköz',    'simge.akoz@mail.com',     N'Premium',  1),
('10000000009', N'İlkin',   N'Aydın',   'ilkin.aydin@mail.com',    N'Öğrenci',  1),
('10000000010', N'İrem',    N'Ölçer',   'iremolcer888@gmail.com',  N'Öğrenci',  1);
GO

INSERT INTO dbo.Loan (member_id, book_id, loan_date, due_date, return_date, loan_status) VALUES
(1,  20, '2026-05-01', '2026-05-15', '2026-05-14', N'İade'),
(2,  21, '2026-05-02', '2026-05-16',  NULL,         N'Gecikmiş'),
(3,  22, '2026-05-05', '2026-05-19', '2026-05-18', N'İade'),
(4,  23, '2026-05-10', '2026-05-24',  NULL,         N'Aktif'),
(5,  24, '2026-05-12', '2026-05-26', '2026-05-25', N'İade'),
(6,  25, '2026-05-15', '2026-05-29',  NULL,         N'Gecikmiş'),
(7, 26, '2026-05-16', '2026-05-30',  NULL,         N'Aktif'),
(8,  27, '2026-05-18', '2026-06-01',  NULL,         N'Aktif'),
(9,  28, '2026-05-20', '2026-06-03',  NULL,         N'Aktif'),
(10, 29, '2026-05-22', '2026-06-05',  NULL,         N'Aktif');
GO

INSERT INTO dbo.Penalty (loan_id, amount, paid,created_at,reason) VALUES
(2,  0.00, 1,'2005-01-13','kayıp'),
(3, 45.50, 0,'2005-02-14','kayıp'),
(4,  0.00, 1,'2005-03-12','kayıp'),
(5, 90.00, 0,'2005-04-15','kayıp'),
(6,  0.00, 1,'2005-06-11','çalınmış'),
(7, 20.00, 0,'2005-08-18','çalınmış'),
(8,  0.00, 0,'2005-09-13','çalınmış'),
(9, 75.00, 0,'2005-10-17','sınav haftası'),
(10,  0.00, 0,'2005-12-12','sınav haftası'),
(11,10.00, 0,'2005-09-19','sınav haftası');
GO

SELECT
    genre                 AS [Kitap Türü],
    COUNT(*)              AS [Toplam Kitap Çeşidi],
    SUM(copy_count)     AS [Kütüphanedeki Toplam Kopya],
    AVG(available_copies) AS [Ortalama Uygun Kopya],
    MIN(publish_year)     AS [En Eski Basım Yılı],
    MAX(publish_year)     AS [En Yeni Basım Yılı]
FROM dbo.Book
GROUP BY genre;
GO
