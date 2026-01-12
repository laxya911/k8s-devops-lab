################################################################################
# ORACLE CLOUD PROVIDER CONFIGURATION
# This file configures Terraform to work with Oracle Cloud Infrastructure
################################################################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
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
  compartment_id = var.compartment_id
}

# Get Ubuntu 22.04 LTS ARM image for A1 instances
data "oci_core_images" "ubuntu_arm" {
  compartment_id = var.compartment_id
  operating_system = "Canonical Ubuntu"
  operating_system_version = "24.04"

  # Filter for ARM compatible images
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}

# Get Ubuntu 22.04 LTS x86 image for E2 instances
data "oci_core_images" "ubuntu_x86" {
  compartment_id = var.compartment_id
  operating_system = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape = "VM.Standard.E2.1.Micro"

  # Filter for x86 compatible images
  sort_by = "TIMECREATED"
  sort_order = "DESC"
}
