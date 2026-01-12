---

# 🏗️ COMPLETE TERRAFORM + ANSIBLE DEVOPS LAB DEPLOYMENT GUIDE

## QUICK START (5 minutes overview)

```bash
# What we'll create:
✅ VCN (Virtual Cloud Network)
✅ Security Groups with proper rules
✅ 5 Compute Instances (K8s master, 2 workers, CI/CD, Monitoring)
✅ Proper networking and IP allocation
✅ All within Oracle Cloud Free Tier limits

# Tools needed:
- Terraform 1.0+
- Ansible 2.9+
- OCI CLI (for authentication)
- Git

# Time to complete:
- Terraform: 5-10 minutes (infrastructure creation)
- Ansible: 15-20 minutes (server configuration)
- Total: ~30 minutes for full lab
```

---

## PART 1: PREREQUISITES & SETUP

### Step 1: Get Oracle Cloud Credentials

```bash
# 1. Log in to Oracle Cloud Console
# 2. Click your profile icon → Tenancy: <your-tenancy-name>
# 3. Copy your Tenancy OCID (save it somewhere)

# Example:
# ocid1.tenancy.oc1..aaaaaaa...

# 4. Generate API Key for CLI
# Profile Icon → User Settings → API Keys → Add API Key
# Download the private key (save as ~/.oci/oci_api_key.pem)
# Copy the fingerprint (save in notes)

# 5. Create OCI config file
mkdir -p ~/.oci
cat > ~/.oci/config << 'EOF'
[DEFAULT]
user=ocid1.user.oc1..aaaaaaa...        # Your user OCID
fingerprint=00:00:00:00:00:00          # Your fingerprint
key_file=~/.oci/oci_api_key.pem
tenancy=ocid1.tenancy.oc1..aaaa...     # Your tenancy OCID
region=ap-mumbai-1                     # Or your region
EOF
cat > ~/.oci/config << 'EOF'
[DEFAULT]
user=ocid1.user.oc1..aaaaaaaarl5zzooc2aqxvkbzp2yrswf73t22khbvhlewfrtxuyasjs76ebma
fingerprint=e1:8d:cc:e7:1a:de:7c:a7:a1:8c:1c:88:92:1d:c5:cb
tenancy=ocid1.tenancy.oc1..aaaaaaaakdkeuaudp7nqg3vkpt5kv2oz2v2lownw7xxydhfnsp4ls3gi2xwq
region=ap-mumbai-1
key_file="C:\Users\Sarita\Desktop\access\oci_api_key.pem">
EOF
# 6. Test OCI CLI
oci os ns get
# Should return your tenancy namespace
```

### Step 2: Generate SSH Keys for Instances

```bash
# Generate SSH key pair (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# View your public key (you'll need this for Terraform)
cat ~/.ssh/id_rsa.pub
# Save this output, you'll use it in terraform.tfvars
```

### Step 3: Install Required Tools

```bash
# On macOS with Homebrew:
brew install terraform ansible

# On Ubuntu/Debian:
sudo apt-get update
sudo apt-get install -y terraform ansible

# Verify installations:
terraform --version
ansible --version
```

---

## PART 2: TERRAFORM FILES

### Directory Structure

```bash
mkdir -p k8s-devops-lab/{terraform,ansible/roles,scripts,docs}
cd k8s-devops-lab
```

### File 1: `terraform/provider.tf`

