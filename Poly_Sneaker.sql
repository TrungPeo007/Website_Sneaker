/* =====================================================================
   POLY_SNEAKER - FULL DATABASE SCRIPT v2 (SQL Server 2016 SP1+)
   - Safe to re-run: tables are created only if missing, so existing
     accounts / products / orders are NEVER dropped.
   - Seed data is idempotent (no duplicates when run again).
   - Wipe everything: uncomment the RESET block right below first.
   - Run in SSMS, or sqlcmd with -I (needed for the filtered index).

   Default logins after running:
     admin       / admin123      (plain text on purpose, owner-only account)
     customer01  / customer123   (BCrypt hash)
   ===================================================================== */
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF DB_ID(N'Poly_Sneaker') IS NULL
    CREATE DATABASE Poly_Sneaker;
GO
USE Poly_Sneaker;
GO

/* ---------------------------------------------------------------------
   OPTIONAL RESET (uncomment ONLY when you want to wipe everything)
   ---------------------------------------------------------------------
IF OBJECT_ID('dbo.vw_LookbookDetail', 'V')      IS NOT NULL DROP VIEW dbo.vw_LookbookDetail;
IF OBJECT_ID('dbo.vw_BestSellingProducts', 'V') IS NOT NULL DROP VIEW dbo.vw_BestSellingProducts;
IF OBJECT_ID('dbo.vw_ProductCards', 'V')        IS NOT NULL DROP VIEW dbo.vw_ProductCards;
IF OBJECT_ID('dbo.sp_RegisterAccount', 'P')     IS NOT NULL DROP PROCEDURE dbo.sp_RegisterAccount;
IF OBJECT_ID('dbo.Reviews', 'U')                IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.OrderDetails', 'U')           IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U')                 IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.CartItems', 'U')              IS NOT NULL DROP TABLE dbo.CartItems;
IF OBJECT_ID('dbo.LookbookItems', 'U')          IS NOT NULL DROP TABLE dbo.LookbookItems;
IF OBJECT_ID('dbo.Lookbooks', 'U')              IS NOT NULL DROP TABLE dbo.Lookbooks;
IF OBJECT_ID('dbo.ProductImages', 'U')          IS NOT NULL DROP TABLE dbo.ProductImages;
IF OBJECT_ID('dbo.ProductDetails', 'U')         IS NOT NULL DROP TABLE dbo.ProductDetails;
IF OBJECT_ID('dbo.Products', 'U')               IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U')             IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Accounts', 'U')               IS NOT NULL DROP TABLE dbo.Accounts;
GO
*/

/* =====================================================
   1. ACCOUNTS (Admin + Customer)
   ===================================================== */
