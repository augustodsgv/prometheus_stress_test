variable "api_key" {
  type        = string
  default     = ""
  description = "mgc api key"
}

variable "ssh_key" {
  type        = string
  default     = ""
  description = "public key to insert to machines"
}

variable "ssh_key_path" {
  type        = string
  default     = ""
  description = "path of public key in this computers"
}

variable "machine_image" {
  type        = string
  default     = "cloud-ubuntu-22.04 LTS"
  description = "virtual machine image"
}

variable "swarm_machine_type" {
  type        = string
  default     = "BV4-8-100"
  description = "swarm node flavor"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "tenant vpc id"
}
