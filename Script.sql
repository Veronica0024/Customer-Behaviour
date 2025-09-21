USE Consumer;

select * from Customers2; 

/* CUSTOMER DEMOGRAPHIC & SEGMENTATIOON  : 
 *  Understand who the customers are by age, gender, and location. */


-- Age group distribution with total spend 
SELECT  
  CASE 
    WHEN Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Age BETWEEN 26 AND 35 THEN '26-35'
    WHEN Age BETWEEN 36 AND 45 THEN '36-45'
    WHEN Age BETWEEN 46 AND 55 THEN '46-55'
    WHEN Age > 55 THEN '55+'
    ELSE 'Unknown'
  END AS Age_Group,
  COUNT(`Customer ID`) AS Total_Customers,
  ROUND(SUM(`Purchase Amount (USD)`),2) AS Total_Spent
FROM Customers2
GROUP BY Age_Group
ORDER BY Age_Group;


-- Gender distribution with total spend
SELECT 
  Gender, 
  COUNT(`Customer ID`) AS Total_Customers, 
  ROUND(SUM(`Purchase Amount (USD)`),2) AS Total_Spent,
  ROUND(AVG(`Purchase Amount (USD)`),2) AS Avg_Spent
FROM Customers2
GROUP BY Gender;


-- Customers by location (top performing locations)
SELECT 
  Location, 
  COUNT(`Customer ID`) AS Total_Customers
FROM Customers2
GROUP BY Location
ORDER BY Total_Customers DESC;



/* PRODUCT & CATEGORY ANALYSIS  : 
 * Identify the most purchased items, revenue drivers, and purchase behaviors by category. */

-- Top 5 most purchased items
SELECT 
  `Item Purchased`, 
  COUNT(*) AS Item_Count, 
  SUM(`Purchase Amount (USD)`) AS Revenue
FROM Customers2
GROUP BY `Item Purchased`
ORDER BY Item_Count DESC
LIMIT 5;

-- Revenue by category
SELECT 
  Category, 
  SUM(`Purchase Amount (USD)`) AS Total_Revenue, 
  COUNT(`Customer ID`) AS Total_Sales,
  ROUND(AVG(`Purchase Amount (USD)`),2) AS Avg_Spent
FROM Customers2
GROUP BY Category
ORDER BY Total_Revenue DESC;

-- Purchase frequency by category
SELECT   
  Category, 
  `Frequency of Purchases`, 
  COUNT(*) AS Purchase_Count
FROM Customers2
GROUP BY Category, `Frequency of Purchases`
ORDER BY Category, Purchase_Count DESC;



/* SEASONAL BEHAVIOUR : 
 * See how customer behavior changes by season. */
-- Subscription sign-ups by season
SELECT 
  Season,
  ROUND(
    100.0 * COUNT(CASE WHEN `Subscription Status` = 'Yes' THEN 1 END) / COUNT(*), 2
  ) AS Subscription_Yes_Percentage
FROM Customers2
GROUP BY Season
ORDER BY Subscription_Yes_Percentage DESC;

-- Average spend by season
SELECT 
  Season, 
  ROUND(AVG(`Purchase Amount (USD)`),2) AS Avg_Spent, 
  COUNT(`Customer ID`) AS Orders
FROM Customers2
GROUP BY Season
ORDER BY Avg_Spent DESC;

-- Seasonal purchase frequency (most common per season)
WITH SeasonFrequency AS (
    SELECT 
        Season,
        `Frequency of Purchases`,
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Season ORDER BY COUNT(*) DESC) AS rn
    FROM Customers2
    GROUP BY Season, `Frequency of Purchases`
)
SELECT 
    Season,
    `Frequency of Purchases`,
    Frequency
FROM SeasonFrequency
WHERE rn = 1;

-- Urgent shipping by season
SELECT 
  Season, 
  COUNT(`Customer ID`) AS Total_Urgent_Shipping