```hcl
################################################################################
# ORACLE CLOUD PROVIDER CONFIGURATION
# This file configures Terraform to work with Oracle Cloud Infrastructure
################################################################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }

  # Optional: Use Terraform Cloud for state management
  # Uncomment if you want remote state storage
  # cloud {
  #   organization = "your-org-name"
  #   workspaces {
  #     name = "k8s-devops-lab"
  #   }
  # }
}

# Configure the OCI Provider
provider "oci" {
  # Uses credentials from ~/.oci/config file (DEFAULT profile)
  # Or set environment variables: OCI_CLI_USER, OCI_CLI_FINGERPRINT, etc.

  region = var.oci_region
}

# Get current tenancy information
data "oci_identity_tenancy" "current" {
  tenancy_id = var.tenancy_ocid
}

# Get availability domains in selected region
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Get Ubuntu 24.04 LTS ARM image for A1 instances
data "oci_core_images" "ubuntu_arm" {
  compartment_id = var.tenancy_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "24.04"

  # Filter for ARM compatible images
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

# Get Ubuntu 24.04 LTS x86 image for E2 instances
data "oci_core_images" "ubuntu_x86" {
  compartment_id = var.tenancy_ocid
  operating_system = "Canonical Ubuntu"
  operating_system_version = "24.04"

  # Filter for x86 compatible images
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}
```

---

### File 2: `terraform/variables.tf`

```hcl
################################################################################
# TERRAFORM VARIABLES
# All input parameters for infrastructure customization
################################################################################

# ============================================================================
# OCI AUTHENTICATION VARIABLES
# ============================================================================

variable "tenancy_ocid" {
  description = "Oracle Cloud Tenancy OCID"
  type        = string
  sensitive   = true
  # Get from: OCI Console → Profile → Tenancy
}

variable "oci_region" {
  description = "Oracle Cloud Region (e.g., ap-mumbai-1 for India)"
  type        = string
  default     = "ap-mumbai-1"
}

variable "compartment_name" {
  description = "OCI Compartment name (usually root/default)"
  type        = string
  default     = "root"
}

# ============================================================================
# NETWORKING VARIABLES
# ============================================================================

variable "vcn_display_name" {
  description = "Virtual Cloud Network display name"
  type        = string
  default     = "k8s-devops-vcn"
}

variable "vcn_cidr" {
  description = "VCN CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_display_name" {
  description = "Subnet display name"
  type        = string
  default     = "k8s-devops-subnet"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block (must be within VCN CIDR)"
  type        = string
  default     = "10.0.1.0/24"
}

# ============================================================================
# SSH ACCESS VARIABLES
# ============================================================================

variable "ssh_public_key" {
  description = "SSH public key for instance access (paste entire key content)"
  type        = string
  sensitive   = true
  # Get from: cat ~/.ssh/id_rsa.pub
  # Paste entire key including 'ssh-rsa' prefix
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key on local machine"
  type        = string
  default     = "~/.ssh/id_rsa"
}

# ============================================================================
# INSTANCE CONFIGURATION VARIABLES
# ============================================================================

variable "kube_master_display_name" {
  description = "Display name for Kubernetes master node"
  type        = string
  default     = "kube-master"
}

variable "kube_master_ocpu" {
  description = "OCPU count for master (0.5-4, must leave space for workers)"
  type        = number
  default     = 1.5
  validation {
    condition     = var.kube_master_ocpu >= 0.5 && var.kube_master_ocpu <= 4
    error_message = "Master OCPU must be between 0.5 and 4"
  }
}

variable "kube_master_memory_gb" {
  description = "Memory in GB for master (minimum 1x OCPU ratio)"
  type        = number
  default     = 8
}

variable "kube_master_boot_volume_gb" {
  description = "Boot volume size for master"
  type        = number
  default     = 50
}

variable "kube_worker_1_display_name" {
  description = "Display name for worker node 1"
  type        = string
  default     = "kube-worker-1"
}

variable "kube_worker_1_ocpu" {
  description = "OCPU count for worker 1"
  type        = number
  default     = 1
}

variable "kube_worker_1_memory_gb" {
  description = "Memory in GB for worker 1"
  type        = number
  default     = 6
}

variable "kube_worker_1_boot_volume_gb" {
  description = "Boot volume size for worker 1"
  type        = number
  default     = 50
}

variable "kube_worker_2_display_name" {
  description = "Display name for worker node 2 (Micro)"
  type        = string
  default     = "kube-worker-2"
}

variable "kube_worker_2_boot_volume_gb" {
  description = "Boot volume size for worker 2"
  type        = number
  default     = 50
}

variable "jenkins_nexus_display_name" {
  description = "Display name for Jenkins + Nexus instance"
  type        = string
  default     = "jenkins-nexus"
}

variable "jenkins_nexus_ocpu" {
  description = "OCPU count for Jenkins/Nexus"
  type        = number
  default     = 1
}

variable "jenkins_nexus_memory_gb" {
  description = "Memory in GB for Jenkins/Nexus"
  type        = number
  default     = 8
}

variable "jenkins_nexus_boot_volume_gb" {
  description = "Boot volume size for Jenkins/Nexus"
  type        = number
  default     = 50
}

variable "monitoring_display_name" {
  description = "Display name for Monitoring (Prometheus/Grafana) instance"
  type        = string
  default     = "monitoring"
}

variable "monitoring_boot_volume_gb" {
  description = "Boot volume size for monitoring"
  type        = number
  default     = 50
}

# ============================================================================
# TAGGING VARIABLES
# ============================================================================

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource identification"
  type        = string
  default     = "k8s-devops-lab"
}

variable "created_by" {
  description = "Creator identifier for audit"
  type        = string
  default     = "terraform"
}

# ============================================================================
# FEATURE FLAGS
# ============================================================================

variable "enable_public_ip_jenkins" {
  description = "Allocate public IP to Jenkins (for GitHub webhooks)"
  type        = bool
  default     = true
}

variable "enable_public_ip_master" {
  description = "Allocate public IP to Kubernetes master"
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Enable instance auto-shutdown (not supported in free tier)"
  type        = bool
  default     = false
}

# ============================================================================
# LOCAL VALUES (Derived from variables)
# ============================================================================

locals {
  # Common tags for all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    CreatedBy   = var.created_by
    ManagedBy   = "Terraform"
  }

  # Kubernetes cluster name
  k8s_cluster_name = "${var.project_name}-cluster"

  # Ansible SSH user for Ubuntu
  ansible_user = "ubuntu"

  # Availability domain to use (first one in region)
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}
```

