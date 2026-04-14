USE H_Tea_Coffee_DB;
GO 

/*PH?N 1: TRUY V?N C? B?N (Core Business Metrics)
M?c tiêu: N?m b?t nhanh tình hình ho?t ??ng kinh doanh thông qua các ch? s? c?t lõi.
Các truy v?n trong ph?n này t?p trung vào vi?c tr? l?i các câu h?i v?n hành h?ng ngày.
*/

/*Assignment 1: Theo dõi doanh thu hàng ngày (Daily Sales)
Logic:
- Gom nhóm d? li?u theo Order_Date ?? t?ng h?p theo t?ng ngày.
- S? d?ng COUNT(Order_ID) ?? ??m s? l??ng ??n hàng phát sinh m?i ngày.
- S? d?ng SUM(Total_Value) ?? tính t?ng doanh thu trong ngày ?ó.
- ORDER BY giúp s?p x?p d? li?u theo timeline ?? d? theo dõi xu h??ng.*/


SELECT 
    Order_Date, 
    COUNT(Order_ID) AS Total_Orders, 
    SUM(Total_Value) AS Daily_Revenue
FROM Sales_Order_Header
GROUP BY Order_Date
ORDER BY Order_Date;

/*Business Meaning:
- Giúp doanh nghi?p theo dõi bi?n ??ng doanh thu theo ngày.
- Phát hi?n các ngày có doanh thu cao/th?p b?t th??ng.
- H? tr? quy?t ??nh phân b? nhân s? giao hàng, kho v?n theo t?ng ngày cao ?i?m.
*/


/*Assignment 2: Phân tích ?óng góp c?a Khách hàng (Customer Contribution)
Logic:
- Join b?ng Customer_Master và Sales_Order_Header thông qua Customer_ID.
- Gom nhóm theo t?ng khách hàng ?? t?ng h?p toàn b? l?ch s? mua hàng.
- SUM(Total_Value) ??i di?n cho t?ng giá tr? chi tiêu (Lifetime Value - LTV).
- ORDER BY gi?m d?n ?? xác ??nh khách hàng mang l?i doanh thu cao nh?t.*/

SELECT 
    C.Customer_Name, 
    C.Customer_Group,
    SUM(H.Total_Value) AS Lifetime_Spend
FROM Customer_Master C
JOIN Sales_Order_Header H ON C.Customer_ID = H.Customer_ID
GROUP BY C.Customer_Name, C.Customer_Group
ORDER BY Lifetime_Spend DESC;
/*Business Meaning:
- Xác ??nh nhóm khách hàng chi?n l??c (key accounts).
- Phân bi?t khách Wholesale vs Retail d?a trên ?óng góp doanh thu.
- Là c? s? ?? xây d?ng chính sách chi?t kh?u, ch?m sóc khách hàng VIP.
*/


/*Assignment 3: Ki?m soát s?n l??ng tiêu th? (Product Volume)
Logic:
- S? d?ng b?ng Sales_Order_Item (c?p ?? chi ti?t) ?? l?y d? li?u s? l??ng bán th?c t?.
- Join v?i Product_Master ?? l?y thông tin tên s?n ph?m.
- SUM(Order_Quantity) ?? tính t?ng s? l??ng ?ã bán c?a t?ng s?n ph?m.
- ORDER BY gi?m d?n ?? tìm s?n ph?m bán ch?y nh?t.*/

SELECT 
    P.Product_Name, 
    SUM(I.Order_Quantity) AS Total_Qty_Sold
FROM Product_Master P
JOIN Sales_Order_Item I ON P.Product_ID = I.Product_ID
GROUP BY P.Product_Name
ORDER BY Total_Qty_Sold DESC;

/*Business Meaning:
- Xác ??nh s?n ph?m có nhu c?u cao trên th? tr??ng.
- H? tr? b? ph?n kho l?p k? ho?ch nh?p hàng và t?n kho.
- Tránh tình tr?ng thi?u hàng (stock-out) ??i v?i s?n ph?m bán ch?y.
*/


