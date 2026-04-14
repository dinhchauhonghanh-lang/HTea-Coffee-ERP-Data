USE H_Tea_Coffee_DB;
GO

/* MASTER DATA EXPORT FOR EXCEL DASHBOARD
M?c tiêu: K?t h?p t?t c? các b?ng Master và Transaction thành m?t ngu?n d? li?u duy nh?t.
*/

SELECT 
    H.Order_ID,
    H.Order_Date,
    C.Customer_Name,
    C.Customer_Group,
    C.City,
    P.Product_Name,
    P.Category,
    I.Order_Quantity,
    I.Net_Price,
    (I.Order_Quantity * I.Net_Price) AS Line_Total, -- Doanh thu t?ng dòng hàng
    Inv.Payment_Status
FROM Sales_Order_Header H
JOIN Customer_Master C ON H.Customer_ID = C.Customer_ID
JOIN Sales_Order_Item I ON H.Order_ID = I.Order_ID
JOIN Product_Master P ON I.Product_ID = P.Product_ID
LEFT JOIN Customer_Invoice Inv ON H.Order_ID = Inv.Order_ID; -- Dùng Left Join ?? l?y c? ??n ch?a xu?t hóa ??n