/* =====================================================================
   POLY_SNEAKER - FULL DATABASE SCRIPT v9 (SQL Server 2016 SP1+)
   - Safe to re-run: tables are created only if missing, so existing
     accounts / products / orders / pages are NEVER dropped.
   - Seed data is idempotent (no duplicates when run again).
   - Wipe everything: uncomment the RESET block right below first.
   - Run in SSMS, or sqlcmd with -I (needed for the filtered index).

   v3: added dbo.SitePages (footer pages edited by admin: Dịch Vụ / Chính Sách)
   v4: ProductDetails has new columns Material + Specifications (under Description);
       Categories and Products are no longer seeded (start EMPTY).
   v5: added dbo.LookbookProducts (Bộ sưu tập <-> Sản phẩm, nhiều-nhiều) and
       dbo.vw_LookbookProducts.
   v6: PHÂN QUYỀN NỘI BỘ (chỉ THÊM, không đổi chức năng cũ)
       - Role mở rộng: BOD, ADMIN, WAREHOUSE, CENTER_MANAGER, SALES, CUSTOMER
       - Thêm dbo.Branches, Accounts.BranchId / ManagerId
       - Thêm dbo.Tickets (gửi BOD duyệt) và dbo.AuditLogs (nhật ký thao tác)
       - Seed BOD + Kho dùng chung theo ca
   v7: KHO (WAREHOUSE) - chỉ THÊM, không đổi chức năng cũ
       - Thêm dbo.Suppliers (nhà cung cấp)
       - Thêm dbo.StockReceipts + dbo.StockReceiptDetails (phiếu nhập kho)
       - Thêm dbo.StockMovements (sổ cái biến động tồn kho)
       - Thêm view: vw_StockOverview, vw_StockMovementDetail, vw_StockReceiptSummary
       - Tồn kho vẫn là ProductDetails.StockQuantity (không đổi)

   v8: VOUCHER + COUPON - chỉ THÊM, không đổi chức năng cũ
       - dbo.Coupons       : mã giảm giá công khai, ai nhập mã cũng dùng được (có giới hạn lượt)
       - dbo.CouponUsages  : lịch sử mỗi lần dùng coupon (theo tài khoản + đơn hàng)
       - dbo.Vouchers      : voucher cá nhân, cấp riêng cho 1 tài khoản, dùng 1 lần
       - Orders thêm 3 cột: DiscountAmount, CouponCode, VoucherCode (snapshot, mặc định 0/NULL)
       - View: vw_CouponSummary, vw_VoucherDetail

   v9: THANH TOÁN ĐƠN HÀNG - chỉ THÊM, không đổi chức năng cũ
       - Orders thêm 3 cột: PaymentStatus (UNPAID / PAID), PaidAt, PaidBy
       - Quy tắc: khách đặt hàng -> PaymentStatus = UNPAID, CHƯA trừ tồn kho.
         Khi khách đã trả tiền, admin bấm "Thanh toán thành công" -> PaymentStatus = PAID,
         lúc đó mới trừ ProductDetails.StockQuantity theo số lượng khách đặt
         (và ghi 1 dòng StockMovements loại OUT_SALE cho mỗi size).
       - Hủy đơn đã PAID thì cộng tồn kho lại (StockMovements loại CANCEL_RETURN).
       - Đơn cũ đã COMPLETED được đánh dấu PAID để không bị trừ kho lần nữa.
       - vw_OrderSummary thêm PaymentStatus, PaidAt, Note, DiscountAmount, CouponCode, VoucherCode.

   Default logins after running:
     admin       / admin123      (plain text on purpose, owner-only account)
     customer01  / customer123   (BCrypt hash)
     bod         / Bod@PolySneaker2026   (BCrypt hash)  <- ĐỔI MẬT KHẨU khi dùng thật
     kho.tong    / Kho@PolySneaker2026   (BCrypt hash)  <- ĐỔI MẬT KHẨU khi dùng thật
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
IF OBJECT_ID('dbo.vw_VoucherDetail', 'V')       IS NOT NULL DROP VIEW dbo.vw_VoucherDetail;
IF OBJECT_ID('dbo.vw_CouponSummary', 'V')       IS NOT NULL DROP VIEW dbo.vw_CouponSummary;
IF OBJECT_ID('dbo.vw_StockReceiptSummary', 'V') IS NOT NULL DROP VIEW dbo.vw_StockReceiptSummary;
IF OBJECT_ID('dbo.vw_StockMovementDetail', 'V') IS NOT NULL DROP VIEW dbo.vw_StockMovementDetail;
IF OBJECT_ID('dbo.vw_StockOverview', 'V')       IS NOT NULL DROP VIEW dbo.vw_StockOverview;
IF OBJECT_ID('dbo.vw_OrderSummary', 'V')        IS NOT NULL DROP VIEW dbo.vw_OrderSummary;
IF OBJECT_ID('dbo.vw_CartDetail', 'V')          IS NOT NULL DROP VIEW dbo.vw_CartDetail;
IF OBJECT_ID('dbo.vw_LookbookProducts', 'V')    IS NOT NULL DROP VIEW dbo.vw_LookbookProducts;
IF OBJECT_ID('dbo.vw_LookbookDetail', 'V')      IS NOT NULL DROP VIEW dbo.vw_LookbookDetail;
IF OBJECT_ID('dbo.vw_BestSellingProducts', 'V') IS NOT NULL DROP VIEW dbo.vw_BestSellingProducts;
IF OBJECT_ID('dbo.vw_ProductCards', 'V')        IS NOT NULL DROP VIEW dbo.vw_ProductCards;
IF OBJECT_ID('dbo.sp_RegisterAccount', 'P')     IS NOT NULL DROP PROCEDURE dbo.sp_RegisterAccount;
IF OBJECT_ID('dbo.CouponUsages', 'U')           IS NOT NULL DROP TABLE dbo.CouponUsages;
IF OBJECT_ID('dbo.Vouchers', 'U')               IS NOT NULL DROP TABLE dbo.Vouchers;
IF OBJECT_ID('dbo.Coupons', 'U')                IS NOT NULL DROP TABLE dbo.Coupons;
IF OBJECT_ID('dbo.StockMovements', 'U')         IS NOT NULL DROP TABLE dbo.StockMovements;
IF OBJECT_ID('dbo.StockReceiptDetails', 'U')    IS NOT NULL DROP TABLE dbo.StockReceiptDetails;
IF OBJECT_ID('dbo.StockReceipts', 'U')          IS NOT NULL DROP TABLE dbo.StockReceipts;
IF OBJECT_ID('dbo.Suppliers', 'U')              IS NOT NULL DROP TABLE dbo.Suppliers;
IF OBJECT_ID('dbo.AuditLogs', 'U')              IS NOT NULL DROP TABLE dbo.AuditLogs;
IF OBJECT_ID('dbo.Tickets', 'U')                IS NOT NULL DROP TABLE dbo.Tickets;
IF OBJECT_ID('dbo.SitePages', 'U')              IS NOT NULL DROP TABLE dbo.SitePages;
IF OBJECT_ID('dbo.Reviews', 'U')                IS NOT NULL DROP TABLE dbo.Reviews;
IF OBJECT_ID('dbo.OrderDetails', 'U')           IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID('dbo.Orders', 'U')                 IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID('dbo.CartItems', 'U')              IS NOT NULL DROP TABLE dbo.CartItems;
IF OBJECT_ID('dbo.LookbookProducts', 'U')       IS NOT NULL DROP TABLE dbo.LookbookProducts;
IF OBJECT_ID('dbo.LookbookItems', 'U')          IS NOT NULL DROP TABLE dbo.LookbookItems;
IF OBJECT_ID('dbo.Lookbooks', 'U')              IS NOT NULL DROP TABLE dbo.Lookbooks;
IF OBJECT_ID('dbo.ProductImages', 'U')          IS NOT NULL DROP TABLE dbo.ProductImages;
IF OBJECT_ID('dbo.ProductDetails', 'U')         IS NOT NULL DROP TABLE dbo.ProductDetails;
IF OBJECT_ID('dbo.Products', 'U')               IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U')             IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Accounts', 'U')               IS NOT NULL DROP TABLE dbo.Accounts;
IF OBJECT_ID('dbo.Branches', 'U')               IS NOT NULL DROP TABLE dbo.Branches;
GO
*/

