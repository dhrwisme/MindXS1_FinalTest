CREATE database Final_Test

-- Câu 1
-- 1a
SELECT COUNT(Invoice_ID) AS Total_Order
FROM [dbo].[supermarket_sales]

-- 1b
SELECT Branch, ROUND(SUM(cogs),2) AS Sum_Sales
FROM [dbo].[supermarket_sales]
GROUP BY Branch

-- Câu 2
-- 2a
SELECT Product_line, ROUND(SUM(cogs),2) AS Sum_Sales, COUNT(Product_line) AS Total_Order
FROM [dbo].[supermarket_sales]
GROUP BY Product_line

-- 2b
SELECT Product_line, Customer_type, ROUND(SUM(cogs),2) AS Sum_Sales, COUNT(Product_line) AS Total_Order
FROM [dbo].[supermarket_sales]
GROUP BY Product_line, Customer_type

-- Câu 3
-- 3a
SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
FROM [dbo].[supermarket_sales] -- tạo table mới chứa cột tháng

SELECT TOP 1 new_month_column, SUM(cogs) AS total_rev_month
FROM (
    SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
    FROM [dbo].[supermarket_sales]
) AS new_table_1
GROUP BY new_month_column
ORDER BY total_rev_month DESC -- tháng 1 là tháng có doanh thu lớn nhất

SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
FROM [dbo].[supermarket_sales]
WHERE DATEPART(MONTH,[Date]) = (
    SELECT TOP 1 new_month_column
    FROM (
        SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
        FROM [dbo].[supermarket_sales]
    ) AS new_table_1
    GROUP BY new_month_column
    ORDER BY SUM(cogs) DESC
) -- tất cả các thông tin về tháng 1

SELECT DATEPART(HOUR,[Time]) AS new_hour_column, COUNT(DATEPART(HOUR,[Time])) AS Total_Order
FROM [dbo].[supermarket_sales]
WHERE DATEPART(MONTH,[Date]) = (
    SELECT TOP 1 new_month_column
    FROM (
        SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
        FROM [dbo].[supermarket_sales]
    ) AS new_table_1
    GROUP BY new_month_column
    ORDER BY SUM(cogs) DESC
)
GROUP BY DATEPART(HOUR,[Time]) -- tổng số lượt order theo giờ

SELECT AVG(Total_Order) AS avg_order_by_hour
FROM (
    SELECT DATEPART(HOUR,[Time]) AS new_hour_column, COUNT(DATEPART(HOUR,[Time])) AS Total_Order
    FROM [dbo].[supermarket_sales]
    WHERE DATEPART(MONTH,[Date]) = (
        SELECT TOP 1 new_month_column
        FROM (
            SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
            FROM [dbo].[supermarket_sales]
        ) AS new_table_1
        GROUP BY new_month_column
        ORDER BY SUM(cogs) DESC
    )
    GROUP BY DATEPART(HOUR,[Time])
) AS new_table_2 -- tìm ra trung bình 1 giờ có 32 order

SELECT *
FROM (
    SELECT DATEPART(HOUR,[Time]) AS new_hour_column, COUNT(DATEPART(HOUR,[Time])) AS Total_Order
    FROM [dbo].[supermarket_sales]
    WHERE DATEPART(MONTH,[Date]) = (
        SELECT TOP 1 new_month_column
        FROM (
            SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
            FROM [dbo].[supermarket_sales]
        ) AS new_table_1
        GROUP BY new_month_column
        ORDER BY SUM(cogs) DESC
    )
    GROUP BY DATEPART(HOUR,[Time])
) AS new_table_3
WHERE Total_Order > (
    SELECT AVG(Total_Order) AS avg_order_by_hour
    FROM (
        SELECT DATEPART(HOUR,[Time]) AS new_hour_column, COUNT(DATEPART(HOUR,[Time])) AS Total_Order
        FROM [dbo].[supermarket_sales]
        WHERE DATEPART(MONTH,[Date]) = (
            SELECT TOP 1 new_month_column
            FROM (
                SELECT *, DATEPART(MONTH,[Date]) AS new_month_column
                FROM [dbo].[supermarket_sales]
            ) AS new_table_1
            GROUP BY new_month_column
            ORDER BY SUM(cogs) DESC
        )
        GROUP BY DATEPART(HOUR,[Time])
    ) AS new_table_2
) -- kết hợp 2 table 1 và 2 để tìm ra new_hour_column nào có total order > trung bình order theo giờ

-- 3b
SELECT Product_line, Customer_type, SUM(cogs) AS SumSales, COUNT(Quantity) AS Total_Order
FROM [dbo].[supermarket_sales]
GROUP BY Product_line, Customer_type
ORDER BY Product_line, Customer_type -- thống kê với mỗi sản phẩm, mỗi loại khách hàng mua tổng bao nhiêu tiền và order

