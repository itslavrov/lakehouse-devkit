# Terraform Deployment 

This directory contains the Terraform configuration used to deploy a ready-to-run Local Lakehouse VM in VK Cloud.
The VM is provisioned with cloud-init, and after startup it automatically launches the full stack.

## 1. Requirements

Before running Terraform, create two files:

### **1. `auth.tf`**

Must contain your VK Cloud credentials:

```hcl
provider "vkcs" {
  username   = ""
  password   = ""
  project_id = ""
  region     = ""
}
```

### **2. `terraform.tfvars`**

Must include all deployment parameters, for example:

```hcl
image_id              = ""
internal_network_id   = ""
external_network_name = "internet"
instance_name         = "local-lakehouse"
flavor_name           = "STD3-4-16"
availability_zone     = "MS1"
```

(Use values from your environment. This file is intentionally excluded from Git.)

---

## 2. Deployment

Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

Terraform will:

* generate SSH keys
* create a Security Group
* create and configure the VM
* assign a Floating IP
* run the cloud-init bootstrap script on first boot

After `apply`, Terraform finishes — but the Lakehouse services still need some time to start inside the VM.

---

## 3. Connecting to the VM

Export the generated SSH key and connect:

```bash
terraform output -raw ssh_private_key > id_lakehouse
chmod 600 id_lakehouse

ssh -i id_lakehouse ubuntu@$(terraform output -raw public_ip)
```

---

## 4. Important: Wait for all services to start

Cloud-init runs the bootstrap scripts:

* `/opt/scripts/03-generate-env.sh`
* `/opt/scripts/04-start-lakehouse.sh`

These scripts:

* generate the `.env`
* build the Airflow image
* start all Docker services (MinIO, Nessie, Trino, Airflow, PostgreSQL, Redis)

Full initialization typically takes **2–5 minutes**.

Check progress:

```bash
sudo docker ps
sudo cat /var/log/lakehouse-bootstrap.log
```

The environment is ready when **all containers are UP and healthy**.

---

## 5. Destroying resources

```bash
terraform destroy
```