---

### File 3: `terraform/vpc.tf`

```hcl
################################################################################
# VIRTUAL CLOUD NETWORK (VCN) AND NETWORKING CONFIGURATION
# Creates network infrastructure, subnets, security groups, and routing
################################################################################

# ============================================================================
# VIRTUAL CLOUD NETWORK (VCN)
# ============================================================================

resource "oci_core_vcn" "main" {
  # Basic configuration
  compartment_id = var.tenancy_ocid
  display_name   = var.vcn_display_name
  cidr_blocks    = [var.vcn_cidr]

  # DNS configuration
  dns_label = "k8sdevops"

  tags = local.common_tags

  depends_on = [data.oci_identity_tenancy.current]
}

# ============================================================================
# INTERNET GATEWAY (for external access)
# ============================================================================

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.vcn_display_name}-igw"
  enabled        = true

  tags = local.common_tags
}

# ============================================================================
# SUBNET (within VCN for instance placement)
# ============================================================================

resource "oci_core_subnet" "main" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.subnet_cidr
  display_name   = var.subnet_display_name

  # DNS configuration
  dns_label = "subnet1"

  # Allow instances to have public IPs (for some instances)
  prohibit_public_ip_on_launch = false

  # Use VCN's DHCP options
  dhcp_options_id = oci_core_vcn.main.default_dhcp_options_id

  # Route table for internet access
  route_table_id = oci_core_route_table.main.id

  tags = local.common_tags
}

# ============================================================================
# ROUTE TABLE (for routing rules)
# ============================================================================

resource "oci_core_route_table" "main" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.vcn_display_name}-rt"

  # Route for internet-bound traffic through IGW
  route_rules {
    destination       = "0.0.0.0/0"  # All external traffic
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id  # Send via IGW
  }

  tags = local.common_tags
}

# ============================================================================
# NETWORK SECURITY GROUPS (NSG) - Firewall rules
# ============================================================================

# NSG for Kubernetes Master
resource "oci_core_network_security_group" "kube_master_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "kube-master-nsg"

  tags = local.common_tags
}

# NSG for Kubernetes Workers
resource "oci_core_network_security_group" "kube_worker_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "kube-worker
}
```

