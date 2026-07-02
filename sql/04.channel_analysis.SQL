-- 04. Channel Analysis - Channel Usage
SELECT
    ch.channel_name,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount,
    AVG(f.amount) AS average_amount
FROM fact_transactions f
JOIN dim_channels ch
ON f.channel_id=ch.channel_id
GROUP BY ch.channel_name
ORDER BY total_transactions DESC;

--04. Channel Analysis - Channel Usage Trend
SELECT
    d.month_name,
    ch.channel_name,
    COUNT(*) total_transactions,
    SUM(f.amount) total_amount
FROM fact_transactions f
JOIN dim_channels ch
ON f.channel_id=ch.channel_id
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
    d.month_name,
    d.month,
    ch.channel_name
ORDER BY
    d.month,
    ch.channel_name;