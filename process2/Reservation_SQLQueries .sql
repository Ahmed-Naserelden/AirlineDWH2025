-- SQL Query Set for Revenue and Profit Analysis
-- 1. Total Revenue and Profit from Reservations
-- Query:
SELECT SUM(Revenue) AS Total_Revenue, 
     SUM(Profit) AS Total_Profit
FROM Reservation_Fact;

-- ________________
-- 2. Total Revenue and Profit by Reservation Channel
-- Query:
SELECT Reservation_Channel, 
SUM(Revenue) AS Total_Revenue, 
SUM(Profit) AS Total_Profit
FROM Reservation_Fact
GROUP BY Reservation_Channel;

-- ________________
-- 3. Most Profitable Airports
-- Which airports generate the highest profit? Query:
SELECT a.Airport_Name, 
a.City, a.Country, 
SUM(r.Profit) AS Total_Profit
FROM Reservation_Fact r
JOIN Airport_DIM a
ON r.Airport_Code = a.Airport_Code
GROUP BY a.Airport_Name, a.City, a.Country
ORDER BY Total_Profit DESC
LIMIT 10;

-- ________________
-- 4. Revenue and Profit per Airport
-- Query:
SELECT a.Airport_Name, 
     SUM(r.Revenue) AS Total_Revenue,
     SUM(r.Profit) AS Total_Profit
FROM Reservation_Fact r
JOIN Airport_DIM a ON r.Airport_Code = a.Airport_Code
GROUP BY a.Airport_Name;

-- ________________
-- 5. Monthly Revenue Trend
-- Query:
SELECT d.Calendar_Year, 
d.Fiscal_Month, 
SUM(r.Revenue) AS Total_Revenue
FROM Reservation_Fact r
JOIN Date_DIM d ON r.Date_ID = d.Date_Id
GROUP BY d.Calendar_Year, d.Fiscal_Month
ORDER BY d.Calendar_Year, d.Fiscal_Month;

-- ________________
-- 6. Promotions Contribution to Revenue
-- Query:
SELECT p.name AS Promotion_Name, 
SUM(r.Revenue) AS Total_Revenue
FROM Reservation_Fact r
JOIN Dim_Promotion p ON r.Promotion_ID = p.promotion_id
GROUP BY p.name
ORDER BY Total_Revenue DESC;

-- ________________
-- 7. Revenue and Cost Breakdown by Country
-- Query:

SELECT c.Country_Name, 
SUM(r.Revenue) AS Total_Revenue, 
SUM(r.Total_Cost) AS Total_Cost
FROM Reservation_Fact r
JOIN Date_DIM d ON r.Date_ID = d.Date_Id
JOIN Country_Specific_Date_Outrigger c ON d.Date_Id = c.Date_Key
GROUP BY c.Country_Name
ORDER BY Total_Revenue DESC;
-- ________________
-- 8. Revenue by Passenger Age Groups
-- Query:
SELECT p.age_category, 
SUM(r.Revenue) AS Total_Revenue
FROM Reservation_Fact r
JOIN Passenger_DIM p ON r.Passenger_ID = p.Passenger_ID
GROUP BY p.age_category
ORDER BY Total_Revenue DESC;
-- ________________
-- 9. Revenue and Profit by Airplane Model
-- Which airplane models contribute the most? Query:
SELECT d.model, 
SUM(r.Revenue) AS Total_Revenue, 
SUM(r.Profit) AS Total_Profit
FROM Reservation_Fact r
JOIN Dim_Airplane d ON r.Airplane_ID = d.Airplane_ID
GROUP BY d.model
ORDER BY Total_Profit DESC;
-- ________________
-- 10. Most Used Payment Methods
What are the most common payment methods? Query:
SELECT Payment_Method, 
COUNT(*) AS Number_of_Reservations, 
SUM(Revenue) AS Total_Revenue
FROM Reservation_Fact
GROUP BY Payment_Method
ORDER BY Number_of_Reservations DESC;
-- ________________
-- 11. Profitability of Reservation Channels
-- Which booking channels generate the most profit? Query:
SELECT Reservation_Channel, 
COUNT(*) AS Number_of_Reservations, 
SUM(Revenue) AS Total_Revenue, 
SUM(Profit) AS Total_Profit
FROM Reservation_Fact
GROUP BY Reservation_Channel
ORDER BY Total_Profit DESC;
-- ________________
-- 12. Total Revenue and Profit by Country
-- Which countries generate the highest revenue? Query:
SELECT a.Country, 
SUM(r.Revenue) AS Total_Revenue, 
SUM(r.Profit) AS Total_Profit
FROM Reservation_Fact r
JOIN Airport_DIM a ON r.Airport_Code = a.Airport_Code
GROUP BY a.Country
ORDER BY Total_Revenue DESC;
-- ________________
-- 13. Flight Distance vs. Profitability
-- How does flight distance affect revenue and profit? Query:
SELECT distance_in_miles, 
AVG(Revenue) AS Avg_Revenue, 
AVG(Profit) AS Avg_Profit
FROM Reservation_Fact
GROUP BY distance_in_miles
ORDER BY distance_in_miles;

-- ________________
-- 14. Seasonal Revenue and Profitability Analysis
-- How do different seasons impact revenue and profit? Query:
SELECT cs.Season_Name, 
SUM(r.Revenue) AS Total_Revenue, 
SUM(r.Profit) AS Total_Profit
FROM Reservation_Fact r
JOIN Date_DIM d ON r.Date_ID = d.Date_Id
JOIN Country-Specific Date Outrigger cs ON d.Date_Id = cs.Date_Key
GROUP BY cs.Season_Name
ORDER BY Total_Revenue DESC;