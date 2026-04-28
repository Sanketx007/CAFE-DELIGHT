-- ============================================================
-- CAFE DELIGHT - FULL DATABASE SCRIPT (SQL Server)
-- ============================================================
-- Database Name : CafeDelightDB
-- Created       : 2026-04-03
-- Description   : Complete database for Cafe Delight website
--                 including all tables, relationships, indexes,
--                 stored procedures, and sample seed data.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. CREATE DATABASE
-- ────────────────────────────────────────────────────────────
IF DB_ID('CafeDelightDB') IS NOT NULL
BEGIN
    ALTER DATABASE CafeDelightDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CafeDelightDB;
END
GO

CREATE DATABASE CafeDelightDB;
GO

USE CafeDelightDB;
GO

-- ────────────────────────────────────────────────────────────
-- 2. TABLES
-- ────────────────────────────────────────────────────────────

-- ========================
-- 2.1  Roles
-- ========================
CREATE TABLE Roles (
    RoleId      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    CreatedAt   DATETIME2 DEFAULT GETDATE()
);
GO

-- ========================
-- 2.2  Users (Customers + Admin)
-- ========================
CREATE TABLE Users (
    UserId        INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(150) NOT NULL,
    Email         NVARCHAR(255) NOT NULL UNIQUE,
    Phone         NVARCHAR(20) NULL,
    PasswordHash  NVARCHAR(512) NOT NULL,
    RoleId        INT NOT NULL DEFAULT 2,          -- 1 = Admin, 2 = Customer
    Status        NVARCHAR(20) NOT NULL DEFAULT 'Active',  -- Active | Blocked
    AvatarUrl     NVARCHAR(500) NULL,
    IsDeleted     BIT NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2 DEFAULT GETDATE(),
    UpdatedAt     DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId),
    CONSTRAINT CK_Users_Status CHECK (Status IN ('Active', 'Blocked'))
);
GO

-- ========================
-- 2.3  Categories
-- ========================
CREATE TABLE Categories (
    CategoryId    INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName  NVARCHAR(100) NOT NULL UNIQUE,
    Description   NVARCHAR(500) NULL,
    SortOrder     INT NOT NULL DEFAULT 0,
    IsActive      BIT NOT NULL DEFAULT 1,
    CreatedAt     DATETIME2 DEFAULT GETDATE()
);
GO

-- ========================
-- 2.4  Products (Menu Items)
-- ========================
CREATE TABLE Products (
    ProductId     INT IDENTITY(1,1) PRIMARY KEY,
    ProductName   NVARCHAR(200) NOT NULL,
    CategoryId    INT NOT NULL,
    Price         DECIMAL(10, 2) NOT NULL,
    Description   NVARCHAR(1000) NULL,
    ImageUrl      NVARCHAR(1000) NULL,
    Status        NVARCHAR(20) NOT NULL DEFAULT 'Active',  -- Active | Out of Stock
    IsDeleted     BIT NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2 DEFAULT GETDATE(),
    UpdatedAt     DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CK_Products_Status CHECK (Status IN ('Active', 'Out of Stock')),
    CONSTRAINT CK_Products_Price CHECK (Price >= 0)
);
GO

-- ========================
-- 2.5  Orders
-- ========================
CREATE TABLE Orders (
    OrderId       INT IDENTITY(1,1) PRIMARY KEY,
    OrderNumber   NVARCHAR(20) NOT NULL UNIQUE,    -- e.g. #ORD-0092
    UserId        INT NULL,                         -- NULL for guest checkout
    CustomerName  NVARCHAR(200) NOT NULL,
    Email         NVARCHAR(255) NULL,
    Phone         NVARCHAR(20) NULL,

    -- Shipping Address
    FirstName     NVARCHAR(100) NULL,
    LastName      NVARCHAR(100) NULL,
    Address       NVARCHAR(500) NULL,
    City          NVARCHAR(100) NULL,
    State         NVARCHAR(100) NULL,
    PostalCode    NVARCHAR(20) NULL,

    -- Payment
    PaymentMethod NVARCHAR(30) NOT NULL DEFAULT 'cod',  -- card | upi | cod
    CardLast4     NVARCHAR(4) NULL,

    -- Totals
    Subtotal      DECIMAL(10, 2) NOT NULL DEFAULT 0,
    TaxRate       DECIMAL(5, 2) NOT NULL DEFAULT 5.00,   -- 5% tax
    TaxAmount     DECIMAL(10, 2) NOT NULL DEFAULT 0,
    TotalAmount   DECIMAL(10, 2) NOT NULL DEFAULT 0,

    -- Status
    Status        NVARCHAR(20) NOT NULL DEFAULT 'Pending', -- Pending | Completed | Cancelled
    Notes         NVARCHAR(1000) NULL,

    CreatedAt     DATETIME2 DEFAULT GETDATE(),
    UpdatedAt     DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Orders_Status CHECK (Status IN ('Pending', 'Completed', 'Cancelled')),
    CONSTRAINT CK_Orders_PaymentMethod CHECK (PaymentMethod IN ('card', 'upi', 'cod'))
);
GO

