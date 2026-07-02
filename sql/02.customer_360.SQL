--Most Active Customers
SELECT
    c.customer_id,
    c.full_name,
    c.segment,
    COUNT(*) AS transaction_count,
    SUM(f.amount) AS total_amount,
    AVG(f.amount) AS average_amount
FROM fact_transactions f
JOIN dim_customers c
ON f.customer_id=c.customer_id
GROUP BY
    c.customer_id,
    c.full_name,
    c.segment
ORDER BY
    transaction_count DESC;
	
--Customer Distribution by Segment
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    COUNT(f.transaction_id) AS total_transactions,
    SUM(f.amount) AS total_amount
FROM dim_customers c
LEFT JOIN fact_transactions f
ON c.customer_id=f.customer_id
GROUP BY c.segment;	