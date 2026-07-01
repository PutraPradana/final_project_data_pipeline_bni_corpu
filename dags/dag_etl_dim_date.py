"""
dag_etl_dim_date.py
===============
ETL pipeline:
dim_date.csv → stg_date → dim_date
"""

import os
from datetime import datetime, timedelta

import pandas as pd
from sqlalchemy import create_engine, text

from airflow.decorators import dag, task
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

# -----------------------------------------------------------------------------
CONN_ID = "postgres_etl"

SOURCE_FILE = os.path.join(
    os.path.dirname(__file__),
    "..",
    "include",
    "dataset",
    "dim_date.csv",
)

DDL_STATEMENTS = """
CREATE TABLE IF NOT EXISTS stg_date (
    date_id INTEGER,
    full_date DATE,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    week_of_year INTEGER,
    day_of_month INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    is_weekend VARCHAR(10),
    is_holiday VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id INTEGER,
    full_date DATE,
    year INTEGER,
    quarter INTEGER,
    month INTEGER,
    month_name VARCHAR(20),
    week_of_year INTEGER,
    day_of_month INTEGER,
    day_of_week INTEGER,
    day_name VARCHAR(20),
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,

    year_month VARCHAR(7),
    quarter_name VARCHAR(5),
    month_year VARCHAR(20),
    day_type VARCHAR(20),

    etl_loaded_at TIMESTAMP DEFAULT NOW()
);
"""


@dag(
    dag_id="dag_etl_dim_date",
    description="ETL dim_date.csv → stg_date → dim_date",
    default_args={
        "owner": "airflow",
        "retries": 1,
        "retry_delay": timedelta(minutes=5),
        "email_on_failure": False,
    },
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
    tags=["etl", "date", "dimension", "postgresql"],
    template_searchpath=["/opt/airflow/include/sql/dim_date"],
)
def dag_etl_dim_date():

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
            connection.execute(text("TRUNCATE TABLE stg_date"))
            connection.commit()

        df.to_sql(
            "stg_date",
            engine,
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


dag_etl_dim_date()