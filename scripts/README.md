## Local Lakehouse – Quick Intro

This repository contains two parts:

* **`scripts/`** – automation scripts for installing dependencies, preparing `.env`, pulling the lakehouse repo, and starting/stopping the entire stack.
* **`lakehouse_repo/`** – the actual lakehouse setup (MinIO, Nessie, Trino, Airflow), including updated Dockerfiles and Compose files.

### All scripts support the environment variable:
```bash
export LAKEHOUSE_HOME=/your/custom/path 
# default: /opt/lakehouse_repo
```
### How to Use

1. **Clone the scripts into `/opt/scripts`:**

```bash
sudo git clone https://github.com/itslavrov/local_lakehouse/tree/main/scripts /opt/scripts
sudo chmod +x /opt/scripts/*.sh
```

2. **Run the installation and setup scripts step-by-step:**

```bash
/opt/scripts/01-install-deps.sh
/opt/scripts/02-clone-lakehouse.sh
/opt/scripts/03-generate-env.sh   # or 03-regenerate-env.sh to rebuild env
/opt/scripts/04-start-lakehouse.sh
```

3. **Check status:**

```bash
/opt/scripts/05-status-lakehouse.sh
```

4. **Stop the stack:**

```bash
/opt/scripts/06-stop-lakehouse.sh
```

### What’s Included

* Cleaned & fixed Docker Compose files for MinIO, Nessie, Trino, and Airflow.
* Improved Dockerfile for Airflow with DBT installation.
* Automated `.env` generation with secure random secrets.
* Scripts for full lifecycle automation (install, pull, generate, start, status, stop).
