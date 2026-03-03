# Qdrant EKS Terraform Module

A production-ready Terraform module for deploying Qdrant Vector Database on AWS EKS clusters using Helm.

## Features

✅ **Helm-based deployment** - Uses official Qdrant Helm chart
✅ **StatefulSet deployment** - Ensures data persistence and ordered rollouts
✅ **EBS-backed storage** - Persistent volumes with configurable StorageClass
✅ **Resource management** - Configurable CPU/memory requests and limits
✅ **Security** - Non-root user, security contexts, and pod security standards
✅ **High availability** - Pod anti-affinity for replica spread
✅ **Health checks** - Liveness and readiness probes configured
✅ **Best practices** - No hardcoded values, modular structure, CI/CD friendly

## Prerequisites

- AWS EKS cluster already created
- `kubectl` configured to access the cluster
- Terraform >= 1.0
- Helm provider configured in root module
- Kubernetes provider configured for the EKS cluster

## Module Structure

```
modules/qdrant/
├── main.tf           # Main module resources (Helm release, namespace, StatefulSet setup)
├── variables.tf      # Input variables with validation
├── outputs.tf        # Output values (service IP, endpoints, etc.)
└── versions.tf       # Provider version requirements
```

## Quick Start

### 1. Basic Usage (ClusterIP service)

```hcl
module "qdrant" {
  source = "./modules/qdrant"

  cluster_name   = "my-eks-cluster"
  namespace      = "qdrant"
  environment    = "dev"
  project_name   = "myapp"
  replica_count  = 1
}
```

### 2. Production Configuration (High Availability)

```hcl
module "qdrant" {
  source = "./modules/qdrant"

  cluster_name        = "prod-eks-cluster"
  namespace           = "qdrant"
  environment         = "prod"
  project_name        = "myapp"
  replica_count       = 3
  storage_size        = "100Gi"
  storage_class_name  = "ebs-sc"
  service_type        = "ClusterIP"
  cpu_request         = "1000m"
  memory_request      = "2Gi"
  cpu_limit           = "2000m"
  memory_limit        = "4Gi"
  qdrant_version      = "0.7.0"
}
```

## Input Variables

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `cluster_name` | Name of the EKS cluster | `string` | - | Yes |
| `namespace` | Kubernetes namespace | `string` | `"qdrant"` | No |
| `environment` | Environment name (dev, staging, prod) | `string` | - | Yes |
| `project_name` | Project name for tagging | `string` | - | Yes |
| `replica_count` | Number of Qdrant pods (1-10) | `number` | `1` | No |
| `persistence_enabled` | Enable persistent storage | `bool` | `true` | No |
| `storage_size` | Size of persistent volume | `string` | `"20Gi"` | No |
| `storage_class_name` | StorageClass name for EBS | `string` | `"gp3"` | No |
| `service_type` | Kubernetes service type | `string` | `"ClusterIP"` | No |
| `cpu_request` | CPU request (m = millicore) | `string` | `"250m"` | No |
| `memory_request` | Memory request | `string` | `"512Mi"` | No |
| `cpu_limit` | CPU limit | `string` | `"1000m"` | No |
| `memory_limit` | Memory limit | `string` | `"2Gi"` | No |
| `qdrant_version` | Helm chart version | `string` | `"0.7.0"` | No |
| `create_namespace` | Auto-create namespace | `bool` | `true` | No |
| `common_tags` | Additional tags for resources | `map(string)` | `{}` | No |
| `helm_values_override` | Override Helm chart values | `any` | `{}` | No |

## Output Values

| Output | Description |
|--------|-------------|
| `namespace` | Kubernetes namespace where Qdrant is deployed |
| `helm_release_name` | Helm release name |
| `service_name` | Kubernetes service name |
| `service_cluster_ip` | ClusterIP address of the service |
| `service_type` | Type of Kubernetes service |
| `replicas` | Number of deployed replicas |
| `persistence_enabled` | Whether persistence is enabled |
| `storage_size` | Size of persistent volumes |
| `storage_class_name` | StorageClass name used |
| `helm_chart_version` | Version of installed Helm chart |
| `qdrant_endpoint_internal` | Internal HTTP endpoint |
| `qdrant_grpc_endpoint_internal` | Internal gRPC endpoint |

## Examples

### Example 1: Development Environment

See `examples/dev/` for a complete working example.

```bash
cd examples/dev

# Initialize Terraform
terraform init

# Review planned changes
terraform plan -var-file="terraform.tfvars"

# Apply configuration
terraform apply -var-file="terraform.tfvars"
```

### Example 2: Staging with LoadBalancer

```hcl
module "qdrant_staging" {
  source = "./modules/qdrant"

  cluster_name       = "staging-eks"
  namespace          = "qdrant"
  environment        = "staging"
  project_name       = "myapp"
  replica_count      = 2
  service_type       = "LoadBalancer"  # Expose via load balancer
  storage_size       = "50Gi"
  storage_class_name = "ebs-sc"
  cpu_request        = "500m"
  memory_request     = "1Gi"
  cpu_limit          = "1500m"
  memory_limit       = "3Gi"
}
```

### Example 3: Custom Helm Values

