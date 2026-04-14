/*
PROJECT: H-Tea & Coffee ERP Data Schema
AUTHOR: Cun
DATE: 2026-04
DESCRIPTION: SQL Server Script to initialize the O2C Database including Master Data, Sales Transactions, and Financial Invoices.
*/

-- 1. T?O DATABASE
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'H_Tea_Coffee_DB')
BEGIN
    CREATE DATABASE H_Tea_Coffee_DB;
END
GO
USE H_Tea_Coffee_DB;
GO

-- 2. T?O CÁC B?NG (Ch? có khóa chính - PK)
-- Xóa b?ng c? n?u t?n t?i (theo th? t? ng??c l?i ?? tránh l?i Foreign Key)
IF OBJECT_ID('Customer_Invoice', 'U') IS NOT NULL DROP TABLE Customer_Invoice;
IF OBJECT_ID('Sales_Order_Item', 'U') IS NOT NULL DROP TABLE Sales_Order_Item;
IF OBJECT_ID('Sales_Order_Header', 'U') IS NOT NULL DROP TABLE Sales_Order_Header;
IF OBJECT_ID('Customer_Master', 'U') IS NOT NULL DROP TABLE Customer_Master;
IF OBJECT_ID('Product_Master', 'U') IS NOT NULL DROP TABLE Product_Master;

CREATE TABLE Customer_Master (
    Customer_ID VARCHAR(10) PRIMARY KEY,
    Customer_Name NVARCHAR(100),
    Customer_Group NVARCHAR(20), -- Wholesale, Retail
    City NVARCHAR(50)
);

CREATE TABLE Product_Master (
    Product_ID VARCHAR(10) PRIMARY KEY,
    Product_Name NVARCHAR(100),
    Category NVARCHAR(20), -- Coffee, Tea
    Base_Unit NVARCHAR(10),
    Standard_Price DECIMAL(18,2)
);

CREATE TABLE Sales_Order_Header (
    Order_ID VARCHAR(15) PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(10),
    Total_Value DECIMAL(18,2)
);

CREATE TABLE Sales_Order_Item (
    Detail_ID INT PRIMARY KEY IDENTITY(1,1),
    Order_ID VARCHAR(15), 
    Product_ID VARCHAR(10),
    Order_Quantity DECIMAL(13,3),
    Net_Price DECIMAL(18,2),
    Batch_ID VARCHAR(20)
);

CREATE TABLE Customer_Invoice (
    Invoice_ID VARCHAR(15) PRIMARY KEY,
    Order_ID VARCHAR(15),
    Invoice_Date DATE,
    Final_Amount DECIMAL(18,2),
    Payment_Status NVARCHAR(15) -- Paid, Unpaid
);
GO

-- 3. THI?T L?P CÁC KHÓA NGO?I (FOREIGN KEYS) 

-- N?i ??n hàng v?i Khách hàng
ALTER TABLE Sales_Order_Header
ADD CONSTRAINT FK_Order_Customer 
FOREIGN KEY (Customer_ID) REFERENCES Customer_Master(Customer_ID);

-- N?i Chi ti?t ??n hàng v?i Header
ALTER TABLE Sales_Order_Item
ADD CONSTRAINT FK_Item_Order
FOREIGN KEY (Order_ID) REFERENCES Sales_Order_Header(Order_ID);

-- N?i Chi ti?t ??n hàng v?i S?n ph?m
ALTER TABLE Sales_Order_Item
ADD CONSTRAINT FK_Item_Product
FOREIGN KEY (Product_ID) REFERENCES Product_Master(Product_ID);

-- N?i Hóa ??n v?i ??n hàng
ALTER TABLE Customer_Invoice
ADD CONSTRAINT FK_Invoice_Order
FOREIGN KEY (Order_ID) REFERENCES Sales_Order_Header(Order_ID);
GO

-- 4. INSERT D? LI?U (DML)
-- Master Data
INSERT INTO Customer_Master VALUES 
('CUS001', N'Siêu th? WinMart', 'Wholesale', N'Hà N?i'),
('CUS002', N'??i lý Trung Nguyên', 'Wholesale', N'Buôn Ma Thu?t'),
('CUS003', N'C?a hàng H-Tea Q1', 'Retail', N'TP.HCM'),
('CUS004', N'Lotte Mart', 'Wholesale', N'TP.HCM'),
('CUS005', N'C?a hàng H-Tea Q7', 'Retail', N'TP.HCM');

INSERT INTO Product_Master VALUES 
('P001', N'Cà phê Arabica C?u ??t', 'Coffee', 'Bag 25kg', 5000000),
('P002', N'Trà Oolong Th??ng H?ng', 'Tea', 'Box', 250000),
('P003', N'Cà phê Robusta Honey', 'Coffee', 'Bag 25kg', 3500000),
('P004', N'Trà Sen Túi L?c', 'Tea', 'Box', 85000);

