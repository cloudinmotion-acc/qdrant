output "qdrant_output" {
  description = "Qdrant output with service details and endpoints"
  value = {
    namespace         = var.namespace
    helm_release_name = helm_release.qdrant.name
    service_name      = "${local.service_name}"
    service_cluster_ip = try(
      data.kubernetes_service_v1.qdrant[0].spec[0].cluster_ip,
      "pending"
    )
    service_type                  = var.service_type
    replicas                      = var.replica_count
    persistence_enabled           = var.persistence_enabled
    storage_size                  = var.storage_size
    storage_class_name            = var.storage_class_name
    helm_chart_version            = helm_release.qdrant.version
    qdrant_endpoint_internal      = "http://${local.service_name}.${var.namespace}.svc.cluster.local:6333"
    qdrant_grpc_endpoint_internal = "http://${local.service_name}.${var.namespace}.svc.cluster.local:6334"
  }
}

output "mpp_report" {
  description = "MPP report for Qdrant deployment"
  value = {
    namespace         = var.namespace
    helm_release_name = helm_release.qdrant.name
    service_name      = "${local.service_name}"
    service_cluster_ip = try(
      data.kubernetes_service_v1.qdrant[0].spec[0].cluster_ip,
      "pending"
    )
    service_type                  = var.service_type
    replicas                      = var.replica_count
    persistence_enabled           = var.persistence_enabled
    storage_size                  = var.storage_size
    storage_class_name            = var.storage_class_name
    helm_chart_version            = helm_release.qdrant.version
    qdrant_endpoint_internal      = "http://${local.service_name}.${var.namespace}.svc.cluster.local:6333"
    qdrant_grpc_endpoint_internal = "http://${local.service_name}.${var.namespace}.svc.cluster.local:6334"
  }
}