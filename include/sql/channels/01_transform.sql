-- Transform: stg_channels → dim_channels
-- Cast data types, add derived columns, deduplicate

TRUNCATE TABLE dim_channels;

INSERT INTO dim_channels (
    channel_id,
    channel_code,
    channel_name,
    channel_category,
    is_digital,
    description,
    -- derived columns
    channel_type,
    channel_group
)
SELECT DISTINCT ON (channel_id)
    channel_id,
    channel_code,
    channel_name,
    UPPER(channel_category) AS channel_category,
    CASE
        WHEN LOWER(is_digital) = 'true' THEN TRUE
        ELSE FALSE
    END AS is_digital,
    description,

    -- derived column: readable channel type
    CASE
        WHEN LOWER(is_digital) = 'true' THEN 'Online'
        ELSE 'Offline'
    END AS channel_type,

    -- derived column: grouping
    CASE
        WHEN channel_code IN ('ATM', 'EDC') THEN 'Self Service'
        WHEN channel_code IN ('MB', 'IB') THEN 'Digital Banking'
        WHEN channel_code IN ('TELLER', 'CS') THEN 'Assisted Service'
        ELSE 'Other'
    END AS channel_group

FROM stg_channels
WHERE channel_id IS NOT NULL
ORDER BY channel_id;