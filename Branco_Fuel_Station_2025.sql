-- ============================================================
--  BRANCO FUEL STATION 2025 — MySQL Workbench Analysis Queries
--  Recreates all summary work done in Excel
-- ============================================================


-- ============================================================
-- STEP 1: CREATE DATABASE & TABLE
-- ============================================================

CREATE DATABASE IF NOT EXISTS branco_fuel;
USE branco_fuel;

CREATE TABLE IF NOT EXISTS transactions (
    Transaction_ID      VARCHAR(20)    PRIMARY KEY,
    Date                DATE,
    Day_Name            VARCHAR(15),
    Time                TIME,
    Pump_Number         INT,
    Fuel_Type           VARCHAR(10),
    Vehicle_Type        VARCHAR(20),
    Litres_Sold         DECIMAL(10,2),
    Price_Per_Litre     DECIMAL(10,2),
    Total_Revenue       DECIMAL(15,2),
    Fuel_Cost_Per_Litre DECIMAL(10,2),
    Total_Fuel_Cost     DECIMAL(15,2),
    Payment_Method      VARCHAR(20),
    Attendant_Name      VARCHAR(50),
    Opening_Meter       DECIMAL(12,2),
    Closing_Meter       DECIMAL(12,2),
    Net_Profit          DECIMAL(15,2),
    Remarks             VARCHAR(255)
);

-- NOTE: After creating the table, import your data using:
-- MySQL Workbench → Table Data Import Wizard → select your CSV export from Excel


-- ============================================================
-- STEP 2: ADD COMPUTED COLUMNS (mirrors Excel formula columns)
-- ============================================================

-- Add Quarter column (mirrors =IF(MONTH<=3,"Q1",...) in Excel)
ALTER TABLE transactions ADD COLUMN Quarter VARCHAR(5);
UPDATE transactions
SET Quarter = CASE
    WHEN MONTH(Date) <= 3 THEN 'Q1'
    WHEN MONTH(Date) <= 6 THEN 'Q2'
    WHEN MONTH(Date) <= 9 THEN 'Q3'
    ELSE 'Q4'
END;

-- Add Day_Type column (mirrors =IF(WEEKDAY>=6,"Weekend","Weekday") in Excel)
ALTER TABLE transactions ADD COLUMN Day_Type VARCHAR(10);
UPDATE transactions
SET Day_Type = CASE
    WHEN DAYOFWEEK(Date) IN (1, 7) THEN 'Weekend'
    ELSE 'Weekday'
END;

-- Add Gross_Profit column (mirrors =Total_Revenue - Total_Fuel_Cost in Excel)
ALTER TABLE transactions ADD COLUMN Gross_Profit DECIMAL(15,2);
UPDATE transactions
SET Gross_Profit = Total_Revenue - Total_Fuel_Cost;

-- Add Month_Name column (mirrors =TEXT(Date,"MMMM") in Excel)
ALTER TABLE transactions ADD COLUMN Month_Name VARCHAR(15);
UPDATE transactions
SET Month_Name = MONTHNAME(Date);


-- ============================================================
-- STEP 3: MONTHLY SUMMARY
-- (mirrors the Monthly_Summary sheet in Excel)
-- ============================================================

SELECT
    Month_Name                          AS Month,
    MONTH(Date)                         AS Month_Number,
    SUM(Total_Revenue)                  AS Total_Revenue,
    SUM(Total_Fuel_Cost)                AS Total_Fuel_Cost,
    SUM(Gross_Profit)                   AS Gross_Profit,
    COUNT(Transaction_ID)               AS Total_Transactions,
    SUM(Litres_Sold)                    AS Total_Litres_Sold
FROM transactions
GROUP BY Month_Name, MONTH(Date)
ORDER BY Month_Number;


-- ============================================================
-- STEP 4: FUEL TYPE ANALYSIS
-- (mirrors Sheet4 in Excel)
-- ============================================================

SELECT
    Fuel_Type,
    SUM(Total_Revenue)                              AS Total_Revenue,
    SUM(Litres_Sold)                                AS Total_Litres_Sold,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    ROUND(SUM(Total_Revenue) /
        (SELECT SUM(Total_Revenue) FROM transactions) * 100, 1) AS Revenue_Share_Pct
FROM transactions
GROUP BY Fuel_Type
ORDER BY Total_Revenue DESC;


-- ============================================================
-- STEP 5: VEHICLE TYPE ANALYSIS
-- (mirrors Sheet5 in Excel)
-- ============================================================

