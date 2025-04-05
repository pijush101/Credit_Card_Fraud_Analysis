use credit_card_fraud;

select *
from fraud_dataset
Limit 1000;

-- Total Transactions and Fraud Breakdown--

SELECT 
    COUNT(*) AS total_transactions, -- Counts all transactions in the dataset.--
    SUM(CASE WHEN IsFraud = 1 THEN 1 ELSE 0 END) AS fraud_transactions  -- Counts only transactions labeled as fraudulent (IsFraud = 1).--
FROM fraud_dataset ;

-- Fraud Transactions by Amount Range--

SELECT 
    CASE 
        WHEN Amount < 100 THEN 'Low (<100)'
        WHEN Amount BETWEEN 100 AND 500 THEN 'Medium (100-1000)'
        ELSE 'High (>10000)'
    END AS amount_category,
    COUNT(*) AS fraud_count
FROM fraud_dataset
WHERE IsFraud = 1
GROUP BY amount_category
ORDER BY fraud_count DESC;

 -- What are the peak hours for fraudulent transactions? --

SELECT 
    HOUR(transactiondate) AS fraud_hour, 
    COUNT(*) AS fraud_count
FROM fraud_dataset
WHERE Isfraud = 1
GROUP BY fraud_hour
ORDER BY fraud_count DESC
LIMIT 10;



-- What is the total revenue and fraudulent revenue for the company? --

SELECT 
    SUM(Amount) AS total_revenue , 
    SUM(CASE WHEN IsFraud = 1 THEN amount ELSE 0 END) AS fraud_revenue
FROM fraud_dataset;

-- What percentage of total transactions are fraudulent?--

SELECT 
    (COUNT(CASE WHEN IsFraud = 1 THEN 1 END) * 100.0) / COUNT(*) AS fraud_percentage
FROM fraud_dataset;

-- Which country have the highest fraud rates?--

SELECT 
    Location, 
    COUNT(*) AS total_transactions, 
    SUM(CASE WHEN IsFraud = 1 THEN 1 ELSE 0 END) AS fraud_count, 
    (SUM(CASE WHEN IsFraud = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS fraud_rate
FROM fraud_dataset
GROUP BY Location
ORDER BY fraud_rate DESC
LIMIT 10;

--  Which locations have the highest number of fraudulent transactions? --

SELECT 
    location, 
    COUNT(*) AS fraud_count
FROM fraud_dataset
WHERE Isfraud = 1
GROUP BY location
ORDER BY fraud_count DESC
LIMIT 10;

--  Which Merchent (customers) have the highest number of fraudulent transactions? --

SELECT 
    MerchantID, 
    COUNT(*) AS fraud_count
FROM fraud_dataset
WHERE Isfraud = 1
GROUP BY MerchantID
ORDER BY fraud_count DESC
LIMIT 10;

--  How many fraudulent transactions happened within 5 minutes of another transaction on the same card? --

SELECT COUNT(*) AS rapid_fraud_transactions
FROM  fraud_dataset t1
JOIN fraud_dataset t2 
ON t1.MerchantID = t2.MerchantID
AND t1.transactionid <> t2.transactionid 
AND ABS(TIMESTAMPDIFF(MINUTE, t1.transactiondate, t2.transactiondate)) <= 5
WHERE t1.isfraud = 1 AND t2.isfraud = 1;

--  Which card numbers were used in different locations within a short period (possible fraud pattern)? --

SELECT 
    t1.MerchantID, 
    t1.location AS location_1, t1.transactiondate AS time_1, 
    t2.location AS location_2, t2.transactiondate AS time_2
FROM fraud_dataset t1
JOIN fraud_dataset t2 
ON t1.MerchantID = t2.MerchantID 
AND t1.location <> t2.location 
AND TIMESTAMPDIFF(HOUR, t1.transactiondate, t2.transactiondate) <= 2
WHERE t1.isfraud = 1;


