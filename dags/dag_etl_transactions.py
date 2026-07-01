"""
dag_etl_transactions.py
=======================

ETL pipeline:
transactions.csv
        │
        ▼
stg_transactions
        │
        ├──── LEFT JOIN stg_fraud_labels
        ▼
fact_transactions
"""

import os
from datetime import datetime, timedelta

import pandas as pd
from sqlalchemy import create_engine, text

from airflow.decorators import dag, task
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

CONN_ID = "postgres_etl"

SOURCE_FILE = os.path.join(
    os.path.dirname(__file__),
    "..",
    "include",
    "dataset",
    "transactions.csv",
)

DDL_STATEMENTS = """
CREATE TABLE IF NOT EXISTS stg_transactions (

    transaction_id INTEGER,
    transaction_code VARCHAR(30),

    account_id INTEGER,
    customer_id INTEGER,
    branch_id INTEGER,
    channel_id INTEGER,

    transaction_date DATE,
    transaction_at TIMESTAMP,

    transaction_type VARCHAR(30),

    amount NUMERIC(18,2),
    balance_before NUMERIC(18,2),
    balance_after NUMERIC(18,2),

    status VARCHAR(20),
    reference_no VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS fact_transactions (

    transaction_id INTEGER PRIMARY KEY,
    transaction_code VARCHAR(30),

    account_id INTEGER,
    customer_id INTEGER,
    branch_id INTEGER,
    channel_id INTEGER,
    date_id INTEGER,

    transaction_date DATE,
    transaction_at TIMESTAMP,

    transaction_type VARCHAR(30),

    amount NUMERIC(18,2),
    balance_before NUMERIC(18,2),
    balance_after NUMERIC(18,2),

    status VARCHAR(20),
    reference_no VARCHAR(50),

    is_fraud BOOLEAN,
    fraud_type VARCHAR(50),
    fraud_score NUMERIC(6,4),
    flagged_at TIMESTAMP,

    amount_segment VARCHAR(20),
    transaction_hour SMALLINT,

    etl_loaded_at TIMESTAMP DEFAULT NOW()
);
"""


@dag(
    dag_id="dag_etl_transactions",
    description="ETL transactions.csv -> stg_transactions -> fact_transactions",
    default_args={
        "owner": "airflow",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        "email_on_failure": False,
    },
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["etl", "fact", "transactions", "postgresql"],
    template_searchpath=[
        "/opt/airflow/include/sql/transactions"
    ],
)
def dag_etl_transactions():

    create_tables = SQLExecuteQueryOperator(
        task_id="create_tables",
        conn_id=CONN_ID,
        sql=DDL_STATEMENTS,
    )

    @task()
    def extract_load():

        from airflow.hooks.base import BaseHook

        conn = BaseHook.get_connection(CONN_ID)

        engine = create_engine(
            f"postgresql+psycopg2://{conn.login}:{conn.password}"
            f"@{conn.host}:{conn.port}/{conn.schema}"
        )

        df = pd.read_csv(SOURCE_FILE)

        with engine.connect() as connection:
            connection.execute(
                text("TRUNCATE TABLE stg_transactions")
            )
            connection.commit()

        df.to_sql(
            name="stg_transactions",
            con=engine,
            if_exists="append",
            index=False,
            method="multi",
            chunksize=1000,
        )

        engine.dispose()

        return len(df)

    transform = SQLExecuteQueryOperator(
        task_id="transform",
        conn_id=CONN_ID,
        sql="01_transform.sql",
    )

    create_tables >> extract_load() >> transform


dag_etl_transactions()