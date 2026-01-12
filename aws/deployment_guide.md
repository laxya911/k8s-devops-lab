## File 22: `DEPLOYMENT_GUIDE.md` (Complete Deployment Instructions)

```markdown
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


```markdown
## Accessing Services

| Service | URL | Credentials | Port |
|---------|-----|-------------|------|
| Kubernetes API | https://10.0.1.10:6443 | kubeconfig | 6443 |
| Jenkins | http://10.0.1.40:8080 | admin/<initial-password> | 8080 |
| Nexus | http://10.0.1.40:8081 | admin/<initial-password> | 8081 |
| Prometheus | http://10.0.1.50:9090 | None (no auth) | 9090 |
| Grafana | http://10.0.1.50:3000 | admin/admin | 3000 |

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

***

## File 23: `QUICK_REFERENCE.md` (Quick Reference Guide)

```markdown
# Quick Reference - Kubernetes DevOps Lab

## Directory Structure

```
k8s-devops-lab/
├── terraform/          # Infrastructure as Code
├── ansible/            # Configuration Management
├── scripts/            # Automation scripts
└── docs/               # Documentation
```

## Common Commands

### Terraform

```bash
cd terraform

# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy
terraform destroy -auto-approve

# Show outputs
terraform output
terraform output -json > ../outputs.json
```

### Ansible

```bash
cd ansible

