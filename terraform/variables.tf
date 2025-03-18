variable "api_key" {
  type        = string
  description = "mgc api key"
}

variable "vpc_id" {
  type        = string
  description = "tenant vpc id"
}

variable "ssh_key_path" {
  type        = string
  default     = "~/.ssh/mgc.pub"
  description = "path of public key in this computers"
}

variable "machine_image" {
  type        = string
  default     = "cloud-ubuntu-22.04 LTS"
  description = "virtual machine image"
}

variable "swarm_machine_type" {
  type        = string
  default     = "BV2-4-10"
  description = "swarm node flavor"
}

variable "worker_count" {
  type        = number
  default     = 0
  description = "number of woker nodes in the cluster"
}

variable "manager_count" {
  type        = number
  default     = 3 
  description = "number of leader in the cluster"
}