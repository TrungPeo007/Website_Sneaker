IF DB_ID(N'Poly_Sneaker') IS NULL
    CREATE DATABASE Poly_Sneaker;
GO
USE Poly_Sneaker;
GO

/* ---------- Drop old objects (safe to re-run) ---------- */
IF OBJECT_ID('vw_BestSellingProducts', 'V') IS NOT NULL DROP VIEW vw_BestSellingProducts;
IF OBJECT_ID('vw_ProductCards', 'V') IS NOT NULL DROP VIEW vw_ProductCards;
IF OBJECT_ID('sp_RegisterAccount', 'P') IS NOT NULL DROP PROCEDURE sp_RegisterAccount;
IF OBJECT_ID('ProductImages', 'U') IS NOT NULL DROP TABLE ProductImages;
IF OBJECT_ID('ProductDetails', 'U') IS NOT NULL DROP TABLE ProductDetails;
IF OBJECT_ID('Products', 'U') IS NOT NULL DROP TABLE Products;
IF OBJECT_ID('Categories', 'U') IS NOT NULL DROP TABLE Categories;
IF OBJECT_ID('Accounts', 'U') IS NOT NULL DROP TABLE Accounts;
GO

/* =====================================================
   1. ACCOUNTS (Admin + Customer)
   ===================================================== */
CREATE TABLE Accounts (
    AccountId  INT IDENTITY(1,1) PRIMARY KEY,
    Username   NVARCHAR(50)  NOT NULL,
    Password   NVARCHAR(255) NOT NULL,          -- store a hashed password (BCrypt), NOT plain text
    Email      NVARCHAR(100) NOT NULL,
    Role       VARCHAR(20)   NOT NULL DEFAULT 'CUSTOMER',
    IsActive   BIT           NOT NULL DEFAULT 1, -- 1: active, 0: locked
    CreatedAt  DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Accounts_Username UNIQUE (Username),
    CONSTRAINT UQ_Accounts_Email    UNIQUE (Email),
    CONSTRAINT CK_Accounts_Role     CHECK (Role IN ('ADMIN', 'CUSTOMER')),
    CONSTRAINT CK_Accounts_Email    CHECK (Email LIKE '%_@_%._%')
);
GO

-- Only ONE ADMIN account is allowed
CREATE UNIQUE INDEX UX_Accounts_SingleAdmin
    ON Accounts (Role)
    WHERE Role = 'ADMIN';
GO

/* =====================================================
   2. CATEGORIES
   - ParentId = NULL  -> root category (e.g. "Shoes")
   - ParentId = x     -> child category (e.g. "Nike Jordan", "Rigorer")
   - A product belongs to a child category; the detail page shows
     the chain "Shoes, Rigorer" by walking up ParentId.
   - The small label on the product card (NIKE JORDAN ...) = CategoryName
   ===================================================== */
CREATE TABLE Categories (
    CategoryId   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    ParentId     INT NULL,
    Description  NVARCHAR(500) NULL,
    IsActive     BIT      NOT NULL DEFAULT 1,   -- 1: visible, 0: hidden
    CreatedAt    DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentId) REFERENCES Categories(CategoryId),
    CONSTRAINT CK_Categories_NotSelfParent CHECK (ParentId IS NULL OR ParentId <> CategoryId)
);
GO

/* =====================================================
   3. PRODUCTS (data for the product CARD + shared detail info)
   Card shows: badge, image, category label, name, rating, sale price,
               original price (strikethrough), discount %
   ===================================================== */
CREATE TABLE Products (
    ProductId       INT IDENTITY(1,1) PRIMARY KEY,
    ProductName     NVARCHAR(200) NOT NULL,
    CategoryId      INT           NOT NULL,
    MainImageUrl    NVARCHAR(500) NULL,
    OriginalPrice   DECIMAL(18,0) NOT NULL,        -- strikethrough price
    SalePrice       DECIMAL(18,0) NOT NULL,        -- price customer pays
    DiscountPercent AS (
        CASE WHEN OriginalPrice > 0 AND SalePrice < OriginalPrice
             THEN CAST(ROUND((OriginalPrice - SalePrice) * 100.0 / OriginalPrice, 0) AS INT)
             ELSE 0 END
    ) PERSISTED,                                   -- "-30%" badge, calculated automatically
    Badge           NVARCHAR(30)  NULL,            -- manual label, e.g. N'YÊU THÍCH'
    AvgRating       DECIMAL(2,1)  NOT NULL DEFAULT 0, -- 4.8  (updated when reviews are added later)
    ReviewCount     INT           NOT NULL DEFAULT 0, -- (128)
    IsActive        BIT           NOT NULL DEFAULT 1, -- 1: on sale, 0: hidden
    CreatedAt       DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CK_Products_Price      CHECK (SalePrice >= 0 AND OriginalPrice >= SalePrice),
    CONSTRAINT CK_Products_AvgRating  CHECK (AvgRating BETWEEN 0 AND 5),
    CONSTRAINT CK_Products_ReviewCount CHECK (ReviewCount >= 0)
);
GO