IF OBJECT_ID('dbo.Accounts', 'U') IS NULL
CREATE TABLE dbo.Accounts (
    AccountId  INT IDENTITY(1,1) PRIMARY KEY,
    Username   NVARCHAR(50)  NOT NULL,
    Password   NVARCHAR(255) NOT NULL,           -- CUSTOMER: BCrypt hash | ADMIN: plain text allowed
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

-- Profile columns for checkout (nullable, so the current JPA entity keeps working)
IF COL_LENGTH('dbo.Accounts', 'FullName') IS NULL ALTER TABLE dbo.Accounts ADD FullName NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Accounts', 'Phone')    IS NULL ALTER TABLE dbo.Accounts ADD Phone    VARCHAR(20)   NULL;
IF COL_LENGTH('dbo.Accounts', 'Address')  IS NULL ALTER TABLE dbo.Accounts ADD Address  NVARCHAR(300) NULL;
GO

-- Only ONE ADMIN account is allowed
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_Accounts_SingleAdmin' AND object_id = OBJECT_ID('dbo.Accounts'))
    CREATE UNIQUE INDEX UX_Accounts_SingleAdmin
        ON dbo.Accounts (Role)
        WHERE Role = 'ADMIN';
GO

/* =====================================================
   2. CATEGORIES
   - ParentId = NULL -> root ("Shoes")
   - ParentId = x    -> child ("Nike Jordan", "Rigorer"...)
   ===================================================== */
IF OBJECT_ID('dbo.Categories', 'U') IS NULL
CREATE TABLE dbo.Categories (
    CategoryId   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    ParentId     INT NULL,
    Description  NVARCHAR(500) NULL,
    IsActive     BIT      NOT NULL DEFAULT 1,
    CreatedAt    DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Categories_CategoryName UNIQUE (CategoryName),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT CK_Categories_NotSelfParent CHECK (ParentId IS NULL OR ParentId <> CategoryId)
);
GO

/* =====================================================
   3. PRODUCTS
   ===================================================== */
IF OBJECT_ID('dbo.Products', 'U') IS NULL
CREATE TABLE dbo.Products (
    ProductId       INT IDENTITY(1,1) PRIMARY KEY,
    ProductName     NVARCHAR(200) NOT NULL,
    CategoryId      INT           NOT NULL,
    MainImageUrl    NVARCHAR(500) NULL,
    OriginalPrice   DECIMAL(18,0) NOT NULL,           -- strikethrough price
    SalePrice       DECIMAL(18,0) NOT NULL,           -- price customer pays
    DiscountPercent AS (
        CASE WHEN OriginalPrice > 0 AND SalePrice < OriginalPrice
             THEN CAST(ROUND((OriginalPrice - SalePrice) * 100.0 / OriginalPrice, 0) AS INT)
             ELSE 0 END
    ) PERSISTED,                                      -- "-30%" badge, auto calculated
    Badge           NVARCHAR(30)  NULL,               -- manual label, e.g. N'YÊU THÍCH'
    AvgRating       DECIMAL(2,1)  NOT NULL DEFAULT 0,
    ReviewCount     INT           NOT NULL DEFAULT 0,
    IsActive        BIT           NOT NULL DEFAULT 1,
    CreatedAt       DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Products_ProductName  UNIQUE (ProductName),
    CONSTRAINT FK_Products_Categories   FOREIGN KEY (CategoryId) REFERENCES dbo.Categories(CategoryId),
    CONSTRAINT CK_Products_Price        CHECK (SalePrice >= 0 AND OriginalPrice >= SalePrice),
    CONSTRAINT CK_Products_AvgRating    CHECK (AvgRating BETWEEN 0 AND 5),
    CONSTRAINT CK_Products_ReviewCount  CHECK (ReviewCount >= 0)
);
GO

/* =====================================================
   4. PRODUCT DETAILS = size variants (one row per size)
   ===================================================== */
IF OBJECT_ID('dbo.ProductDetails', 'U') IS NULL
CREATE TABLE dbo.ProductDetails (
    ProductDetailId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId       INT           NOT NULL,
    Size            DECIMAL(3,1)  NOT NULL,          -- supports 42.5
    Description     NVARCHAR(MAX) NULL,
    StockQuantity   INT           NOT NULL DEFAULT 0,
    SoldQuantity    INT           NOT NULL DEFAULT 0,
    IsActive        BIT           NOT NULL DEFAULT 1,

    CONSTRAINT FK_ProductDetails_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId) ON DELETE CASCADE,
    CONSTRAINT UQ_ProductDetails_Product_Size UNIQUE (ProductId, Size),
    CONSTRAINT CK_ProductDetails_Size  CHECK (Size > 0),
    CONSTRAINT CK_ProductDetails_Stock CHECK (StockQuantity >= 0),
    CONSTRAINT CK_ProductDetails_Sold  CHECK (SoldQuantity >= 0)
);
GO

/* =====================================================
   5. PRODUCT IMAGES (gallery on the detail page)
   ===================================================== */
IF OBJECT_ID('dbo.ProductImages', 'U') IS NULL
CREATE TABLE dbo.ProductImages (
    ImageId   INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT           NOT NULL,
    ImageUrl  NVARCHAR(500) NOT NULL,
    SortOrder INT           NOT NULL DEFAULT 0,

    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId) ON DELETE CASCADE,
    CONSTRAINT UQ_ProductImages_Product_Url UNIQUE (ProductId, ImageUrl)
);
GO

/* =====================================================
   6. LOOKBOOK
   - Lookbooks     : one collection / outfit story
   - LookbookItems : photos, each can be tagged with a product
   ===================================================== */
