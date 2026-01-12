# Application Deployment Testing Guide

This guide provides a structured, progressive approach to testing your Kubernetes DevOps lab. Each phase builds on the previous one, introducing new concepts and complexity.

---

## Overview

**Goal:** Validate your K3s cluster, Jenkins CI/CD pipeline, and Nexus registry through progressively complex application deployments.

**Testing Flow:**
1. Manual deployment → Verify K8s works
2. Jenkins pipeline deployment → Verify CI/CD works
3. Auto-healing & scaling tests → Verify K8s features
4. Infrastructure rebuild → Verify reproducibility

---

## Phase 1: Static Web Application (START HERE)

### Application: Custom Nginx Static Site

**What it is:** A simple Nginx web server serving custom HTML/CSS content.

**Why start here:**
- ✅ Simplest possible deployment
- ✅ Quick to build and verify
- ✅ No database or backend complexity
- ✅ Easy to see changes when rebuilding
- ✅ Tests fundamental K8s concepts

### Learning Objectives

**Kubernetes Concepts:**
- Creating Deployments
- Exposing Services (NodePort/LoadBalancer)
- Managing Pods
- Basic kubectl commands
- Resource management (CPU/Memory limits)

**CI/CD Concepts:**
- Building Docker images
- Pushing to private registry (Nexus)
- Jenkins pipeline basics
- Automated deployment

**DevOps Testing:**
- Pod self-healing (delete pods, watch recreation)
- Manual scaling (increase/decrease replicas)
- Rolling updates (change image, watch rollout)
- Service discovery and load balancing

### Testing Checklist

- [ ] Manual deployment using kubectl
- [ ] Access application via NodePort
- [ ] Delete a pod, verify auto-recreation
- [ ] Scale to 5 replicas
- [ ] Build image via Jenkins
- [ ] Push image to Nexus
- [ ] Deploy from Nexus image
- [ ] Update HTML, trigger rolling update
- [ ] Verify zero-downtime deployment

### Expected Outcomes

- Application accessible on all worker nodes
- 3 replicas running across cluster
- Pods automatically recreate when deleted
- Jenkins successfully builds and pushes to Nexus
- Rolling updates work without downtime

---

## Phase 2: Stateless REST API

### Application: Simple Todo API (In-Memory Storage)

**What it is:** A REST API built with Node.js/Python Flask that stores data in memory (no database).

**Why this phase:**
- ✅ Introduces API testing
- ✅ Better for load balancing demos
- ✅ Enables horizontal pod autoscaling
- ✅ Still no database complexity
- ✅ Real-world stateless microservice pattern

### Learning Objectives

**Kubernetes Concepts:**
- Horizontal Pod Autoscaler (HPA)
- Service types (ClusterIP vs NodePort)
- Liveness and readiness probes
- Resource requests and limits
- ConfigMaps for configuration

**CI/CD Concepts:**
- Multi-stage Docker builds
- Environment-specific configurations
- API testing in pipeline
- Health check endpoints

**DevOps Testing:**
- Load testing with curl/ab
- Auto-scaling based on CPU
- Service mesh basics (optional)
- Blue-green deployments

### Testing Checklist

- [ ] Deploy API with 3 replicas
- [ ] Test CRUD operations via curl
- [ ] Configure HPA (min: 3, max: 10)
- [ ] Generate load, watch auto-scaling
- [ ] Test rolling update with new version
- [ ] Verify load balancing across pods
- [ ] Test liveness probe (kill process)
- [ ] Test readiness probe (startup delay)

### Expected Outcomes

- API responds to HTTP requests
- Load distributed across all replicas
- Auto-scaling triggers under load
- Unhealthy pods automatically restarted
- Zero-downtime during updates

---

## Phase 3: Full-Stack Application with Database

### Application: Voting App or Guestbook

**What it is:** Multi-tier application with frontend, backend API, and persistent database.

**Why this phase:**
- ✅ Real-world architecture pattern
- ✅ Tests StatefulSets for databases
- ✅ Introduces persistent storage
- ✅ Multi-container coordination
- ✅ Complex networking scenarios

### Learning Objectives

**Kubernetes Concepts:**
- StatefulSets for databases
- PersistentVolumes and PersistentVolumeClaims
- Secrets for sensitive data
- ConfigMaps for application config
- Multi-tier networking
- Init containers
- Volume mounts