/*PH?N 2: TRUY V?N NÂNG CAO (Advanced Analytics)
M?c tiêu: Khai thác sâu h?n d? li?u b?ng Window Functions và CTEs ?? tìm ra insight ?n.
*/


/*Assignment 4: X?p h?ng s?n ph?m theo Danh m?c (Window Function - RANK)
Logic:
- T?o subquery ?? tính t?ng doanh thu cho t?ng s?n ph?m.
- S? d?ng RANK() OVER:
    + PARTITION BY Category ? chia d? li?u theo t?ng ngành hàng (Coffee, Tea).
    + ORDER BY Total_Revenue DESC ? x?p h?ng theo doanh thu gi?m d?n.
- K?t qu?: m?i s?n ph?m có th? h?ng riêng trong ngành hàng c?a nó.*/

SELECT 
    Category, Product_Name, Total_Revenue,
    RANK() OVER (PARTITION BY Category ORDER BY Total_Revenue DESC) AS Rank_In_Category
FROM (
    SELECT P.Category, P.Product_Name, SUM(I.Order_Quantity * I.Net_Price) AS Total_Revenue
    FROM Product_Master P
    JOIN Sales_Order_Item I ON P.Product_ID = I.Product_ID
    GROUP BY P.Category, P.Product_Name
) AS Sub_Sales;

/*Business Meaning:
- Xác ??nh “best-seller” trong t?ng danh m?c.
- So sánh hi?u su?t s?n ph?m trong cùng ngành hàng (không b? bias gi?a Coffee và Tea).
- H? tr? quy?t ??nh marketing và ?u tiên tr?ng bày s?n ph?m.
*/


/*Assignment 5: T?ng tr??ng doanh thu tích l?y (Running Total)
Logic:
- S? d?ng SUM() OVER v?i ORDER BY Order_Date ?? tính t?ng l?y k? theo th?i gian.
- ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW:
    + C?ng d?n t? dòng ??u tiên ??n dòng hi?n t?i.
- Không c?n GROUP BY vì ?ây là window function.*/

SELECT 
    Order_Date,
    Total_Value,
    SUM(Total_Value) OVER (ORDER BY Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Running_Total
FROM Sales_Order_Header;

/*Business Meaning:
- Theo dõi ti?n ?? ??t m?c tiêu doanh thu theo th?i gian.
- Phù h?p ?? v? bi?u ?? t?ng tr??ng (line chart) trong BI tools (Power BI, Excel).
- Giúp qu?n lý ?ánh giá t?c ?? t?ng tr??ng (growth momentum).
*/


/*Assignment 6: Phân tích giá tr? ??n hàng trung bình (AOV - Average Order Value)
Logic:
- S? d?ng CTE (Customer_Stats) ?? tách b??c tính toán:
    + COUNT(Order_ID) ? s? l??ng ??n hàng m?i khách.
    + SUM(Total_Value) ? t?ng chi tiêu.
- Sau ?ó join l?i v?i Customer_Master ?? l?y thông tin khách hàng.
- AOV = Total_Spent / Order_Count ? giá tr? trung bình m?i ??n hàng.*/

WITH Customer_Stats AS (
    SELECT 
        Customer_ID,
        COUNT(Order_ID) AS Order_Count,
        SUM(Total_Value) AS Total_Spent
    FROM Sales_Order_Header
    GROUP BY Customer_ID
)
SELECT 
    C.Customer_Name,
    S.Order_Count,
    S.Total_Spent,
    (S.Total_Spent / S.Order_Count) AS Avg_Order_Value
FROM Customer_Master C
JOIN Customer_Stats S ON C.Customer_ID = S.Customer_ID
ORDER BY Avg_Order_Value DESC;

/*Business Meaning:
- ?o l??ng “?? ch?u chi” c?a khách hàng trong m?i l?n mua.
- Phân bi?t:
    + Khách mua nhi?u ??n nh?
    + Khách mua ít nh?ng giá tr? cao
- H? tr? chi?n l??c upsell, cross-sell và cá nhân hóa bán hàng.
*/