IF OBJECT_ID('dbo.Lookbooks', 'U') IS NULL
CREATE TABLE dbo.Lookbooks (
    LookbookId    INT IDENTITY(1,1) PRIMARY KEY,
    Title         NVARCHAR(150)  NOT NULL,
    Description   NVARCHAR(1000) NULL,
    CoverImageUrl NVARCHAR(500)  NULL,
    SortOrder     INT      NOT NULL DEFAULT 0,
    IsActive      BIT      NOT NULL DEFAULT 1,
    CreatedAt     DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Lookbooks_Title UNIQUE (Title)
);
GO

IF OBJECT_ID('dbo.LookbookItems', 'U') IS NULL
CREATE TABLE dbo.LookbookItems (
    LookbookItemId INT IDENTITY(1,1) PRIMARY KEY,
    LookbookId     INT           NOT NULL,
    ProductId      INT           NULL,               -- product tagged in the photo
    ImageUrl       NVARCHAR(500) NOT NULL,
    Caption        NVARCHAR(300) NULL,
    SortOrder      INT           NOT NULL DEFAULT 0,

    CONSTRAINT FK_LookbookItems_Lookbooks FOREIGN KEY (LookbookId) REFERENCES dbo.Lookbooks(LookbookId) ON DELETE CASCADE,
    CONSTRAINT FK_LookbookItems_Products  FOREIGN KEY (ProductId)  REFERENCES dbo.Products(ProductId)   ON DELETE SET NULL,
    CONSTRAINT UQ_LookbookItems_Lookbook_Image UNIQUE (LookbookId, ImageUrl)
);
GO

/* =====================================================
   7. CART  (one row = one size of a product in a customer's cart)
   ===================================================== */
IF OBJECT_ID('dbo.CartItems', 'U') IS NULL
CREATE TABLE dbo.CartItems (
    CartItemId      INT IDENTITY(1,1) PRIMARY KEY,
    AccountId       INT NOT NULL,
    ProductDetailId INT NOT NULL,
    Quantity        INT NOT NULL DEFAULT 1,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_CartItems_Accounts       FOREIGN KEY (AccountId)       REFERENCES dbo.Accounts(AccountId)             ON DELETE CASCADE,
    CONSTRAINT FK_CartItems_ProductDetails FOREIGN KEY (ProductDetailId) REFERENCES dbo.ProductDetails(ProductDetailId) ON DELETE CASCADE,
    CONSTRAINT UQ_CartItems_Account_Detail UNIQUE (AccountId, ProductDetailId),
    CONSTRAINT CK_CartItems_Quantity       CHECK (Quantity > 0)
);
GO

/* =====================================================
   8. ORDERS + ORDER DETAILS
   - OrderDetails keeps a SNAPSHOT of name/size/price at purchase time,
     so later price or name changes never alter old orders.
   - No cascade delete: an account/variant with orders cannot be hard-deleted
     (use IsActive = 0 instead).
   ===================================================== */
