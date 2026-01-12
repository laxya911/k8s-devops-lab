laxman@Web-Dev:/mnt/d/k8s-devops-lab/terraform$ terraform plan
data.oci_core_images.ubuntu_arm: Reading...
data.oci_identity_availability_domains.ads: Reading...
data.oci_identity_tenancy.current: Reading...
data.oci_core_images.ubuntu_x86: Reading...
data.oci_identity_tenancy.current: Read complete after 0s [id=ocid1.tenancy.oc1..aaaaaaaakdkeuaudp7nqg3vkpt5kv2oz2v2lownw7xxydhfnsp4ls3gi2xwq]
data.oci_identity_availability_domains.ads: Read complete after 0s [id=IdentityAvailabilityDomainsDataSource-2441687109]
data.oci_core_images.ubuntu_arm: Read complete after 0s [id=CoreImagesDataSource-3210361110]
data.oci_core_images.ubuntu_x86: Read complete after 0s [id=CoreImagesDataSource-3210361110]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # oci_core_instance.jenkins_nexus will be created
  + resource "oci_core_instance" "jenkins_nexus" {
      + availability_domain                 = "QHup:AP-MUMBAI-1-AD-1"
      + boot_volume_id                      = (known after apply)
      + capacity_reservation_id             = (known after apply)
      + compartment_id                      = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + compute_cluster_id                  = (known after apply)
      + dedicated_vm_host_id                = (known after apply)
      + defined_tags                        = (known after apply)
      + display_name                        = "jenkins-nexus"
      + extended_metadata                   = (known after apply)
      + fault_domain                        = (known after apply)
      + freeform_tags                       = (known after apply)
      + hostname_label                      = (known after apply)
      + id                                  = (known after apply)
      + image                               = (known after apply)
      + instance_configuration_id           = (known after apply)
      + ipxe_script                         = (known after apply)
      + is_cross_numa_node                  = (known after apply)
      + is_pv_encryption_in_transit_enabled = (known after apply)
      + launch_mode                         = (known after apply)
      + metadata                            = {
          + "ssh_authorized_keys" = (sensitive value)
        }
      + preserve_boot_volume                = true
      + private_ip                          = (known after apply)
      + public_ip                           = (known after apply)
      + region                              = (known after apply)
      + shape                               = "VM.Standard.A1.Flex"
      + state                               = (known after apply)
      + subnet_id                           = (known after apply)
      + system_tags                         = (known after apply)
      + time_created                        = (known after apply)
      + time_maintenance_reboot_due         = (known after apply)

      + agent_config (known after apply)

      + availability_config (known after apply)

      + create_vnic_details {
          + assign_ipv6ip          = (known after apply)
          + assign_public_ip       = "true"
          + defined_tags           = (known after apply)
          + display_name           = "jenkins-nexus-vnic"
          + freeform_tags          = (known after apply)
          + hostname_label         = (known after apply)
          + nsg_ids                = (known after apply)
          + private_ip             = "10.0.1.40"
          + skip_source_dest_check = false
          + subnet_id              = (known after apply)
          + vlan_id                = (known after apply)

          + ipv6address_ipv6subnet_cidr_pair_details (known after apply)
        }

      + instance_options (known after apply)

      + launch_options (known after apply)

      + launch_volume_attachments (known after apply)

      + platform_config (known after apply)

      + preemptible_instance_config (known after apply)

      + shape_config {
          + baseline_ocpu_utilization     = (known after apply)
          + gpu_description               = (known after apply)
          + gpus                          = (known after apply)
          + local_disk_description        = (known after apply)
          + local_disks                   = (known after apply)
          + local_disks_total_size_in_gbs = (known after apply)
          + max_vnic_attachments          = (known after apply)
          + memory_in_gbs                 = 8
          + networking_bandwidth_in_gbps  = (known after apply)
          + nvmes                         = (known after apply)
          + ocpus                         = 1
          + processor_description         = (known after apply)
          + vcpus                         = (known after apply)
        }

      + source_details {
          + boot_volume_size_in_gbs = (known after apply)
          + boot_volume_vpus_per_gb = (known after apply)
          + source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaohman5szirc6pao66iw4xiyi7wrknar66xmy7t3hf7yxx7eoplqa"
          + source_type             = "image"

          + instance_source_image_filter_details (known after apply)
        }

      + timeouts {
          + create = "10m"
          + delete = "5m"
        }
    }

  # oci_core_instance.kube_master will be created
  + resource "oci_core_instance" "kube_master" {
      + availability_domain                 = "QHup:AP-MUMBAI-1-AD-1"
      + boot_volume_id                      = (known after apply)
      + capacity_reservation_id             = (known after apply)
      + compartment_id                      = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + compute_cluster_id                  = (known after apply)
      + dedicated_vm_host_id                = (known after apply)
      + defined_tags                        = (known after apply)
      + display_name                        = "kube-master"
      + extended_metadata                   = (known after apply)
      + fault_domain                        = (known after apply)
      + freeform_tags                       = (known after apply)
      + hostname_label                      = (known after apply)
      + id                                  = (known after apply)
      + image                               = (known after apply)
      + instance_configuration_id           = (known after apply)
      + ipxe_script                         = (known after apply)
      + is_cross_numa_node                  = (known after apply)
      + is_pv_encryption_in_transit_enabled = (known after apply)
      + launch_mode                         = (known after apply)
      + metadata                            = {
          + "ssh_authorized_keys" = (sensitive value)
        }
      + preserve_boot_volume                = true
      + private_ip                          = (known after apply)
      + public_ip                           = (known after apply)
      + region                              = (known after apply)
      + shape                               = "VM.Standard.A1.Flex"
      + state                               = (known after apply)
      + subnet_id                           = (known after apply)
      + system_tags                         = (known after apply)
      + time_created                        = (known after apply)
      + time_maintenance_reboot_due         = (known after apply)

      + agent_config (known after apply)

      + availability_config (known after apply)

      + create_vnic_details {
          + assign_ipv6ip          = (known after apply)
          + assign_public_ip       = "true"
          + defined_tags           = (known after apply)
          + display_name           = "kube-master-vnic"
          + freeform_tags          = (known after apply)
          + hostname_label         = (known after apply)
          + nsg_ids                = (known after apply)
          + private_ip             = "10.0.1.10"
          + skip_source_dest_check = false
          + subnet_id              = (known after apply)
          + vlan_id                = (known after apply)

          + ipv6address_ipv6subnet_cidr_pair_details (known after apply)
        }

      + instance_options (known after apply)

      + launch_options (known after apply)

      + launch_volume_attachments (known after apply)

      + platform_config (known after apply)

      + preemptible_instance_config (known after apply)

      + shape_config {
          + baseline_ocpu_utilization     = (known after apply)
          + gpu_description               = (known after apply)
          + gpus                          = (known after apply)
          + local_disk_description        = (known after apply)
          + local_disks                   = (known after apply)
          + local_disks_total_size_in_gbs = (known after apply)
          + max_vnic_attachments          = (known after apply)
          + memory_in_gbs                 = 8
          + networking_bandwidth_in_gbps  = (known after apply)
          + nvmes                         = (known after apply)
          + ocpus                         = 1.5
          + processor_description         = (known after apply)
          + vcpus                         = (known after apply)
        }

      + source_details {
          + boot_volume_size_in_gbs = (known after apply)
          + boot_volume_vpus_per_gb = (known after apply)
          + source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaohman5szirc6pao66iw4xiyi7wrknar66xmy7t3hf7yxx7eoplqa"
          + source_type             = "image"

          + instance_source_image_filter_details (known after apply)
        }

      + timeouts {
          + create = "10m"
          + delete = "5m"
        }
    }

  # oci_core_instance.kube_worker_1 will be created
  + resource "oci_core_instance" "kube_worker_1" {
      + availability_domain                 = "QHup:AP-MUMBAI-1-AD-1"
      + boot_volume_id                      = (known after apply)
      + capacity_reservation_id             = (known after apply)
      + compartment_id                      = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + compute_cluster_id                  = (known after apply)
      + dedicated_vm_host_id                = (known after apply)
      + defined_tags                        = (known after apply)
      + display_name                        = "kube-worker-1"
      + extended_metadata                   = (known after apply)
      + fault_domain                        = (known after apply)
      + freeform_tags                       = (known after apply)
      + hostname_label                      = (known after apply)
      + id                                  = (known after apply)
      + image                               = (known after apply)
      + instance_configuration_id           = (known after apply)
      + ipxe_script                         = (known after apply)
      + is_cross_numa_node                  = (known after apply)
      + is_pv_encryption_in_transit_enabled = (known after apply)
      + launch_mode                         = (known after apply)
      + metadata                            = {
          + "ssh_authorized_keys" = (sensitive value)
        }
      + preserve_boot_volume                = true
      + private_ip                          = (known after apply)
      + public_ip                           = (known after apply)
      + region                              = (known after apply)
      + shape                               = "VM.Standard.A1.Flex"
      + state                               = (known after apply)
      + subnet_id                           = (known after apply)
      + system_tags                         = (known after apply)
      + time_created                        = (known after apply)
      + time_maintenance_reboot_due         = (known after apply)

      + agent_config (known after apply)

      + availability_config (known after apply)

      + create_vnic_details {
          + assign_ipv6ip          = (known after apply)
          + assign_public_ip       = "true"
          + defined_tags           = (known after apply)
          + display_name           = "kube-worker-1-vnic"
          + freeform_tags          = (known after apply)
          + hostname_label         = (known after apply)
          + nsg_ids                = (known after apply)
          + private_ip             = "10.0.1.20"
          + skip_source_dest_check = false
          + subnet_id              = (known after apply)
          + vlan_id                = (known after apply)

          + ipv6address_ipv6subnet_cidr_pair_details (known after apply)
        }

      + instance_options (known after apply)

      + launch_options (known after apply)

      + launch_volume_attachments (known after apply)

      + platform_config (known after apply)

      + preemptible_instance_config (known after apply)

      + shape_config {
          + baseline_ocpu_utilization     = (known after apply)
          + gpu_description               = (known after apply)
          + gpus                          = (known after apply)
          + local_disk_description        = (known after apply)
          + local_disks                   = (known after apply)
          + local_disks_total_size_in_gbs = (known after apply)
          + max_vnic_attachments          = (known after apply)
          + memory_in_gbs                 = 6
          + networking_bandwidth_in_gbps  = (known after apply)
          + nvmes                         = (known after apply)
          + ocpus                         = 1
          + processor_description         = (known after apply)
          + vcpus                         = (known after apply)
        }

      + source_details {
          + boot_volume_size_in_gbs = (known after apply)
          + boot_volume_vpus_per_gb = (known after apply)
          + source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaohman5szirc6pao66iw4xiyi7wrknar66xmy7t3hf7yxx7eoplqa"
          + source_type             = "image"

          + instance_source_image_filter_details (known after apply)
        }

      + timeouts {
          + create = "10m"
          + delete = "5m"
        }
    }

  # oci_core_instance.kube_worker_2 will be created
  + resource "oci_core_instance" "kube_worker_2" {
      + availability_domain                 = "QHup:AP-MUMBAI-1-AD-1"
      + boot_volume_id                      = (known after apply)
      + capacity_reservation_id             = (known after apply)
      + compartment_id                      = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + compute_cluster_id                  = (known after apply)
      + dedicated_vm_host_id                = (known after apply)
      + defined_tags                        = (known after apply)
      + display_name                        = "kube-worker-2"
      + extended_metadata                   = (known after apply)
      + fault_domain                        = (known after apply)
      + freeform_tags                       = (known after apply)
      + hostname_label                      = (known after apply)
      + id                                  = (known after apply)
      + image                               = (known after apply)
      + instance_configuration_id           = (known after apply)
      + ipxe_script                         = (known after apply)
      + is_cross_numa_node                  = (known after apply)
      + is_pv_encryption_in_transit_enabled = (known after apply)
      + launch_mode                         = (known after apply)
      + metadata                            = {
          + "ssh_authorized_keys" = (sensitive value)
        }
      + preserve_boot_volume                = true
      + private_ip                          = (known after apply)
      + public_ip                           = (known after apply)
      + region                              = (known after apply)
      + shape                               = "VM.Standard.E2.1.Micro"
      + state                               = (known after apply)
      + subnet_id                           = (known after apply)
      + system_tags                         = (known after apply)
      + time_created                        = (known after apply)
      + time_maintenance_reboot_due         = (known after apply)

      + agent_config (known after apply)

      + availability_config (known after apply)

      + create_vnic_details {
          + assign_ipv6ip          = (known after apply)
          + assign_public_ip       = "true"
          + defined_tags           = (known after apply)
          + display_name           = "kube-worker-2-vnic"
          + freeform_tags          = (known after apply)
          + hostname_label         = (known after apply)
          + nsg_ids                = (known after apply)
          + private_ip             = "10.0.1.30"
          + skip_source_dest_check = false
          + subnet_id              = (known after apply)
          + vlan_id                = (known after apply)

          + ipv6address_ipv6subnet_cidr_pair_details (known after apply)
        }

      + instance_options (known after apply)

      + launch_options (known after apply)

      + launch_volume_attachments (known after apply)

      + platform_config (known after apply)

      + preemptible_instance_config (known after apply)

      + shape_config (known after apply)

      + source_details {
          + boot_volume_size_in_gbs = (known after apply)
          + boot_volume_vpus_per_gb = (known after apply)
          + source_id               = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaohman5szirc6pao66iw4xiyi7wrknar66xmy7t3hf7yxx7eoplqa"
          + source_type             = "image"

          + instance_source_image_filter_details (known after apply)
        }

      + timeouts {
          + create = "10m"
          + delete = "5m"
        }
    }

  # oci_core_internet_gateway.main will be created
  + resource "oci_core_internet_gateway" "main" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + defined_tags   = (known after apply)
      + display_name   = "k8s-devops-vcn-igw"
      + enabled        = true
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)
    }

  # oci_core_network_security_group.cicd_nsg will be created
  + resource "oci_core_network_security_group" "cicd_nsg" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + defined_tags   = (known after apply)
      + display_name   = "cicd-nsg"
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)
    }

  # oci_core_network_security_group.kube_master_nsg will be created
  + resource "oci_core_network_security_group" "kube_master_nsg" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + defined_tags   = (known after apply)
      + display_name   = "kube-master-nsg"
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)
    }

  # oci_core_network_security_group.kube_worker_nsg will be created
  + resource "oci_core_network_security_group" "kube_worker_nsg" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + defined_tags   = (known after apply)
      + display_name   = "kube-worker-nsg"
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)
    }

  # oci_core_network_security_group_security_rule.cicd_docker_registry will be created
  + resource "oci_core_network_security_group_security_rule" "cicd_docker_registry" {
      + description               = "Docker registry (internal)"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "10.0.1.0/24"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 5000
              + min = 5000
            }
        }
    }

  # oci_core_network_security_group_security_rule.cicd_egress will be created
  + resource "oci_core_network_security_group_security_rule" "cicd_egress" {
      + description               = "Allow all outbound traffic"
      + destination               = "0.0.0.0/0"
      + destination_type          = "CIDR_BLOCK"
      + direction                 = "EGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "all"
      + source_type               = (known after apply)
      + stateless                 = (known after apply)
      + time_created              = (known after apply)
    }

  # oci_core_network_security_group_security_rule.cicd_jenkins will be created
  + resource "oci_core_network_security_group_security_rule" "cicd_jenkins" {
      + description               = "Jenkins web interface"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "0.0.0.0/0"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 8080
              + min = 8080
            }
        }
    }

  # oci_core_network_security_group_security_rule.cicd_nexus will be created
  + resource "oci_core_network_security_group_security_rule" "cicd_nexus" {
      + description               = "Nexus repository manager"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "0.0.0.0/0"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 8081
              + min = 8081
            }
        }
    }

  # oci_core_network_security_group_security_rule.cicd_ssh will be created
  + resource "oci_core_network_security_group_security_rule" "cicd_ssh" {
      + description               = "SSH access to Jenkins"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "0.0.0.0/0"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 22
              + min = 22
            }
        }
    }

  # oci_core_network_security_group_security_rule.master_egress will be created
  + resource "oci_core_network_security_group_security_rule" "master_egress" {
      + description               = "Allow all outbound traffic"
      + destination               = "0.0.0.0/0"
      + destination_type          = "CIDR_BLOCK"
      + direction                 = "EGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "all"
      + source_type               = (known after apply)
      + stateless                 = (known after apply)
      + time_created              = (known after apply)
    }

  # oci_core_network_security_group_security_rule.master_etcd will be created
  + resource "oci_core_network_security_group_security_rule" "master_etcd" {
      + description               = "etcd communication"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "10.0.1.0/24"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 2380
              + min = 2379
            }
        }
    }

  # oci_core_network_security_group_security_rule.master_k8s_api will be created
  + resource "oci_core_network_security_group_security_rule" "master_k8s_api" {
      + description               = "Kubernetes API server"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "10.0.1.0/24"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 6443
              + min = 6443
            }
        }
    }

  # oci_core_network_security_group_security_rule.master_kubelet will be created
  + resource "oci_core_network_security_group_security_rule" "master_kubelet" {
      + description               = "Kubelet API"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "10.0.1.0/24"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 10250
              + min = 10250
            }
        }
    }

  # oci_core_network_security_group_security_rule.master_ssh will be created
  + resource "oci_core_network_security_group_security_rule" "master_ssh" {
      + description               = "SSH access to master"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "0.0.0.0/0"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 22
              + min = 22
            }
        }
    }

  # oci_core_network_security_group_security_rule.worker_egress will be created
  + resource "oci_core_network_security_group_security_rule" "worker_egress" {
      + description               = "Allow all outbound traffic"
      + destination               = "0.0.0.0/0"
      + destination_type          = "CIDR_BLOCK"
      + direction                 = "EGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "all"
      + source_type               = (known after apply)
      + stateless                 = (known after apply)
      + time_created              = (known after apply)
    }

  # oci_core_network_security_group_security_rule.worker_kubelet will be created
  + resource "oci_core_network_security_group_security_rule" "worker_kubelet" {
      + description               = "Kubelet API"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "10.0.1.0/24"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 10250
              + min = 10250
            }
        }
    }

  # oci_core_network_security_group_security_rule.worker_nodeport will be created
  + resource "oci_core_network_security_group_security_rule" "worker_nodeport" {
      + description               = "Kubernetes NodePort services"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "0.0.0.0/0"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 32767
              + min = 30000
            }
        }
    }

  # oci_core_network_security_group_security_rule.worker_ssh will be created
  + resource "oci_core_network_security_group_security_rule" "worker_ssh" {
      + description               = "SSH from VCN"
      + destination               = (known after apply)
      + destination_type          = (known after apply)
      + direction                 = "INGRESS"
      + id                        = (known after apply)
      + is_valid                  = (known after apply)
      + network_security_group_id = (known after apply)
      + protocol                  = "6"
      + source                    = "10.0.1.0/24"
      + source_type               = "CIDR_BLOCK"
      + stateless                 = (known after apply)
      + time_created              = (known after apply)

      + tcp_options {
          + destination_port_range {
              + max = 22
              + min = 22
            }
        }
    }

  # oci_core_route_table.main will be created
  + resource "oci_core_route_table" "main" {
      + compartment_id = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + defined_tags   = (known after apply)
      + display_name   = "k8s-devops-vcn-rt"
      + freeform_tags  = (known after apply)
      + id             = (known after apply)
      + state          = (known after apply)
      + time_created   = (known after apply)
      + vcn_id         = (known after apply)

      + route_rules {
          + cidr_block        = (known after apply)
          + description       = (known after apply)
          + destination       = "0.0.0.0/0"
          + destination_type  = "CIDR_BLOCK"
          + network_entity_id = (known after apply)
          + route_type        = (known after apply)
        }
    }

  # oci_core_subnet.main will be created
  + resource "oci_core_subnet" "main" {
      + availability_domain        = (known after apply)
      + cidr_block                 = "10.0.1.0/24"
      + compartment_id             = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + defined_tags               = (known after apply)
      + dhcp_options_id            = (known after apply)
      + display_name               = "k8s-devops-subnet"
      + dns_label                  = "subnet1"
      + freeform_tags              = (known after apply)
      + id                         = (known after apply)
      + ipv6cidr_block             = (known after apply)
      + ipv6cidr_blocks            = (known after apply)
      + ipv6virtual_router_ip      = (known after apply)
      + prohibit_internet_ingress  = (known after apply)
      + prohibit_public_ip_on_vnic = false
      + route_table_id             = (known after apply)
      + security_list_ids          = (known after apply)
      + state                      = (known after apply)
      + subnet_domain_name         = (known after apply)
      + time_created               = (known after apply)
      + vcn_id                     = (known after apply)
      + virtual_router_ip          = (known after apply)
      + virtual_router_mac         = (known after apply)
    }

  # oci_core_vcn.main will be created
  + resource "oci_core_vcn" "main" {
      + byoipv6cidr_blocks               = (known after apply)
      + cidr_block                       = (known after apply)
      + cidr_blocks                      = [
          + "10.0.0.0/16",
        ]
      + compartment_id                   = "ocid1.compartment.oc1..aaaaaaaam3elaucgdikrq7uyltmt2ubzo3pnyoyptqpe22v7ykvdzdvofu5a"
      + default_dhcp_options_id          = (known after apply)
      + default_route_table_id           = (known after apply)
      + default_security_list_id         = (known after apply)
      + defined_tags                     = (known after apply)
      + display_name                     = "k8s-devops-vcn"
      + dns_label                        = "k8sdevops"
      + freeform_tags                    = (known after apply)
      + id                               = (known after apply)
      + ipv6cidr_blocks                  = (known after apply)
      + ipv6private_cidr_blocks          = (known after apply)
      + is_ipv6enabled                   = (known after apply)
      + is_oracle_gua_allocation_enabled = (known after apply)
      + state                            = (known after apply)
      + time_created                     = (known after apply)
      + vcn_domain_name                  = (known after apply)

      + byoipv6cidr_details (known after apply)
    }

