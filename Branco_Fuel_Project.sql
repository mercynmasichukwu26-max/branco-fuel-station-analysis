CREATE DATABASE branco_fuel_project;
USE branco_fuel_project;
SELECT COUNT(*) FROM all_transactions_2025;
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE all_transactions_2025 ADD COLUMN Month_Number INT;

UPDATE all_transactions_2025
SET Month_Number = MONTH(STR_TO_DATE(Date, '%m/%d/%Y'));
ALTER TABLE all_transactions_2025 ADD COLUMN Quarter VARCHAR(5);

UPDATE all_transactions_2025
SET Quarter = CASE
    WHEN Month_Number <= 3 THEN 'Q1'
    WHEN Month_Number <= 6 THEN 'Q2'
    WHEN Month_Number <= 9 THEN 'Q3'
    ELSE 'Q4'
END;
ALTER TABLE all_transactions_2025 ADD COLUMN Day_Type VARCHAR(10);

UPDATE all_transactions_2025
SET Day_Type = CASE
    WHEN Day_Name IN ('Saturday', 'Sunday') THEN 'Weekend'
    ELSE 'Weekday'
END;
SELECT Transaction_ID, Total_Revenue, Total_Fuel_Cost 
FROM all_transactions_2025 
LIMIT 5;
ALTER TABLE all_transactions_2025 ADD COLUMN Gross_Profit DECIMAL(15,2);

UPDATE all_transactions_2025
SET Gross_Profit = Total_Revenue - Total_Fuel_Cost;
SELECT 
    Month_Number,
    SUM(Total_Revenue) AS Total_Revenue,
    SUM(Total_Fuel_Cost) AS Total_Fuel_Cost,
    SUM(Gross_Profit) AS Total_Gross_Profit
FROM all_transactions_2025
GROUP BY Month_Number
ORDER BY Month_Number;
SELECT 
    Month_Number,
    SUM(Total_Revenue) AS Total_Revenue
FROM all_transactions_2025
GROUP BY Month_Number
ORDER BY Total_Revenue DESC
LIMIT 1;
SELECT 
    Month_Number,
    SUM(Total_Revenue) AS Total_Revenue
FROM all_transactions_2025
GROUP BY Month_Number
ORDER BY Total_Revenue ASC
LIMIT 1;
SELECT 
    Fuel_Type,
    SUM(Total_Revenue) AS Total_Revenue
FROM all_transactions_2025
GROUP BY Fuel_Type
ORDER BY Total_Revenue DESC;
SELECT 
    Fuel_Type,
    SUM(Total_Revenue) AS Total_Revenue,
    ROUND(SUM(Total_Revenue) / (SELECT SUM(Total_Revenue) FROM all_transactions_2025) * 100, 2) AS Revenue_Percentage
FROM all_transactions_2025
GROUP BY Fuel_Type
ORDER BY Total_Revenue DESC;
SELECT 
    Vehicle_Type,
    SUM(Litres_Sold) AS Total_Litres
FROM all_transactions_2025
GROUP BY Vehicle_Type
ORDER BY Total_Litres DESC;
SELECT 
    Pump_Number,
    SUM(Litres_Sold) AS Total_Litres
FROM all_transactions_2025
GROUP BY Pump_Number
ORDER BY Total_Litres DESC
LIMIT 1;
SELECT 
    Payment_Method,
    COUNT(Transaction_ID) AS Total_Transactions
FROM all_transactions_2025
GROUP BY Payment_Method
ORDER BY Total_Transactions DESC;
SELECT 
    Attendant_Name,
    SUM(Total_Revenue) AS Total_Revenue
FROM all_transactions_2025
GROUP BY Attendant_Name
ORDER BY Total_Revenue DESC
LIMIT 1;
SELECT 
    Date,
    SUM(Total_Revenue) AS Daily_Revenue
FROM all_transactions_2025
GROUP BY Date
ORDER BY Daily_Revenue DESC
LIMIT 5;
SELECT 
    Month_Number,
    SUM(Litres_Sold) AS Total_Litres
FROM all_transactions_2025
WHERE Fuel_Type = 'DPK'
GROUP BY Month_Number
ORDER BY Month_Number;
SELECT 
    Quarter,
    SUM(Total_Revenue) AS Total_Revenue
FROM all_transactions_2025
GROUP BY Quarter
ORDER BY Total_Revenue DESC;
SELECT 
    Day_Type,
    SUM(Total_Revenue) AS Total_Revenue
FROM all_transactions_2025
GROUP BY Day_Type
ORDER BY Total_Revenue DESC;
SELECT 
    ROUND(SUM(Total_Revenue) / COUNT(DISTINCT Date), 2) AS Avg_Daily_Revenue
FROM all_transactions_2025;