# Check syntax
ansible-playbook --syntax-check playbooks/*.yml

# Run playbook
ansible-playbook -i inventory.ini playbooks/01-prepare.yml

# Run specific host
ansible-playbook -i inventory.ini playbooks/02-k3s-master.yml -l kube-master

# Dry run
ansible-playbook -i inventory.ini playbooks/*.yml --check

# Verbose output
ansible-playbook -i inventory.ini playbooks/*.yml -vv
```

### Kubernetes

```bash
# Get resources
kubectl get nodes
kubectl get pods -A
kubectl get svc -A
kubectl get deploy -A

# Describe resource
kubectl describe node kube-master
kubectl describe pod <pod-name> -n default

# View logs
kubectl logs <pod-name> -n default
kubectl logs -f <pod-name> -n default  # Follow

# Execute command
kubectl exec -it <pod-name> -n default -- /bin/bash

# Port forward
kubectl port-forward pod/<pod-name> 8080:8080

# Scale deployment
kubectl scale deployment <name> --replicas=3

# Delete resource
kubectl delete pod <pod-name>
kubectl delete deployment <name>
```

### SSH Access

```bash
# Master
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10

# Worker 1
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.20

# Worker 2
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.30

# Jenkins
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40

# Monitoring
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.50
```

## Instance IPs

| Instance | Private IP | Service |
|----------|-----------|---------|
| Master | 10.0.1.10 | K8s API, etcd, Kubelet |
| Worker 1 | 10.0.1.20 | Kubelet, Pods |
| Worker 2 | 10.0.1.30 | Kubelet, Pods |
| CI/CD | 10.0.1.40 | Jenkins, Nexus |
| Monitoring | 10.0.1.50 | Prometheus, Grafana |

## Service Ports

| Service | Port | Access |
|---------|------|--------|
| Kubernetes API | 6443 | Internal |
| Jenkins | 8080 | Public |
| Nexus | 8081 | Public |
| Prometheus | 9090 | Internal |
| Grafana | 3000 | Public |
| Node Exporter | 9100 | Internal |
| Kubelet | 10250 | Internal |
| etcd | 2379-2380 | Internal |

## File Locations

### On Master
- `/etc/rancher/k3s/k3s.yaml` - kubeconfig
- `/var/lib/rancher/k3s/` - K3s data
- `/var/lib/rancher/k3s/server/node-token` - Worker token

### On Jenkins
- `/var/lib/jenkins/` - Jenkins home
- `/opt/nexus/data/` - Nexus data
- `/var/lib/jenkins/secrets/initialAdminPassword` - Jenkins admin password

### On Monitoring
- `/etc/prometheus/prometheus.yml` - Prometheus config
- `/var/lib/prometheus/` - Prometheus data
- `/etc/grafana/provisioning/` - Grafana config
- `/var/lib/grafana/` - Grafana data

## Resource Limits (Free Tier)

- Total OCPU: 4
- Total Memory: 24GB
- Total Storage: 200GB
- Instances: 5 (3 Ampere A1.Flex + 2 E2 Micro)

## Playbook Execution Order

1. `01-prepare.yml` - Base system setup (all hosts)
2. `02-k3s-master.yml` - Kubernetes master
3. `03-k3s-worker.yml` - Kubernetes workers
4. `04-jenkins-nexus.yml` - CI/CD stack
5. `05-monitoring.yml` - Monitoring stack

## Useful Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kgn='kubectl get nodes'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kdesc='kubectl describe'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| SSH timeout | Wait 2-3 min for instances to boot |
| K3s not starting | Check logs: `journalctl -u k3s -f` |
| Worker not joining | Verify token on master: `/var/lib/rancher/k3s/server/node-token` |
| Jenkins not accessible | Check firewall: `sudo ufw status` |
| Prometheus no data | Verify targets: `http://localhost:9090/api/v1/targets` |
| High memory usage | Check resource limits: `kubectl top nodes` |
| Disk full | Check storage: `df -h` |

## Monitoring Checklist

- [ ] All instances running
- [ ] All nodes joined K3s cluster
- [ ] Jenkins accessible and plugins installed
- [ ] Nexus accessible and configured
- [ ] Prometheus scraping targets
- [ ] Grafana dashboards configured
- [ ] Node exporters reporting metrics
- [ ] Storage not exceeding 200GB
- [ ] Memory not exceeding 24GB
```

***

## File 24: `TROUBLESHOOTING.md` (Detailed Troubleshooting Guide)

```markdown
# Troubleshooting Guide

## Infrastructure Issues

### Terraform Apply Fails

**Error**: `Error: 400-InvalidParameter`

**Solution**:
```bash
# Check OCI credentials
oci os ns get

# Validate variables
terraform validate

# Check tenancy OCID format
echo $tenancy_ocid  # Should be: ocid1.tenancy.oc1..aaa...

# Retry with verbose output
TF_LOG=DEBUG terraform apply tfplan
```

### Instances Won't Start

**Error**: `Error creating instance`

**Solution**:
```bash
# Check capacity
terraform plan

# Verify shape availability
oci compute shape list --compartment-id <ocid>

# Check free tier resources
oci limits quota get --compartment-id <ocid>
```

### SSH Connection Timeout

**Error**: `Connection timeout connecting to...`

**Solution**:
```bash
# Instances need 2-3 minutes to boot
sleep 180

# Test connectivity
ping 10.0.1.10

# Check security groups
oci compute instance get --instance-id <ocid>

# Verify SSH key
ssh -vv -i ~/.ssh/id_rsa ubuntu@10.0.1.10
```

## Kubernetes Issues

### Nodes Not Joining Cluster

**Symptom**: `kubectl get nodes` shows only master

**Solution**:
```bash
# Check worker K3s logs
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.20
sudo journalctl -u k3s-agent -f

# Verify master token
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10
cat /var/lib/rancher/k3s/server/node-token

# Manually join worker
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.20
sudo /tmp/k3s agent \
  --server https://10.0.1.10:6443 \
  --token '...'
```

### Pods Not Running

**Symptom**: `kubectl get pods` shows Pending/CrashLoopBackOff

**Solution**:
```bash
# Check pod status
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name> -c tainer-name>

# Check resource availability
kubectl top nodes
kubectl top pods

# Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

### Network Issues Between Pods

**Symptom**: Pods can't communicate

**Solution**:
```bash
# Test DNS
kubectl run -it --image=busybox dns-test -- sh
nslookup kubernetes.default

# Check network policies
kubectl get networkpolicies -A

# Check CNI
kubectl get daemonset -n kube-system

# Test connectivity
kubectl exec -it <pod1> -- ping <pod2-ip>
```

## Jenkins Issues

### Jenkins Won't Start

**Error**: Port 8080 in use or Jenkins service inactive

**Solution**:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40

# Check service status
sudo systemctl status jenkins

# View logs
sudo journalctl -u jenkins -f

# Restart service
sudo systemctl restart jenkins

# Check port
sudo netstat -tlnp | grep 8080

# Kill process on port
sudo lsof -ti:8080 | xargs kill -9
```

### Initial Admin Password Not Found

**Error**: Initializing Jenkins and password file missing

**Solution**:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40

# Wait for Jenkins to initialize
sleep 30

# Get password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# If still missing, check Java process
ps aux | grep jenkins

# Increase heap size
sudo nano /etc/systemd/system/jenkins.service.d/override.conf
# Set: JENKINS_JAVA_OPTS=-Xmx3g -Xms1g
sudo systemctl daemon-reload
sudo systemctl restart jenkins
```

### Jenkins Plugins Won't Install

**Solution**:
```bash
# Check internet connectivity
curl https://plugins.jenkins.io/

# Use offline plugin installation
# 1. Download .hpi files
# 2. Copy to /var/lib/jenkins/plugins/