FROM Customers2
WHERE `Shipping Type` IN ('Express', 'Next Day Air','2-Day Shipping')
GROUP BY Season
ORDER BY Total_Urgent_Shipping DESC;

/* DISCOUNTS, PROMOS & PRICING IMPACT : 
 * Understand how discounts and promo codes influence spending. */

-- Discount usage by age group
SELECT 
  CASE
    WHEN Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Age BETWEEN 26 AND 35 THEN '26-35'
    WHEN Age BETWEEN 36 AND 45 THEN '36-45'
    WHEN Age BETWEEN 46 AND 55 THEN '46-55'
    WHEN Age > 55 THEN '55+'
    ELSE 'Unknown'
  END AS Age_Group,
  `Discount Applied`,
  COUNT(*) AS Discount_Usage_Count
FROM Customers2
GROUP BY Age_Group, `Discount Applied`
ORDER BY Discount_Usage_Count DESC;

-- Promo code vs. average spend
SELECT 
  `Promo Code Used`, 
  ROUND(AVG(`Purchase Amount (USD)`), 2) AS Avg_Spent
FROM Customers2
GROUP BY `Promo Code Used`;

-- Discount + promo contribution to revenue
SELECT  
  `Promo Code Used`, 
  `Discount Applied`, 
  SUM(`Purchase Amount (USD)`) AS Total_Revenue,
  COUNT(*) AS Total_Orders
FROM Customers2
WHERE `Promo Code Used` = 'Yes' OR `Discount Applied` = 'Yes'
GROUP BY `Promo Code Used`, `Discount Applied`
ORDER BY Total_Revenue DESC;



/* CUSTOMER LOYALTY & RETENTION : 
 * Explore returning customers, subscriptions, and preferred payment methods. */

-- Average number of previous purchases by subscription status
SELECT 
  `Subscription Status`, 
  ROUND(AVG(`Previous Purchases`),2) AS Avg_Previous_Purchases
FROM Customers2 
GROUP BY `Subscription Status`;

-- Frequency of purchases vs. subscription
SELECT 
  `Frequency of Purchases`, 
  `Subscription Status`, 
  COUNT(*) AS Count_Customers
FROM Customers2
GROUP BY `Frequency of Purchases`, `Subscription Status`
ORDER BY `Frequency of Purchases` DESC;

-- Popular payment methods among frequent buyers
SELECT 
  `Payment Method`, 
  COUNT(*) AS Total_Customers
FROM Customers2
WHERE `Frequency of Purchases` IN ('Weekly', 'Fortnightly', 'Bi-Weekly')
GROUP BY `Payment Method`
ORDER BY Total_Customers DESC;


/* CUSTOMER SATISFACTION & REVIEWS : 
 * Check how reviews vary by category, gender, and discount usage.  */

-- Average review by age group
SELECT
  CASE
    WHEN Age BETWEEN 18 AND 25 THEN '18-25'
    WHEN Age BETWEEN 26 AND 35 THEN '26-35'
    WHEN Age BETWEEN 36 AND 45 THEN '36-45'
    WHEN Age BETWEEN 46 AND 55 THEN '46-55'
    WHEN Age > 55 THEN '55+'
    ELSE 'Unknown'
  END AS Age_Group,
  ROUND(AVG(`Review Rating`), 2) AS Avg_Review_Rating
FROM Customers2
GROUP BY Age_Group
ORDER BY Age_Group;

-- Average review by gender
SELECT
  Gender,
  ROUND(AVG(`Review Rating`), 2) AS Avg_Review_Rating
FROM Customers2
GROUP BY Gender;

-- Review ratings by category
SELECT  
  Category, 
  ROUND(AVG(`Review Rating`),2) AS Avg_Review
FROM Customers2
GROUP BY Category
ORDER BY Avg_Review DESC;

-- Discount impact on review ratings
SELECT 
  `Discount Applied`, 
  ROUND(AVG(`Review Rating`),2) AS Avg_Review_Rating
FROM Customers2 
GROUP BY `Discount Applied`;
