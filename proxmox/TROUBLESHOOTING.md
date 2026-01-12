## File 24: `TROUBLESHOOTING.md` (Detailed Troubleshooting Guide)

````markdown
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
````

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

# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Increase memory if needed
sudo nano /etc/systemd/system/jenkins.service.d/override.conf
# Change: JENKINS_JAVA_OPTS=-Xmx3g -Xms2g
sudo systemctl daemon-reload
sudo systemctl restart jenkins

# Manual plugin installation
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40
cd /var/lib/jenkins/plugins
sudo wget https://mirrors.jenkins.io/plugins/kubernetes/VERSION/kubernetes.hpi
sudo systemctl restart jenkins
```

## Nexus Issues

### Nexus Container Won't Start

**Solution**:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40

# Check Docker daemon
sudo systemctl status docker

# View Nexus logs
docker logs nexus3

# Increase memory
docker update --memory 2g nexus3

# Restart container
docker restart nexus3

# Check port
sudo netstat -tlnp | grep 8081
```

### Nexus Initial Password Not Found

**Solution**:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40

# Wait for Nexus to fully start (2-3 minutes)
sleep 180

# Get password
docker exec nexus3 cat /nexus-data/admin.password

# If not found, check logs
docker logs nexus3 | tail -20

# Check file permissions
docker exec nexus3 ls -la /nexus-data/
```

## Prometheus Issues

### Prometheus Targets Down

**Symptom**: Targets marked as "Down" in Prometheus

**Solution**:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.50

# Check configuration
sudo nano /etc/prometheus/prometheus.yml

# Verify target IPs are correct
ping 10.0.1.10
ping 10.0.1.40

# Restart Prometheus
sudo systemctl restart prometheus

# Check logs
sudo journalctl -u prometheus -f

# Test connectivity from Prometheus
sudo su - prometheus
curl http://10.0.1.10:10250/metrics
```

### Prometheus High Memory Usage

**Solution**:

```bash
# Reduce retention period
sudo nano /etc/prometheus/prometheus.yml
# Add: --storage.tsdb.retention.time=7d

# Reduce scrape frequency
# Change: scrape_interval: 60s (instead of 30s)

# Restart Prometheus
sudo systemctl restart prometheus
```

## Grafana Issues

### Grafana Won't Start

**Solution**:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.50

# Check service status
sudo systemctl status grafana-server

# View logs
sudo journalctl -u grafana-server -f

# Check port
sudo netstat -tlnp | grep 3000

# Restart service
sudo systemctl restart grafana-server
```

### Prometheus Datasource Connection Failed

**Solution**:

```bash
# Verify Prometheus is running
curl http://10.0.1.50:9090/-/healthy

# Check Grafana configuration
sudo nano /etc/grafana/provisioning/datasources/prometheus.yaml

# Update URL if needed:
# url: http://localhost:9090

# Restart Grafana
sudo systemctl restart grafana-server
```

### Default Credentials Not Working

**Solution**:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.50

# Reset admin password
sudo grafana-cli admin reset-admin-password newpassword

# Or via database
sudo sqlite3 /var/lib/grafana/grafana.db \
  "UPDATE user SET password='admin',version=0 WHERE login='admin';"

# Restart Grafana
sudo systemctl restart grafana-server
```

## Storage Issues

### Disk Space Running Out

**Error**: `Error: No space left on device`

**Solution**:

```bash
# Check disk usage
df -h

# Check which folder is large
du -sh /var/lib/*
du -sh /home/*

# Clean old logs
sudo journalctl --vacuum=100M

# Clean Docker unused images
docker image prune -a

# Clean Prometheus old data (if needed)
# Stop Prometheus first
sudo systemctl stop prometheus
# Find and remove old data
ls -la /var/lib/prometheus/wal
# Restart
sudo systemctl start prometheus

# Check total usage
terraform output resource_summary
```

## Memory Issues

### High Memory Usage

**Solution**:

```bash
# Check current usage
free -h

# Per-service breakdown
ps aux --sort=-%mem | head

# Kubernetes usage
kubectl top nodes
kubectl top pods -A

# Reduce Jenkins memory
sudo nano /etc/systemd/system/jenkins.service.d/override.conf
# Change: JENKINS_JAVA_OPTS=-Xmx1g -Xms512m

# Reduce Prometheus scrape interval
sudo nano /etc/prometheus/prometheus.yml
# Change: scrape_interval: 60s

# Reduce Nexus memory
docker update --memory 1g nexus3
docker restart nexus3
```

