Perfect 👍
Below is a **single, clean, copy-paste–ready review document** you can hand to another agent to **fix everything in one pass**.

This covers **01 → 05 playbooks**, grouped into **Critical Issues, Package/Config Mismatches, Design Problems, and Final Recommendations**.

---

# 📋 ANSIBLE K8S DEVOPS LAB – CONSOLIDATED REVIEW & FIX LIST

**Scope:** `01-prepare.yml` → `05-monitoring.yml`
**Inventory:** Proxmox dynamic inventory (`community.general.proxmox`)

---

## 🚨 CRITICAL ISSUES (MUST FIX – WILL BREAK OR MISCONFIGURE)

---

### 1. ❌ SSH connectivity assumptions (01-prepare.yml)

* Initial failures occurred because:

  * Hostnames were not resolvable
  * `ansible_host` was not set
* **Fix already applied correctly** via:

  ```yaml
  compose:
    ansible_host: proxmox_net0.ip | regex_replace('/.*$', '')
    ansible_user: root
  ```
* ✅ No further action required

---

### 2. ❌ UFW firewall used on all nodes (01–05)

**Affected playbooks:**

* 02-k3s-master.yml
* 03-k3s-worker.yml
* 04-jenkins-nexus.yml
* 05-monitoring.yml

**Why this is critical**

* Kubernetes, Docker, Flannel, and VXLAN manage iptables themselves
* UFW breaks:

  * Pod networking
  * NodePort services
  * Docker registry access
  * Metrics scraping

**Required Fix**

* ❌ REMOVE **all** `ufw:` tasks from every playbook
* Firewalling should be done at:

  * Proxmox
  * Router
  * External firewall

---

### 3. ❌ Docker not installed but heavily used (04-jenkins-nexus.yml)

**Used modules:**

* `docker_container`
* `docker_image`
* `docker_network`

**Docker is never installed → hard failure**

**Required Fix**
Add **before Nexus tasks**:

```yaml
- name: Install Docker
  apt:
    name:
      - docker.io
      - docker-compose-plugin
    state: present
    update_cache: yes

- name: Enable Docker
  systemd:
    name: docker
    state: started
    enabled: yes
```

---

### 4. ❌ Jenkins plugin installation via raw curl (04)

```bash
curl -X POST ... /pluginManager/installNecessaryPlugins
```

**Problems**

* No authentication
* No CSRF crumb
* Non-idempotent
* Breaks on restart
* Unreliable

**Required Fix**
Replace with:

```yaml
community.general.jenkins_plugin
```

---

### 5. ❌ Hardcoded IP addresses in monitoring (05-monitoring.yml)

Examples:

```yaml
10.0.1.10
10.0.1.20
```

**Why this is critical**

* Dynamic inventory already exists
* Nodes will change
* New nodes won’t be monitored

**Required Fix**

* Generate targets dynamically from:

  * `groups['kubernetes_master']`
  * `groups['kubernetes_workers']`
  * `groups['jenkins_servers']`
* Or use Prometheus `file_sd_configs`

---

### 6. ❌ Node Exporter installed only on monitoring host (05)

**Wrong architecture**

**Required Fix**

* Node exporter must run on:

  * Kubernetes master
  * Kubernetes workers
  * Jenkins/Nexus
  * Monitoring
* Either:

  * Run node-exporter play on `hosts: all`
  * Or move monitoring into Kubernetes (recommended)

---

## ⚠ PACKAGE / CONFIG MISMATCHES

---

### 7. ⚠ Java version mismatch for Jenkins (04)

* Installed: `openjdk-11`
* Jenkins LTS now prefers **Java 17**

**Recommended Fix**

```yaml
openjdk-17-jdk
```

---

### 8. ⚠ Jenkins reload handler is invalid (04)

```yaml
curl ... --user admin:admin
```

**Problem**

* Default Jenkins password ≠ `admin`
* Handler always fails

**Fix**

* Remove this handler
* Rely on systemd restart only

---

### 9. ⚠ Manual Flannel install conflicts with K3s (02)

```yaml
kubectl apply -f kube-flannel.yml
```

**Problem**

* K3s already manages Flannel
* Can cause CNI conflicts

**Fix**

* ❌ Remove manual Flannel installation task
* Keep only `--flannel-backend=host-gw`

---

### 10. ⚠ Kubelet scraping via port 10250 (05)

* Modern Kubernetes blocks this with TLS
* Will silently fail

**Fix**

* Use:

  * kube-state-metrics
  * metrics-server
  * ServiceMonitor (preferred)

---

## 🧱 DESIGN & STRUCTURAL ISSUES (NOT BROKEN, BUT RISKY)

---

### 11. ⚠ Secrets stored in `/tmp`

Examples:

* Jenkins admin password
* Nexus admin password
* K3s token

**Risks**

* Ephemeral
* Potential exposure

**Recommended Fix**

* Store under:

  ```text
  /root/.secrets/
  ```
* Or use Ansible Vault

---

### 12. ⚠ Overuse of `shell` where modules exist

Examples:

* kubectl calls
* Jenkins plugin install
* Labeling nodes

**Recommendation**

* Prefer Ansible modules where available
* Keeps idempotency and readability

---

### 13. ⚠ Playbooks should be roles

Current:

```text
01-prepare.yml
02-k3s-master.yml
03-k3s-worker.yml
```

**Recommended**
Convert to roles:

* `common`
* `k3s_master`
* `k3s_worker`
* `jenkins`
* `monitoring`

---

## 🧠 STRATEGIC RECOMMENDATIONS (BEST PRACTICE)

---

### ✅ Inventory & Targeting (GOOD – KEEP THIS)

* Dynamic Proxmox inventory is correct
* Group-based targeting prevents host contamination
* `ansible_host` via IP is the right solution

---

### 🚀 Strong Recommendation: Move Monitoring into Kubernetes

Instead of bare-metal Prometheus/Grafana:

* Deploy `kube-prometheus-stack` via Helm
* Use:

  * ServiceMonitor
  * DaemonSet node-exporter
  * Native Kubernetes discovery

---

### 🔐 Security Improvements

* Use Ansible Vault
* Disable password SSH
* Use non-root Ansible user later

---

## 🏁 FINAL SUMMARY

**Current State:**
✔ Architecture is solid
✔ Dynamic inventory implemented correctly
❌ Firewalls, Docker, monitoring, and Jenkins plugins need fixes

**After applying this list:**
🔥 Clean, safe, reproducible DevOps lab
🔥 Interview-ready infrastructure
🔥 Correct separation of concerns

---

If you want, next steps can be:

* Full role refactor
* Monitoring via Helm
* Jenkins → Kubernetes agents
* TLS + cert-manager
* MetalLB + Ingress

Just say the word.