---

Perfect! Now let me provide all the remaining Terraform files. I'll give them in a complete, copy-paste format.

---

# 📁 COMPLETE TERRAFORM FILES - READY TO USE

## Summary of ALL Files Needed:

```
terraform/
├── provider.tf          ✅ (Already provided)
├── variables.tf         ✅ (Already provided)
├── vpc.tf               ✅ (Already provided)
├── instances.tf         ⬅️ CONTINUE FROM HERE (completion + security rules)
├── outputs.tf           🆕 (IP addresses, connection strings)
├── terraform.tfvars     🆕 (Your actual values - IMPORTANT!)
└── .gitignore           🆕 (Protect sensitive files)
```

---

## File 4: `terraform/instances.tf` (REMAINING PART - Security Rules)

```hcl
# ---- WORKER SECURITY RULES (CONTINUED) ----

resource "oci_core_network_security_group_security_rule" "worker_nodeport" {
  network_security_group_id = oci_core_network_security_group.kube_worker_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 30000
      max = 32767
    }
  }
  description = "Kubernetes NodePort services"
}

resource "oci_core_network_security_group_security_rule" "worker_egress" {
  network_security_group_id = oci_core_network_security_group.kube_worker_nsg.id
  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  description = "Allow all outbound traffic"
}

# ---- CI/CD SECURITY RULES ----

resource "oci_core_network_security_group_security_rule" "cicd_ssh" {
  network_security_group_id = oci_core_network_security_group.cicd_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "SSH access to Jenkins"
}

resource "oci_core_network_security_group_security_rule" "cicd_jenkins" {
  network_security_group_id = oci_core_network_security_group.cicd_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 8080
      max = 8080
    }
  }
  description = "Jenkins web interface"
}

resource "oci_core_network_security_group_security_rule" "cicd_nexus" {
  network_security_group_id = oci_core_network_security_group.cicd_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 8081
      max = 8081
    }
  }
  description = "Nexus repository manager"
}

resource "oci_core_network_security_group_security_rule" "cicd_docker_registry" {
  network_security_group_id = oci_core_network_security_group.cicd_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 5000
      max = 5000
    }
  }
  description = "Docker registry (internal)"
}

resource "oci_core_network_security_group_security_rule" "cicd_egress" {
  network_security_group_id = oci_core_network_security_group.cicd_nsg.id
  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  description = "Allow all outbound traffic"
}

# ---- MONITORING SECURITY RULES ----

resource "oci_core_network_security_group_security_rule" "monitoring_ssh" {
  network_security_group_id = oci_core_network_security_group.monitoring_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
  description = "SSH from VCN"
}

resource "oci_core_network_security_group_security_rule" "monitoring_prometheus" {
  network_security_group_id = oci_core_network_security_group.monitoring_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 9090
      max = 9090
    }
  }
  description = "Prometheus metrics"
}

resource "oci_core_network_security_group_security_rule" "monitoring_grafana" {
  network_security_group_id = oci_core_network_security_group.monitoring_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 3000
      max = 3000
    }
  }
  description = "Grafana dashboard"
}

resource "oci_core_network_security_group_security_rule" "monitoring_node_exporter" {
  network_security_group_id = oci_core_network_security_group.monitoring_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 9100
      max = 9100
    }
  }
  description = "Node exporter metrics"
}

resource "oci_core_network_security_group_security_rule" "monitoring_egress" {
  network_security_group_id = oci_core_network_security_group.monitoring_nsg.id
  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  description = "Allow all outbound traffic"
}
```

---

## File 5: `terraform/outputs.tf` (NEW FILE)

