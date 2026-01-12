Perfect! Let me complete both files:

---

## File 19: `ansible/playbooks/03-k3s-worker.yml` (COMPLETE - MISSING PART)

```yaml
# ========================================================================
# VERIFICATION (CONTINUED FROM ABOVE)
# ========================================================================

- name: Check K3s agent status
  shell: systemctl status k3s-agent
  register: k3s_agent_status
  ignore_errors: yes

- name: Display K3s agent status
  debug:
    msg: '{{ k3s_agent_status.stdout }}'

- name: View K3s agent logs
  shell: journalctl -u k3s-agent -n 20 --no-pager
  register: k3s_logs

- name: Display recent K3s agent logs
  debug:
    msg: '{{ k3s_logs.stdout }}'
```

---

## File 20: `ansible/playbooks/04-jenkins-nexus.yml` (COMPLETE - MISSING PART)

```yaml
    - name: Display Nexus URL
      debug:
        msg: "Nexus: http://{{ ansible_host }}:{{ nexus_port }}"

    - name: Jenkins service status
      systemctl:
        name: jenkins
      register: jenkins_status_result

    - name: Display Jenkins status
      debug:
        msg: "Jenkins Status: {{ 'Active' if jenkins_status_result.status.ActiveState == 'active' else 'Inactive' }}"

    - name: Nexus container status
      shell: docker ps | grep nexus3
      register: nexus_status

    - name: Display Nexus container status
      debug:
        msg: "{{ nexus_status.stdout }}"

  handlers:
    - name: Restart Jenkins
      systemctl:
        name: jenkins
        state: restarted

    - name: Restart Nexus
      docker_container:
        name: nexus3
        state: restarted
```

---

## File 21: `ansible/playbooks/05-monitoring.yml` (Monitoring Stack)