/* =====================================================
   0. BRANCHES (chi nhánh) - tạo trước Accounts vì Accounts tham chiếu tới
   ===================================================== */
IF OBJECT_ID('dbo.Branches', 'U') IS NULL
CREATE TABLE dbo.Branches (
    BranchId   INT IDENTITY(1,1) PRIMARY KEY,
    BranchName NVARCHAR(150) NOT NULL,
    Address    NVARCHAR(300) NULL,
    Phone      VARCHAR(20)   NULL,
    IsActive   BIT           NOT NULL DEFAULT 1,
    CreatedAt  DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Branches_Name UNIQUE (BranchName)
);
GO

/* =====================================================
   1. ACCOUNTS (BOD / Admin / Kho / Center Manager / Sales / Customer)
   Role: BOD, ADMIN, WAREHOUSE, CENTER_MANAGER, SALES, CUSTOMER
   BranchId : chi nhánh (bắt buộc với CENTER_MANAGER và SALES)
   ManagerId: Center Manager đã tạo tài khoản Sales
   ===================================================== */
IF OBJECT_ID('dbo.Accounts', 'U') IS NULL
CREATE TABLE dbo.Accounts (
    AccountId  INT IDENTITY(1,1) PRIMARY KEY,
    Username   NVARCHAR(50)  NOT NULL,
    Password   NVARCHAR(255) NOT NULL,           -- BCrypt hash | ADMIN: plain text allowed
    Email      NVARCHAR(100) NOT NULL,
    Role       VARCHAR(20)   NOT NULL DEFAULT 'CUSTOMER',
    IsActive   BIT           NOT NULL DEFAULT 1, -- 1: active, 0: locked
    CreatedAt  DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Accounts_Username UNIQUE (Username),
    CONSTRAINT UQ_Accounts_Email    UNIQUE (Email),
    CONSTRAINT CK_Accounts_Role     CHECK (Role IN ('BOD', 'ADMIN', 'WAREHOUSE', 'CENTER_MANAGER', 'SALES', 'CUSTOMER')),
    CONSTRAINT CK_Accounts_Email    CHECK (Email LIKE '%_@_%._%')
);
GO

-- Profile columns for checkout (nullable, so the current JPA entity keeps working)
IF COL_LENGTH('dbo.Accounts', 'FullName') IS NULL ALTER TABLE dbo.Accounts ADD FullName NVARCHAR(100) NULL;
IF COL_LENGTH('dbo.Accounts', 'Phone')    IS NULL ALTER TABLE dbo.Accounts ADD Phone    VARCHAR(20)   NULL;
IF COL_LENGTH('dbo.Accounts', 'Address')  IS NULL ALTER TABLE dbo.Accounts ADD Address  NVARCHAR(300) NULL;
-- v6: chi nhánh + người quản lý (nullable nên entity cũ vẫn chạy bình thường)
IF COL_LENGTH('dbo.Accounts', 'BranchId')  IS NULL ALTER TABLE dbo.Accounts ADD BranchId  INT NULL;
IF COL_LENGTH('dbo.Accounts', 'ManagerId') IS NULL ALTER TABLE dbo.Accounts ADD ManagerId INT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Accounts_Branch')
    ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_Branch  FOREIGN KEY (BranchId)  REFERENCES dbo.Branches(BranchId);
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Accounts_Manager')
    ALTER TABLE dbo.Accounts ADD CONSTRAINT FK_Accounts_Manager FOREIGN KEY (ManagerId) REFERENCES dbo.Accounts(AccountId);
GO

-- v6: DB cũ chỉ cho ADMIN/CUSTOMER -> mở rộng danh sách role (giữ nguyên dữ liệu cũ)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = 'CK_Accounts_Role' AND parent_object_id = OBJECT_ID('dbo.Accounts')
                 AND definition LIKE '%BOD%')
BEGIN
    IF EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = 'CK_Accounts_Role' AND parent_object_id = OBJECT_ID('dbo.Accounts'))
        ALTER TABLE dbo.Accounts DROP CONSTRAINT CK_Accounts_Role;

    ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_Role
        CHECK (Role IN ('BOD', 'ADMIN', 'WAREHOUSE', 'CENTER_MANAGER', 'SALES', 'CUSTOMER'));
END
GO

-- Center Manager và Sales bắt buộc có chi nhánh
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Accounts_BranchRequired')
    ALTER TABLE dbo.Accounts ADD CONSTRAINT CK_Accounts_BranchRequired
        CHECK (Role NOT IN ('CENTER_MANAGER', 'SALES') OR BranchId IS NOT NULL);
GO

-- Only ONE ADMIN account is allowed
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_Accounts_SingleAdmin' AND object_id = OBJECT_ID('dbo.Accounts'))
    CREATE UNIQUE INDEX UX_Accounts_SingleAdmin
        ON dbo.Accounts (Role)
        WHERE Role = 'ADMIN';
GO

-- Mỗi chi nhánh chỉ có 1 Center Manager
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_Accounts_OneManagerPerBranch' AND object_id = OBJECT_ID('dbo.Accounts'))
    CREATE UNIQUE INDEX UX_Accounts_OneManagerPerBranch
        ON dbo.Accounts (BranchId)
        WHERE Role = 'CENTER_MANAGER';
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

-- Old databases created before the Description column existed
IF COL_LENGTH('dbo.Categories', 'Description') IS NULL
    ALTER TABLE dbo.Categories ADD Description NVARCHAR(500) NULL;
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
   Material + Specifications sit right under Description.
   ===================================================== */
