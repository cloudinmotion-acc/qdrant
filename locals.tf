data "kubernetes_service_v1" "qdrant" {
  count = 1

  metadata {
    name      = local.service_name
    namespace = var.namespace
  }

  depends_on = [helm_release.qdrant]
}

locals {
  # Naming convention based on environment and project3
  release_name = "${var.platform_output.system_name}-qdrant"
  service_name = "${var.platform_output.system_name}-qdrant"

  # Default tags
  common_labels = {
    environment = var.platform_output.environment_type
    project     = var.platform_output.system_name
  }

  # Merge common tags with provided tags
  all_tags = merge(
    local.common_labels,
    var.common_tags
  )

  # Helm values for Qdrant
  helm_values = {
    # Replica configuration
    replicaCount = var.replica_count

    # StatefulSet specific settings
    statefulset = {
      enabled = true
    }

    # Image configuration
    image = {
      repository = "qdrant/qdrant"
      tag        = var.qdrant_version
      pullPolicy = "IfNotPresent"
    }

    # Service configuration
    service = {
      type = var.service_type
      name = local.service_name
      port = 6333
      # Annotations to prevent external exposure by default
      annotations = var.service_type == "LoadBalancer" ? {} : {
        "service.spec.externalTrafficPolicy" = "Local"
      }
    }

    # Persistence configuration
    persistence = {
      enabled      = var.persistence_enabled
      storageClass = var.storage_class_name
      size         = var.storage_size
      # Use default path from Qdrant Helm chart
      mountPath = "/qdrant/storage"
    }

    # Resource requests and limits
    resources = {
      requests = {
        cpu    = var.cpu_request
        memory = var.memory_request
      }
      limits = {
        cpu    = var.cpu_limit
        memory = var.memory_limit
      }
    }

    # Pod annotations for tagging
    podAnnotations = {
      "environment" = var.platform_output.environment_type
      "deployed_at" = timestamp()
    }

    # Labels
    labels = local.all_tags

    # Security context
    securityContext = {
      runAsNonRoot = true
      runAsUser    = 1000
      fsGroup      = 1000
    }

    # Pod security standards
    podSecurityPolicy = {
      enabled = false
    }

    # Health checks
    livenessProbe = {
      enabled = true
      httpGet = {
        path = "/health"
        port = 6333
      }
      initialDelaySeconds = 30
      periodSeconds       = 10
      timeoutSeconds      = 5
      failureThreshold    = 3
    }

    readinessProbe = {
      enabled = true
      httpGet = {
        path = "/read_only"
        port = 6333
      }
      initialDelaySeconds = 10
      periodSeconds       = 5
      timeoutSeconds      = 5
      failureThreshold    = 3
    }
  }
}