## Network Issues

### Pods Can't Reach External Services

**Solution**:

```bash
# Check network policies
kubectl get networkpolicies -A

# Check DNS
kubectl run -it --image=busybox debug -- sh
/ # nslookup google.com
/ # ping 8.8.8.8

# Check default gateway
route -n

# Check iptables rules
sudo iptables -L -n
```

### Services Can't Reach Each Other

**Solution**:

```bash
# Test connectivity between instances
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10
ping 10.0.1.40

# Check security groups
oci compute instance list-vnics --instance-id <ocid>

# Check UFW firewall
sudo ufw status

# Temporarily disable UFW for testing
sudo ufw disable
# Re-enable after testing
sudo ufw enable
```

## Performance Issues

### Slow Kubernetes Response

**Solution**:

```bash
# Check etcd performance
kubectl get --raw /metrics | grep etcd

# Check API server logs
kubectl logs -n kube-system -l component=kube-apiserver

# Check node resources
kubectl top nodes
kubectl describe nodes

# Optimize K3s
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10
sudo nano /etc/systemd/system/k3s.service
# Add: --kube-apiserver-arg=max-requests-inflight=2000
sudo systemctl restart k3s
```

### Slow Builds in Jenkins

**Solution**:

```bash
# Increase executor count
Jenkins → Manage Jenkins → Configure System → # of executors = 4

# Increase memory
Increase JENKINS_JAVA_OPTS

# Use distributed builds
Install Jenkins Kubernetes plugin

# Optimize Docker
# Remove unused images: docker image prune
# Remove unused volumes: docker volume prune
```

## Connectivity Verification

### Complete Health Check Script

```bash
#!/bin/bash
# save as: health-check.sh

echo "=== Infrastructure Health Check ==="

# Test instance connectivity
echo "Testing SSH connectivity..."
for ip in 10.0.1.10 10.0.1.20 10.0.1.30 10.0.1.40 10.0.1.50; do
    timeout 3 bash -c "echo > /dev/tcp/$ip/22" && echo "✓ $ip SSH OK" || echo "✗ $ip SSH FAILED"
done

# Test Kubernetes
echo -e "\n=== Kubernetes Status ==="
kubectl get nodes
kubectl get pods -A

# Test services
echo -e "\n=== Service Status ==="
curl -s http://10.0.1.50:9090/-/healthy && echo "✓ Prometheus OK" || echo "✗ Prometheus FAILED"
curl -s http://10.0.1.50:3000/api/health && echo "✓ Grafana OK" || echo "✗ Grafana FAILED"
curl -s -I http://10.0.1.40:8080 | head -1 && echo "✓ Jenkins OK" || echo "✗ Jenkins FAILED"
curl -s -I http://10.0.1.40:8081 | head -1 && echo "✓ Nexus OK" || echo "✗ Nexus FAILED"

# Check resources
echo -e "\n=== Resource Usage ==="
free -h
df -h /
kubectl top nodes 2>/dev/null || echo "Metrics not available yet"

echo -e "\n=== Health Check Complete ==="
```

## Emergency Procedures

### Full Reset

```bash
# If everything is broken, perform full reset

# 1. Delete all K3s data (on master and workers)
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10
sudo /usr/local/bin/k3s-uninstall.sh
sudo rm -rf /var/lib/rancher

# 2. Delete Docker containers (on Jenkins)
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.40
docker rm -f $(docker ps -aq)
docker volume prune -f

# 3. Re-run Ansible playbooks
cd ansible
ansible-playbook -i inventory.ini playbooks/02-k3s-master.yml
ansible-playbook -i inventory.ini playbooks/03-k3s-worker.yml
```

### Backup Before Testing

```bash
# Create kubeconfig backup
ssh -i ~/.ssh/id_rsa ubuntu@10.0.1.10
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/k3s.yaml.bak

# Create etcd snapshot
kubectl exec -n kube-system -it etcd-kube-master -- \
  etcdctl --endpoints=localhost:2379 snapshot save /tmp/etcd-backup.db

# Download backup
scp -i ~/.ssh/id_rsa ubuntu@10.0.1.10:/tmp/etcd-backup.db ~/backups/
```
