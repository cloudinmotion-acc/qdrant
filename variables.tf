variable "namespace" {
  description = "Kubernetes namespace for Qdrant deployment"
  type        = string
  default     = "qdrant"

  validation {
    condition     = length(var.namespace) > 0 && can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "Namespace must be a valid Kubernetes namespace name."
  }
}

variable "platform_output" {
  description = "Platform output variables (name, owner, environment_type, tags, system_name)"
  type = object({
    name             = string
    owner            = string
    environment_type = string
    tags             = map(string)
    system_name      = string
  })
}

variable "replica_count" {
  description = "Number of Qdrant replicas"
  type        = number
  default     = 1

  validation {
    condition     = var.replica_count > 0 && var.replica_count <= 10
    error_message = "Replica count must be between 1 and 10."
  }
}

variable "persistence_enabled" {
  description = "Enable persistent storage for Qdrant"
  type        = bool
  default     = true
}

variable "storage_size" {
  description = "Size of the persistent volume for Qdrant"
  type        = string
  default     = "20Gi"

  validation {
    condition     = can(regex("^[0-9]+(Gi|Ti|Mi)$", var.storage_size))
    error_message = "Storage size must be in format like 20Gi, 100Gi, 1Ti, etc."
  }
}

variable "storage_class_name" {
  description = "StorageClass name for persistent volumes (e.g., ebs-sc)"
  type        = string
  default     = "gp3"

  validation {
    condition     = length(var.storage_class_name) > 0
    error_message = "Storage class name must not be empty."
  }
}

variable "service_type" {
  description = "Kubernetes service type (ClusterIP or LoadBalancer)"
  type        = string
  default     = "ClusterIP"

  validation {
    condition     = contains(["ClusterIP", "LoadBalancer"], var.service_type)
    error_message = "Service type must be either ClusterIP or LoadBalancer."
  }
}

variable "cpu_request" {
  description = "CPU request for Qdrant container"
  type        = string
  default     = "250m"

  validation {
    condition     = can(regex("^[0-9]+m$|^[0-9]+$", var.cpu_request))
    error_message = "CPU request must be in millicores format (e.g., 250m, 1)."
  }
}

variable "memory_request" {
  description = "Memory request for Qdrant container"
  type        = string
  default     = "512Mi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.memory_request))
    error_message = "Memory request must be in format like 512Mi, 1Gi, etc."
  }
}

variable "cpu_limit" {
  description = "CPU limit for Qdrant container"
  type        = string
  default     = "1000m"

  validation {
    condition     = can(regex("^[0-9]+m$|^[0-9]+$", var.cpu_limit))
    error_message = "CPU limit must be in millicores format (e.g., 1000m, 2)."
  }
}

variable "memory_limit" {
  description = "Memory limit for Qdrant container"
  type        = string
  default     = "2Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.memory_limit))
    error_message = "Memory limit must be in format like 1Gi, 2Gi, etc."
  }
}

variable "qdrant_version" {
  description = "Qdrant Helm chart version"
  type        = string
  default     = "0.7.0"
}


variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "helm_values_override" {
  description = "Additional Helm values to override (as map)"
  type        = any
  default     = {}
}
