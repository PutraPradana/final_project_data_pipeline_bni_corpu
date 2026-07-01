"""
dag_etl_fraud_labels.py
=======================

ETL pipeline:
fraud_labels.csv -> stg_fraud_labels

This staging table is later joined with stg_transactions
when loading fact_transactions.
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
    "fraud_labels.csv",
)

DDL_STATEMENTS = """
CREATE TABLE IF NOT EXISTS stg_fraud_labels (

    transaction_id      INTEGER,
    transaction_code    VARCHAR(30),
    is_fraud            VARCHAR(10),
    fraud_type          VARCHAR(50),
    fraud_score         NUMERIC(6,4),
    flagged_at          TIMESTAMP

);
"""


@dag(
    dag_id="dag_etl_fraud_labels",
    description="ETL fraud_labels.csv -> stg_fraud_labels",
    default_args={
        "owner": "airflow",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        "email_on_failure": False,
    },
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["etl", "fraud", "staging", "postgresql"],
)
def dag_etl_fraud_labels():

    # ----------------------------------------------------------------------
    # Create staging table
    # ----------------------------------------------------------------------
    create_tables = SQLExecuteQueryOperator(
        task_id="create_tables",
        conn_id=CONN_ID,
        sql=DDL_STATEMENTS,
    )

    # ----------------------------------------------------------------------
    # Load CSV -> stg_fraud_labels
    # ----------------------------------------------------------------------
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
                text("TRUNCATE TABLE stg_fraud_labels")
            )
            connection.commit()

        df.to_sql(
            name="stg_fraud_labels",
            con=engine,
            if_exists="append",
            index=False,
            method="multi",
            chunksize=1000,
        )

        engine.dispose()

        return len(df)

    create_tables >> extract_load()


dag_etl_fraud_labels()