```yaml
################################################################################
# ANSIBLE PLAYBOOK 5: MONITORING STACK SETUP
# Installs Prometheus and Grafana for metrics collection and visualization
################################################################################

---
- name: Setup Monitoring Stack (Prometheus + Grafana)
  hosts: monitoring_servers
  become: true
  gather_facts: true

  vars:
    prometheus_version: '2.48.0'
    grafana_version: '10.2.0'
    node_exporter_version: '1.7.0'

  tasks:
    # ========================================================================
    # SYSTEM PREREQUISITES
    # ========================================================================

    - name: Create prometheus system user
      user:
        name: prometheus
        system: yes
        shell: /bin/false
        home: /var/lib/prometheus

    - name: Create grafana system user
      user:
        name: grafana
        system: yes
        shell: /bin/false
        home: /var/lib/grafana

    # ========================================================================
    # PROMETHEUS INSTALLATION
    # ========================================================================

    - name: Create prometheus directories
      file:
        path: '{{ item }}'
        state: directory
        owner: prometheus
        group: prometheus
      loop:
        - /opt/prometheus
        - /var/lib/prometheus
        - /etc/prometheus

    - name: Download Prometheus
      get_url:
        url: 'https://github.com/prometheus/prometheus/releases/download/v{{ prometheus_version }}/prometheus-{{ prometheus_version }}.linux-arm64.tar.gz'
        dest: /tmp/prometheus.tar.gz
      when: ansible_machine == 'aarch64'

    - name: Download Prometheus (x86)
      get_url:
        url: 'https://github.com/prometheus/prometheus/releases/download/v{{ prometheus_version }}/prometheus-{{ prometheus_version }}.linux-amd64.tar.gz'
        dest: /tmp/prometheus.tar.gz
      when: ansible_machine == 'x86_64'

    - name: Extract Prometheus
      unarchive:
        src: /tmp/prometheus.tar.gz
        dest: /opt/prometheus
        remote_src: yes
        extra_opts: ['--strip-components=1']

    - name: Create Prometheus config directory
      file:
        path: /etc/prometheus
        state: directory
        owner: prometheus
        group: prometheus

    - name: Create Prometheus configuration file
      copy:
        content: |
          global:
            scrape_interval: 30s
            evaluation_interval: 30s
            external_labels:
              cluster: 'kubernetes-devops-lab'
              environment: 'dev'

          scrape_configs:
            - job_name: 'prometheus'
              static_configs:
                - targets: ['localhost:9090']

            - job_name: 'kubernetes-master'
              static_configs:
                - targets: ['10.0.1.10:10250']

            - job_name: 'kubernetes-workers'
              static_configs:
                - targets:
                    - '10.0.1.20:10250'
                    - '10.0.1.30:10250'

            - job_name: 'node-exporter'
              static_configs:
                - targets:
                    - '10.0.1.10:9100'
                    - '10.0.1.20:9100'
                    - '10.0.1.30:9100'
                    - '10.0.1.40:9100'
                    - '10.0.1.50:9100'

            - job_name: 'jenkins'
              metrics_path: '/prometheus'
              static_configs:
                - targets: ['10.0.1.40:8080']

            - job_name: 'grafana'
              static_configs:
                - targets: ['localhost:3000']
        dest: /etc/prometheus/prometheus.yml
        owner: prometheus
        group: prometheus

    - name: Create Prometheus systemd service
      copy:
        content: |
          [Unit]
          Description=Prometheus
          Wants=network-online.target
          After=network-online.target

          [Service]
          Type=simple
          User=prometheus
          Group=prometheus
          ExecStart=/opt/prometheus/prometheus \
            --config.file=/etc/prometheus/prometheus.yml \
            --storage.tsdb.path=/var/lib/prometheus \
            --web.console.templates=/opt/prometheus/consoles \
            --web.console.libraries=/opt/prometheus/console_libraries
          Restart=on-failure

          [Install]
          WantedBy=multi-user.target
        dest: /etc/systemd/system/prometheus.service
        mode: '0644'

    - name: Start Prometheus service
      systemd:
        name: prometheus
        state: started
        enabled: yes
        daemon_reload: yes

    - name: Wait for Prometheus to start
      wait_for:
        port: 9090
        delay: 5
        timeout: 60

    # ========================================================================
    # GRAFANA INSTALLATION
    # ========================================================================

    - name: Add Grafana GPG key
      apt_key:
        url: https://packages.grafana.com/gpg.key
        state: present

    - name: Add Grafana repository
      apt_repository:
        repo: 'deb https://packages.grafana.com/oss/deb stable main'
        state: present

    - name: Install Grafana
      apt:
        name: grafana-server
        state: present

    - name: Create Grafana datasources directory
      file:
        path: /etc/grafana/provisioning/datasources
        state: directory
        owner: grafana
        group: grafana

    - name: Create Prometheus datasource
      copy:
        content: |
          apiVersion: 1

          datasources:
            - name: Prometheus
              type: prometheus
              access: proxy
              url: http://localhost:9090
              isDefault: true
              editable: true
        dest: /etc/grafana/provisioning/datasources/prometheus.yaml
        owner: grafana
        group: grafana

    - name: Start Grafana service
      systemd:
        name: grafana-server
        state: started
        enabled: yes

    - name: Wait for Grafana to start
      wait_for:
        port: 3000
        delay: 5
        timeout: 60

    # ========================================================================
    # NODE EXPORTER INSTALLATION
    # ========================================================================

    - name: Create node-exporter user
      user:
        name: node_exporter
        system: yes
        shell: /bin/false

    - name: Download node-exporter
      get_url:
        url: 'https://github.com/prometheus/node_exporter/releases/download/v{{ node_exporter_version }}/node_exporter-{{ node_exporter_version }}.linux-arm64.tar.gz'
        dest: /tmp/node_exporter.tar.gz
      when: ansible_machine == 'aarch64'

    - name: Download node-exporter (x86)
      get_url:
        url: 'https://github.com/prometheus/node_exporter/releases/download/v{{ node_exporter_version }}/node_exporter-{{ node_exporter_version }}.linux-amd64.tar.gz'
        dest: /tmp/node_exporter.tar.gz
      when: ansible_machine == 'x86_64'

    - name: Extract node-exporter
      unarchive:
        src: /tmp/node_exporter.tar.gz
        dest: /opt
        remote_src: yes
        extra_opts: ['--strip-components=1']

    - name: Create node-exporter systemd service
      copy:
        content: |
          [Unit]
          Description=Node Exporter
          After=network.target

          [Service]
          Type=simple
          User=node_exporter
          ExecStart=/opt/node_exporter/node_exporter
          Restart=on-failure

          [Install]
          WantedBy=multi-user.target
        dest: /etc/systemd/system/node-exporter.service
        mode: '0644'

    - name: Start node-exporter service
      systemd:
        name: node-exporter
        state: started
        enabled: yes
        daemon_reload: yes

    - name: Wait for node-exporter to start
      wait_for:
        port: 9100
        delay: 5
        timeout: 60

    # ========================================================================
    # FIREWALL RULES
    # ========================================================================

    - name: Allow Prometheus port
      ufw:
        rule: allow
        port: '9090'
        proto: tcp

    - name: Allow Grafana port
      ufw:
        rule: allow
        port: '3000'
        proto: tcp

    - name: Allow node-exporter port
      ufw:
        rule: allow
        port: '9100'
        proto: tcp

    # ========================================================================
    # VERIFICATION
    # ========================================================================

    - name: Check Prometheus service
      systemctl:
        name: prometheus
      register: prometheus_service

    - name: Check Grafana service
      systemctl:
        name: grafana-server
      register: grafana_service

    - name: Check node-exporter service
      systemctl:
        name: node-exporter
      register: node_exporter_service

    - name: Display Prometheus status
      debug:
        msg: "Prometheus Status: {{ 'Active' if prometheus_service.status.ActiveState == 'active' else 'Inactive' }}"

    - name: Display Grafana status
      debug:
        msg: "Grafana Status: {{ 'Active' if grafana_service.status.ActiveState == 'active' else 'Inactive' }}"

    - name: Display node-exporter status
      debug:
        msg: "Node Exporter Status: {{ 'Active' if node_exporter_service.status.ActiveState == 'active' else 'Inactive' }}"

    - name: Display access URLs
      debug:
        msg:
          - 'Prometheus: http://{{ ansible_host }}:9090'
          - 'Grafana: http://{{ ansible_host }}:3000 (admin/admin)'
          - 'Node Exporter: http://{{ ansible_host }}:9100'

  handlers:
    - name: Restart Prometheus
      systemctl:
        name: prometheus
        state: restarted

    - name: Restart Grafana
      systemctl:
        name: grafana-server
        state: restarted
```