IF OBJECT_ID('dbo.ProductDetails', 'U') IS NULL
CREATE TABLE dbo.ProductDetails (
    ProductDetailId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId       INT           NOT NULL,
    Size            DECIMAL(3,1)  NOT NULL,          -- supports 42.5
    Description     NVARCHAR(MAX) NULL,
    Material        NVARCHAR(500) NULL,              -- chất liệu
    Specifications  NVARCHAR(MAX) NULL,              -- thông số kỹ thuật
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

-- Old databases that already have the table: add the 2 new columns (safe to re-run)
IF COL_LENGTH('dbo.ProductDetails', 'Material') IS NULL
    ALTER TABLE dbo.ProductDetails ADD Material NVARCHAR(500) NULL;
IF COL_LENGTH('dbo.ProductDetails', 'Specifications') IS NULL
    ALTER TABLE dbo.ProductDetails ADD Specifications NVARCHAR(MAX) NULL;
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
   - Lookbooks        : one collection / outfit story (vd: Thu Đông, Mới ra mắt)
   - LookbookItems    : photos, each can be tagged with a product
   - LookbookProducts : products that belong to a collection (many-to-many)
                        One product can be in many collections, one collection
                        can have many products. Admin picks them in the form.
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

IF OBJECT_ID('dbo.LookbookProducts', 'U') IS NULL
CREATE TABLE dbo.LookbookProducts (
    LookbookId INT NOT NULL,
    ProductId  INT NOT NULL,
    SortOrder  INT NOT NULL DEFAULT 0,               -- smaller = shown first

    CONSTRAINT PK_LookbookProducts           PRIMARY KEY (LookbookId, ProductId),
    CONSTRAINT FK_LookbookProducts_Lookbooks FOREIGN KEY (LookbookId) REFERENCES dbo.Lookbooks(LookbookId) ON DELETE CASCADE,
    CONSTRAINT FK_LookbookProducts_Products  FOREIGN KEY (ProductId)  REFERENCES dbo.Products(ProductId)   ON DELETE CASCADE
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
   10. SITE PAGES (footer pages edited by admin)
   - Slug       : public URL is /pages/<slug>
   - FooterGroup: SERVICE = under the "Dịch Vụ" heading
                  POLICY  = under the "Chính Sách" heading
                  NONE    = not shown in the footer (direct link only)
   - Content    : plain text written by admin
                  ("## " = heading, "- " = bullet, blank line = new paragraph)
   ===================================================== */
IF OBJECT_ID('dbo.SitePages', 'U') IS NULL
CREATE TABLE dbo.SitePages (
    PageId      INT IDENTITY(1,1) PRIMARY KEY,
    Slug        VARCHAR(100)  NOT NULL,
    Title       NVARCHAR(200) NOT NULL,
    Content     NVARCHAR(MAX) NULL,
    FooterGroup VARCHAR(20)   NOT NULL DEFAULT 'POLICY',
    SortOrder   INT           NOT NULL DEFAULT 0,
    IsActive    BIT           NOT NULL DEFAULT 1,
    CreatedAt   DATETIME      NOT NULL DEFAULT GETDATE(),
    UpdatedAt   DATETIME      NULL,

    CONSTRAINT UQ_SitePages_Slug  UNIQUE (Slug),
    CONSTRAINT CK_SitePages_Group CHECK (FooterGroup IN ('SERVICE', 'POLICY', 'NONE'))
);
GO

/* =====================================================
   10b. TICKETS (v6) - việc vượt thẩm quyền thì gửi ticket lên BOD.
   BOD duyệt / từ chối, sau đó BOD tự thao tác bằng quyền của mình.
   ===================================================== */
IF OBJECT_ID('dbo.Tickets', 'U') IS NULL
CREATE TABLE dbo.Tickets (
    TicketId    INT IDENTITY(1,1) PRIMARY KEY,
    CreatorId   INT            NOT NULL,
    Category    VARCHAR(30)    NOT NULL DEFAULT 'OTHER',
    Title       NVARCHAR(200)  NOT NULL,
    Content     NVARCHAR(2000) NULL,
    Status      VARCHAR(20)    NOT NULL DEFAULT 'PENDING',
    BodNote     NVARCHAR(1000) NULL,
    ProcessedBy INT            NULL,
    ProcessedAt DATETIME       NULL,
    CreatedAt   DATETIME       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_Tickets_Creator   FOREIGN KEY (CreatorId)   REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT FK_Tickets_Processor FOREIGN KEY (ProcessedBy) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT CK_Tickets_Status    CHECK (Status IN ('PENDING', 'APPROVED', 'REJECTED'))
);
GO

/* =====================================================
   10c. AUDIT LOGS (v6) - nhật ký thao tác.
   Username / Role lưu dạng snapshot để khóa tài khoản vẫn còn dấu vết.
   ===================================================== */
IF OBJECT_ID('dbo.AuditLogs', 'U') IS NULL
CREATE TABLE dbo.AuditLogs (
    LogId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    AccountId  INT            NULL,
    Username   NVARCHAR(50)   NULL,
    Role       VARCHAR(20)    NULL,
    Action     VARCHAR(50)    NOT NULL,
    Target     NVARCHAR(200)  NULL,
    Detail     NVARCHAR(1000) NULL,
    CreatedAt  DATETIME       NOT NULL DEFAULT GETDATE()
);
GO

/* =====================================================
   10d. KHO (v7) - Suppliers, StockReceipts, StockReceiptDetails, StockMovements
   Tồn kho thực tế vẫn nằm ở ProductDetails.StockQuantity.
   StockMovements là sổ cái: mỗi lần tồn kho đổi thì ghi 1 dòng.
   ===================================================== */

-- Nhà cung cấp
IF OBJECT_ID('dbo.Suppliers', 'U') IS NULL
CREATE TABLE dbo.Suppliers (
    SupplierId   INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(150) NOT NULL,
    ContactName  NVARCHAR(100) NULL,
    Phone        VARCHAR(20)   NULL,
    Email        NVARCHAR(100) NULL,
    Address      NVARCHAR(300) NULL,
    IsActive     BIT           NOT NULL DEFAULT 1,
    CreatedAt    DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Suppliers_Name UNIQUE (SupplierName)
);
GO

-- Phiếu nhập kho. Status: DRAFT = đang soạn, COMPLETED = đã nhập (cộng tồn), CANCELLED = hủy
IF OBJECT_ID('dbo.StockReceipts', 'U') IS NULL
CREATE TABLE dbo.StockReceipts (
    ReceiptId   INT IDENTITY(1,1) PRIMARY KEY,
    ReceiptCode VARCHAR(30)    NOT NULL,              -- vd: PN-20261113-001
    SupplierId  INT            NULL,                  -- không bắt buộc chọn nhà cung cấp
    CreatedBy   INT            NOT NULL,
    Note        NVARCHAR(500)  NULL,
    Status      VARCHAR(20)    NOT NULL DEFAULT 'DRAFT',
    CreatedAt   DATETIME       NOT NULL DEFAULT GETDATE(),
    CompletedAt DATETIME       NULL,

    CONSTRAINT UQ_StockReceipts_Code     UNIQUE (ReceiptCode),
    CONSTRAINT FK_StockReceipts_Supplier FOREIGN KEY (SupplierId) REFERENCES dbo.Suppliers(SupplierId),
    CONSTRAINT FK_StockReceipts_Creator  FOREIGN KEY (CreatedBy)  REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT CK_StockReceipts_Status   CHECK (Status IN ('DRAFT', 'COMPLETED', 'CANCELLED'))
);
GO

IF OBJECT_ID('dbo.StockReceiptDetails', 'U') IS NULL
CREATE TABLE dbo.StockReceiptDetails (
    ReceiptDetailId INT IDENTITY(1,1) PRIMARY KEY,
    ReceiptId       INT           NOT NULL,
    ProductDetailId INT           NOT NULL,
    Quantity        INT           NOT NULL,
    UnitCost        DECIMAL(18,0) NOT NULL DEFAULT 0,   -- giá nhập

    CONSTRAINT FK_SRD_Receipt        FOREIGN KEY (ReceiptId)       REFERENCES dbo.StockReceipts(ReceiptId) ON DELETE CASCADE,
    CONSTRAINT FK_SRD_ProductDetail  FOREIGN KEY (ProductDetailId) REFERENCES dbo.ProductDetails(ProductDetailId),
    CONSTRAINT UQ_SRD_Receipt_Detail UNIQUE (ReceiptId, ProductDetailId),
    CONSTRAINT CK_SRD_Quantity       CHECK (Quantity > 0),
    CONSTRAINT CK_SRD_UnitCost       CHECK (UnitCost >= 0)
);
GO

-- Sổ cái biến động tồn kho.
-- MovementType: IN (nhập), OUT_SALE (bán), CANCEL_RETURN (hủy đơn trả lại), ADJUST (kiểm kê / điều chỉnh tay)
-- Quantity là số có dấu: +10 nhập, -2 bán, -3 điều chỉnh giảm...
IF OBJECT_ID('dbo.StockMovements', 'U') IS NULL
CREATE TABLE dbo.StockMovements (
    MovementId      BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProductDetailId INT           NOT NULL,
    MovementType    VARCHAR(20)   NOT NULL,
    Quantity        INT           NOT NULL,
    StockBefore     INT           NOT NULL,
    StockAfter      INT           NOT NULL,
    RefType         VARCHAR(20)   NULL,                 -- RECEIPT / ORDER / MANUAL
    RefId           INT           NULL,
    Note            NVARCHAR(500) NULL,
    CreatedBy       INT           NULL,
    CreatedAt       DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_SM_ProductDetail FOREIGN KEY (ProductDetailId) REFERENCES dbo.ProductDetails(ProductDetailId),
    CONSTRAINT FK_SM_Creator       FOREIGN KEY (CreatedBy)       REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT CK_SM_Type          CHECK (MovementType IN ('IN', 'OUT_SALE', 'CANCEL_RETURN', 'ADJUST')),
    CONSTRAINT CK_SM_Quantity      CHECK (Quantity <> 0),
    CONSTRAINT CK_SM_After         CHECK (StockAfter >= 0)
);
GO

/* =====================================================
   10e. VOUCHER + COUPON (v8)
   - Coupons      : mã giảm giá CÔNG KHAI. Khách nhập mã ở bước thanh toán.
                    Giới hạn tổng lượt (UsageLimit) và lượt / tài khoản (PerAccountLimit).
   - CouponUsages : mỗi lần coupon được dùng cho 1 đơn (để đếm lượt theo tài khoản,
                    và trả lượt lại khi đơn bị hủy).
   - Vouchers     : voucher CÁ NHÂN, cấp riêng cho 1 tài khoản (quà sinh nhật, đền bù,
                    khách thân thiết...). Chỉ chủ tài khoản dùng được, dùng 1 lần.
   - DiscountType : PERCENT (giảm %, có thể chặn trần bằng MaxDiscount)
                    AMOUNT  (giảm số tiền cố định, VND)
   - Orders       : lưu snapshot DiscountAmount / CouponCode / VoucherCode,
                    TotalAmount vẫn là số tiền khách phải trả cuối cùng.
   - Mã (Code) chỉ gồm chữ, số, gạch ngang, gạch dưới; không phân biệt hoa thường.
     Coupons.Code và Vouchers.Code nên không trùng nhau (app kiểm tra khi tạo).
   ===================================================== */

-- Orders: thêm cột giảm giá (an toàn khi chạy lại, dữ liệu cũ mặc định 0 / NULL)
IF COL_LENGTH('dbo.Orders', 'DiscountAmount') IS NULL
    ALTER TABLE dbo.Orders ADD DiscountAmount DECIMAL(18,0) NOT NULL
        CONSTRAINT DF_Orders_DiscountAmount DEFAULT 0;
IF COL_LENGTH('dbo.Orders', 'CouponCode')  IS NULL ALTER TABLE dbo.Orders ADD CouponCode  VARCHAR(30) NULL;
IF COL_LENGTH('dbo.Orders', 'VoucherCode') IS NULL ALTER TABLE dbo.Orders ADD VoucherCode VARCHAR(30) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = 'CK_Orders_Discount' AND parent_object_id = OBJECT_ID('dbo.Orders'))
    ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_Discount CHECK (DiscountAmount >= 0);
GO

IF OBJECT_ID('dbo.Coupons', 'U') IS NULL
CREATE TABLE dbo.Coupons (
    CouponId        INT IDENTITY(1,1) PRIMARY KEY,
    Code            VARCHAR(30)    NOT NULL,
    Title           NVARCHAR(200)  NOT NULL,
    Description     NVARCHAR(500)  NULL,
    DiscountType    VARCHAR(10)    NOT NULL,              -- PERCENT / AMOUNT
    DiscountValue   DECIMAL(18,0)  NOT NULL,              -- PERCENT: 1..100 | AMOUNT: số tiền VND
    MaxDiscount     DECIMAL(18,0)  NULL,                  -- trần giảm khi PERCENT (NULL = không chặn)
    MinOrderAmount  DECIMAL(18,0)  NOT NULL DEFAULT 0,    -- đơn tối thiểu để áp dụng
    UsageLimit      INT            NULL,                  -- tổng lượt dùng (NULL = không giới hạn)
    UsedCount       INT            NOT NULL DEFAULT 0,
    PerAccountLimit INT            NOT NULL DEFAULT 1,    -- mỗi tài khoản dùng tối đa bao nhiêu lần
    StartsAt        DATETIME       NOT NULL DEFAULT GETDATE(),
    ExpiresAt       DATETIME       NULL,                  -- NULL = không hết hạn
    IsActive        BIT            NOT NULL DEFAULT 1,
    CreatedBy       INT            NULL,
    CreatedAt       DATETIME       NOT NULL DEFAULT GETDATE(),
    UpdatedAt       DATETIME       NULL,

    CONSTRAINT UQ_Coupons_Code        UNIQUE (Code),
    CONSTRAINT FK_Coupons_Creator     FOREIGN KEY (CreatedBy) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT CK_Coupons_Code        CHECK (Code NOT LIKE '%[^A-Za-z0-9_-]%'),
    CONSTRAINT CK_Coupons_Type        CHECK (DiscountType IN ('PERCENT', 'AMOUNT')),
    CONSTRAINT CK_Coupons_Value       CHECK ((DiscountType = 'PERCENT' AND DiscountValue BETWEEN 1 AND 100)
                                          OR (DiscountType = 'AMOUNT'  AND DiscountValue > 0)),
    CONSTRAINT CK_Coupons_MaxDiscount CHECK (MaxDiscount IS NULL OR MaxDiscount > 0),
    CONSTRAINT CK_Coupons_MinOrder    CHECK (MinOrderAmount >= 0),
    CONSTRAINT CK_Coupons_UsageLimit  CHECK (UsageLimit IS NULL OR UsageLimit > 0),
    CONSTRAINT CK_Coupons_UsedCount   CHECK (UsedCount >= 0 AND (UsageLimit IS NULL OR UsedCount <= UsageLimit)),
    CONSTRAINT CK_Coupons_PerAccount  CHECK (PerAccountLimit >= 1),
    CONSTRAINT CK_Coupons_Dates       CHECK (ExpiresAt IS NULL OR ExpiresAt > StartsAt)
);
GO

IF OBJECT_ID('dbo.CouponUsages', 'U') IS NULL
CREATE TABLE dbo.CouponUsages (
    UsageId        INT IDENTITY(1,1) PRIMARY KEY,
    CouponId       INT           NOT NULL,
    AccountId      INT           NOT NULL,
    OrderId        INT           NOT NULL,
    DiscountAmount DECIMAL(18,0) NOT NULL,                -- số tiền thực tế đã giảm
    UsedAt         DATETIME      NOT NULL DEFAULT GETDATE(),

    CONSTRAINT FK_CouponUsages_Coupon  FOREIGN KEY (CouponId)  REFERENCES dbo.Coupons(CouponId),
    CONSTRAINT FK_CouponUsages_Account FOREIGN KEY (AccountId) REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT FK_CouponUsages_Order   FOREIGN KEY (OrderId)   REFERENCES dbo.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT UQ_CouponUsages_Coupon_Order UNIQUE (CouponId, OrderId),
    CONSTRAINT CK_CouponUsages_Discount CHECK (DiscountAmount >= 0)
);
GO

-- Voucher cá nhân. Status: UNUSED (chưa dùng), USED (đã dùng), REVOKED (thu hồi).
-- "Hết hạn" không lưu mà suy ra từ ExpiresAt (xem vw_VoucherDetail).
IF OBJECT_ID('dbo.Vouchers', 'U') IS NULL
CREATE TABLE dbo.Vouchers (
    VoucherId      INT IDENTITY(1,1) PRIMARY KEY,
    Code           VARCHAR(30)    NOT NULL,
    AccountId      INT            NOT NULL,               -- chủ voucher
    Title          NVARCHAR(200)  NOT NULL,
    Reason         NVARCHAR(300)  NULL,                   -- lý do cấp (quà sinh nhật, đền bù...)
    DiscountType   VARCHAR(10)    NOT NULL,
    DiscountValue  DECIMAL(18,0)  NOT NULL,
    MaxDiscount    DECIMAL(18,0)  NULL,
    MinOrderAmount DECIMAL(18,0)  NOT NULL DEFAULT 0,
    StartsAt       DATETIME       NOT NULL DEFAULT GETDATE(),
    ExpiresAt      DATETIME       NOT NULL,
    Status         VARCHAR(10)    NOT NULL DEFAULT 'UNUSED',
    UsedOrderId    INT            NULL,
    UsedAt         DATETIME       NULL,
    IssuedBy       INT            NULL,
    CreatedAt      DATETIME       NOT NULL DEFAULT GETDATE(),

    CONSTRAINT UQ_Vouchers_Code        UNIQUE (Code),
    CONSTRAINT FK_Vouchers_Account     FOREIGN KEY (AccountId)   REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT FK_Vouchers_Order       FOREIGN KEY (UsedOrderId) REFERENCES dbo.Orders(OrderId) ON DELETE SET NULL,
    CONSTRAINT FK_Vouchers_Issuer      FOREIGN KEY (IssuedBy)    REFERENCES dbo.Accounts(AccountId),
    CONSTRAINT CK_Vouchers_Code        CHECK (Code NOT LIKE '%[^A-Za-z0-9_-]%'),
    CONSTRAINT CK_Vouchers_Type        CHECK (DiscountType IN ('PERCENT', 'AMOUNT')),
    CONSTRAINT CK_Vouchers_Value       CHECK ((DiscountType = 'PERCENT' AND DiscountValue BETWEEN 1 AND 100)
                                           OR (DiscountType = 'AMOUNT'  AND DiscountValue > 0)),
    CONSTRAINT CK_Vouchers_MaxDiscount CHECK (MaxDiscount IS NULL OR MaxDiscount > 0),
    CONSTRAINT CK_Vouchers_MinOrder    CHECK (MinOrderAmount >= 0),
    CONSTRAINT CK_Vouchers_Dates       CHECK (ExpiresAt > StartsAt),
    CONSTRAINT CK_Vouchers_Status      CHECK (Status IN ('UNUSED', 'USED', 'REVOKED'))
);
GO

/* =====================================================
   10f. THANH TOÁN ĐƠN HÀNG (v9)
   - PaymentStatus : UNPAID = chưa thu tiền (mặc định), PAID = admin đã xác nhận thu tiền.
   - PaidAt        : thời điểm admin bấm "Thanh toán thành công".
   - PaidBy        : tài khoản admin đã bấm.
   Quy tắc tồn kho (do app thực hiện, trong 1 transaction):
     * Đặt hàng            -> KHÔNG trừ tồn kho.
     * Admin bấm PAID      -> UPDATE ProductDetails SET StockQuantity = StockQuantity - Quantity,
                              SoldQuantity = SoldQuantity + Quantity WHERE StockQuantity >= Quantity,
                              rồi ghi StockMovements (OUT_SALE, RefType = 'ORDER', RefId = OrderId).
                              Chỉ chạy khi PaymentStatus đang là UNPAID (chống trừ kho 2 lần).
     * Hủy đơn đã PAID     -> cộng tồn kho lại, ghi StockMovements (CANCEL_RETURN).
   ===================================================== */
IF COL_LENGTH('dbo.Orders', 'PaymentStatus') IS NULL
    ALTER TABLE dbo.Orders ADD PaymentStatus VARCHAR(10) NOT NULL
        CONSTRAINT DF_Orders_PaymentStatus DEFAULT 'UNPAID';
IF COL_LENGTH('dbo.Orders', 'PaidAt') IS NULL ALTER TABLE dbo.Orders ADD PaidAt DATETIME NULL;
IF COL_LENGTH('dbo.Orders', 'PaidBy') IS NULL ALTER TABLE dbo.Orders ADD PaidBy INT      NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = 'CK_Orders_PaymentStatus' AND parent_object_id = OBJECT_ID('dbo.Orders'))
    ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_PaymentStatus
        CHECK (PaymentStatus IN ('UNPAID', 'PAID'));
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Orders_PaidBy')
    ALTER TABLE dbo.Orders ADD CONSTRAINT FK_Orders_PaidBy
        FOREIGN KEY (PaidBy) REFERENCES dbo.Accounts(AccountId);
