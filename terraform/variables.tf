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
  default     = "BV4-16-40"
  description = "swarm node flavor"
}

variable "prometheus_node_machine_type" {
  type        = string
  default     = "BV8-32-100"
  description = "prometheus node flavor"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "tenant vpc id"
}

variable "worker_count" {
  type        = number
  default     = 6
  description = "number of woker nodes in the cluster"
}

variable "manager_count" {
  type        = number
  default     = 2 
  description = "number of leader in the cluster"
}