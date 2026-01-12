################################################################################
# LOCAL VALUES
# Centralized locals for the Terraform module
################################################################################

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    CreatedBy   = var.created_by
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }

  k8s_cluster_name = "${var.project_name}-cluster"

  ansible_user = "ubuntu"

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}