GO

-- Đơn cũ đã COMPLETED coi như đã thu tiền (tránh admin bấm PAID rồi trừ kho thêm lần nữa)
UPDATE dbo.Orders
SET PaymentStatus = 'PAID',
    PaidAt        = ISNULL(UpdatedAt, CreatedAt)
WHERE Status = 'COMPLETED' AND PaymentStatus = 'UNPAID';
GO

-- PAID thì bắt buộc có PaidAt (thêm sau khi đã chuẩn hóa dữ liệu cũ ở trên)
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints
               WHERE name = 'CK_Orders_PaidAt' AND parent_object_id = OBJECT_ID('dbo.Orders'))
    ALTER TABLE dbo.Orders ADD CONSTRAINT CK_Orders_PaidAt
        CHECK (PaymentStatus = 'UNPAID' OR PaidAt IS NOT NULL);
GO

/* =====================================================
   11. INDEXES
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_LookbookProducts_ProductId' AND object_id = OBJECT_ID('dbo.LookbookProducts'))
    CREATE INDEX IX_LookbookProducts_ProductId ON dbo.LookbookProducts(ProductId);
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
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SitePages_Footer' AND object_id = OBJECT_ID('dbo.SitePages'))
    CREATE INDEX IX_SitePages_Footer ON dbo.SitePages(FooterGroup, SortOrder) INCLUDE (Slug, Title, IsActive);
-- v6
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Accounts_Role' AND object_id = OBJECT_ID('dbo.Accounts'))
    CREATE INDEX IX_Accounts_Role ON dbo.Accounts(Role, BranchId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Tickets_Status' AND object_id = OBJECT_ID('dbo.Tickets'))
    CREATE INDEX IX_Tickets_Status ON dbo.Tickets(Status, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Tickets_Creator' AND object_id = OBJECT_ID('dbo.Tickets'))
    CREATE INDEX IX_Tickets_Creator ON dbo.Tickets(CreatorId, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AuditLogs_CreatedAt' AND object_id = OBJECT_ID('dbo.AuditLogs'))
    CREATE INDEX IX_AuditLogs_CreatedAt ON dbo.AuditLogs(CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_AuditLogs_Account' AND object_id = OBJECT_ID('dbo.AuditLogs'))
    CREATE INDEX IX_AuditLogs_Account ON dbo.AuditLogs(AccountId, CreatedAt DESC);
-- v7
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_StockReceipts_Status' AND object_id = OBJECT_ID('dbo.StockReceipts'))
    CREATE INDEX IX_StockReceipts_Status ON dbo.StockReceipts(Status, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SRD_ReceiptId' AND object_id = OBJECT_ID('dbo.StockReceiptDetails'))
    CREATE INDEX IX_SRD_ReceiptId ON dbo.StockReceiptDetails(ReceiptId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SM_ProductDetail' AND object_id = OBJECT_ID('dbo.StockMovements'))
    CREATE INDEX IX_SM_ProductDetail ON dbo.StockMovements(ProductDetailId, CreatedAt DESC);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_SM_CreatedAt' AND object_id = OBJECT_ID('dbo.StockMovements'))
    CREATE INDEX IX_SM_CreatedAt ON dbo.StockMovements(CreatedAt DESC);
-- v8
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Coupons_Active' AND object_id = OBJECT_ID('dbo.Coupons'))
    CREATE INDEX IX_Coupons_Active ON dbo.Coupons(IsActive, StartsAt, ExpiresAt);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CouponUsages_Coupon_Account' AND object_id = OBJECT_ID('dbo.CouponUsages'))
    CREATE INDEX IX_CouponUsages_Coupon_Account ON dbo.CouponUsages(CouponId, AccountId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CouponUsages_OrderId' AND object_id = OBJECT_ID('dbo.CouponUsages'))
    CREATE INDEX IX_CouponUsages_OrderId ON dbo.CouponUsages(OrderId);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Vouchers_Account' AND object_id = OBJECT_ID('dbo.Vouchers'))
    CREATE INDEX IX_Vouchers_Account ON dbo.Vouchers(AccountId, Status, ExpiresAt);
-- v9
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_Payment' AND object_id = OBJECT_ID('dbo.Orders'))
    CREATE INDEX IX_Orders_Payment ON dbo.Orders(PaymentStatus, Status, CreatedAt DESC);
GO

/* =====================================================
   12. ACCOUNTS SEED
   - ADMIN: plain-text password by design (owner-only account).
     * No admin yet            -> create with password admin123
     * Admin still has the old placeholder -> set to admin123
     * Admin already has a real password / BCrypt hash -> left untouched
   - customer01: BCrypt hash of "customer123" (for testing login/cart/order)
   - bod / kho (v6): BCrypt hash of "Bod@PolySneaker2026" / "Kho@PolySneaker2026"
     (kho là tài khoản dùng chung theo ca; BOD cấp quyền sử dụng)
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

IF NOT EXISTS (SELECT 1 FROM dbo.Accounts WHERE Username = N'bod')
    INSERT INTO dbo.Accounts (Username, Password, Email, Role, FullName)
    VALUES (N'bod',
            N'$2a$10$sfPbIG7CU5NynIlf14lO9OKyssWd6uRfHIYxUSP65vXqcad0g6ju6',
            N'bod@polysneaker.net.vn', 'BOD', N'Ban Giám Đốc');

IF NOT EXISTS (SELECT 1 FROM dbo.Accounts WHERE Username = N'kho.tong')
    INSERT INTO dbo.Accounts (Username, Password, Email, Role, FullName)
    VALUES (N'kho.tong',
            N'$2a$10$id5SIobhZuxbDiyAZcwMTO9pW4u39CILKr1NckIEcX4.khb1Lk4/K',
            N'kho@polysneaker.net.vn', 'WAREHOUSE', N'Quản lý kho');
GO

/* Forgot the admin password? Uncomment the line below, run it ONCE, then comment it again.
UPDATE dbo.Accounts SET Password = N'admin123' WHERE Username = N'admin';
*/
GO