```hcl
module "qdrant_custom" {
  source = "./modules/qdrant"

  cluster_name = "my-eks"
  environment  = "prod"
  project_name = "myapp"

  # Override specific Helm chart values
  helm_values_override = {
    qdrant = {
      apiKey = "your-api-key"  # Set API key for Qdrant
    }
    config = {
      log_level = "info"
    }
  }
}
```

## Persistent Storage

### EBS StorageClass Setup

Before deploying with EBS persistence, ensure your EKS cluster has an EBS StorageClass:

```bash
# Create EBS CSI Driver if not already installed
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm repo update
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  -n kube-system

# Create StorageClass for gp3 volumes
kubectl apply -f - <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gp3
provisioner: ebs.csi.aws.com
parameters:
  type: gp3
  iops: "3000"
  throughput: "125"
EOF
```

## Deployment

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review Changes
```bash
terraform plan
```

### 3. Deploy
```bash
terraform apply
```

### 4. Verify Deployment
```bash
# Check Helm release
helm list -n qdrant

# Check StatefulSet
kubectl get sts -n qdrant

# Check pods
kubectl get pods -n qdrant

# Check persistent volumes
kubectl get pvc -n qdrant

# Port forward to access Qdrant locally (dev only)
kubectl port-forward -n qdrant svc/myapp-qdrant 6333:6333
# Access at http://localhost:6333/docs
```

## Scaling

### Increase Replicas
```bash
terraform apply -var replica_count=3
```

### Increase Storage
```bash
# Update persistent volume claim
terraform apply -var storage_size=50Gi
```

## Networking

### Internal Access (ClusterIP)
From other pods in the cluster:
```
http://myapp-qdrant.qdrant.svc.cluster.local:6333
```

### External Access (LoadBalancer)
When `service_type = "LoadBalancer"`:
```bash
# Get external IP
kubectl get svc -n qdrant myapp-qdrant

# Connect via external IP
http://<EXTERNAL_IP>:6333
```

## Security Considerations

1. **No Public Exposure** - Services default to ClusterIP (internal only)
2. **Non-Root User** - Qdrant runs as user 1000
3. **Resource Limits** - Prevents resource exhaustion
4. **Health Checks** - Automatic pod recovery on failures
5. **Pod Anti-affinity** - Distributes replicas across nodes
6. **RBAC** - Configure additional RBAC policies as needed

### Additional Security Hardening

```hcl
# Add network policies for namespace isolation
module "qdrant" {
  # ... other configuration
  
  helm_values_override = {
    networkPolicy = {
      enabled = true
      ingress = [
        {
          from = [
            {
              podSelector = {
                matchLabels = {
                  "app" = "my-app"
                }
              }
            }
          ]
        }
      ]
    }
  }
}
```

## Monitoring & Logging

### Prometheus Metrics
Qdrant exposes metrics at `/metrics` endpoint:
```bash
kubectl port-forward -n qdrant svc/myapp-qdrant 6333:6333
# Access metrics at http://localhost:6333/metrics
```

### Logs
```bash
# View Qdrant logs
kubectl logs -n qdrant -l app=qdrant -f
```

## Troubleshooting

### Pods not starting
```bash
# Check pod status and events
kubectl describe pod -n qdrant <pod-name>

# Check logs
kubectl logs -n qdrant <pod-name>
```

### Storage issues
```bash
# Check PVC status
kubectl describe pvc -n qdrant

# Check StorageClass
kubectl get storageclass
```

### Helm release issues
```bash
# Check Helm release status
helm status myapp-qdrant -n qdrant

# Get Helm values
helm get values myapp-qdrant -n qdrant

# Rollback to previous release
helm rollback myapp-qdrant -n qdrant
```

## Cleanup

```bash
# Destroy Qdrant deployment
terraform destroy

# Manually clean up PVCs if needed
kubectl delete pvc -n qdrant --all
```

## CI/CD Integration

### GitLab CI Example
```yaml
deploy_qdrant:
  stage: deploy
  image: hashicorp/terraform:latest
  script:
    - cd terraform/examples/dev
    - terraform init
    - terraform plan -var-file="terraform.tfvars"
    - terraform apply -auto-approve
```

### GitHub Actions Example
```yaml
name: Deploy Qdrant
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v1
      - run: |
          cd terraform/examples/dev
          terraform init
          terraform plan
          terraform apply -auto-approve
```

## Best Practices Applied

✅ **No Hardcoded Values** - All values are variables
✅ **Input Validation** - Variables have validation rules
✅ **Naming Convention** - Consistent naming based on environment/project
✅ **Modular Design** - Easy to reuse across environments
✅ **Documentation** - Comprehensive comments in code
✅ **State Management** - Remote state support configured
✅ **DRY Principle** - Uses locals for derived values
✅ **Default Values** - Sensible defaults for all inputs

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Kubernetes Provider >= 2.20.0
- Helm Provider >= 2.10.0

## Support

For issues or questions related to:
- **Terraform Module** - Check variables and module configuration
- **Qdrant** - See [Qdrant Documentation](https://qdrant.tech/documentation/)
- **EKS** - See [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- **Helm Chart** - See [Qdrant Helm Chart](https://github.com/qdrant/qdrant-helm)

## License

This Terraform module is provided as-is for internal use.

---

**Last Updated**: March 2026
**Maintained By**: Platform Engineering Team
