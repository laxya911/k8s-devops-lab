Below is a **clean, practical Markdown document** you can drop directly into a Git repo (e.g. `LOW_RESOURCE_VM_GUIDE.md`).
It’s written to be **cloud-agnostic** (Oracle / AWS / Azure / GCP free tiers) and focused on **real performance gains**, not risky hacks.

---

````md
# Optimizing Low-Resource Free Tier VMs (1 vCPU / 1 GB RAM)

This document provides a **practical, battle-tested guide** for getting the best performance and stability from **low-resource free tier virtual machines** across cloud providers such as:

- Oracle Cloud Free Tier
- AWS Free Tier (t2.micro / t3.micro)
- Azure B1s
- GCP e2-micro

The goal is **maximum usability, not minimalism at the cost of stability**.

---

## 1. Target System Profile

Typical free tier VM constraints:

| Resource | Typical Value                |
| -------- | ---------------------------- |
| CPU      | 1 vCPU                       |
| RAM      | ~1 GB                        |
| Disk     | Network-backed block storage |
| Network  | Shared / burstable           |

**Key implications:**

- RAM is the main bottleneck
- Disk is slow compared to RAM
- CPU contention hurts latency fast

---

## 2. Base OS Choice

### Recommended

- **Ubuntu Server LTS (20.04 / 22.04)**
- **Debian 11/12**

### Avoid

- Desktop variants
- Heavy distributions with aggressive background services

**Why Ubuntu/Debian?**

- Stable
- Predictable memory usage
- Best Docker support
- Large community & documentation

---

## 3. Memory Is King: Understand Linux Memory

Linux aggressively uses RAM for cache. This is **good**.

Important fields:

- `used`: memory actively used by processes
- `buff/cache`: reclaimable memory
- `available`: what actually matters

Always trust **`available`**, not `free`.

---

## 4. Swap: Mandatory on 1 GB Systems

### Why swap is required

- Prevents OOM killer
- Handles short memory spikes (Docker image pulls, TLS, Go apps)
- Improves system stability

### Recommended swap size

| RAM  | Swap                    |
| ---- | ----------------------- |
| 1 GB | **1–2 GB** (sweet spot) |

**More swap ≠ better performance**

### Swap setup (example)

```bash
fallocate -l 1G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```
````

### Tune swappiness

```bash
sysctl vm.swappiness=10
```

This ensures swap is used **only as a last resort**.

---

## 5. Remove What You Don’t Need (Safely)

### High-value removals

#### Snap (Ubuntu)

```bash
systemctl disable --now snapd snapd.socket
apt purge snapd
```

Saves ~30–50 MB RAM.

#### multipathd (cloud VMs)

```bash
systemctl disable --now multipathd
systemctl mask multipathd
```

Saves ~25–30 MB RAM.
Safe on all major cloud compute instances.

---

### Optional (if unused)

```bash
systemctl disable --now iscsid
systemctl disable --now irqbalance
```

---

### Do NOT remove

- systemd
- systemd-networkd
- systemd-resolved
- udev
- dbus
- sshd

Removing these causes instability for minimal gains.

---

## 6. Docker on Low-Memory Systems (Critical)

### Always set memory limits

Unrestricted containers can kill the host.

Example:

```bash
docker run \
  --memory=128m \
  --memory-swap=256m \
  --cpus=0.5 \
  nginx
```

### Docker daemon tuning

`/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Prevents logs from consuming disk and RAM.

---

## 7. Reverse Proxy Choice

### Nginx

- ~10–20 MB RAM
- Static config
- Extremely efficient

### Traefik

- ~60–100 MB RAM
- Dynamic routing
- Auto TLS
- Requires strict limits

**Recommendation:**

- Few services → **Nginx**
- Dynamic Docker routing → **Traefik with limits**

---

## 8. CPU Strategy (1 vCPU Reality)

- Avoid CPU-heavy workloads
- Prefer async / event-driven services
- Limit containers to fractional CPUs

Example:

```bash
--cpus=0.25
```

---

## 9. Databases on Free Tier

### Recommended

- SQLite
- Small Postgres (128–256 MB limit)
- Redis with strict maxmemory

### Avoid

- Elasticsearch
- MongoDB
- JVM databases
- Anything with background compaction

---

## 10. Monitoring (Lightweight)

Install:

```bash
apt install htop
```

Watch:

- Available memory
- Swap usage trend
- CPU wait time

**Healthy system:**

- Swap near zero most of the time
- Occasional small swap usage is fine

---

## 11. When to Scale Up (Important)

You should **upgrade the VM** when:

- Swap usage grows continuously
- CPU stays >70% under normal load
- Latency spikes despite tuning

Optimization cannot replace real resources.

---

## 12. Golden Rules Summary

- Swap is a safety net, not RAM
- Memory limits beat swap size
- Remove unused services, not core ones
- Simplicity > clever hacks
- Stability first, performance second

---

## 13. Example Safe Budget (1 GB VM)

| Component | Memory     |
| --------- | ---------- |
| Base OS   | ~190 MB    |
| Nginx     | 20 MB      |
| App 1     | 128 MB     |
| App 2     | 128 MB     |
| Small DB  | 128–192 MB |
| Buffer    | ~150 MB    |

---

## Sample Docker compose to limit resources

```
version: "3.8"

services:
  nginx:
    image: nginx:alpine
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    deploy:
      resources:
        limits:
          cpus: "0.25"
          memory: 32M
    mem_swappiness: 0

  app:
    image: ghcr.io/example/lightweight-app:latest
    container_name: app
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    deploy:
      resources:
        limits:
          cpus: "0.50"
          memory: 128M
    mem_swappiness: 0

  redis:
    image: redis:7-alpine
    container_name: redis
    restart: unless-stopped
    command: >
      redis-server
      --maxmemory 64mb
      --maxmemory-policy allkeys-lru
      --save ""
    deploy:
      resources:
        limits:
          cpus: "0.25"
          memory: 96M
    mem_swappiness: 0

networks:
  default:
    driver: bridge


```

## License

```
MIT – use freely, modify responsibly.

```
