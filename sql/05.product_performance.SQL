SELECT
    a.product_name,
    a.account_type,
    COUNT(*) total_transactions,
    SUM(f.amount) total_amount,
    AVG(f.balance_after) average_balance
FROM fact_transactions f
JOIN dim_accounts a
ON f.account_id=a.account_id
GROUP BY
    a.product_name,
    a.account_type
ORDER BY total_amount DESC;