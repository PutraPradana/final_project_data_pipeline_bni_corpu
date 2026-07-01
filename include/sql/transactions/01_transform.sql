-- ============================================================================
-- Transform: stg_transactions -> fact_transactions
--
-- Joins:
--   - dim_accounts
--   - dim_customers
--   - dim_branches
--   - dim_channels
--   - dim_date
--   - stg_fraud_labels
--
-- Purpose:
--   Populate the fact table for Transaction Analytics dashboards.
-- ============================================================================

TRUNCATE TABLE fact_transactions;

INSERT INTO fact_transactions (

    transaction_id,
    transaction_code,

    account_id,
    customer_id,
    branch_id,
    channel_id,
    date_id,

    transaction_date,
    transaction_at,

    transaction_type,
    status,

    amount,
    balance_before,
    balance_after,

    reference_no,

    is_fraud,
    fraud_type,
    fraud_score,
    flagged_at,

    amount_segment,
    transaction_hour

)

SELECT DISTINCT ON (t.transaction_id)

    t.transaction_id,
    t.transaction_code,

    a.account_id,
    c.customer_id,
    b.branch_id,
    ch.channel_id,
    d.date_id,

    t.transaction_date::DATE,
    t.transaction_at::TIMESTAMP,

    UPPER(t.transaction_type),
    UPPER(t.status),

    t.amount,
    t.balance_before,
    t.balance_after,

    t.reference_no,

    COALESCE(
        CASE
            WHEN LOWER(f.is_fraud) = 'true'
            THEN TRUE
            ELSE FALSE
        END,
        FALSE
    ) AS is_fraud,

    f.fraud_type,
    f.fraud_score,
    f.flagged_at,

    --------------------------------------------------------------------------
    -- Derived: Amount Segment
    --------------------------------------------------------------------------
    CASE
        WHEN t.amount < 1000000 THEN 'Small'
        WHEN t.amount < 10000000 THEN 'Medium'
        WHEN t.amount < 50000000 THEN 'Large'
        ELSE 'Very Large'
    END AS amount_segment,

    --------------------------------------------------------------------------
    -- Derived: Transaction Hour
    --------------------------------------------------------------------------
    EXTRACT(HOUR FROM t.transaction_at)::SMALLINT AS transaction_hour

FROM stg_transactions t

INNER JOIN dim_accounts a
    ON t.account_id = a.account_id

INNER JOIN dim_customers c
    ON t.customer_id = c.customer_id

INNER JOIN dim_branches b
    ON t.branch_id = b.branch_id

INNER JOIN dim_channels ch
    ON t.channel_id = ch.channel_id

INNER JOIN dim_date d
    ON t.transaction_date = d.full_date

LEFT JOIN stg_fraud_labels f
    ON t.transaction_id = f.transaction_id

WHERE t.transaction_id IS NOT NULL

ORDER BY t.transaction_id;