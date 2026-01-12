
## File 4: `terraform/instances.tf`

################################################################################
# COMPUTE INSTANCES CONFIGURATION
# Creates all 5 instances for Kubernetes DevOps Lab
################################################################################

// availability_domain is defined in provider/main.tf locals; remove duplicate.

# ============================================================================
# INSTANCE 1: KUBERNETES MASTER NODE
# ============================================================================

resource "oci_core_instance" "kube_master" {
  compartment_id      = var.compartment_id
  display_name        = var.kube_master_display_name
  availability_domain = local.availability_domain

  shape    = "VM.Standard.A1.Flex"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  shape_config {
    ocpus         = var.kube_master_ocpu
    memory_in_gbs = var.kube_master_memory_gb
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.main.id
    display_name           = "${var.kube_master_display_name}-vnic"
    private_ip             = "10.0.1.10"
    skip_source_dest_check = false
    nsg_ids                = [oci_core_network_security_group.kube_master_nsg.id]
    assign_public_ip       = var.enable_public_ip_master
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = true

  freeform_tags = merge(local.common_tags, {
    Role = "kubernetes-master"
    Tier = "control-plane"
  })

  depends_on = [
    oci_core_subnet.main,
    oci_core_network_security_group.kube_master_nsg
  ]

  timeouts {
    create = "10m"
    delete = "5m"
  }
}

# Public IP for Master (optional)


# ============================================================================
# INSTANCE 2: KUBERNETES WORKER NODE 1
# ============================================================================

resource "oci_core_instance" "kube_worker_1" {
  compartment_id      = var.compartment_id
  display_name        = var.kube_worker_1_display_name
  availability_domain = local.availability_domain

  shape    = "VM.Standard.A1.Flex"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  shape_config {
    ocpus         = var.kube_worker_1_ocpu
    memory_in_gbs = var.kube_worker_1_memory_gb
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.main.id
    display_name           = "${var.kube_worker_1_display_name}-vnic"
    private_ip             = "10.0.1.20"
    skip_source_dest_check = false
    nsg_ids                = [oci_core_network_security_group.kube_worker_nsg.id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = true

  freeform_tags = merge(local.common_tags, {
    Role = "kubernetes-worker"
    Tier = "data-plane"
  })

  depends_on = [oci_core_subnet.main]

  timeouts {
    create = "10m"
    delete = "5m"
  }
}

# ============================================================================
# INSTANCE 3: KUBERNETES WORKER NODE 2 (MICRO)
# ============================================================================

resource "oci_core_instance" "kube_worker_2" {
  compartment_id      = var.compartment_id
  display_name        = var.kube_worker_2_display_name
  availability_domain = local.availability_domain

  shape    = "VM.Standard.E2.1.Micro"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_x86.images[0].id
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.main.id
    display_name           = "${var.kube_worker_2_display_name}-vnic"
    private_ip             = "10.0.1.30"
    skip_source_dest_check = false
    nsg_ids                = [oci_core_network_security_group.kube_worker_nsg.id]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = true

  freeform_tags = merge(local.common_tags, {
    Role     = "kubernetes-worker"
    Tier     = "lightweight"
    NodeType = "micro"
  })

  depends_on = [oci_core_subnet.main]

  timeouts {
    create = "10m"
    delete = "5m"
  }
}

# ============================================================================
# INSTANCE 4: CI/CD (JENKINS + NEXUS)
# ============================================================================

resource "oci_core_instance" "jenkins_nexus" {
  compartment_id      = var.compartment_id
  display_name        = var.jenkins_nexus_display_name
  availability_domain = local.availability_domain

  shape    = "VM.Standard.A1.Flex"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  shape_config {
    ocpus         = var.jenkins_nexus_ocpu
    memory_in_gbs = var.jenkins_nexus_memory_gb
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.main.id
    display_name           = "${var.jenkins_nexus_display_name}-vnic"
    private_ip             = "10.0.1.40"
    skip_source_dest_check = false
    nsg_ids                = [oci_core_network_security_group.cicd_nsg.id]
    assign_public_ip       = var.enable_public_ip_jenkins
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  preserve_boot_volume = true

  freeform_tags = merge(local.common_tags, {
    Role     = "ci-cd"
    Services = "jenkins,nexus"
  })

  depends_on = [oci_core_subnet.main]

  timeouts {
    create = "10m"
    delete = "5m"
  }
}

# Public IP for Jenkins


# ============================================================================
# SECURITY GROUP RULES
# ============================================================================

# ---- MASTER SECURITY RULES ----

resource "oci_core_network_security_group_security_rule" "master_ssh" {
  network_security_group_id = oci_core_network_security_group.kube_master_nsg.id
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
  description = "SSH access to master"
}

resource "oci_core_network_security_group_security_rule" "master_k8s_api" {
  network_security_group_id = oci_core_network_security_group.kube_master_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
  description = "Kubernetes API server"
}

resource "oci_core_network_security_group_security_rule" "master_etcd" {
  network_security_group_id = oci_core_network_security_group.kube_master_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 2379
      max = 2380
    }
  }
  description = "etcd communication"
}

resource "oci_core_network_security_group_security_rule" "master_kubelet" {
  network_security_group_id = oci_core_network_security_group.kube_master_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 10250
      max = 10250
    }
  }
  description = "Kubelet API"
}

resource "oci_core_network_security_group_security_rule" "master_egress" {
  network_security_group_id = oci_core_network_security_group.kube_master_nsg.id
  direction   = "EGRESS"
  protocol    = "all"
  destination = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
  description = "Allow all outbound traffic"
}

# ---- WORKER SECURITY RULES ----

resource "oci_core_network_security_group_security_rule" "worker_ssh" {
  network_security_group_id = oci_core_network_security_group.kube_worker_nsg.id
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

resource "oci_core_network_security_group_security_rule" "worker_kubelet" {
  network_security_group_id = oci_core_network_security_group.kube_worker_nsg.id
  direction   = "INGRESS"
  protocol    = "6"
  source      = var.subnet_cidr
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 10250
      max = 10250
    }
  }
  description = "Kubelet API"
}

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

