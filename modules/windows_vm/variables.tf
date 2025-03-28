variable "vm_index" {
  description = "Index of the Windows VM"
  type        = number
}

variable "base_domain" {
  description = "Base domain for ingress routes"
  type        = string
}

variable "image" {
  description = "Docker image for Windows VM"
  type        = string
  default     = "dockur/windows"
}

variable "cpu_limit" {
  description = "CPU limit for the Windows VM"
  type        = string
  default     = "2"
}

variable "memory_limit" {
  description = "Memory limit for the Windows VM"
  type        = string
  default     = "4Gi"
}

variable "cpu_request" {
  description = "CPU request for the Windows VM"
  type        = string
  default     = "1"
}

variable "memory_request" {
  description = "Memory request for the Windows VM"
  type        = string
  default     = "2Gi"
}