```hcl
################################################################################
# TERRAFORM OUTPUTS
# Displays important information after infrastructure creation
# Run: terraform output to view all values
################################################################################

# ============================================================================
# MASTER NODE OUTPUTS
# ============================================================================

output "kube_master_private_ip" {
  description = "Private IP address of Kubernetes master node"
  value       = oci_core_instance.kube_master.private_ip
}

output "kube_master_public_ip" {
  description = "Public IP address of Kubernetes master (if enabled)"
  value       = "Public IP is assigned to VNIC when enabled; use terraform show or OCI console."
}

output "kube_master_instance_id" {
  description = "OCID of Kubernetes master instance"
  value       = oci_core_instance.kube_master.id
}

# ============================================================================
# WORKER NODE 1 OUTPUTS
# ============================================================================

output "kube_worker_1_private_ip" {
  description = "Private IP address of Kubernetes worker 1"
  value       = oci_core_instance.kube_worker_1.private_ip
}

output "kube_worker_1_instance_id" {
  description = "OCID of Kubernetes worker 1 instance"
  value       = oci_core_instance.kube_worker_1.id
}

# ============================================================================
# WORKER NODE 2 (MICRO) OUTPUTS
# ============================================================================

output "kube_worker_2_private_ip" {
  description = "Private IP address of Kubernetes worker 2 (Micro)"
  value       = oci_core_instance.kube_worker_2.private_ip
}

output "kube_worker_2_instance_id" {
  description = "OCID of Kubernetes worker 2 instance"
  value       = oci_core_instance.kube_worker_2.id
}

# ============================================================================
# CI/CD OUTPUTS
# ============================================================================

output "jenkins_nexus_private_ip" {
  description = "Private IP address of Jenkins + Nexus instance"
  value       = oci_core_instance.jenkins_nexus.private_ip
}

output "jenkins_nexus_public_ip" {
  description = "Public IP address of Jenkins + Nexus (if enabled)"
  value       = "Public IP is assigned to VNIC when enabled; use terraform show or OCI console."
}

output "jenkins_nexus_instance_id" {
  description = "OCID of Jenkins + Nexus instance"
  value       = oci_core_instance.jenkins_nexus.id
}

output "jenkins_url" {
  description = "Jenkins web interface URL"
  value       = "http://${oci_core_instance.jenkins_nexus.private_ip}:8080"
}

output "nexus_url" {
  description = "Nexus repository manager URL"
  value       = "http://${oci_core_instance.jenkins_nexus.private_ip}:8081"
}

# ============================================================================
# MONITORING OUTPUTS
# ============================================================================

output "monitoring_private_ip" {
  description = "Private IP address of Monitoring instance"
  value       = oci_core_instance.monitoring.private_ip
}

output "monitoring_instance_id" {
  description = "OCID of Monitoring instance"
  value       = oci_core_instance.monitoring.id
}

output "prometheus_url" {
  description = "Prometheus metrics dashboard"
  value       = "http://${oci_core_instance.monitoring.private_ip}:9090"
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = "http://${oci_core_instance.monitoring.private_ip}:3000"
}

# ============================================================================
# NETWORK OUTPUTS
# ============================================================================

output "vcn_id" {
  description = "Oracle Cloud VCN ID"
  value       = oci_core_vcn.main.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = oci_core_subnet.main.id
}

output "subnet_cidr" {
  description = "Subnet CIDR block"
  value       = oci_core_subnet.main.cidr_block
}

# ============================================================================
# CONNECTION INFORMATION
# ============================================================================

output "kubernetes_cluster_info" {
  description = "Kubernetes cluster connection information"
  value = {
    master_private_ip = oci_core_instance.kube_master.private_ip
    master_public_ip  = "Public IP is assigned to VNIC when enabled; use terraform show or OCI console."
    worker_1_ip       = oci_core_instance.kube_worker_1.private_ip
    worker_2_ip       = oci_core_instance.kube_worker_2.private_ip
    api_endpoint      = "https://${oci_core_instance.kube_master.private_ip}:6443"
  }
}

output "ssh_connection_commands" {
  description = "SSH connection commands for each instance"
  value = {
    master = "ssh -i ~/.ssh/id_rsa ubuntu@${oci_core_instance.kube_master.private_ip}"
    worker_1 = "ssh -i ~/.ssh/id_rsa ubuntu@${oci_core_instance.kube_worker_1.private_ip}"
    worker_2 = "ssh -i ~/.ssh/id_rsa ubuntu@${oci_core_instance.kube_worker_2.private_ip}"
    jenkins = "ssh -i ~/.ssh/id_rsa ubuntu@${oci_core_instance.jenkins_nexus.private_ip}"
    monitoring = "ssh -i ~/.ssh/id_rsa ubuntu@${oci_core_instance.monitoring.private_ip}"
  }
}

output "resource_summary" {
  description = "Summary of created resources"
  value = {
    instances_created = 5
    total_ocpu = "${var.kube_master_ocpu + var.kube_worker_1_ocpu + 1 + var.jenkins_nexus_ocpu} (approximately)"
    total_memory_gb = var.kube_master_memory_gb + var.kube_worker_1_memory_gb + 1 + var.jenkins_nexus_memory_gb
    total_storage_gb = var.kube_master_boot_volume_gb + var.kube_worker_1_boot_volume_gb + var.kube_worker_2_boot_volume_gb + var.jenkins_nexus_boot_volume_gb + var.monitoring_boot_volume_gb
    environment = var.environment
    project = var.project_name
  }
}
```

