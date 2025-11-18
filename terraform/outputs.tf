output "public_ip" {
  description = "Public Floating IP of the lakehouse instance."
  value       = vkcs_networking_floatingip.lakehouse.address
}

output "ssh_private_key" {
  description = "Generated SSH private key for accessing the instance."
  value       = tls_private_key.lakehouse_ssh.private_key_pem
  sensitive   = true
}

output "ssh_public_key" {
  description = "Generated SSH public key imported into VKCS."
  value       = tls_private_key.lakehouse_ssh.public_key_openssh
}

output "lakehouse_endpoints" {
  description = "Common endpoints for the Lakehouse stack."
  value = {
    vm_ip     = vkcs_networking_floatingip.lakehouse.address
    minio     = "http://${vkcs_networking_floatingip.lakehouse.address}:9000"
    trino     = "http://${vkcs_networking_floatingip.lakehouse.address}:8080"
    airflow   = "http://${vkcs_networking_floatingip.lakehouse.address}:8081"
    home_path = "/opt/lakehouse_repo"
  }
}
