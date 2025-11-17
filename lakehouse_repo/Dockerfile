FROM apache/airflow:3.0.6

USER airflow

COPY requirements-dbt.txt /requirements-dbt.txt

RUN pip install --no-cache-dir -r /requirements-dbt.txt