---

Perfect! Let me provide File 6 completely and all remaining files:

---

## File 6: `terraform/terraform.tfvars` (COMPLETE)

```hcl
################################################################################
# TERRAFORM VARIABLES VALUES
# IMPORTANT: Fill in YOUR actual values here
# This file is gitignored to protect sensitive information
################################################################################

# ============================================================================
# ORACLE CLOUD CREDENTIALS - REQUIRED
# ============================================================================

# Get from OCI Console > Profile > Tenancy
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaa"  # REPLACE WITH YOUR TENANCY OCID

# Your region
oci_region = "ap-mumbai-1"

# ============================================================================
# SSH PUBLIC KEY - REQUIRED
# ============================================================================

# Get from: cat ~/.ssh/id_rsa.pub
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCxxxxxxx..."  # REPLACE

# ============================================================================
# KUBERNETES MASTER CONFIGURATION
# ============================================================================

kube_master_display_name   = "kube-master"
kube_master_ocpu           = 1.5
kube_master_memory_gb      = 8
kube_master_boot_volume_gb = 50

# ============================================================================
# KUBERNETES WORKER 1 CONFIGURATION
# ============================================================================

kube_worker_1_display_name   = "kube-worker-1"
kube_worker_1_ocpu           = 1
kube_worker_1_memory_gb      = 6
kube_worker_1_boot_volume_gb = 50

# ============================================================================
# KUBERNETES WORKER 2 CONFIGURATION (MICRO - NO CUSTOMIZATION)
# ============================================================================

kube_worker_2_display_name   = "kube-worker-2"
kube_worker_2_boot_volume_gb = 50

# ============================================================================
# CI/CD CONFIGURATION (JENKINS + NEXUS)
# ============================================================================

jenkins_nexus_display_name   = "jenkins-nexus"
jenkins_nexus_ocpu           = 1
jenkins_nexus_memory_gb      = 8
jenkins_nexus_boot_volume_gb = 50

# ============================================================================
# MONITORING CONFIGURATION (PROMETHEUS + GRAFANA)
# ============================================================================

monitoring_display_name   = "monitoring"
monitoring_boot_volume_gb = 50

# ============================================================================
# NETWORKING
# ============================================================================

vcn_display_name = "k8s-devops-vcn"
vcn_cidr         = "10.0.0.0/16"

subnet_display_name = "k8s-devops-subnet"
subnet_cidr         = "10.0.1.0/24"

# ============================================================================
# FEATURES
# ============================================================================

enable_public_ip_master  = true   # Master needs public IP for SSH
enable_public_ip_jenkins = true   # Jenkins needs public IP for GitHub webhooks

# ============================================================================
# TAGS
# ============================================================================

environment = "dev"
project_name = "k8s-devops-lab"
created_by  = "terraform"
```