**CI/CD Concepts:**
- Multi-service deployments
- Database migrations
- Environment promotion (dev → staging → prod)
- Rollback strategies

**DevOps Testing:**
- Database persistence across pod restarts
- Backup and restore
- StatefulSet scaling
- Network policies
- Resource quotas

### Testing Checklist

- [ ] Deploy database (PostgreSQL/MySQL) as StatefulSet
- [ ] Create PersistentVolume for data
- [ ] Deploy backend API connected to database
- [ ] Deploy frontend connected to backend
- [ ] Test data persistence (delete pod, data remains)
- [ ] Scale database (if applicable)
- [ ] Test backup and restore
- [ ] Implement secrets for DB credentials
- [ ] Test full stack via browser

### Expected Outcomes

- All tiers communicate correctly
- Data persists across pod deletions
- Secrets properly secured
- Application accessible via browser
- Database survives pod restarts

---

## Testing Scenarios (All Phases)

### 1. Self-Healing Test
```bash
# Delete a pod
kubectl delete pod <pod-name>

# Watch it recreate automatically
kubectl get pods -w
```

**Expected:** New pod created within seconds, application continues running.

### 2. Scaling Test
```bash
# Scale up
kubectl scale deployment <name> --replicas=5

# Scale down
kubectl scale deployment <name> --replicas=2
```

**Expected:** Pods created/terminated smoothly, service remains available.

### 3. Rolling Update Test
```bash
# Update image
kubectl set image deployment/<name> <container>=<new-image>

# Watch rollout
kubectl rollout status deployment/<name>
```

**Expected:** Zero downtime, gradual pod replacement.

### 4. Rollback Test
```bash
# Rollback to previous version
kubectl rollout undo deployment/<name>

# Check rollout history
kubectl rollout history deployment/<name>
```

**Expected:** Quick rollback, application returns to previous state.

### 5. Node Failure Simulation
```bash
# Drain a node (simulate failure)
kubectl drain <node-name> --ignore-daemonsets

# Watch pods reschedule
kubectl get pods -o wide -w
```

**Expected:** Pods move to healthy nodes automatically.

---

## Infrastructure Rebuild Test

**Purpose:** Verify your infrastructure is fully reproducible.

### Steps

1. **Document Current State**
   ```bash
   kubectl get all -A > before-destroy.txt
   ```

2. **Destroy Infrastructure**
   ```bash
   cd d:/k8s-devops-lab/proxmox/terraform
   terraform destroy
   ```

3. **Rebuild Infrastructure**
   ```bash
   terraform apply
   cd ../ansible
   ansible-playbook -i inventory/proxmox_inventory.proxmox.yml playbooks/01-prepare.yml
   ansible-playbook -i inventory/proxmox_inventory.proxmox.yml playbooks/02-k3s-master.yml
   ansible-playbook -i inventory/proxmox_inventory.proxmox.yml playbooks/03-k3s-worker.yml
   ansible-playbook -i inventory/proxmox_inventory.proxmox.yml playbooks/04-jenkins-nexus.yml
   ```

4. **Redeploy Application**
   - Run Jenkins pipeline
   - Verify application works identically

5. **Compare State**
   ```bash
   kubectl get all -A > after-rebuild.txt
   diff before-destroy.txt after-rebuild.txt
   ```

**Expected:** Infrastructure rebuilds identically, applications deploy successfully.

---

## Success Criteria

### Phase 1 Complete When:
- ✅ Static site accessible via browser
- ✅ Jenkins builds and pushes to Nexus
- ✅ Self-healing and scaling work
- ✅ Rolling updates successful

### Phase 2 Complete When:
- ✅ API responds to HTTP requests
- ✅ Auto-scaling triggers under load
- ✅ Health checks working
- ✅ Load balancing verified

### Phase 3 Complete When:
- ✅ Full stack accessible
- ✅ Data persists across restarts
- ✅ All tiers communicate
- ✅ Secrets properly managed

### Lab Complete When:
- ✅ All phases completed
- ✅ Infrastructure rebuild successful
- ✅ Documentation complete
- ✅ Ready for real projects

---

## Next Steps After Completion

1. **Add Monitoring:** Deploy Prometheus/Grafana (playbook 05)
2. **Implement Ingress:** Set up Nginx Ingress Controller
3. **Add CI/CD Features:** Automated testing, security scanning
4. **Explore Advanced Topics:** Service mesh, GitOps, Helm charts
5. **Deploy Real Projects:** Use this lab for actual development work
