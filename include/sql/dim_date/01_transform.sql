-- Transform: stg_date → dim_date
-- Cast data types, add derived columns, deduplicate

TRUNCATE TABLE dim_date;

INSERT INTO dim_date (
    date_id,
    full_date,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend,
    is_holiday,

    -- derived columns
    year_month,
    quarter_name,
    month_year,
    day_type
)

SELECT DISTINCT ON (date_id)

    date_id,
    full_date::DATE,
    year,
    quarter,
    month,
    month_name,
    week_of_year,
    day_of_month,
    day_of_week,
    day_name,

    CASE
        WHEN LOWER(is_weekend) = 'true' THEN TRUE
        ELSE FALSE
    END,

    CASE
        WHEN LOWER(is_holiday) = 'true' THEN TRUE
        ELSE FALSE
    END,

    -- YYYY-MM
    TO_CHAR(full_date::DATE, 'YYYY-MM') AS year_month,

    -- Quarter label
    'Q' || quarter AS quarter_name,

    -- Example: Januari 2023
    month_name || ' ' || year AS month_year,

    -- Working Day / Weekend / Holiday
    CASE
        WHEN LOWER(is_holiday) = 'true'
            THEN 'Holiday'
        WHEN LOWER(is_weekend) = 'true'
            THEN 'Weekend'
        ELSE 'Working Day'
    END AS day_type

FROM stg_date

WHERE date_id IS NOT NULL

ORDER BY date_id;