/* =====================================================
   4. PRODUCT DETAILS = size variants of a product
   One row per size (39, 40, 41, 42, 42.5, 43, 45, 46 ...)
   ===================================================== */
CREATE TABLE ProductDetails (
    ProductDetailId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId       INT          NOT NULL,
    Size            DECIMAL(3,1) NOT NULL,         -- supports half sizes like 42.5
    Description     NVARCHAR(MAX) NULL,            -- product description shown on detail page, written by Admin
    StockQuantity   INT          NOT NULL DEFAULT 0,
    SoldQuantity    INT          NOT NULL DEFAULT 0, -- total purchased, used for best-seller stats
    IsActive        BIT          NOT NULL DEFAULT 1,

    CONSTRAINT FK_ProductDetails_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE,
    CONSTRAINT UQ_ProductDetails_Product_Size UNIQUE (ProductId, Size),
    CONSTRAINT CK_ProductDetails_Size  CHECK (Size > 0),
    CONSTRAINT CK_ProductDetails_Stock CHECK (StockQuantity >= 0),
    CONSTRAINT CK_ProductDetails_Sold  CHECK (SoldQuantity >= 0)
);
GO

/* =====================================================
   5. PRODUCT IMAGES (gallery on the detail page)
   ===================================================== */
CREATE TABLE ProductImages (
    ImageId   INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT           NOT NULL,
    ImageUrl  NVARCHAR(500) NOT NULL,
    SortOrder INT           NOT NULL DEFAULT 0,

    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE
);
GO

/* ---------- Indexes ---------- */
CREATE INDEX IX_Categories_ParentId      ON Categories(ParentId);
CREATE INDEX IX_Products_CategoryId      ON Products(CategoryId);
CREATE INDEX IX_ProductDetails_ProductId ON ProductDetails(ProductId) INCLUDE (SoldQuantity, StockQuantity);
CREATE INDEX IX_ProductImages_ProductId  ON ProductImages(ProductId);
GO

/* =====================================================
   6. ADMIN ACCOUNT (self-created, only one)
   Replace Password with a BCrypt hash generated by your app
   ===================================================== */
INSERT INTO Accounts (Username, Password, Email, Role)
VALUES (N'admin', N'REPLACE_WITH_BCRYPT_HASH', N'admin@polysneaker.com', 'ADMIN');
GO

/* =====================================================
   7. REGISTER PROCEDURE
   - Always creates role CUSTOMER (nobody can register as Admin)
   - Checks duplicate Username / Email
   ===================================================== */
CREATE PROCEDURE sp_RegisterAccount
    @Username NVARCHAR(50),
    @Password NVARCHAR(255),
    @Email    NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Accounts WHERE Username = @Username)
    BEGIN
        RAISERROR(N'Username already exists', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Accounts WHERE Email = @Email)
    BEGIN
        RAISERROR(N'Email is already in use', 16, 1);
        RETURN;
    END

    INSERT INTO Accounts (Username, Password, Email, Role)
    VALUES (@Username, @Password, @Email, 'CUSTOMER');

    SELECT SCOPE_IDENTITY() AS AccountId;
END
GO

/* =====================================================
   8. VIEWS
   ===================================================== */

-- Everything the product card needs, in one query
CREATE VIEW vw_ProductCards
AS
SELECT
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    c.CategoryName,          -- label above the product name
    p.Badge,
    p.AvgRating,
    p.ReviewCount,
    p.SalePrice,
    p.OriginalPrice,
    p.DiscountPercent
FROM Products p
JOIN Categories c ON c.CategoryId = p.CategoryId
WHERE p.IsActive = 1 AND c.IsActive = 1;
GO

-- Best-selling products = total SoldQuantity across all sizes
CREATE VIEW vw_BestSellingProducts
AS
SELECT
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    ISNULL(SUM(pd.SoldQuantity), 0) AS TotalSold
FROM Products p
LEFT JOIN ProductDetails pd ON pd.ProductId = p.ProductId
WHERE p.IsActive = 1
GROUP BY p.ProductId, p.ProductName, p.MainImageUrl;
GO

