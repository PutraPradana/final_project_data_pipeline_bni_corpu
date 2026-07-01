-- Transform: stg_accounts → dim_accounts
-- Cast data types, add derived columns, deduplicate

TRUNCATE TABLE dim_accounts;

INSERT INTO dim_accounts (
    account_id,
    account_no,
    account_type,
    product_name,
    currency,
    open_date,
    close_date,
    status,
    interest_rate,
    customer_id,
    branch_id,

    -- derived columns
    account_age_years,
    account_status_group,
    interest_rate_segment
)

SELECT DISTINCT ON (account_id)

    account_id,
    account_no,
    UPPER(account_type),
    product_name,
    UPPER(currency),
    open_date::DATE,
    close_date::DATE,
    UPPER(status),
    interest_rate,
    customer_id,
    branch_id,

    -- Age of account
    DATE_PART(
        'year',
        AGE(
            COALESCE(close_date::DATE, CURRENT_DATE),
            open_date::DATE
        )
    )::SMALLINT AS account_age_years,

    -- Active / Inactive
    CASE
        WHEN UPPER(status) = 'ACTIVE'
            THEN 'Active'
        ELSE 'Inactive'
    END AS account_status_group,

    -- Interest rate segmentation
    CASE
        WHEN interest_rate < 2 THEN 'Low'
        WHEN interest_rate < 4 THEN 'Medium'
        WHEN interest_rate < 6 THEN 'High'
        ELSE 'Very High'
    END AS interest_rate_segment

FROM stg_accounts

WHERE account_id IS NOT NULL

ORDER BY account_id;