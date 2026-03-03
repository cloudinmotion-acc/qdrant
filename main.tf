resource "kubernetes_namespace" "qdrant" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace

    labels = merge(
      local.all_tags,
      {
        name = var.namespace
      }
    )
  }
}

# Deploy Qdrant using Helm
resource "helm_release" "qdrant" {
  name             = local.release_name
  namespace        = var.namespace
  create_namespace = var.create_namespace
  chart            = "qdrant"
  repository       = "https://qdrant.to/helm"
  version          = var.qdrant_version
  wait             = true
  timeout          = 600

  # Merge default values with overrides
  values = [
    yamlencode(merge(
      local.helm_values,
      var.helm_values_override
    ))
  ]

  # Ensure namespace is created first if specified
  depends_on = var.create_namespace ? [
    kubernetes_namespace.qdrant
  ] : []
}

# Wait for StatefulSet to be ready
resource "null_resource" "wait_for_statefulset" {
  triggers = {
    helm_release = helm_release.qdrant.id
  }

  provisioner "local-exec" {
    command = "kubectl rollout status statefulset/${local.service_name} -n ${var.namespace} --timeout=10m"
  }

  depends_on = [helm_release.qdrant]
}
