terraform {
  required_version = ">= 1.6.0"

  required_providers {
    vkcs = {
      source  = "vk-cs/vkcs"
      version = ">= 0.8.0, < 1.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}

resource "tls_private_key" "lakehouse_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "vkcs_compute_keypair" "lakehouse" {
  name       = "${var.instance_name}-key"
  public_key = tls_private_key.lakehouse_ssh.public_key_openssh
}

resource "vkcs_networking_secgroup" "lakehouse" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Local Lakehouse instance (open for development usage)"
}

resource "vkcs_networking_secgroup_rule" "lakehouse_ingress" {
  direction         = "ingress"
  security_group_id = vkcs_networking_secgroup.lakehouse.id
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "vkcs_networking_secgroup_rule" "lakehouse_egress" {
  direction         = "egress"
  security_group_id = vkcs_networking_secgroup.lakehouse.id
  remote_ip_prefix  = "0.0.0.0/0"
}

data "vkcs_compute_flavor" "lakehouse" {
  name = var.flavor_name
}

resource "vkcs_networking_floatingip" "lakehouse" {
  pool = var.external_network_name
}

resource "vkcs_compute_instance" "lakehouse" {
  name              = var.instance_name
  flavor_id         = data.vkcs_compute_flavor.lakehouse.id
  key_pair          = vkcs_compute_keypair.lakehouse.name
  availability_zone = var.availability_zone

  security_group_ids = [
    vkcs_networking_secgroup.lakehouse.id
  ]

  network {
    uuid = var.internal_network_id
  }

  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    destination_type      = "volume"
    volume_type           = "ceph-ssd"
    volume_size           = 50
    boot_index            = 0
    delete_on_termination = true
  }

  user_data = <<-EOF
  #cloud-config
  write_files:
    - path: /tmp/run-lakehouse.sh
      permissions: "0755"
      owner: root:root
      content: |
        #!/usr/bin/env bash
        set -e

        echo "[lakehouse] starting bootstrap scripts" >> /var/log/lakehouse-bootstrap.log

        if [ -x /opt/scripts/03-generate-env.sh ]; then
          echo "[lakehouse] running 03-generate-env.sh" >> /var/log/lakehouse-bootstrap.log
          /opt/scripts/03-generate-env.sh >> /var/log/lakehouse-bootstrap.log 2>&1
        else
          echo "[lakehouse] 03-generate-env.sh not found or not executable" >> /var/log/lakehouse-bootstrap.log
        fi

        if [ -x /opt/scripts/04-start-lakehouse.sh ]; then
          echo "[lakehouse] running 04-start-lakehouse.sh" >> /var/log/lakehouse-bootstrap.log
          /opt/scripts/04-start-lakehouse.sh >> /var/log/lakehouse-bootstrap.log 2>&1
        else
          echo "[lakehouse] 04-start-lakehouse.sh not found or not executable" >> /var/log/lakehouse-bootstrap.log
        fi

        echo "[lakehouse] bootstrap scripts finished" >> /var/log/lakehouse-bootstrap.log

  runcmd:
    - ["/tmp/run-lakehouse.sh"]
  EOF
}

resource "vkcs_compute_floatingip_associate" "lakehouse" {
  instance_id = vkcs_compute_instance.lakehouse.id
  floating_ip = vkcs_networking_floatingip.lakehouse.address
}