/* =====================================================
   13. REGISTER PROCEDURE
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
   14. VIEWS
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

-- Lookbook detail page: products that belong to a collection.
-- = products admin picked for the collection (LookbookProducts)
--   + products tagged on photos of the collection (LookbookItems), no duplicates.
-- Only active products. Order by SortOrder (picked products first, then photo-tagged ones).
CREATE OR ALTER VIEW dbo.vw_LookbookProducts
AS
SELECT
    x.LookbookId,
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    p.Badge,
    p.SalePrice,
    p.OriginalPrice,
    p.DiscountPercent,
    p.AvgRating,
    p.ReviewCount,
    MIN(x.SortOrder) AS SortOrder
FROM (
    SELECT LookbookId, ProductId, SortOrder        FROM dbo.LookbookProducts
    UNION ALL
    SELECT LookbookId, ProductId, 1000 + SortOrder FROM dbo.LookbookItems WHERE ProductId IS NOT NULL
) AS x
JOIN dbo.Products AS p ON p.ProductId = x.ProductId AND p.IsActive = 1
GROUP BY x.LookbookId, p.ProductId, p.ProductName, p.MainImageUrl, p.Badge,
         p.SalePrice, p.OriginalPrice, p.DiscountPercent, p.AvgRating, p.ReviewCount;
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

-- Order history + admin order list: one row per order with item count (v9: thêm trạng thái thanh toán)
CREATE OR ALTER VIEW dbo.vw_OrderSummary
AS
SELECT
    o.OrderId,
    o.AccountId,
    a.Username,
    o.ReceiverName,
    o.Phone,
    o.Address,
    o.Note,
    o.PaymentMethod,
    o.PaymentStatus,
    o.PaidAt,
    o.PaidBy,
    o.Status,
    o.DiscountAmount,
    o.CouponCode,
    o.VoucherCode,
    o.TotalAmount,
    o.CreatedAt,
    o.UpdatedAt,
    ISNULL(SUM(od.Quantity), 0) AS TotalItems
FROM dbo.Orders AS o
JOIN dbo.Accounts AS a ON a.AccountId = o.AccountId
LEFT JOIN dbo.OrderDetails AS od ON od.OrderId = o.OrderId
GROUP BY o.OrderId, o.AccountId, a.Username, o.ReceiverName, o.Phone, o.Address, o.Note,
         o.PaymentMethod, o.PaymentStatus, o.PaidAt, o.PaidBy, o.Status,
         o.DiscountAmount, o.CouponCode, o.VoucherCode, o.TotalAmount, o.CreatedAt, o.UpdatedAt;
GO

/* ---------- v7: views cho kho ---------- */