SELECT
    Vehicle_Type,
    SUM(Litres_Sold)                                AS Total_Litres_Sold,
    SUM(Total_Revenue)                              AS Total_Revenue,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    ROUND(SUM(Litres_Sold) /
        (SELECT SUM(Litres_Sold) FROM transactions) * 100, 1) AS Volume_Share_Pct
FROM transactions
GROUP BY Vehicle_Type
ORDER BY Total_Litres_Sold DESC;


-- ============================================================
-- STEP 6: PUMP PERFORMANCE
-- (mirrors Sheet6 in Excel)
-- ============================================================

SELECT
    Pump_Number,
    SUM(Litres_Sold)                                AS Total_Litres_Sold,
    SUM(Total_Revenue)                              AS Total_Revenue,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    ROUND(SUM(Litres_Sold) /
        (SELECT SUM(Litres_Sold) FROM transactions) * 100, 1) AS Volume_Share_Pct
FROM transactions
GROUP BY Pump_Number
ORDER BY Total_Litres_Sold DESC;


-- ============================================================
-- STEP 7: PAYMENT METHOD ANALYSIS
-- (mirrors Sheet7 in Excel)
-- ============================================================

SELECT
    Payment_Method,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    SUM(Total_Revenue)                              AS Total_Revenue,
    ROUND(COUNT(Transaction_ID) /
        (SELECT COUNT(*) FROM transactions) * 100, 1) AS Transaction_Share_Pct
FROM transactions
GROUP BY Payment_Method
ORDER BY Total_Transactions DESC;


-- ============================================================
-- STEP 8: ATTENDANT PERFORMANCE
-- (mirrors Sheet8 in Excel)
-- ============================================================

SELECT
    Attendant_Name,
    SUM(Total_Revenue)                              AS Total_Revenue,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    SUM(Litres_Sold)                                AS Total_Litres_Sold,
    ROUND(SUM(Total_Revenue) /
        (SELECT SUM(Total_Revenue) FROM transactions) * 100, 1) AS Revenue_Share_Pct
FROM transactions
GROUP BY Attendant_Name
ORDER BY Total_Revenue DESC;


-- ============================================================
-- STEP 9: WEEKDAY VS WEEKEND
-- (mirrors Sheet9 in Excel)
-- ============================================================

SELECT
    Day_Type,
    SUM(Total_Revenue)                              AS Total_Revenue,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    ROUND(SUM(Total_Revenue) /
        (SELECT SUM(Total_Revenue) FROM transactions) * 100, 1) AS Revenue_Share_Pct
FROM transactions
GROUP BY Day_Type
ORDER BY Total_Revenue DESC;


-- ============================================================
-- STEP 10: QUARTERLY SUMMARY
-- ============================================================

SELECT
    Quarter,
    SUM(Total_Revenue)                              AS Total_Revenue,
    SUM(Total_Fuel_Cost)                            AS Total_Fuel_Cost,
    SUM(Gross_Profit)                               AS Gross_Profit,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    SUM(Litres_Sold)                                AS Total_Litres_Sold
FROM transactions
GROUP BY Quarter
ORDER BY Quarter;


-- ============================================================
-- STEP 11: OVERALL KPI SUMMARY
-- (mirrors the Dashboard KPI cards in Excel)
-- ============================================================

SELECT
    SUM(Total_Revenue)                              AS Total_Annual_Revenue,
    SUM(Total_Fuel_Cost)                            AS Total_Fuel_Cost,
    SUM(Gross_Profit)                               AS Total_Gross_Profit,
    ROUND(SUM(Gross_Profit) /
        SUM(Total_Revenue) * 100, 2)                AS Gross_Margin_Pct,
    COUNT(Transaction_ID)                           AS Total_Transactions,
    SUM(Litres_Sold)                                AS Total_Litres_Sold,
    ROUND(AVG(Total_Revenue), 2)                    AS Avg_Transaction_Value,
    (SELECT Month_Name FROM transactions
        GROUP BY Month_Name ORDER BY SUM(Total_Revenue) DESC LIMIT 1)
                                                    AS Best_Month,
    (SELECT Fuel_Type FROM transactions
        GROUP BY Fuel_Type ORDER BY SUM(Total_Revenue) DESC LIMIT 1)
                                                    AS Top_Fuel_Type,
    (SELECT Attendant_Name FROM transactions
        GROUP BY Attendant_Name ORDER BY SUM(Total_Revenue) DESC LIMIT 1)
                                                    AS Top_Attendant
FROM transactions;


-- ============================================================
-- END OF SCRIPT
-- ============================================================