-- ========================
-- 2.6  Order Items
-- ========================
CREATE TABLE OrderItems (
    OrderItemId   INT IDENTITY(1,1) PRIMARY KEY,
    OrderId       INT NOT NULL,
    ProductId     INT NULL,                         -- NULL if product was deleted
    ProductName   NVARCHAR(200) NOT NULL,           -- Snapshot of product name at order time
    Quantity      INT NOT NULL DEFAULT 1,
    UnitPrice     DECIMAL(10, 2) NOT NULL,
    TotalPrice    AS (Quantity * UnitPrice) PERSISTED,  -- Computed column

    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT CK_OrderItems_Quantity CHECK (Quantity > 0),
    CONSTRAINT CK_OrderItems_UnitPrice CHECK (UnitPrice >= 0)
);
GO

-- ========================
-- 2.7  Cart (Session-based)
-- ========================
CREATE TABLE CartItems (
    CartItemId    INT IDENTITY(1,1) PRIMARY KEY,
    SessionId     NVARCHAR(100) NOT NULL,           -- Browser session / cookie
    UserId        INT NULL,
    ProductId     INT NOT NULL,
    ProductName   NVARCHAR(200) NOT NULL,
    UnitPrice     DECIMAL(10, 2) NOT NULL,
    Quantity      INT NOT NULL DEFAULT 1,
    ImageUrl      NVARCHAR(1000) NULL,
    AddedAt       DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_CartItems_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
    CONSTRAINT FK_CartItems_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT CK_CartItems_Quantity CHECK (Quantity > 0)
);
GO

-- ========================
-- 2.8  Contact Messages
-- ========================
CREATE TABLE ContactMessages (
    MessageId     INT IDENTITY(1,1) PRIMARY KEY,
    FullName      NVARCHAR(150) NOT NULL,
    Email         NVARCHAR(255) NOT NULL,
    Subject       NVARCHAR(300) NULL,
    Message       NVARCHAR(MAX) NOT NULL,
    IsRead        BIT NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2 DEFAULT GETDATE()
);
GO