-- Trang tồn kho: mỗi size một dòng, kèm tên sản phẩm
CREATE OR ALTER VIEW dbo.vw_StockOverview
AS
SELECT
    pd.ProductDetailId,
    p.ProductId,
    p.ProductName,
    p.MainImageUrl,
    c.CategoryName,
    pd.Size,
    pd.StockQuantity,
    pd.SoldQuantity,
    pd.IsActive
FROM dbo.ProductDetails AS pd
JOIN dbo.Products   AS p ON p.ProductId  = pd.ProductId
JOIN dbo.Categories AS c ON c.CategoryId = p.CategoryId;
GO

-- Lịch sử biến động tồn kho, có tên người thao tác
CREATE OR ALTER VIEW dbo.vw_StockMovementDetail
AS
SELECT
    m.MovementId,
    m.ProductDetailId,
    p.ProductName,
    pd.Size,
    m.MovementType,
    m.Quantity,
    m.StockBefore,
    m.StockAfter,
    m.RefType,
    m.RefId,
    m.Note,
    m.CreatedBy,
    a.Username AS CreatedByName,
    m.CreatedAt
FROM dbo.StockMovements AS m
JOIN dbo.ProductDetails AS pd ON pd.ProductDetailId = m.ProductDetailId
JOIN dbo.Products       AS p  ON p.ProductId        = pd.ProductId
LEFT JOIN dbo.Accounts  AS a  ON a.AccountId        = m.CreatedBy;
GO

