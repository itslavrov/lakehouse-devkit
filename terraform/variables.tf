variable "image_id" {
  type        = string
  description = "ID of the Packer-built image."
}

variable "internal_network_id" {
  type        = string
  description = "ID of the internal VK Cloud network used by the instance."
}

variable "external_network_name" {
  type        = string
  description = "External network name used for allocating a Floating IP."
}

variable "instance_name" {
  type        = string
  description = "Name of the compute instance."
  default     = "local-lakehouse"
}

variable "flavor_name" {
  type        = string
  description = "Flavor name used for the VM."
  default     = "STD3-4-16"
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the instance."
  default     = "MS1"
}
