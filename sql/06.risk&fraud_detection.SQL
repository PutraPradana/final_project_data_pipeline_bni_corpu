--06. Risk & Fraud Detection - 	Fraud Detection
SELECT
    fraud_type,
    COUNT(*) total_cases,
    AVG(fraud_score) average_score,
    SUM(amount) total_amount
FROM fact_transactions
WHERE is_fraud=TRUE
GROUP BY fraud_type
ORDER BY total_cases DESC;

--06. Risk & Fraud Detection - Failed Transactions
SELECT
    d.month_name,
    COUNT(*) total_failed,
    SUM(amount) total_amount
FROM fact_transactions f
JOIN dim_date d
ON f.date_id=d.date_id
WHERE status='FAILED'
GROUP BY
    d.month_name,
    d.month
ORDER BY d.month;