-- Danh sách phiếu nhập: tổng số lượng và tổng tiền
CREATE OR ALTER VIEW dbo.vw_StockReceiptSummary
AS
SELECT
    r.ReceiptId,
    r.ReceiptCode,
    r.SupplierId,
    s.SupplierName,
    r.CreatedBy,
    a.Username AS CreatedByName,
    r.Status,
    r.Note,
    r.CreatedAt,
    r.CompletedAt,
    ISNULL(SUM(d.Quantity), 0)              AS TotalQuantity,
    ISNULL(SUM(d.Quantity * d.UnitCost), 0) AS TotalCost
FROM dbo.StockReceipts AS r
JOIN dbo.Accounts AS a ON a.AccountId = r.CreatedBy
LEFT JOIN dbo.Suppliers AS s ON s.SupplierId = r.SupplierId
LEFT JOIN dbo.StockReceiptDetails AS d ON d.ReceiptId = r.ReceiptId
GROUP BY r.ReceiptId, r.ReceiptCode, r.SupplierId, s.SupplierName, r.CreatedBy,
         a.Username, r.Status, r.Note, r.CreatedAt, r.CompletedAt;
GO

/* ---------- v8: views cho voucher / coupon ---------- */

-- Danh sách coupon cho admin: trạng thái hiệu lực + số lượt còn lại
-- EffectiveStatus: DISABLED (tắt tay) / UPCOMING (chưa tới giờ) / EXPIRED (hết hạn)
--                  USED_UP (hết lượt) / ACTIVE (đang dùng được)
CREATE OR ALTER VIEW dbo.vw_CouponSummary
AS
SELECT
    c.CouponId,
    c.Code,
    c.Title,
    c.Description,
    c.DiscountType,
    c.DiscountValue,
    c.MaxDiscount,
    c.MinOrderAmount,
    c.UsageLimit,
    c.UsedCount,
    CASE WHEN c.UsageLimit IS NULL THEN NULL ELSE c.UsageLimit - c.UsedCount END AS RemainingUses,
    c.PerAccountLimit,
    c.StartsAt,
    c.ExpiresAt,
    c.IsActive,
    CASE
        WHEN c.IsActive = 0                                              THEN 'DISABLED'
        WHEN GETDATE() < c.StartsAt                                      THEN 'UPCOMING'
        WHEN c.ExpiresAt IS NOT NULL AND GETDATE() > c.ExpiresAt         THEN 'EXPIRED'
        WHEN c.UsageLimit IS NOT NULL AND c.UsedCount >= c.UsageLimit    THEN 'USED_UP'
        ELSE 'ACTIVE'
    END AS EffectiveStatus,
    c.CreatedBy,
    a.Username AS CreatedByName,
    c.CreatedAt,
    c.UpdatedAt
FROM dbo.Coupons AS c
LEFT JOIN dbo.Accounts AS a ON a.AccountId = c.CreatedBy;
GO

-- Voucher cá nhân kèm thông tin chủ sở hữu.
-- EffectiveStatus: UNUSED / USED / REVOKED / EXPIRED (UNUSED nhưng quá hạn)
CREATE OR ALTER VIEW dbo.vw_VoucherDetail
AS
SELECT
    v.VoucherId,
    v.Code,
    v.AccountId,
    o.Username AS OwnerUsername,
    o.FullName AS OwnerFullName,
    v.Title,
    v.Reason,
    v.DiscountType,
    v.DiscountValue,
    v.MaxDiscount,
    v.MinOrderAmount,
    v.StartsAt,
    v.ExpiresAt,
    v.Status,
    CASE WHEN v.Status = 'UNUSED' AND GETDATE() > v.ExpiresAt THEN 'EXPIRED' ELSE v.Status END AS EffectiveStatus,
    v.UsedOrderId,
    v.UsedAt,
    v.IssuedBy,
    i.Username AS IssuedByName,
    v.CreatedAt
FROM dbo.Vouchers AS v
JOIN dbo.Accounts AS o ON o.AccountId = v.AccountId
LEFT JOIN dbo.Accounts AS i ON i.AccountId = v.IssuedBy;
GO

/* =====================================================
   15. CATALOG SEED
   Categories và Products để TRỐNG: admin tự thêm trong trang quản trị.
   (Lookbooks mẫu vẫn giữ, nhưng chưa có sản phẩm nào gắn vào.)
   ===================================================== */
IF NOT EXISTS (SELECT 1 FROM dbo.Lookbooks WHERE Title = N'Amber Street')
    INSERT INTO dbo.Lookbooks (Title, Description, CoverImageUrl, SortOrder)
    VALUES (N'Amber Street', N'Phối đồ đường phố với tông cam hổ phách.', N'lookbook-amber-cover.jpg', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.Lookbooks WHERE Title = N'Daily Run')
    INSERT INTO dbo.Lookbooks (Title, Description, CoverImageUrl, SortOrder)
    VALUES (N'Daily Run', N'Nhẹ, êm và gọn cho những buổi chạy mỗi ngày.', N'lookbook-run-cover.jpg', 2);
GO

/* Ví dụ gắn sản phẩm vào bộ sưu tập (sau khi admin đã thêm sản phẩm; đổi Id cho đúng):
INSERT INTO dbo.LookbookProducts (LookbookId, ProductId, SortOrder)
SELECT l.LookbookId, p.ProductId, 1
FROM dbo.Lookbooks AS l, dbo.Products AS p
WHERE l.Title = N'Amber Street' AND p.ProductId = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.LookbookProducts lp WHERE lp.LookbookId = l.LookbookId AND lp.ProductId = p.ProductId);
*/
GO

/* =====================================================
   16. SITE PAGES SEED (idempotent)
   5 sample pages matching the footer links. Admin edits the real content
   in Admin > Trang Nội Dung. A page whose content still starts with
   "Nội dung mẫu" is shown as "Chưa nhập nội dung" in the admin list.
   ===================================================== */