---

## File 7: `terraform/.gitignore` (NEW FILE - PROTECT SENSITIVE DATA)

```
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files (unless explicitly committed)
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do want to commit
!example_override.tf

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore plan files
*.tfplan

# Ignore lock files (optional - version control is recommended)
# .terraform.lock.hcl

# OS-specific files
.DS_Store
.vscode/
*.swp
*.swo
*~

# IDE files
.idea/
*.iml
.vscode/

# Ignore local SSH keys
*.pem
*.key

# Ignore OCI credentials
.oci/
oci_api_key.pem

# Ignore variable files with sensitive data
terraform.tfvars.local
```

---

## File 8: `terraform/vpc.tf` (MISSING SECURITY GROUP DEFINITIONS)

Add this to your existing `vpc.tf` file (after the route table):

```hcl
# ============================================================================
# NETWORK SECURITY GROUPS (NSG) - Firewall rules
# ============================================================================

# NSG for Kubernetes Master
resource "oci_core_network_security_group" "kube_master_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "kube-master-nsg"

  tags = local.common_tags
}

# NSG for Kubernetes Workers
resource "oci_core_network_security_group" "kube_worker_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "kube-worker-nsg"

  tags = local.common_tags
}

# NSG for CI/CD (Jenkins + Nexus)
resource "oci_core_network_security_group" "cicd_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "cicd-nsg"

  tags = local.common_tags
}

# NSG for Monitoring (Prometheus + Grafana)
resource "oci_core_network_security_group" "monitoring_nsg" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "monitoring-nsg"

  tags = local.common_tags
}
```

---

## File 9: `scripts/setup.sh` (Initial Setup Script)

```bash
#!/bin/bash
################################################################################
# KUBERNETES DEVOPS LAB - SETUP SCRIPT
# This script initializes your local environment for Terraform deployment
################################################################################

set -e

echo "================================"
echo "K8s DevOps Lab - Setup Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running from correct directory
if [ ! -d "terraform" ]; then
    echo -e "${RED}Error: terraform directory not found!${NC}"
    echo "Please run this script from the k8s-devops-lab directory"
    exit 1
fi

echo -e "${GREEN}✓ Found terraform directory${NC}"
echo ""

# Check for required tools
echo "Checking required tools..."
echo ""

# Check Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗ Terraform is not installed${NC}"
    echo "Install from: https://www.terraform.io/downloads.html"
    exit 1
fi
echo -e "${GREEN}✓ Terraform $(terraform version -json | grep terraform_version | cut -d'"' -f4)${NC}"

# Check OCI CLI
if ! command -v oci &> /dev/null; then
    echo -e "${RED}✗ OCI CLI is not installed${NC}"
    echo "Install from: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm"
    exit 1
fi
echo -e "${GREEN}✓ OCI CLI installed${NC}"

# Check SSH key
if [ ! -f ~/.ssh/id_rsa ]; then
    echo -e "${RED}✗ SSH key not found at ~/.ssh/id_rsa${NC}"
    echo "Generate with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ''"
    exit 1
fi
echo -e "${GREEN}✓ SSH key found${NC}"

# Check OCI config
if [ ! -f ~/.oci/config ]; then
    echo -e "${RED}✗ OCI config not found at ~/.oci/config${NC}"
    echo "Please configure OCI CLI first"
    exit 1
fi
echo -e "${GREEN}✓ OCI config found${NC}"
echo ""

# Initialize Terraform
echo "Initializing Terraform..."
cd terraform

if terraform init; then
    echo -e "${GREEN}✓ Terraform initialized${NC}"
else
    echo -e "${RED}✗ Terraform initialization failed${NC}"
    exit 1
fi

echo ""
echo "================================"
echo -e "${GREEN}Setup Complete!${NC}"
echo "================================"
echo ""
echo "Next steps:"
echo "1. Edit terraform/terraform.tfvars with your values:"
echo "   - Replace tenancy_ocid with your actual OCID"
echo "   - Replace ssh_public_key with your SSH public key"
echo ""
echo "2. Validate configuration:"
echo "   terraform validate"
echo ""
echo "3. Plan deployment:"
echo "   terraform plan -out=tfplan"
echo ""
echo "4. Apply configuration:"
echo "   terraform apply tfplan"
echo ""
```