-- Sales_Order_Header (20 ??n hàng)
INSERT INTO Sales_Order_Header (Order_ID, Order_Date, Customer_ID, Total_Value) VALUES 
('SO001', '2026-03-01', 'CUS001', 15000000), ('SO002', '2026-03-02', 'CUS002', 7000000),
('SO003', '2026-03-03', 'CUS003', 500000), ('SO004', '2026-03-04', 'CUS004', 25000000),
('SO005', '2026-03-05', 'CUS005', 750000), ('SO006', '2026-03-06', 'CUS001', 10000000),
('SO007', '2026-03-07', 'CUS002', 10500000), ('SO008', '2026-03-08', 'CUS003', 250000),
('SO009', '2026-03-09', 'CUS004', 15000000), ('SO010', '2026-03-10', 'CUS005', 1250000),
('SO011', '2026-03-11', 'CUS001', 5000000), ('SO012', '2026-03-12', 'CUS002', 3500000),
('SO013', '2026-03-13', 'CUS003', 850000), ('SO014', '2026-03-14', 'CUS004', 50000000),
('SO015', '2026-03-15', 'CUS005', 170000), ('SO016', '2026-03-16', 'CUS001', 20000000),
('SO017', '2026-03-17', 'CUS002', 7000000), ('SO018', '2026-03-18', 'CUS003', 500000),
('SO019', '2026-03-19', 'CUS004', 35000000), ('SO020', '2026-03-20', 'CUS005', 250000);

-- Sales_Order_Item (20 dòng chi ti?t)
INSERT INTO Sales_Order_Item (Order_ID, Product_ID, Order_Quantity, Net_Price, Batch_ID) VALUES 
('SO001', 'P001', 3, 5000000, 'BATCH26_01'), ('SO002', 'P003', 2, 3500000, 'BATCH26_02'),
('SO003', 'P002', 2, 250000, 'BATCH26_01'), ('SO004', 'P001', 5, 5000000, 'BATCH26_03'),
('SO005', 'P002', 3, 250000, 'BATCH26_02'), ('SO006', 'P001', 2, 5000000, 'BATCH26_04'),
('SO007', 'P003', 3, 3500000, 'BATCH26_01'), ('SO008', 'P002', 1, 250000, 'BATCH26_03'),
('SO009', 'P001', 3, 5000000, 'BATCH26_02'), ('SO010', 'P002', 5, 250000, 'BATCH26_04'),
('SO011', 'P001', 1, 5000000, 'BATCH26_05'), ('SO012', 'P003', 1, 3500000, 'BATCH26_05'),
('SO013', 'P004', 10, 85000, 'BATCH26_01'), ('SO014', 'P001', 10, 5000000, 'BATCH26_06'),
('SO015', 'P004', 2, 85000, 'BATCH26_02'), ('SO016', 'P001', 4, 5000000, 'BATCH26_07'),
('SO017', 'P003', 2, 3500000, 'BATCH26_07'), ('SO018', 'P002', 2, 250000, 'BATCH26_05'),
('SO019', 'P001', 7, 5000000, 'BATCH26_08'), ('SO020', 'P002', 1, 250000, 'BATCH26_08');

-- Customer_Invoice (20 hóa ??n t??ng ?ng)
INSERT INTO Customer_Invoice (Invoice_ID, Order_ID, Invoice_Date, Final_Amount, Payment_Status) VALUES 
('INV001', 'SO001', '2026-03-05', 16500000, 'Paid'), ('INV002', 'SO002', '2026-03-06', 7700000, 'Unpaid'),
('INV003', 'SO003', '2026-03-07', 550000, 'Paid'), ('INV004', 'SO004', '2026-03-08', 27500000, 'Unpaid'),
('INV005', 'SO005', '2026-03-09', 825000, 'Paid'), ('INV006', 'SO006', '2026-03-10', 11000000, 'Paid'),
('INV007', 'SO007', '2026-03-11', 11550000, 'Unpaid'), ('INV008', 'SO008', '2026-03-12', 275000, 'Paid'),
('INV009', 'SO009', '2026-03-13', 16500000, 'Unpaid'), ('INV010', 'SO010', '2026-03-14', 1375000, 'Paid'),
('INV011', 'SO011', '2026-03-15', 5500000, 'Paid'), ('INV012', 'SO012', '2026-03-16', 3850000, 'Unpaid'),
('INV013', 'SO013', '2026-03-17', 935000, 'Paid'), ('INV014', 'SO014', '2026-03-18', 55000000, 'Unpaid'),
('INV015', 'SO015', '2026-03-19', 187000, 'Paid'), ('INV016', 'SO016', '2026-03-20', 22000000, 'Paid'),
('INV017', 'SO017', '2026-03-21', 7700000, 'Unpaid'), ('INV018', 'SO018', '2026-03-22', 550000, 'Paid'),
('INV019', 'SO019', '2026-03-23', 38500000, 'Unpaid'), ('INV020', 'SO020', '2026-03-24', 275000, 'Paid');
GO