INSERT INTO dbo.SitePages (Slug, Title, Content, FooterGroup, SortOrder)
SELECT v.Slug, v.Title, v.Content, v.FooterGroup, v.SortOrder
FROM (VALUES
(N'warranty', N'Quy trình Bảo Hành tại cửa hàng', N'Nội dung mẫu: quản trị viên vào Admin > Trang Nội Dung để chỉnh sửa cho đúng với cửa hàng.

## Điều kiện bảo hành
- Sản phẩm mua tại PolySneaker, còn thông tin đơn hàng hoặc hóa đơn.
- Lỗi do nhà sản xuất như bong keo, đứt chỉ, hở đế trong thời gian bảo hành.

## Quy trình
- Bước 1: Mang sản phẩm đến cửa hàng hoặc gọi hotline 1900 3256.
- Bước 2: Nhân viên kiểm tra tình trạng sản phẩm.
- Bước 3: Cửa hàng xử lý và hẹn ngày nhận lại sản phẩm.', 'SERVICE', 1),

(N'terms', N'Điều khoản và điều kiện', N'Nội dung mẫu: quản trị viên vào Admin > Trang Nội Dung để chỉnh sửa cho đúng với cửa hàng.

## Quy định chung
Khi mua hàng tại PolySneaker, khách hàng đồng ý với các điều khoản dưới đây.

## Đơn hàng
- Đơn hàng chỉ được xác nhận khi cửa hàng còn đủ sản phẩm và size khách chọn.
- Cửa hàng có thể liên hệ khách để xác nhận thông tin trước khi giao.

## Giá và thanh toán
- Giá hiển thị trên website đã bao gồm VAT.
- Khách có thể thanh toán khi nhận hàng (COD) hoặc chuyển khoản.', 'POLICY', 1),

(N'privacy', N'Chính sách bảo mật', N'Nội dung mẫu: quản trị viên vào Admin > Trang Nội Dung để chỉnh sửa cho đúng với cửa hàng.

## Thông tin chúng tôi thu thập
- Họ tên, số điện thoại, địa chỉ giao hàng, email khi khách đăng ký hoặc đặt hàng.

## Mục đích sử dụng
- Xử lý đơn hàng, giao hàng và chăm sóc khách hàng.

## Cam kết
PolySneaker không bán hoặc chia sẻ thông tin cá nhân của khách cho bên thứ ba ngoài mục đích giao hàng.', 'POLICY', 2),

(N'refund-policy', N'Hoàn tiền và đổi trả', N'Nội dung mẫu: quản trị viên vào Admin > Trang Nội Dung để chỉnh sửa cho đúng với cửa hàng.

## Thời gian đổi trả
- Hỗ trợ đổi size, đổi sản phẩm trong 30 ngày kể từ ngày nhận hàng.

## Điều kiện
- Sản phẩm còn nguyên tem, hộp, chưa qua sử dụng.
- Có thông tin đơn hàng hoặc hóa đơn mua hàng.

## Hoàn tiền
Cửa hàng hoàn tiền cho khách khi sản phẩm lỗi hoặc không còn hàng để đổi.', 'POLICY', 3),

(N'shipping-policy', N'Vận chuyển và giao hàng', N'Nội dung mẫu: quản trị viên vào Admin > Trang Nội Dung để chỉnh sửa cho đúng với cửa hàng.

## Thời gian giao hàng
- Giao nhanh trong 2 giờ với một số khu vực nội thành, nhân viên sẽ báo khi xác nhận đơn.
- Các khu vực khác: thời gian giao do cửa hàng thông báo khi xác nhận đơn.

## Đóng gói
- Sản phẩm được đóng hộp 2 lớp chống va đập.

## Phí vận chuyển
Phí giao hàng được báo cho khách trước khi xác nhận đơn.', 'POLICY', 4)
) AS v(Slug, Title, Content, FooterGroup, SortOrder)
WHERE NOT EXISTS (SELECT 1 FROM dbo.SitePages sp WHERE sp.Slug = v.Slug);
GO

-- Pages created by the previous version still mention the old menu name: fix the sample text only
UPDATE dbo.SitePages
SET Content = REPLACE(Content, N'Admin > Chính Sách', N'Admin > Trang Nội Dung')
WHERE Content LIKE N'Nội dung mẫu:%';
GO

/* =====================================================
   17. VERIFICATION QUERIES
   (the Password column is not selected on purpose)
   ===================================================== */
SELECT 'Accounts' AS TableName, COUNT(*) AS TotalRows FROM dbo.Accounts
UNION ALL SELECT 'Branches',            COUNT(*) FROM dbo.Branches
UNION ALL SELECT 'Categories',          COUNT(*) FROM dbo.Categories
UNION ALL SELECT 'Products',            COUNT(*) FROM dbo.Products
UNION ALL SELECT 'ProductDetails',      COUNT(*) FROM dbo.ProductDetails
UNION ALL SELECT 'ProductImages',       COUNT(*) FROM dbo.ProductImages
UNION ALL SELECT 'Lookbooks',           COUNT(*) FROM dbo.Lookbooks
UNION ALL SELECT 'LookbookItems',       COUNT(*) FROM dbo.LookbookItems
UNION ALL SELECT 'LookbookProducts',    COUNT(*) FROM dbo.LookbookProducts
UNION ALL SELECT 'CartItems',           COUNT(*) FROM dbo.CartItems
UNION ALL SELECT 'Orders',              COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderDetails',        COUNT(*) FROM dbo.OrderDetails
UNION ALL SELECT 'Reviews',             COUNT(*) FROM dbo.Reviews
UNION ALL SELECT 'SitePages',           COUNT(*) FROM dbo.SitePages
UNION ALL SELECT 'Tickets',             COUNT(*) FROM dbo.Tickets
UNION ALL SELECT 'AuditLogs',           COUNT(*) FROM dbo.AuditLogs
UNION ALL SELECT 'Suppliers',           COUNT(*) FROM dbo.Suppliers
UNION ALL SELECT 'StockReceipts',       COUNT(*) FROM dbo.StockReceipts
UNION ALL SELECT 'StockReceiptDetails', COUNT(*) FROM dbo.StockReceiptDetails
UNION ALL SELECT 'StockMovements',      COUNT(*) FROM dbo.StockMovements
UNION ALL SELECT 'Coupons',             COUNT(*) FROM dbo.Coupons
UNION ALL SELECT 'CouponUsages',        COUNT(*) FROM dbo.CouponUsages
UNION ALL SELECT 'Vouchers',            COUNT(*) FROM dbo.Vouchers;

SELECT * FROM dbo.vw_ProductCards;
SELECT TOP 5 * FROM dbo.vw_BestSellingProducts ORDER BY TotalSold DESC;
SELECT * FROM dbo.vw_LookbookDetail ORDER BY LookbookSortOrder, ItemSortOrder;
SELECT * FROM dbo.vw_LookbookProducts ORDER BY LookbookId, SortOrder, ProductId;
SELECT * FROM dbo.vw_StockOverview ORDER BY ProductName, Size;
SELECT * FROM dbo.vw_StockReceiptSummary ORDER BY CreatedAt DESC;
SELECT TOP 50 * FROM dbo.vw_StockMovementDetail ORDER BY CreatedAt DESC;
SELECT * FROM dbo.vw_CouponSummary ORDER BY CreatedAt DESC;
SELECT * FROM dbo.vw_VoucherDetail ORDER BY CreatedAt DESC;
SELECT TOP 50 OrderId, Username, Status, PaymentMethod, PaymentStatus, PaidAt, TotalAmount, CreatedAt FROM dbo.vw_OrderSummary ORDER BY CreatedAt DESC;
SELECT AccountId, Username, Email, Role, BranchId, ManagerId, IsActive, CreatedAt FROM dbo.Accounts ORDER BY AccountId;
SELECT PageId, Slug, Title, FooterGroup, SortOrder, IsActive FROM dbo.SitePages ORDER BY FooterGroup DESC, SortOrder;
GO