-- ========================
-- 2.9  Password Reset Tokens
-- ========================
CREATE TABLE PasswordResetTokens (
    TokenId       INT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT NOT NULL,
    Token         NVARCHAR(512) NOT NULL UNIQUE,
    ExpiresAt     DATETIME2 NOT NULL,
    IsUsed        BIT NOT NULL DEFAULT 0,
    CreatedAt     DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_PasswordReset_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
GO

-- ========================
-- 2.10  Admin Settings
-- ========================
CREATE TABLE AdminSettings (
    SettingId     INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey    NVARCHAR(100) NOT NULL UNIQUE,
    SettingValue  NVARCHAR(MAX) NULL,
    UpdatedAt     DATETIME2 DEFAULT GETDATE()
);
GO

-- ========================
-- 2.11  Admin Activity Log
-- ========================
CREATE TABLE AdminActivityLog (
    LogId         INT IDENTITY(1,1) PRIMARY KEY,
    UserId        INT NOT NULL,
    Action        NVARCHAR(100) NOT NULL,          -- e.g. 'Product Created', 'Order Deleted'
    EntityType    NVARCHAR(50) NULL,               -- e.g. 'Product', 'Order', 'User'
    EntityId      INT NULL,
    Details       NVARCHAR(MAX) NULL,
    CreatedAt     DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_ActivityLog_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
GO


-- ────────────────────────────────────────────────────────────
-- 3. INDEXES  (for performance)
-- ────────────────────────────────────────────────────────────
CREATE INDEX IX_Users_Email           ON Users(Email);
CREATE INDEX IX_Users_RoleId          ON Users(RoleId);
CREATE INDEX IX_Users_Status          ON Users(Status) WHERE IsDeleted = 0;

CREATE INDEX IX_Products_CategoryId   ON Products(CategoryId);
CREATE INDEX IX_Products_Status       ON Products(Status) WHERE IsDeleted = 0;
CREATE INDEX IX_Products_Name         ON Products(ProductName);

CREATE INDEX IX_Orders_UserId         ON Orders(UserId);
CREATE INDEX IX_Orders_Status         ON Orders(Status);
CREATE INDEX IX_Orders_OrderNumber    ON Orders(OrderNumber);
CREATE INDEX IX_Orders_CreatedAt      ON Orders(CreatedAt DESC);

CREATE INDEX IX_OrderItems_OrderId    ON OrderItems(OrderId);
CREATE INDEX IX_OrderItems_ProductId  ON OrderItems(ProductId);

CREATE INDEX IX_CartItems_SessionId   ON CartItems(SessionId);
CREATE INDEX IX_CartItems_UserId      ON CartItems(UserId);

CREATE INDEX IX_ContactMessages_IsRead ON ContactMessages(IsRead);
GO


-- ────────────────────────────────────────────────────────────
-- 4. SEED DATA
-- ────────────────────────────────────────────────────────────

-- 4.1  Roles
INSERT INTO Roles (RoleName, Description) VALUES
    ('Admin',    'Full access to admin panel, settings, and data management'),
    ('Customer', 'Regular customer who can browse menu, place orders, and manage their account');
GO

-- 4.2  Categories
INSERT INTO Categories (CategoryName, Description, SortOrder) VALUES
    ('Hot Coffee',       'Freshly brewed hot coffee beverages',              1),
    ('Cold Coffee',      'Chilled and iced coffee drinks',                   2),
    ('Iced Coffee',      'Coffee served over ice',                           3),
    ('Bakery',           'Freshly baked pastries, muffins, and breads',      4),
    ('Bakery & Snacks',  'Bakery items and light snacks',                    5),
    ('Beverages',        'Non-coffee beverages including teas and juices',   6);
GO

-- 4.3  Admin User  (Password: admin123 — hashed placeholder)
INSERT INTO Users (FullName, Email, Phone, PasswordHash, RoleId, Status) VALUES
    ('Admin User', 'admin@cafedelight.com', '+91 98765 43210',
     'HASH_admin123_PLACEHOLDER', 1, 'Active');
GO

-- 4.4  Sample Customer Users
INSERT INTO Users (FullName, Email, Phone, PasswordHash, RoleId, Status) VALUES
    ('Priya Sharma',     'priya.sharma@gmail.com',  '+91 99887 76655', 'HASH_password_PLACEHOLDER', 2, 'Active'),
    ('Maria Rodriguez',  'maria@gmail.com',         '+91 88776 65544', 'HASH_password_PLACEHOLDER', 2, 'Active'),
    ('Robert Johnson',   'robert@gmail.com',        '+91 77665 54433', 'HASH_password_PLACEHOLDER', 2, 'Blocked'),
    ('Amit Sharma',      'amit.sharma@gmail.com',   '+91 98765 12345', 'HASH_password_PLACEHOLDER', 2, 'Active'),
    ('Priya Verma',      'priya.verma@gmail.com',   '+91 98765 67890', 'HASH_password_PLACEHOLDER', 2, 'Active'),
    ('Rahul Singh',      'rahul.singh@gmail.com',   '+91 87654 32100', 'HASH_password_PLACEHOLDER', 2, 'Active'),
    ('Neha Patel',       'neha.patel@gmail.com',    '+91 76543 21000', 'HASH_password_PLACEHOLDER', 2, 'Active');
GO

-- 4.5  Products (Menu Items)
INSERT INTO Products (ProductName, CategoryId, Price, Description, ImageUrl, Status) VALUES
    ('Cappuccino',           1, 180.00,
     'Rich espresso with equal parts steamed milk and foam.',
     'https://images.pexels.com/photos/312418/pexels-photo-312418.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Hazelnut Latte',       1, 210.00,
     'Smooth espresso with nutty hazelnut syrup.',
     'https://images.pexels.com/photos/4109993/pexels-photo-4109993.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Double Espresso',      1, 140.00,
     'Strong, concentrated coffee served in a small cup.',
     'https://images.pexels.com/photos/2396220/pexels-photo-2396220.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Flat White',           1, 180.00,
     'Two shots of espresso with smooth micro-foam milk.',
     'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Americano',            1, 150.00,
     'Espresso mixed with hot water for a clean taste.',
     'https://images.pexels.com/photos/4109996/pexels-photo-4109996.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Iced Mocha',           2, 240.00,
     'Chilled coffee with chocolate syrup, milk, and ice.',
     'https://images.pexels.com/photos/4109744/pexels-photo-4109744.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Cold Brew',            2, 200.00,
     'Slow steeped, smooth, and naturally sweet cold coffee.',
     'https://images.pexels.com/photos/3736397/pexels-photo-3736397.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Caramel Macchiato',    2, 230.00,
     'Espresso, vanilla syrup, milk, and caramel drizzle.',
     'https://images.pexels.com/photos/302896/pexels-photo-302896.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Butter Croissant',     4, 120.00,
     'Flaky, golden-brown pastry made with pure butter.',
     'https://images.pexels.com/photos/1860209/pexels-photo-1860209.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Chocolate Muffin',     4, 170.00,
     'Moist chocolate muffin topped with dark choco chips.',
     'https://images.pexels.com/photos/6930269/pexels-photo-6930269.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active'),

    ('Blueberry Cheesecake', 5, 250.00,
     'Creamy cheesecake topped with fresh blueberry compote.',
     'https://images.pexels.com/photos/3026808/pexels-photo-3026808.jpeg?auto=compress&cs=tinysrgb&w=800',
     'Active');
GO

-- 4.6  Sample Orders
INSERT INTO Orders (OrderNumber, UserId, CustomerName, Email, Phone,
                    FirstName, LastName, Address, City, State, PostalCode,
                    PaymentMethod, Subtotal, TaxRate, TaxAmount, TotalAmount, Status, CreatedAt)
VALUES
    ('#ORD-0092', 5, 'Amit Sharma', 'amit.sharma@gmail.com', '+91 98765 12345',
     'Amit', 'Sharma', '45 MG Road', 'Mumbai', 'MH', '400001',
     'card', 428.57, 5.00, 21.43, 450.00, 'Completed', '2026-03-20 10:30:00'),

    ('#ORD-0093', 6, 'Priya Verma', 'priya.verma@gmail.com', '+91 98765 67890',
     'Priya', 'Verma', '12 Park Street', 'Delhi', 'DL', '110001',
     'upi', 209.52, 5.00, 10.48, 220.00, 'Pending', '2026-03-21 14:15:00'),

    ('#ORD-0094', 7, 'Rahul Singh', 'rahul.singh@gmail.com', '+91 87654 32100',
     'Rahul', 'Singh', '78 Sector 21', 'Noida', 'UP', '201301',
     'card', 819.05, 5.00, 40.95, 860.00, 'Completed', '2026-03-22 09:45:00'),

    ('#ORD-0095', 8, 'Neha Patel', 'neha.patel@gmail.com', '+91 76543 21000',
     'Neha', 'Patel', '33 SG Highway', 'Ahmedabad', 'GJ', '380015',
     'cod', 238.10, 5.00, 11.90, 250.00, 'Pending', '2026-03-23 16:00:00');
GO

-- 4.7  Order Items
-- Order #ORD-0092: 2x Cappuccino, 1x Croissant  => ₹180*2 + ₹120 = ₹480 (with tax ~₹450 given)
INSERT INTO OrderItems (OrderId, ProductId, ProductName, Quantity, UnitPrice) VALUES
    (1, 1, 'Cappuccino',       2, 180.00),
    (1, 9, 'Butter Croissant', 1, 120.00);

-- Order #ORD-0093: 1x Iced Latte (Hazelnut Latte)
INSERT INTO OrderItems (OrderId, ProductId, ProductName, Quantity, UnitPrice) VALUES
    (2, 2, 'Hazelnut Latte',   1, 210.00);

-- Order #ORD-0094: 4x Espresso, 2x Muffin
INSERT INTO OrderItems (OrderId, ProductId, ProductName, Quantity, UnitPrice) VALUES
    (3, 3, 'Double Espresso',  4, 140.00),
    (3, 10, 'Chocolate Muffin', 2, 170.00);

-- Order #ORD-0095: 1x Blueberry Cheesecake
INSERT INTO OrderItems (OrderId, ProductId, ProductName, Quantity, UnitPrice) VALUES
    (4, 11, 'Blueberry Cheesecake', 1, 250.00);
GO

-- 4.8  Sample Contact Messages
INSERT INTO ContactMessages (FullName, Email, Subject, Message, IsRead) VALUES
    ('Vikram Mehta', 'vikram@email.com', 'Catering inquiry',
     'Hi, I wanted to ask about catering options for a corporate event of 50 people. Do you offer bulk order discounts?', 0),
    ('Sneha Kapoor', 'sneha.k@email.com', 'Loved the coffee!',
     'Just wanted to say your Cappuccino is the best I have ever had! Keep up the amazing work.', 1),
    ('Arjun Reddy',  'arjun.r@email.com', 'Feedback on service',
     'The ambience is great but the waiting time was a bit long on Saturday afternoon. Otherwise everything was perfect.', 0);
GO

-- 4.9  Admin Settings
INSERT INTO AdminSettings (SettingKey, SettingValue) VALUES
    ('site_name',        'Cafe Delight'),
    ('site_email',       'hello@cafedelight.com'),
    ('site_phone',       '+1 (555) 123-4567'),
    ('site_address',     '123 Coffee Street, Flavor Town, NY 10012, United States'),
    ('tax_rate',         '5.00'),
    ('currency_symbol',  '₹'),
    ('opening_hours_weekday', '7:00 AM – 9:00 PM'),
    ('opening_hours_weekend', '8:00 AM – 10:00 PM');
GO


-- ────────────────────────────────────────────────────────────
-- 5. VIEWS  (for easy querying)
-- ────────────────────────────────────────────────────────────

-- 5.1  Active Products with Category Name
CREATE VIEW vw_ActiveProducts
AS
SELECT
    p.ProductId,
    p.ProductName,
    c.CategoryName,
    p.Price,
    p.Description,
    p.ImageUrl,
    p.Status,
    p.CreatedAt,
    p.UpdatedAt
FROM Products p
INNER JOIN Categories c ON p.CategoryId = c.CategoryId
WHERE p.IsDeleted = 0;
GO

-- 5.2  Active Users (non-deleted customers)
CREATE VIEW vw_ActiveUsers
AS
SELECT
    u.UserId,
    u.FullName,
    u.Email,
    u.Phone,
    r.RoleName,
    u.Status,
    u.CreatedAt
FROM Users u
INNER JOIN Roles r ON u.RoleId = r.RoleId
WHERE u.IsDeleted = 0;
GO

-- 5.3  Order Summary (for Admin Dashboard)
CREATE VIEW vw_OrderSummary
AS
SELECT
    o.OrderId,
    o.OrderNumber,
    o.CustomerName,
    o.Email,
    o.TotalAmount,
    o.Status,
    o.PaymentMethod,
    o.CreatedAt,
    STRING_AGG(
        CAST(oi.Quantity AS NVARCHAR) + 'x ' + oi.ProductName, ', '
    ) AS ItemsSummary
FROM Orders o
LEFT JOIN OrderItems oi ON o.OrderId = oi.OrderId
GROUP BY o.OrderId, o.OrderNumber, o.CustomerName, o.Email,
         o.TotalAmount, o.Status, o.PaymentMethod, o.CreatedAt;
GO

-- 5.4  Dashboard Statistics
CREATE VIEW vw_DashboardStats
AS
SELECT
    (SELECT COUNT(*)        FROM Orders)                              AS TotalOrders,
    (SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders)                 AS TotalRevenue,
    (SELECT COUNT(*)        FROM Products WHERE IsDeleted = 0)       AS TotalProducts,
    (SELECT COUNT(*)        FROM Users    WHERE IsDeleted = 0
                                          AND RoleId = 2)            AS TotalCustomers,
    (SELECT COUNT(*)        FROM Orders   WHERE Status = 'Pending')  AS PendingOrders,
    (SELECT COUNT(*)        FROM Orders   WHERE Status = 'Completed') AS CompletedOrders,
    (SELECT COUNT(*)        FROM ContactMessages WHERE IsRead = 0)   AS UnreadMessages;
GO


-- ────────────────────────────────────────────────────────────
-- 6. STORED PROCEDURES
-- ────────────────────────────────────────────────────────────

-- 6.1  Get All Active Products (optionally filtered by category)
CREATE PROCEDURE sp_GetProducts
    @CategoryId INT = NULL,
    @SearchTerm NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductId,
        p.ProductName,
        c.CategoryName,
        p.Price,
        p.Description,
        p.ImageUrl,
        p.Status,
        p.CreatedAt
    FROM Products p
    INNER JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE p.IsDeleted = 0
      AND (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
      AND (@SearchTerm IS NULL
           OR p.ProductName LIKE '%' + @SearchTerm + '%'
           OR c.CategoryName LIKE '%' + @SearchTerm + '%')
    ORDER BY c.SortOrder, p.ProductName;
END
GO

-- 6.2  Add Product
CREATE PROCEDURE sp_AddProduct
    @ProductName  NVARCHAR(200),
    @CategoryId   INT,
    @Price        DECIMAL(10,2),
    @Description  NVARCHAR(1000) = NULL,
    @ImageUrl     NVARCHAR(1000) = NULL,
    @Status       NVARCHAR(20)   = 'Active'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Products (ProductName, CategoryId, Price, Description, ImageUrl, Status)
    VALUES (@ProductName, @CategoryId, @Price, @Description, @ImageUrl, @Status);

    SELECT SCOPE_IDENTITY() AS NewProductId;
END
GO

-- 6.3  Update Product
CREATE PROCEDURE sp_UpdateProduct
    @ProductId    INT,
    @ProductName  NVARCHAR(200),
    @CategoryId   INT,
    @Price        DECIMAL(10,2),
    @Description  NVARCHAR(1000) = NULL,
    @ImageUrl     NVARCHAR(1000) = NULL,
    @Status       NVARCHAR(20)   = 'Active'
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Products
    SET ProductName = @ProductName,
        CategoryId  = @CategoryId,
        Price       = @Price,
        Description = @Description,
        ImageUrl    = @ImageUrl,
        Status      = @Status,
        UpdatedAt   = GETDATE()
    WHERE ProductId = @ProductId;
END
GO

-- 6.4  Soft Delete Product
CREATE PROCEDURE sp_DeleteProduct
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Products
    SET IsDeleted = 1, UpdatedAt = GETDATE()
    WHERE ProductId = @ProductId;
END
GO

-- 6.5  Create Order (with items)
CREATE PROCEDURE sp_CreateOrder
    @OrderNumber    NVARCHAR(20),
    @UserId         INT = NULL,
    @CustomerName   NVARCHAR(200),
    @Email          NVARCHAR(255) = NULL,
    @Phone          NVARCHAR(20)  = NULL,
    @FirstName      NVARCHAR(100) = NULL,
    @LastName       NVARCHAR(100) = NULL,
    @Address        NVARCHAR(500) = NULL,
    @City           NVARCHAR(100) = NULL,
    @State          NVARCHAR(100) = NULL,
    @PostalCode     NVARCHAR(20)  = NULL,
    @PaymentMethod  NVARCHAR(30)  = 'cod',
    @CardLast4      NVARCHAR(4)   = NULL,
    @Subtotal       DECIMAL(10,2),
    @TaxAmount      DECIMAL(10,2),
    @TotalAmount    DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Orders (OrderNumber, UserId, CustomerName, Email, Phone,
                        FirstName, LastName, Address, City, State, PostalCode,
                        PaymentMethod, CardLast4,
                        Subtotal, TaxRate, TaxAmount, TotalAmount, Status)
    VALUES (@OrderNumber, @UserId, @CustomerName, @Email, @Phone,
            @FirstName, @LastName, @Address, @City, @State, @PostalCode,
            @PaymentMethod, @CardLast4,
            @Subtotal, 5.00, @TaxAmount, @TotalAmount, 'Pending');

    SELECT SCOPE_IDENTITY() AS NewOrderId;
END
GO

-- 6.6  Add Order Item
CREATE PROCEDURE sp_AddOrderItem
    @OrderId     INT,
    @ProductId   INT = NULL,
    @ProductName NVARCHAR(200),
    @Quantity    INT,
    @UnitPrice   DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO OrderItems (OrderId, ProductId, ProductName, Quantity, UnitPrice)
    VALUES (@OrderId, @ProductId, @ProductName, @Quantity, @UnitPrice);
END
GO

-- 6.7  Update Order Status
CREATE PROCEDURE sp_UpdateOrderStatus
    @OrderId  INT,
    @Status   NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Orders
    SET Status    = @Status,
        UpdatedAt = GETDATE()
    WHERE OrderId = @OrderId;
END
GO

-- 6.8  Delete Order
CREATE PROCEDURE sp_DeleteOrder
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- OrderItems will be cascade-deleted
    DELETE FROM Orders WHERE OrderId = @OrderId;
END
GO

-- 6.9  Get Recent Orders (for Dashboard)
CREATE PROCEDURE sp_GetRecentOrders
    @Count INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Count)
        o.OrderId,
        o.OrderNumber,
        o.CustomerName,
        o.TotalAmount,
        o.Status,
        o.CreatedAt,
        STRING_AGG(
            CAST(oi.Quantity AS NVARCHAR) + 'x ' + oi.ProductName, ', '
        ) AS ItemsSummary
    FROM Orders o
    LEFT JOIN OrderItems oi ON o.OrderId = oi.OrderId
    GROUP BY o.OrderId, o.OrderNumber, o.CustomerName,
             o.TotalAmount, o.Status, o.CreatedAt
    ORDER BY o.CreatedAt DESC;
END
GO

-- 6.10  Register Customer
CREATE PROCEDURE sp_RegisterUser
    @FullName     NVARCHAR(150),
    @Email        NVARCHAR(255),
    @Phone        NVARCHAR(20)  = NULL,
    @PasswordHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        RAISERROR('A user with this email already exists.', 16, 1);
        RETURN;
    END

    INSERT INTO Users (FullName, Email, Phone, PasswordHash, RoleId, Status)
    VALUES (@FullName, @Email, @Phone, @PasswordHash, 2, 'Active');

    SELECT SCOPE_IDENTITY() AS NewUserId;
END
GO

-- 6.11  Authenticate User (Login)
CREATE PROCEDURE sp_AuthenticateUser
    @Email        NVARCHAR(255),
    @PasswordHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        UserId,
        FullName,
        Email,
        Phone,
        RoleId,
        Status
    FROM Users
    WHERE Email        = @Email
      AND PasswordHash = @PasswordHash
      AND IsDeleted    = 0
      AND Status       = 'Active';
END
GO

-- 6.12  Soft Delete User (Admin)
CREATE PROCEDURE sp_DeleteUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Users
    SET IsDeleted = 1, UpdatedAt = GETDATE()
    WHERE UserId = @UserId;
END
GO

-- 6.13  Get All Users (Admin Panel)
CREATE PROCEDURE sp_GetUsers
    @SearchTerm NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.UserId,
        u.FullName,
        u.Email,
        u.Phone,
        r.RoleName,
        u.Status,
        u.CreatedAt
    FROM Users u
    INNER JOIN Roles r ON u.RoleId = r.RoleId
    WHERE u.IsDeleted = 0
      AND u.RoleId = 2  -- Customers only
      AND (@SearchTerm IS NULL
           OR u.FullName LIKE '%' + @SearchTerm + '%'
           OR u.Email    LIKE '%' + @SearchTerm + '%')
    ORDER BY u.CreatedAt DESC;
END
GO

-- 6.14  Generate Next Order Number
CREATE PROCEDURE sp_GetNextOrderNumber
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxNum INT;
    SELECT @MaxNum = ISNULL(MAX(
        TRY_CAST(REPLACE(REPLACE(OrderNumber, '#ORD-', ''), ' ', '') AS INT)
    ), 91) FROM Orders;

    SELECT '#ORD-' + RIGHT('0000' + CAST(@MaxNum + 1 AS NVARCHAR), 4) AS NextOrderNumber;
END
GO

-- 6.15  Dashboard Stats
CREATE PROCEDURE sp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        (SELECT COUNT(*)                   FROM Orders)                              AS TotalOrders,
        (SELECT ISNULL(SUM(TotalAmount),0) FROM Orders)                              AS TotalRevenue,
        (SELECT COUNT(*)                   FROM Products WHERE IsDeleted = 0)        AS TotalProducts,
        (SELECT COUNT(*)                   FROM Users WHERE IsDeleted = 0 AND RoleId = 2) AS TotalUsers,
        (SELECT COUNT(*)                   FROM Orders WHERE Status = 'Pending')     AS PendingOrders,
        (SELECT COUNT(*)                   FROM Orders WHERE Status = 'Completed')   AS CompletedOrders;
END
GO

-- 6.16  Save Contact Message
CREATE PROCEDURE sp_SaveContactMessage
    @FullName NVARCHAR(150),
    @Email    NVARCHAR(255),
    @Subject  NVARCHAR(300) = NULL,
    @Message  NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ContactMessages (FullName, Email, Subject, Message)
    VALUES (@FullName, @Email, @Subject, @Message);

    SELECT SCOPE_IDENTITY() AS NewMessageId;
END
GO

-- 6.17  Update Admin Password
CREATE PROCEDURE sp_UpdateAdminPassword
    @UserId          INT,
    @OldPasswordHash NVARCHAR(512),
    @NewPasswordHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE UserId = @UserId AND PasswordHash = @OldPasswordHash)
    BEGIN
        RAISERROR('Current password is incorrect.', 16, 1);
        RETURN;
    END

    UPDATE Users
    SET PasswordHash = @NewPasswordHash,
        UpdatedAt    = GETDATE()
    WHERE UserId = @UserId;

    SELECT 'Password updated successfully.' AS Message;
END
GO

-- 6.18  Cart Operations
CREATE PROCEDURE sp_AddToCart
    @SessionId   NVARCHAR(100),
    @UserId      INT = NULL,
    @ProductId   INT,
    @Quantity    INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Name  NVARCHAR(200), @Price DECIMAL(10,2), @Image NVARCHAR(1000);

    SELECT @Name  = ProductName,
           @Price = Price,
           @Image = ImageUrl
    FROM Products
    WHERE ProductId = @ProductId AND IsDeleted = 0;

    IF @Name IS NULL
    BEGIN
        RAISERROR('Product not found or is unavailable.', 16, 1);
        RETURN;
    END

    -- If item already in cart, increment quantity
    IF EXISTS (SELECT 1 FROM CartItems WHERE SessionId = @SessionId AND ProductId = @ProductId)
    BEGIN
        UPDATE CartItems
        SET Quantity = Quantity + @Quantity
        WHERE SessionId = @SessionId AND ProductId = @ProductId;
    END
    ELSE
    BEGIN
        INSERT INTO CartItems (SessionId, UserId, ProductId, ProductName, UnitPrice, Quantity, ImageUrl)
        VALUES (@SessionId, @UserId, @ProductId, @Name, @Price, @Quantity, @Image);
    END
END
GO

CREATE PROCEDURE sp_GetCartItems
    @SessionId NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ci.CartItemId,
        ci.ProductId,
        ci.ProductName,
        ci.UnitPrice,
        ci.Quantity,
        (ci.UnitPrice * ci.Quantity) AS TotalPrice,
        ci.ImageUrl
    FROM CartItems ci
    WHERE ci.SessionId = @SessionId
    ORDER BY ci.AddedAt;
END
GO

CREATE PROCEDURE sp_ClearCart
    @SessionId NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM CartItems WHERE SessionId = @SessionId;
END
GO


-- ────────────────────────────────────────────────────────────
-- 7. TRIGGERS
-- ────────────────────────────────────────────────────────────

-- Auto-update the UpdatedAt timestamp on Products
CREATE TRIGGER trg_Products_UpdateTimestamp
ON Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Products
    SET UpdatedAt = GETDATE()
    FROM Products p
    INNER JOIN inserted i ON p.ProductId = i.ProductId;
END
GO

-- Auto-update the UpdatedAt timestamp on Orders
CREATE TRIGGER trg_Orders_UpdateTimestamp
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders
    SET UpdatedAt = GETDATE()
    FROM Orders o
    INNER JOIN inserted i ON o.OrderId = i.OrderId;
END
GO


-- ────────────────────────────────────────────────────────────
-- 8. VERIFICATION QUERIES
-- ────────────────────────────────────────────────────────────
PRINT '========================================';
PRINT '  Cafe Delight Database Created!';
PRINT '========================================';
PRINT '';

-- Show table row counts
SELECT 'Roles'            AS TableName, COUNT(*) AS [RowCount] FROM Roles
UNION ALL
SELECT 'Users'            AS TableName, COUNT(*) AS [RowCount] FROM Users
UNION ALL
SELECT 'Categories'       AS TableName, COUNT(*) AS [RowCount] FROM Categories
UNION ALL
SELECT 'Products'         AS TableName, COUNT(*) AS [RowCount] FROM Products
UNION ALL
SELECT 'Orders'           AS TableName, COUNT(*) AS [RowCount] FROM Orders
UNION ALL
SELECT 'OrderItems'       AS TableName, COUNT(*) AS [RowCount] FROM OrderItems
UNION ALL
SELECT 'ContactMessages'  AS TableName, COUNT(*) AS [RowCount] FROM ContactMessages
UNION ALL
SELECT 'AdminSettings'    AS TableName, COUNT(*) AS [RowCount] FROM AdminSettings;
GO

-- Show dashboard stats
SELECT * FROM vw_DashboardStats;
GO

-- Show all products with categories
SELECT * FROM vw_ActiveProducts ORDER BY Price;
GO

-- Show order summary
SELECT * FROM vw_OrderSummary ORDER BY CreatedAt DESC;
GO

PRINT '';
PRINT '✅ All tables, views, stored procedures, triggers, and seed data created successfully!';
PRINT '';
GO
