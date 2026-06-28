# setup-eks-v2

One-time provisioning role for the `ckan-v2` EKS cluster. Idempotent — safe to re-run if provisioning is interrupted.

## What it does

1. **Provisions the cluster** via `eksctl` (skipped if it already exists)
2. **Generates a kubeconfig** for `ckan-v2` at `~/.kube/ckan-v2_cluster_config`
3. **Stores cluster details** (CA, endpoint, ARN) in AWS Secrets Manager so the deploy role can build kubeconfigs without EKS API access
4. **Updates the RDS security group** to allow the new cluster nodes inbound on port 5432
5. **Updates the EFS mount target** to allow the new cluster nodes access
6. **Attaches `eks-secrets-access-policy`** to the node group IAM role
7. **Updates the Giftless S3 bucket policy** to allow the new node role to read/write objects (skipped if `use_giftless` is false)
8. **Creates the `amazon-cloudwatch` namespace** in the new cluster
9. **Deploys Fluent-bit** via Kubernetes manifests (CloudWatch log forwarding)
10. **Deploys Reloader** via Helm
11. **Deploys the NFS subdir external provisioner** via Helm (creates the `efs-client` StorageClass backed by EFS)

## Prerequisites

- `eksctl` v0.228.0+ on `PATH`
- `envsubst` (`apt-get install gettext` or `brew install gettext`)
- `aws` CLI v2 on `PATH` (used directly for EKS, EFS, and STS calls)
- `helm` v3 on `PATH` (required by `kubernetes.core.helm` tasks)
- AWS credentials with the `github-actions-eks-provisioning` role (or equivalent — see `dms-infrastructure/docs/iam-roles.md`)
- VPC and subnet IDs available as environment variables (loaded from `.env` in the CI workflow)

## Variables

### Required (from inventory group_vars)

| Variable | Description |
|---|---|
| `eks_cluster_name` | Name of the existing (old) cluster — used to find the shared EFS by tag (`{{ eks_cluster_name }}-efs`); also appears in the RDS SG description but the SG itself is looked up by `{{ application_namespace }}-rds-sg` |
| `application_namespace` | Kubernetes/app namespace prefix (e.g. `dms-dev`) — used to find the RDS security group |
| `use_giftless` | Boolean — whether to update the Giftless S3 bucket policy |
| `giftless_s3_bucket` | S3 bucket name for Giftless (required if `use_giftless` is true) |

### Required (from environment variables)

The playbook's `pre_tasks` load these from the shell environment (sourced from `dms-infrastructure/.env` in CI):

| Environment variable | Ansible variable | Description |
|---|---|---|
| `EKS_VPC_ID` | `eks_vpc_id` | VPC ID for the cluster |
| `EKS_SUBNET_AF_SOUTH_1A` | `eks_subnet_af_south_1a` | Subnet ID for `af-south-1a` |
| `EKS_SUBNET_AF_SOUTH_1B` | `eks_subnet_af_south_1b` | Subnet ID for `af-south-1b` |
| `EKS_SUBNET_AF_SOUTH_1C` | `eks_subnet_af_south_1c` | Subnet ID for `af-south-1c` |
| `EKS_EFS_IP` | `eks_efs_ip` | IP address of the EFS mount target to grant access to |

### Required (passed as extra vars)

| Variable | Description |
|---|---|
| `aws_region` | AWS region (e.g. `af-south-1`) — pass via `-e aws_region=<region>` |

### Defaults

| Variable | Default | Description |
|---|---|---|
| `eks_cluster_name_v2` | `ckan-v2` | Name of the new cluster to provision — **do not change**: the playbook asserts this must be `ckan-v2` to match `eksctl/cluster-config.yaml` |
| `cloudwatch_logs_retention` | `30` | CloudWatch log retention in days |

## Usage

Run via the `setup_eks_v2.yml` playbook (which is triggered by the `Setup EKS v2 (ckan-v2)` GitHub Actions workflow in `dms-infrastructure`):

```bash
# Run from the fjelltopp-ansible directory; inventory lives in the parent dms-infrastructure repo
ansible-playbook -i ../inventory/<environment> setup_eks_v2.yml -e "aws_region=af-south-1"
```

Replace `<environment>` with the target inventory directory (e.g. `dms_dev`, `dms_prod`). The playbook uses `connection: local` — the inventory is used only for group_vars, not to connect to remote hosts.

## First-time account notes

- `AWSServiceRoleForAmazonEKSNodegroup` is created automatically on first run if it doesn't exist (requires `iam:CreateServiceLinkedRole`)
- The EKS Access Entries API requires the cluster to have `authenticationMode: API_AND_CONFIG_MAP` or `API` — this is the default for K8s 1.23+