---

## File 10: `scripts/deploy.sh` (Deployment Script)

```bash
#!/bin/bash
################################################################################
# KUBERNETES DEVOPS LAB - DEPLOYMENT SCRIPT
# Deploys infrastructure and runs Ansible playbooks
################################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════╗"
echo "║   K8s DevOps Lab - Full Deployment                ║"
echo "║   Terraform + Ansible                             ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Step 1: Validate Terraform
echo -e "${BLUE}[1/4] Validating Terraform configuration...${NC}"
cd terraform
terraform validate
echo -e "${GREEN}✓ Terraform validation passed${NC}"
echo ""

# Step 2: Plan Terraform
echo -e "${BLUE}[2/4] Creating Terraform plan...${NC}"
terraform plan -out=tfplan
echo -e "${GREEN}✓ Terraform plan created${NC}"
echo ""

# Step 3: Apply Terraform
echo -e "${BLUE}[3/4] Applying Terraform configuration (Creating infrastructure)...${NC}"
echo -e "${YELLOW}This will create 5 instances. Continue? (yes/no)${NC}"
read -r response
if [ "$response" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

terraform apply tfplan
echo -e "${GREEN}✓ Infrastructure created${NC}"
echo ""

# Step 4: Get outputs
echo -e "${BLUE}[4/4] Retrieving instance information...${NC}"
terraform output -json > outputs.json
echo -e "${GREEN}✓ Outputs saved${NC}"
echo ""

# Display connection information
echo -e "${GREEN}"
echo "════════════════════════════════════════════════════"
echo "Deployment Complete!"
echo "════════════════════════════════════════════════════"
echo -e "${NC}"
echo ""
echo "Instance Details:"
terraform output kubernetes_cluster_info
echo ""
echo "SSH Connection Commands:"
terraform output ssh_connection_commands
echo ""
echo -e "${YELLOW}Note: Instances are starting. Wait 2-3 minutes before SSH connection.${NC}"
echo ""
echo "Next steps:"
echo "1. Wait for instances to fully boot (~2-3 minutes)"
echo "2. Run Ansible playbooks: cd ../ansible && ansible-playbook -i inventory.ini 01-prepare.yml"
echo ""
```

---

## File 11: `scripts/validate.sh` (Validation Script)

````bash
#!/bin/bash
################################################################################
# VALIDATION SCRIPT
# Checks infrastructure readiness
################################################################################

set -e

RED='\033

---

## File 12: `terraform.tfvars.example` (Template without sensitive data)

```hcl
################################################################################
# EXAMPLE TERRAFORM VARIABLES
# Copy to terraform.tfvars and fill in your actual values
################################################################################

# Your Tenancy OCID from OCI Console > Profile
tenancy_ocid = "ocid1.tenancy.oc1..aaaaaaaXXXXXXXXXXX"

# Your SSH public key (from: cat ~/.ssh/id_rsa.pub)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCXXXXXXXXXXXXX..."

# Region
oci_region = "ap-mumbai-1"

# Instance names
kube_master_display_name   = "kube-master"
kube_worker_1_display_name = "kube-worker-1"
kube_worker_2_display_name = "kube-worker-2"
jenkins_nexus_display_name = "jenkins-nexus"
monitoring_display_name    = "monitoring"

# Resource sizing
kube_master_ocpu           = 1.5
kube_master_memory_gb      = 8
kube_worker_1
````
