
# Local Lakehouse

We will set up a lake house with MinIO as the backend storage, Iceberg as the table format, Project Nessie as the catalog for Iceberg, Trino as the query engine, dbt as the abstraction for SQL transformation, and finally, Airflow to glue everything together. For the sample data, we will use five input tables from the AdventureWorks sample dataset: product, product_category, product_subcategory, sale, and territories.
<img width="986" height="624" alt="image" src="https://github.com/user-attachments/assets/802f9857-0112-4296-a13a-d2e2c5fdb697" />
