# Local Lakehouse Environment 

This repository contains a fully automated local Lakehouse setup built on **MinIO, Nessie, Trino, and Airflow**, combined with automation scripts for fast and repeatable deployment.

The repository consists of two main directories:

* **scripts/** — automation for dependency installation, environment generation, cloning/updating the Lakehouse repo, and starting/stopping the full stack
  (all scripts support `LAKEHOUSE_HOME`, defaulting to `/opt/lakehouse_repo`)

* **lakehouse_repo/** — the Lakehouse environment itself (Docker Compose files, Airflow Dockerfile, configs, DBT setup, and DAGs)

Using these components, you can deploy a complete local Lakehouse instance on a clean Ubuntu machine in minutes, with secure secret generation and a standardized, script-driven workflow.

This file provides a high-level overview.
Detailed usage instructions are available inside the **scripts/** and **lakehouse_repo/** directories.

---