--Daily Transaction Trend
SELECT
    d.full_date,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount
FROM fact_transactions f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY d.full_date
ORDER BY d.full_date;

--Weekly Transaction Trend
SELECT
    d.year,
    d.week_of_year,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount
FROM fact_transactions f
JOIN dim_date d
    ON f.date_id = d.date_id
GROUP BY
    d.year,
    d.week_of_year
ORDER BY
    d.year,
    d.week_of_year;
	
--Monthly Transaction Trend
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS total_transactions,
    SUM(f.amount) AS total_amount
FROM fact_transactions f
JOIN dim_date d
ON f.date_id=d.date_id
GROUP BY
    d.year,
    d.month,
    d.month_name
ORDER BY
    d.year,
    d.month;	