/* =====================================================
   9. SAMPLE DATA + TESTS
   ===================================================== */
INSERT INTO Categories (CategoryName, ParentId)
VALUES (N'Shoes', NULL);                                   -- Id 1 (root)

INSERT INTO Categories (CategoryName, ParentId)
VALUES (N'Nike Jordan', 1),                                -- Id 2
       (N'Adidas Running', 1),                             -- Id 3
       (N'New Balance', 1),                                -- Id 4
       (N'Nike Sportswear', 1),                            -- Id 5
       (N'Rigorer', 1);                                    -- Id 6

INSERT INTO Products (ProductName, CategoryId, MainImageUrl, OriginalPrice, SalePrice, Badge, AvgRating, ReviewCount)
VALUES (N'Air Jordan 1 High OG "Amber Gold"',   2, N'aj1-amber-gold.jpg',   4990000, 3890000, N'YÊU THÍCH', 4.8, 128),
       (N'Ultraboost Light Primeknit Beige',    3, N'ultraboost-beige.jpg', 4200000, 2950000, NULL,         5.0, 94),
       (N'New Balance 1906R Soft Vanilla',      4, N'nb-1906r.jpg',         4100000, 3450000, N'BÁN CHẠY',  4.7, 76),
       (N'Nike Dunk Low "Sunburst Amber"',      5, N'dunk-sunburst.jpg',    3500000, 2650000, NULL,         4.9, 210),
       (N'AR2 ''HBK''',                         6, N'ar2-hbk.jpg',          3500000, 2590000, NULL,         0,   0);

-- Size variants (Description is written by Admin for each product detail)
INSERT INTO ProductDetails (ProductId, Size, Description, StockQuantity)
SELECT p.ProductId, s.Size, N'Sample description written by Admin.', 10
FROM Products p
CROSS JOIN (VALUES (39), (40), (41), (42), (43)) AS s(Size)
WHERE p.ProductId BETWEEN 1 AND 4;

INSERT INTO ProductDetails (ProductId, Size, Description, StockQuantity)
SELECT 5, s.Size, N'Basketball shoe. Message the shop if you need more photos of your favorite pair.', 10
FROM (VALUES (39), (40), (41), (42), (42.5), (43), (45), (46)) AS s(Size);

-- Fake some sales to test best-seller stats
UPDATE ProductDetails SET SoldQuantity = 25 WHERE ProductId = 3 AND Size IN (40, 41);
UPDATE ProductDetails SET SoldQuantity = 10 WHERE ProductId = 1 AND Size = 42;
UPDATE ProductDetails SET SoldQuantity = 5  WHERE ProductId = 5 AND Size = 42.5;

-- Gallery images
INSERT INTO ProductImages (ProductId, ImageUrl, SortOrder)
VALUES (5, N'ar2-hbk-1.jpg', 1), (5, N'ar2-hbk-2.jpg', 2), (5, N'ar2-hbk-3.jpg', 3);

-- Test register
EXEC sp_RegisterAccount N'customer01', N'HASHED_PASSWORD', N'customer01@gmail.com';

-- 1) Product cards
SELECT * FROM vw_ProductCards;

-- 2) Product detail page: info + category chain (e.g. "Shoes, Rigorer")
SELECT p.ProductId, p.ProductName, p.OriginalPrice, p.SalePrice, p.DiscountPercent,
       parent.CategoryName AS ParentCategory, c.CategoryName AS Category
FROM Products p
JOIN Categories c ON c.CategoryId = p.CategoryId
LEFT JOIN Categories parent ON parent.CategoryId = c.ParentId
WHERE p.ProductId = 5;

-- 3) Product details: sizes + description
SELECT Size, Description, StockQuantity, IsActive
FROM ProductDetails
WHERE ProductId = 5
ORDER BY Size;

-- 4) Gallery of a product
SELECT ImageUrl FROM ProductImages WHERE ProductId = 5 ORDER BY SortOrder;

-- 5) Best sellers
SELECT TOP 5 * FROM vw_BestSellingProducts ORDER BY TotalSold DESC;
GO

select*from Accounts

USE Poly_Sneaker;

UPDATE Accounts
SET Password = (SELECT Password FROM Accounts WHERE Username = N'tam01')
WHERE Username = N'admin';

DELETE FROM Accounts WHERE Username = N'tam01';