IF OBJECT_ID('dbo.Orders', 'U') IS NULL
CREATE TABLE dbo.Orders (
    OrderId       INT IDENTITY(1,1) PRIMARY KEY,
    AccountId     INT           NOT NULL,
    ReceiverName  NVARCHAR(100) NOT NULL,
    Phone         VARCHAR(20)   NOT NULL,
    Address       NVARCHAR(300) NOT NULL,
    Note          NVARCHAR(500) NULL,
    PaymentMethod VARCHAR(20)   NOT NULL DEFAULT 'COD',
    Status        VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    TotalAmount   DECIMAL(18,0) NOT NULL DEFAULT 0,
    CreatedAt     DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt     DATETIME      NULL,

    CONSTRAINT FK_Orders_Accounts  FOREIGN KEY (AccountId) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT CK_Orders_Payment   CHECK (PaymentMethod IN ('COD', 'BANK')),
    CONSTRAINT CK_Orders_Status    CHECK (Status IN ('PENDING', 'CONFIRMED', 'SHIPPING', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT CK_Orders_Total     CHECK (TotalAmount >= 0)
);
GO

IF OBJECT_ID('dbo.OrderDetails', 'U') IS NULL
CREATE TABLE dbo.OrderDetails (
    OrderDetailId   INT IDENTITY(1,1) PRIMARY KEY,
    OrderId         INT           NOT NULL,
    ProductDetailId INT           NOT NULL,
    ProductName     NVARCHAR(200) NOT NULL,          -- snapshot
    Size            DECIMAL(3,1)  NOT NULL,          -- snapshot
    UnitPrice       DECIMAL(18,0) NOT NULL,          -- snapshot of SalePrice
    Quantity        INT           NOT NULL,

    CONSTRAINT FK_OrderDetails_Orders         FOREIGN KEY (OrderId)         REFERENCES dbo.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderDetails_ProductDetails FOREIGN KEY (ProductDetailId) REFERENCES dbo.ProductDetails(ProductDetailId),
    CONSTRAINT CK_OrderDetails_Quantity       CHECK (Quantity > 0),
    CONSTRAINT CK_OrderDetails_UnitPrice      CHECK (UnitPrice >= 0)
);
GO

/* =====================================================
   9. REVIEWS (one review per customer per product)
   After insert/update/delete, the app should refresh
   Products.AvgRating and Products.ReviewCount.
   ===================================================== */
IF OBJECT_ID('dbo.Reviews', 'U') IS NULL
CREATE TABLE dbo.Reviews (
    ReviewId  INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT           NOT NULL,
    AccountId INT           NOT NULL,
    Rating    TINYINT       NOT NULL,
    Comment   NVARCHAR(1000) NULL,
    CreatedAt DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Reviews_Products FOREIGN KEY (ProductId) REFERENCES dbo.Products(ProductId) ON DELETE CASCADE,
    CONSTRAINT FK_Reviews_Accounts FOREIGN KEY (AccountId) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT UQ_Reviews_Product_Account UNIQUE (ProductId, AccountId),
    CONSTRAINT CK_Reviews_Rating CHECK (Rating BETWEEN 1 AND 5)
);
GO

/* =====================================================
   10. INDEXES
   ===================================================== */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Categories_ParentId' AND object_id = OBJECT_ID('dbo.Categories'))
    CREATE INDEX IX_Categories_ParentId ON dbo.Categories(ParentId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Products_CategoryId' AND object_id = OBJECT_ID('dbo.Products'))
    CREATE INDEX IX_Products_CategoryId ON dbo.Products(CategoryId) INCLUDE (IsActive);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductDetails_ProductId' AND object_id = OBJECT_ID('dbo.ProductDetails'))
    CREATE INDEX IX_ProductDetails_ProductId ON dbo.ProductDetails(ProductId) INCLUDE (SoldQuantity, StockQuantity);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ProductImages_ProductId' AND object_id = OBJECT_ID('dbo.ProductImages'))
    CREATE INDEX IX_ProductImages_ProductId ON dbo.ProductImages(ProductId, SortOrder);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LookbookItems_LookbookId' AND object_id = OBJECT_ID('dbo.LookbookItems'))
    CREATE INDEX IX_LookbookItems_LookbookId ON dbo.LookbookItems(LookbookId, SortOrder);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LookbookItems_ProductId' AND object_id = OBJECT_ID('dbo.LookbookItems'))
    CREATE INDEX IX_LookbookItems_ProductId ON dbo.LookbookItems(ProductId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CartItems_AccountId' AND object_id = OBJECT_ID('dbo.CartItems'))
    CREATE INDEX IX_CartItems_AccountId ON dbo.CartItems(AccountId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_AccountId' AND object_id = OBJECT_ID('dbo.Orders'))
    CREATE INDEX IX_Orders_AccountId ON dbo.Orders(AccountId, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Status' AND object_id = OBJECT_ID('dbo.Orders'))
    CREATE INDEX IX_Orders_Status ON dbo.Orders(Status);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderDetails_OrderId' AND object_id = OBJECT_ID('dbo.OrderDetails'))
    CREATE INDEX IX_OrderDetails_OrderId ON dbo.OrderDetails(OrderId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_OrderDetails_ProductDetailId' AND object_id = OBJECT_ID('dbo.OrderDetails'))
    CREATE INDEX IX_OrderDetails_ProductDetailId ON dbo.OrderDetails(ProductDetailId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Reviews_ProductId' AND object_id = OBJECT_ID('dbo.Reviews'))
    CREATE INDEX IX_Reviews_ProductId ON dbo.Reviews(ProductId);
GO

/* =====================================================
   11. ACCOUNTS SEED
   - ADMIN: plain-text password by design (owner-only account).
     * No admin yet            -> create with password admin123
     * Admin still has the old placeholder -> set to admin123
     * Admin already has a real password / BCrypt hash -> left untouched
   - customer01: BCrypt hash of "customer123" (for testing login/cart/order)
   ===================================================== */
IF NOT EXISTS (SELECT 1 FROM dbo.Accounts WHERE Role = 'ADMIN')
    INSERT INTO dbo.Accounts (Username, Password, Email, Role)
    VALUES (N'admin', N'admin123', N'admin@polysneaker.com', 'ADMIN');
ELSE
    UPDATE dbo.Accounts
    SET Password = N'admin123'
    WHERE Role = 'ADMIN' AND Password = N'REPLACE_WITH_BCRYPT_HASH';

IF NOT EXISTS (SELECT 1 FROM dbo.Accounts WHERE Username = N'customer01')
    INSERT INTO dbo.Accounts (Username, Password, Email, Role, FullName, Phone, Address)
    VALUES (N'customer01',
            N'$2a$10$mZJLuKZQ51vG5h5BkmtfGuAGJ6Na.Heu8tcKC8Ptb//IL7.5NTmTC',
            N'customer01@gmail.com', 'CUSTOMER',
            N'Khách Hàng Mẫu', '0900000001', N'Thành phố Hồ Chí Minh');
GO

/* =====================================================
   12. REGISTER PROCEDURE
   (the Spring app registers through AccountService; this procedure
   is kept for manual use / testing and expects an already-hashed password)
   ===================================================== */
CREATE OR ALTER PROCEDURE dbo.sp_RegisterAccount
    @Username NVARCHAR(50),
    @Password NVARCHAR(255),
    @Email    NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Username = @Username)
        THROW 50001, N'Username already exists', 1;

    IF EXISTS (SELECT 1 FROM dbo.Accounts WHERE Email = @Email)
        THROW 50002, N'Email is already in use', 1;

    INSERT INTO dbo.Accounts (Username, Password, Email, Role)
    VALUES (@Username, @Password, @Email, 'CUSTOMER');

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS AccountId;
END
GO

/* =====================================================
   13. VIEWS
   ===================================================== */

-- Everything the product card needs, in one query
CREATE OR ALTER VIEW dbo.vw_ProductCards
AS
SELECT
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    c.CategoryName,
    p.Badge,
    p.AvgRating,
    p.ReviewCount,
    p.SalePrice,
    p.OriginalPrice,
    p.DiscountPercent
FROM dbo.Products AS p
JOIN dbo.Categories AS c ON c.CategoryId = p.CategoryId
WHERE p.IsActive = 1 AND c.IsActive = 1;
GO

-- Best sellers = total SoldQuantity across all sizes
CREATE OR ALTER VIEW dbo.vw_BestSellingProducts
AS
SELECT
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    ISNULL(SUM(pd.SoldQuantity), 0) AS TotalSold
FROM dbo.Products AS p
LEFT JOIN dbo.ProductDetails AS pd ON pd.ProductId = p.ProductId
WHERE p.IsActive = 1
GROUP BY p.ProductId, p.ProductName, p.MainImageUrl;
GO

-- Lookbook page: each photo with its tagged product (if any)
CREATE OR ALTER VIEW dbo.vw_LookbookDetail
AS
SELECT
    l.LookbookId,
    l.Title,
    l.Description,
    l.CoverImageUrl,
    l.SortOrder       AS LookbookSortOrder,
    li.LookbookItemId,
    li.ImageUrl,
    li.Caption,
    li.SortOrder      AS ItemSortOrder,
    p.ProductId,
    p.ProductName,
    p.SalePrice,
    p.OriginalPrice,
    p.DiscountPercent
FROM dbo.Lookbooks AS l
LEFT JOIN dbo.LookbookItems AS li ON li.LookbookId = l.LookbookId
LEFT JOIN dbo.Products      AS p  ON p.ProductId   = li.ProductId AND p.IsActive = 1
WHERE l.IsActive = 1;
GO

-- Cart page: items with live price, stock and line total
CREATE OR ALTER VIEW dbo.vw_CartDetail
AS
SELECT
    ci.CartItemId,
    ci.AccountId,
    ci.ProductDetailId,
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    pd.Size,
    pd.StockQuantity,
    p.SalePrice,
    ci.Quantity,
    p.SalePrice * ci.Quantity AS LineTotal
FROM dbo.CartItems AS ci
JOIN dbo.ProductDetails AS pd ON pd.ProductDetailId = ci.ProductDetailId
JOIN dbo.Products       AS p  ON p.ProductId        = pd.ProductId;
GO

-- Order history: one row per order with item count
CREATE OR ALTER VIEW dbo.vw_OrderSummary
AS
SELECT
    o.OrderId,
    o.AccountId,
    a.Username,
    o.ReceiverName,
    o.Phone,
    o.Address,
    o.PaymentMethod,
    o.Status,
    o.TotalAmount,
    o.CreatedAt,
    ISNULL(SUM(od.Quantity), 0) AS TotalItems
FROM dbo.Orders AS o
JOIN dbo.Accounts AS a ON a.AccountId = o.AccountId
LEFT JOIN dbo.OrderDetails AS od ON od.OrderId = o.OrderId
GROUP BY o.OrderId, o.AccountId, a.Username, o.ReceiverName, o.Phone, o.Address,
         o.PaymentMethod, o.Status, o.TotalAmount, o.CreatedAt;
GO

/* =====================================================
   14. CATALOG SEED (idempotent: running again adds no duplicates)
   ===================================================== */
IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Shoes')
    INSERT INTO dbo.Categories (CategoryName, ParentId) VALUES (N'Shoes', NULL);
GO

DECLARE @ShoesCategoryId INT = (SELECT TOP 1 CategoryId FROM dbo.Categories WHERE CategoryName = N'Shoes');

IF @ShoesCategoryId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Nike Jordan')
        INSERT INTO dbo.Categories (CategoryName, ParentId) VALUES (N'Nike Jordan', @ShoesCategoryId);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Adidas Running')
        INSERT INTO dbo.Categories (CategoryName, ParentId) VALUES (N'Adidas Running', @ShoesCategoryId);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'New Balance')
        INSERT INTO dbo.Categories (CategoryName, ParentId) VALUES (N'New Balance', @ShoesCategoryId);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Nike Sportswear')
        INSERT INTO dbo.Categories (CategoryName, ParentId) VALUES (N'Nike Sportswear', @ShoesCategoryId);
    IF NOT EXISTS (SELECT 1 FROM dbo.Categories WHERE CategoryName = N'Rigorer')
        INSERT INTO dbo.Categories (CategoryName, ParentId) VALUES (N'Rigorer', @ShoesCategoryId);
END;
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductName = N'Air Jordan 1 High OG "Amber Gold"')
    INSERT INTO dbo.Products (ProductName, CategoryId, MainImageUrl, OriginalPrice, SalePrice, Badge, AvgRating, ReviewCount)
    SELECT N'Air Jordan 1 High OG "Amber Gold"', CategoryId, N'aj1-amber-gold.jpg', 4990000, 3890000, N'YÊU THÍCH', 4.8, 128
    FROM dbo.Categories WHERE CategoryName = N'Nike Jordan';

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductName = N'Ultraboost Light Primeknit Beige')
    INSERT INTO dbo.Products (ProductName, CategoryId, MainImageUrl, OriginalPrice, SalePrice, Badge, AvgRating, ReviewCount)
    SELECT N'Ultraboost Light Primeknit Beige', CategoryId, N'ultraboost-beige.jpg', 4200000, 2950000, NULL, 5.0, 94
    FROM dbo.Categories WHERE CategoryName = N'Adidas Running';

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductName = N'New Balance 1906R Soft Vanilla')
    INSERT INTO dbo.Products (ProductName, CategoryId, MainImageUrl, OriginalPrice, SalePrice, Badge, AvgRating, ReviewCount)
    SELECT N'New Balance 1906R Soft Vanilla', CategoryId, N'nb-1906r.jpg', 4100000, 3450000, N'BÁN CHẠY', 4.7, 76
    FROM dbo.Categories WHERE CategoryName = N'New Balance';

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductName = N'Nike Dunk Low "Sunburst Amber"')
    INSERT INTO dbo.Products (ProductName, CategoryId, MainImageUrl, OriginalPrice, SalePrice, Badge, AvgRating, ReviewCount)
    SELECT N'Nike Dunk Low "Sunburst Amber"', CategoryId, N'dunk-sunburst.jpg', 3500000, 2650000, NULL, 4.9, 210
    FROM dbo.Categories WHERE CategoryName = N'Nike Sportswear';

IF NOT EXISTS (SELECT 1 FROM dbo.Products WHERE ProductName = N'AR2 ''HBK''')
    INSERT INTO dbo.Products (ProductName, CategoryId, MainImageUrl, OriginalPrice, SalePrice, Badge, AvgRating, ReviewCount)
    SELECT N'AR2 ''HBK''', CategoryId, N'ar2-hbk.jpg', 3500000, 2590000, NULL, 0, 0
    FROM dbo.Categories WHERE CategoryName = N'Rigorer';
GO

/* Size variants for demo products */
INSERT INTO dbo.ProductDetails (ProductId, Size, Description, StockQuantity)
SELECT p.ProductId, s.Size, N'Sample description written by Admin.', 10
FROM dbo.Products p
CROSS JOIN (VALUES (CAST(39.0 AS DECIMAL(3,1))), (40.0), (41.0), (42.0), (43.0)) AS s(Size)
WHERE p.ProductName IN (
    N'Air Jordan 1 High OG "Amber Gold"',
    N'Ultraboost Light Primeknit Beige',
    N'New Balance 1906R Soft Vanilla',
    N'Nike Dunk Low "Sunburst Amber"'
)
AND NOT EXISTS (
    SELECT 1 FROM dbo.ProductDetails pd WHERE pd.ProductId = p.ProductId AND pd.Size = s.Size
);

INSERT INTO dbo.ProductDetails (ProductId, Size, Description, StockQuantity)
SELECT p.ProductId, s.Size, N'Basketball shoe. Message the shop if you need more photos of your favorite pair.', 10
FROM dbo.Products p
CROSS JOIN (VALUES (CAST(39.0 AS DECIMAL(3,1))), (40.0), (41.0), (42.0), (42.5), (43.0), (45.0), (46.0)) AS s(Size)
WHERE p.ProductName = N'AR2 ''HBK'''
AND NOT EXISTS (
    SELECT 1 FROM dbo.ProductDetails pd WHERE pd.ProductId = p.ProductId AND pd.Size = s.Size
);
GO

/* Demo sales: only set when the current value is zero (keeps real sales data) */
UPDATE pd SET SoldQuantity = 25
FROM dbo.ProductDetails pd JOIN dbo.Products p ON p.ProductId = pd.ProductId
WHERE p.ProductName = N'New Balance 1906R Soft Vanilla' AND pd.Size IN (40, 41) AND pd.SoldQuantity = 0;

UPDATE pd SET SoldQuantity = 10
FROM dbo.ProductDetails pd JOIN dbo.Products p ON p.ProductId = pd.ProductId
WHERE p.ProductName = N'Air Jordan 1 High OG "Amber Gold"' AND pd.Size = 42 AND pd.SoldQuantity = 0;

UPDATE pd SET SoldQuantity = 5
FROM dbo.ProductDetails pd JOIN dbo.Products p ON p.ProductId = pd.ProductId
WHERE p.ProductName = N'AR2 ''HBK''' AND pd.Size = 42.5 AND pd.SoldQuantity = 0;
GO

/* Demo gallery images */
INSERT INTO dbo.ProductImages (ProductId, ImageUrl, SortOrder)
SELECT p.ProductId, v.ImageUrl, v.SortOrder
FROM dbo.Products p
CROSS JOIN (VALUES (N'ar2-hbk-1.jpg', 1), (N'ar2-hbk-2.jpg', 2), (N'ar2-hbk-3.jpg', 3)) AS v(ImageUrl, SortOrder)
WHERE p.ProductName = N'AR2 ''HBK'''
AND NOT EXISTS (SELECT 1 FROM dbo.ProductImages pi WHERE pi.ProductId = p.ProductId AND pi.ImageUrl = v.ImageUrl);
GO

/* Demo lookbooks */
IF NOT EXISTS (SELECT 1 FROM dbo.Lookbooks WHERE Title = N'Amber Street')
    INSERT INTO dbo.Lookbooks (Title, Description, CoverImageUrl, SortOrder)
    VALUES (N'Amber Street', N'Phối đồ đường phố với tông cam hổ phách.', N'lookbook-amber-cover.jpg', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Lookbooks WHERE Title = N'Daily Run')
    INSERT INTO dbo.Lookbooks (Title, Description, CoverImageUrl, SortOrder)
    VALUES (N'Daily Run', N'Nhẹ, êm và gọn cho những buổi chạy mỗi ngày.', N'lookbook-run-cover.jpg', 2);
GO

INSERT INTO dbo.LookbookItems (LookbookId, ProductId, ImageUrl, Caption, SortOrder)
SELECT l.LookbookId, p.ProductId, v.ImageUrl, v.Caption, v.SortOrder
FROM (VALUES
    (N'Amber Street', N'Air Jordan 1 High OG "Amber Gold"', N'lookbook-amber-1.jpg', N'Jordan 1 với áo khoác bomber',     1),
    (N'Amber Street', N'Nike Dunk Low "Sunburst Amber"',    N'lookbook-amber-2.jpg', N'Dunk Low phối quần cargo',         2),
    (N'Daily Run',    N'Ultraboost Light Primeknit Beige',  N'lookbook-run-1.jpg',   N'Ultraboost cho buổi chạy sáng',     1),
    (N'Daily Run',    N'New Balance 1906R Soft Vanilla',    N'lookbook-run-2.jpg',   N'1906R phong cách retro runner',     2)
) AS v(LookbookTitle, ProductName, ImageUrl, Caption, SortOrder)
JOIN dbo.Lookbooks l ON l.Title = v.LookbookTitle
JOIN dbo.Products  p ON p.ProductName = v.ProductName
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.LookbookItems li WHERE li.LookbookId = l.LookbookId AND li.ImageUrl = v.ImageUrl
);
GO

/* =====================================================
   15. VERIFICATION QUERIES
   (the Password column is not selected on purpose)
   ===================================================== */
SELECT 'Accounts' AS TableName, COUNT(*) AS TotalRows FROM dbo.Accounts
UNION ALL SELECT 'Categories',     COUNT(*) FROM dbo.Categories
UNION ALL SELECT 'Products',       COUNT(*) FROM dbo.Products
UNION ALL SELECT 'ProductDetails', COUNT(*) FROM dbo.ProductDetails
UNION ALL SELECT 'ProductImages',  COUNT(*) FROM dbo.ProductImages
UNION ALL SELECT 'Lookbooks',      COUNT(*) FROM dbo.Lookbooks
UNION ALL SELECT 'LookbookItems',  COUNT(*) FROM dbo.LookbookItems
UNION ALL SELECT 'CartItems',      COUNT(*) FROM dbo.CartItems
UNION ALL SELECT 'Orders',         COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderDetails',   COUNT(*) FROM dbo.OrderDetails
UNION ALL SELECT 'Reviews',        COUNT(*) FROM dbo.Reviews;

SELECT * FROM dbo.vw_ProductCards;
SELECT TOP 5 * FROM dbo.vw_BestSellingProducts ORDER BY TotalSold DESC;
SELECT * FROM dbo.vw_LookbookDetail ORDER BY LookbookSortOrder, ItemSortOrder;
SELECT AccountId, Username, Email, Role, IsActive, CreatedAt FROM dbo.Accounts ORDER BY AccountId;
GO

USE Poly_Sneaker;
SELECT Username, Role, IsActive, LEN(Password) AS PassLen, LEFT(Password, 4) AS PassHead
FROM dbo.Accounts;

UPDATE dbo.Accounts
SET Password = N'admin123'
WHERE Username = N'admin';

SELECT *From Accounts 

SELECT*From Products

USE Poly_Sneaker;

SELECT CategoryId, CategoryName, ParentId, IsActive FROM dbo.Categories;

   IF COL_LENGTH('dbo.Categories', 'Description') IS NULL
       ALTER TABLE dbo.Categories ADD Description NVARCHAR(500) NULL;