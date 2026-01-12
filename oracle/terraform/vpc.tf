################################################################################
# VIRTUAL CLOUD NETWORK (VCN) AND NETWORKING CONFIGURATION
# Creates network infrastructure, subnets, security groups, and routing
################################################################################

# ============================================================================
# VIRTUAL CLOUD NETWORK (VCN)
# ============================================================================

resource "oci_core_vcn" "main" {
  # Basic configuration
  compartment_id = var.compartment_id
  display_name   = var.vcn_display_name
  cidr_blocks    = [var.vcn_cidr]

  # DNS configuration
  dns_label = "k8sdevops"

  freeform_tags = local.common_tags

  depends_on = [data.oci_identity_tenancy.current]
}

# ============================================================================
# INTERNET GATEWAY (for external access)
# ============================================================================

resource "oci_core_internet_gateway" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.vcn_display_name}-igw"
  enabled        = true

  freeform_tags = local.common_tags
}

# ============================================================================
# SUBNET (within VCN for instance placement)
# ============================================================================

resource "oci_core_subnet" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  cidr_block     = var.subnet_cidr
  display_name   = var.subnet_display_name

  # DNS configuration
  dns_label = "subnet1"

  # Allow instances to have public IPs (for some instances)
  prohibit_public_ip_on_vnic = false

  # Use VCN's DHCP options
  dhcp_options_id = oci_core_vcn.main.default_dhcp_options_id

  # Route table for internet access
  route_table_id = oci_core_route_table.main.id

  freeform_tags = local.common_tags
}

# ============================================================================
# ROUTE TABLE (for routing rules)
# ============================================================================

resource "oci_core_route_table" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${var.vcn_display_name}-rt"

  # Route for internet-bound traffic through IGW
  route_rules {
    destination       = "0.0.0.0/0"  # All external traffic
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main.id  # Send via IGW
  }

  freeform_tags = local.common_tags
}

# ============================================================================
# NETWORK SECURITY GROUPS (NSG) - Firewall rules
# ============================================================================

# NSG for Kubernetes Master
resource "oci_core_network_security_group" "kube_master_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "kube-master-nsg"

  freeform_tags = local.common_tags
}

# NSG for Kubernetes Workers
resource "oci_core_network_security_group" "kube_worker_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "kube-worker-nsg"
}

# NSG for CI/CD (Jenkins + Nexus)
resource "oci_core_network_security_group" "cicd_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "cicd-nsg"

  freeform_tags = local.common_tags
}