---

## File 22: `DEPLOYMENT_GUIDE.md` (Complete Deployment Instructions)

````markdown
# Complete Deployment Guide - Kubernetes DevOps Lab

## Prerequisites

```bash
# 1. Terraform installed (>= 1.0)
terraform --version

# 2. Ansible installed (>= 2.9)
ansible --version

# 3. OCI CLI configured
oci --version
oci os ns get  # Test connection

# 4. SSH key pair generated
ls ~/.ssh/id_rsa
```
````

## Step 1: Prepare Terraform Variables

```bash
cd terraform

# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars
```

**Required values to fill:**

- `tenancy_ocid`: From OCI Console > Profile
- `ssh_public_key`: From `cat ~/.ssh/id_rsa.pub`

## Step 2: Initialize Terraform

```bash
terraform init
terraform validate
terraform fmt
```

## Step 3: Plan Deployment

```bash
terraform plan -out=tfplan
```

Review the plan output carefully. It should show:

- 1 VCN
- 1 Subnet
- 4 Security Groups
- 5 Compute Instances

## Step 4: Apply Terraform

```bash
terraform apply tfplan
```

**Expected time:** 5-10 minutes

Once complete, save the outputs:

```bash
terraform output
terraform output -json > ../outputs.json
```

## Step 5: Update Ansible Inventory

```bash
cd ../ansible

# Update inventory.ini with instance IPs from Terraform outputs
nano inventory.ini
```

Update these IPs:

- kube-master: 10.0.1.10
- kube-worker-1: 10.0.1.20
- kube-worker-2: 10.0.1.30
- jenkins-nexus: 10.0.1.40
- monitoring: 10.0.1.50

## Step 6: Wait for Instances to Boot

```bash
# Wait 2-3 minutes for instances to fully boot
sleep 180

# Test SSH connectivity
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10 "echo 'SSH connected!'"
```

## Step 7: Run Ansible Playbooks

```bash
cd ansible

# 1. Prepare all systems
ansible-playbook -i inventory.ini playbooks/01-prepare.yml

# 2. Setup Kubernetes master
ansible-playbook -i inventory.ini playbooks/02-k3s-master.yml

# 3. Setup Kubernetes workers
ansible-playbook -i inventory.ini playbooks/03-k3s-worker.yml

# 4. Setup CI/CD (Jenkins + Nexus)
ansible-playbook -i inventory.ini playbooks/04-jenkins-nexus.yml

# 5. Setup Monitoring (Prometheus + Grafana)
ansible-playbook -i inventory.ini playbooks/05-monitoring.yml
```

**Total time:** ~30-45 minutes

## Step 8: Verify Deployment

```bash
# SSH into master
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10

# Check Kubernetes cluster
kubectl get nodes -o wide
kubectl get pods -A

# Check services
kubectl get svc -A

# View cluster info
kubectl cluster-info
```

## Accessing Services

| Service | URL | Credentials |
| ------- | --- | ----------- |

Good! Now let me complete the deployment guide and provide all remaining files:

---

## File 22: `DEPLOYMENT_GUIDE.md` (COMPLETE - Accessing Services Section)

````markdown
## Accessing Services

| Service        | URL                    | Credentials              | Port |
| -------------- | ---------------------- | ------------------------ | ---- |
| Kubernetes API | https://10.0.1.10:6443 | kubeconfig               | 6443 |
| Jenkins        | http://10.0.1.40:8080  | admin/<initial-password> | 8080 |
| Nexus          | http://10.0.1.40:8081  | admin/<initial-password> | 8081 |
| Prometheus     | http://10.0.1.50:9090  | None (no auth)           | 9090 |
| Grafana        | http://10.0.1.50:3000  | admin/admin              | 3000 |

## Testing Kubernetes Cluster

```bash
# SSH into master
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10

# Get kubeconfig
cat ~/.kube/config

# Test basic commands
kubectl get nodes
kubectl get pods -A
kubectl get svc -A

# Deploy test application
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --type=LoadBalancer --port=80

# Check deployment
kubectl get deployment
kubectl get svc

# Scale test deployment
kubectl scale deployment nginx --replicas=3

# Check pods
kubectl get pods -o wide

# View logs
kubectl logs -l app=nginx
```
````

## Testing Jenkins Pipeline

1. Access Jenkins: `http://10.0.1.40:8080`
2. Get initial admin password:
   ```bash
   ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Install suggested plugins
4. Create new pipeline job
5. Configure GitHub/GitLab webhook
6. Trigger build

## Testing Prometheus & Grafana

1. Access Prometheus: `http://10.0.1.50:9090`

   - View targets
   - Query metrics

2. Access Grafana: `http://10.0.1.50:3000`
   - Default login: admin/admin
   - Add Prometheus as datasource
   - Import Kubernetes dashboards

## Monitoring Kubernetes

```bash
# View resource usage
kubectl top nodes
kubectl top pods -A

# Check cluster health
kubectl get cs
kubectl get events -A

# View Prometheus targets
curl http://10.0.1.50:9090/api/v1/targets
```

## Troubleshooting

### Instances not responding

```bash
# Check instance status
terraform show | grep instance_id

# Get instance details from OCI CLI
oci compute instance list --compartment-id <ocid>
```

### Kubernetes nodes not joining

```bash
# Check K3s master logs
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10
journalctl -u k3s -f

# Check K3s agent logs
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.20
journalctl -u k3s-agent -f
```

### Jenkins not starting

```bash
# Check Jenkins logs
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40
sudo journalctl -u jenkins -n 50

# Restart Jenkins
sudo systemctl restart jenkins
```

### Prometheus not collecting metrics

```bash
# Check Prometheus targets
curl http://10.0.1.50:9090/api/v1/targets | jq '.'

# Check node-exporter
curl http://10.0.1.50:9100/metrics
```

## Cleanup

```bash
# Destroy all infrastructure
cd terraform
terraform destroy -auto-approve

# Clean local files
rm -f tfplan terraform.tfstate* outputs.json
rm -f ansible/ansible.log

# Remove SSH known_hosts entries
ssh-keygen -R 10.0.1.10
ssh-keygen -R 10.0.1.20
ssh-keygen -R 10.0.1.30
ssh-keygen -R 10.0.1.40
ssh-keygen -R 10.0.1.50
```

## Performance Tuning

### For K3s Master

- Monitor etcd performance
- Adjust API server flags
- Optimize scheduler

### For Workers

- Monitor pod density
- Adjust resource limits
- Optimize networking

### For Jenkins

- Increase Java heap size
- Use distributed builds
- Optimize pipeline

### For Prometheus

- Adjust scrape intervals
- Optimize retention policy
- Use remote storage

## Security Best Practices

1. Change default credentials
2. Enable RBAC
3. Implement network policies
4. Use SSL/TLS
5. Regular backups
6. Monitor access logs
7. Keep components updated

## Resource Monitoring

```bash
# Check overall resource usage
terraform output resource_summary

# Monitor during operation
watch kubectl top nodes
watch 'kubectl get pods -A'
watch 'df -h'
```

## Next Steps

1. **Add persistent storage**: PV/PVC for stateful apps
2. **Implement backup**: etcd snapshots, PV backups
3. **Setup logging**: ELK stack or Loki
4. **Add ingress**: NGINX or Traefik
5. **Implement CI/CD**: Full pipeline setup
6. **Add security scanning**: Trivy, Falco
7. **Setup monitoring alerts**: AlertManager rules

```

```
