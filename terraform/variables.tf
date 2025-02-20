variable "api_key" {
  type        = string
  description = "mgc api key"
}

variable "ssh_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP3ZVdMwfp/G2xNX2U2gXTFoPallyXkKT1nbFpItLqfh augusto@wnlec-drlr6q3"
  description = "public key to insert to machines"
}

variable "ssh_key_path" {
  type        = string
  default     = "/home/augusto/.ssh/id_ed25519.pub"
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

variable "vpc_id" {
  type        = string
  default     = "ae9f55e8-7ab6-4d01-b746-a084dc423025"
  description = "tenant vpc id"
}

variable "worker_count" {
  type        = number
  default     = 2
  description = "number of woker nodes in the cluster"
}

variable "manager_count" {
  type        = number
  default     = 1
  description = "number of leader in the cluster"
}