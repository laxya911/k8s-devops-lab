## File 5: `terraform/outputs.tf` (NEW FILE)

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
  }
}

output "resource_summary" {
  description = "Summary of created resources"
  value = {
    instances_created = 4
    total_ocpu = "${var.kube_master_ocpu + var.kube_worker_1_ocpu + 1 + var.jenkins_nexus_ocpu} (approximately)"
    total_memory_gb = var.kube_master_memory_gb + var.kube_worker_1_memory_gb + 1 + var.jenkins_nexus_memory_gb
    total_storage_gb = var.kube_master_boot_volume_gb + var.kube_worker_1_boot_volume_gb + var.kube_worker_2_boot_volume_gb + var.jenkins_nexus_boot_volume_gb
    environment = var.environment
    project = var.project_name
  }
}