Plan: 25 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + jenkins_nexus_instance_id = (known after apply)
  + jenkins_nexus_private_ip  = (known after apply)
  + jenkins_nexus_public_ip   = "Public IP is assigned to VNIC when enabled; use terraform show or OCI console."
  + jenkins_url               = (known after apply)
  + kube_master_instance_id   = (known after apply)
  + kube_master_private_ip    = (known after apply)
  + kube_master_public_ip     = "Public IP is assigned to VNIC when enabled; use terraform show or OCI console."
  + kube_worker_1_instance_id = (known after apply)
  + kube_worker_1_private_ip  = (known after apply)
  + kube_worker_2_instance_id = (known after apply)
  + kube_worker_2_private_ip  = (known after apply)
  + kubernetes_cluster_info   = {
      + api_endpoint      = (known after apply)
      + master_private_ip = (known after apply)
      + master_public_ip  = "Public IP is assigned to VNIC when enabled; use terraform show or OCI console."
      + worker_1_ip       = (known after apply)
      + worker_2_ip       = (known after apply)
    }
  + nexus_url                 = (known after apply)
  + resource_summary          = {
      + environment       = "dev"
      + instances_created = 4
      + project           = "k8s-devops-lab"
      + total_memory_gb   = 23
      + total_ocpu        = "4.5 (approximately)"
      + total_storage_gb  = 197
    }
  + ssh_connection_commands   = {
      + jenkins  = (known after apply)
      + master   = (known after apply)
      + worker_1 = (known after apply)
      + worker_2 = (known after apply)
    }
  + subnet_cidr               = "10.0.1.0/24"
  + subnet_id                 = (known after apply)
  + vcn_id                    = (known after apply)