SELECT Product_line, Customer_type, SUM(cogs) AS SumSales, COUNT(Quantity) AS Total_Order
FROM [dbo].[supermarket_sales]
WHERE Customer_type = 'Member'
GROUP BY Product_line, Customer_type -- tạo table cho customer_type là member

SELECT Product_line, Customer_type, SUM(cogs) AS SumSales, COUNT(Quantity) AS Total_Order
FROM [dbo].[supermarket_sales]
WHERE Customer_type = 'Normal'
GROUP BY Product_line, Customer_type -- tạo table cho customer_type là normal

SELECT table_1.Product_line, table_1.cus_mem, table_1.mem_sales, table_1.mem_order,
    table_2.nor_mem, table_2.nor_sales, table_2.nor_order
FROM (
    SELECT Product_line, Customer_type AS cus_mem, SUM(cogs) AS mem_sales, COUNT(Quantity) AS mem_order
    FROM [dbo].[supermarket_sales]
    WHERE Customer_type = 'Member'
    GROUP BY Product_line, Customer_type
) AS table_1
LEFT JOIN (
    SELECT Product_line, Customer_type AS nor_mem, SUM(cogs) AS nor_sales, COUNT(Quantity) AS nor_order
    FROM [dbo].[supermarket_sales]
    WHERE Customer_type = 'Normal'
    GROUP BY Product_line, Customer_type
) AS table_2
ON table_1.Product_line = table_2.Product_line -- tạo 1 bảng nhưng customer_type và số lượng order được tách riêng

SELECT *
FROM (
    SELECT table_1.Product_line, table_1.cus_mem, table_1.mem_sales, table_1.mem_order,
        table_2.nor_mem, table_2.nor_sales, table_2.nor_order
    FROM (
        SELECT Product_line, Customer_type AS cus_mem, ROUND(SUM(cogs),2) AS mem_sales, COUNT(Quantity) AS mem_order
        FROM [dbo].[supermarket_sales]
        WHERE Customer_type = 'Member'
        GROUP BY Product_line, Customer_type
    ) AS table_1
    LEFT JOIN (
        SELECT Product_line, Customer_type AS nor_mem, ROUND(SUM(cogs),2) AS nor_sales, COUNT(Quantity) AS nor_order
        FROM [dbo].[supermarket_sales]
        WHERE Customer_type = 'Normal'
        GROUP BY Product_line, Customer_type
    ) AS table_2
    ON table_1.Product_line = table_2.Product_line
) AS new_table
WHERE (mem_sales > nor_sales and mem_order < nor_order) OR (mem_sales < nor_sales and mem_order > nor_order) -- lọc ra theo yêu cầu đề bài

-- Câu 4
SELECT DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
FROM [dbo].[supermarket_sales]
GROUP BY DATEPART(MONTH,[Date])
ORDER BY [Month] -- kiểm tra mỗi tháng total sales và total order là bao nhiêu

SELECT *
FROM (
    SELECT TOP 1000 DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
    FROM [dbo].[supermarket_sales]
    GROUP BY DATEPART(MONTH,[Date])
    ORDER BY [Month]
) AS current_table -- tạo bảng tổng quát

SELECT *
FROM (
    SELECT TOP 1000 DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
    FROM [dbo].[supermarket_sales]
    GROUP BY DATEPART(MONTH,[Date])
    ORDER BY [Month]
) AS current_table
EXCEPT
SELECT TOP 1 *
FROM (
    SELECT TOP 1000 DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
    FROM [dbo].[supermarket_sales]
    GROUP BY DATEPART(MONTH,[Date])
    ORDER BY [Month] DESC
) AS past_table -- tạo bảng thông tin các tháng trừ tháng cuối cùng

-- Final Code
SELECT current_table.[Month], current_table.SumSales, current_table.TotalOrder,
    past_table.SumSales AS Total_Sales_Before, past_table.TotalOrder AS Total_Order_Before
FROM (
    SELECT TOP 1000 DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
    FROM [dbo].[supermarket_sales]
    GROUP BY DATEPART(MONTH,[Date])
    ORDER BY [Month]
) AS current_table
LEFT JOIN (
    SELECT *
    FROM (
        SELECT TOP 1000 DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
        FROM [dbo].[supermarket_sales]
        GROUP BY DATEPART(MONTH,[Date])
        ORDER BY [Month]
    ) AS current_table
    EXCEPT
    SELECT TOP 1 *
    FROM (
        SELECT TOP 1000 DATEPART(MONTH,[Date]) AS Month, ROUND(SUM(cogs),2) AS SumSales, COUNT(DATEPART(MONTH,[Date])) AS TotalOrder
        FROM [dbo].[supermarket_sales]
        GROUP BY DATEPART(MONTH,[Date])
        ORDER BY [Month] DESC
    ) AS past_table_1
) AS past_table
ON current_table.[Month] - 1 = past_table.[Month] -- kết hợp current và past table với nhau