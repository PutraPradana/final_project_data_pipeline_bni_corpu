SELECT
    b.branch_name,
    b.city,
    b.region,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount,
    AVG(f.amount) AS average_transaction
FROM fact_transactions f
JOIN dim_branches b
ON f.branch_id=b.branch_id
GROUP BY
    b.branch_name,
    b.city,
    b.region
ORDER BY total_amount DESC;