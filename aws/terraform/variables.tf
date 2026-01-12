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

variable "compartment_id" {
  description = "OCI Compartment OCID"
  type        = string
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
  description = "Boot volume size for worker 2 (min 47GB for standard images)"
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

# Local values are defined in main.tf to avoid duplication across files.
