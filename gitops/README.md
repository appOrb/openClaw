# OpenClaw GitOps with ArgoCD

**Production-grade GitOps deployment using ArgoCD for continuous delivery.**

---

## 🎯 Overview

GitOps workflow:
1. Code changes pushed to GitHub
2. ArgoCD detects changes
3. Syncs to Kubernetes automatically
4. Backstage shows deployment status
5. Discord notifications on events

---

## 🚀 Quick Start

### **Install ArgoCD**

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f gitops/argocd/argocd-install.yaml

# Install ArgoCD CLI
brew install argocd  # macOS
# or
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

### **Access ArgoCD UI**

```bash
# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Login
argocd login localhost:8080
```

### **Deploy OpenClaw Project**

```bash
# Create OpenClaw project
kubectl apply -f gitops/configs/project.yaml

# Deploy applications
kubectl apply -f gitops/apps/openclaw.yaml
```

---

## 📁 Directory Structure

```
gitops/
├── argocd/
│   ├── argocd-install.yaml     # ArgoCD installation
│   ├── argocd-cm.yaml          # ConfigMap
│   └── argocd-rbac-cm.yaml     # RBAC policies
├── apps/
│   ├── openclaw.yaml           # OpenClaw applications
│   ├── monitoring.yaml         # Monitoring stack
│   └── backstage.yaml          # Backstage deployment
├── configs/
│   ├── project.yaml            # ArgoCD project
│   ├── repositories.yaml       # Git repositories
│   └── notifications.yaml      # Notification config
└── k8s/
    ├── base/                   # Base manifests
    └── overlays/               # Environment overlays
        ├── dev/
        ├── staging/
        └── production/
```

---

## 🔧 Configuration

### **ArgoCD Project**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: openclaw
  namespace: argocd
spec:
  description: OpenClaw AI Developer Platform
  sourceRepos:
    - 'https://github.com/appOrb/openClaw.git'
  destinations:
    - namespace: 'openclaw-*'
      server: https://kubernetes.default.svc
```

### **Application (Dev)**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: openclaw-dev
spec:
  source:
    repoURL: https://github.com/appOrb/openClaw.git
    targetRevision: HEAD
    path: k8s/overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: openclaw-dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 🔄 Sync Policies

### **Development (Auto-sync)**

```yaml
syncPolicy:
  automated:
    prune: true        # Delete removed resources
    selfHeal: true     # Auto-revert manual changes
    allowEmpty: false
  syncOptions:
    - CreateNamespace=true
  retry:
    limit: 5
    backoff:
      duration: 5s
      factor: 2
      maxDuration: 3m
```

### **Production (Manual)**

```yaml
syncPolicy:
  automated: null      # Requires manual approval
  syncOptions:
    - CreateNamespace=true
  retry:
    limit: 3
```

---

## 🔐 RBAC

### **Roles**

**Admin:**
```yaml
roles:
  - name: admin
    policies:
      - p, proj:openclaw:admin, applications, *, openclaw/*, allow
    groups:
      - appOrb:admins
```

**Developer:**
```yaml
roles:
  - name: developer
    policies:
      - p, proj:openclaw:developer, applications, get, openclaw/*, allow
      - p, proj:openclaw:developer, applications, sync, openclaw/*, allow
    groups:
      - appOrb:developers
```

**Backstage (Automation):**
```yaml
roles:
  - name: backstage
    policies:
      - p, proj:openclaw:backstage, applications, *, openclaw/*, allow
```

---

## 🔔 Notifications

### **Discord Webhook**

```yaml
notifications:
  service.webhook.discord:
    url: $DISCORD_WEBHOOK_URL
  
  subscriptions:
    - recipients:
      - discord
      triggers:
      - on-deployed
      - on-health-degraded
      - on-sync-failed
```

### **Events**

- ✅ **on-deployed** - Successful deployment
- ⚠️ **on-health-degraded** - Pod failures
- ❌ **on-sync-failed** - Sync errors
- 📊 **on-sync-running** - Sync started
- 🔄 **on-sync-status-unknown** - Sync status unclear

---

## 🔗 Backstage Integration

### **ArgoCD Plugin**

```yaml
# backstage/app-config.yaml
argocd:
  baseUrl: https://argocd.openclaw.ai
  username: backstage
  password: ${ARGOCD_BACKSTAGE_TOKEN}
  
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argocd
          url: https://argocd.openclaw.ai
          username: backstage
          password: ${ARGOCD_BACKSTAGE_TOKEN}
```

### **Component Annotation**

```yaml
# catalog-info.yaml
metadata:
  annotations:
    argocd/app-name: openclaw-dev
```

---

## 📊 Monitoring

### **Metrics**

ArgoCD exposes Prometheus metrics:

```yaml
- job_name: 'argocd'
  static_configs:
    - targets: ['argocd-metrics:8082']
```

### **Dashboards**

Import ArgoCD Grafana dashboards:
- Application Overview
- Sync Performance
- Resource Health
- API Performance

---

## 🚢 Deployment Workflow

### **Typical Flow**

1. **Developer commits code**
   ```bash
   git commit -m "Update OpenClaw"
   git push origin main
   ```

2. **ArgoCD detects change**
   - Polls repository every 3 minutes
   - Or webhook triggers immediately

3. **Auto-sync (dev/staging)**
   - Fetches latest manifests
   - Applies to cluster
   - Verifies health

4. **Manual sync (production)**
   - Developer reviews changes
   - Approves via UI or CLI
   ```bash
   argocd app sync openclaw-production
   ```

5. **Notifications**
   - Discord: "✅ openclaw-dev deployed v1.2.3"
   - Backstage: Status updated

---

## 🎨 Kustomize Overlays

### **Base Manifests**

```yaml
# k8s/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openclaw
spec:
  replicas: 1  # Overridden by overlays
  template:
    spec:
      containers:
        - name: openclaw
          image: openclaw:latest
```

### **Environment Overlays**

```yaml
# k8s/overlays/production/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

bases:
  - ../../base

replicas:
  - name: openclaw
    count: 5

images:
  - name: openclaw
    newTag: v1.0.0
```

---

## 🧪 Testing

### **Validate Manifests**

```bash
# Validate YAML
kubectl apply --dry-run=client -f gitops/apps/

# Validate with ArgoCD
argocd app create openclaw-test \
  --project openclaw \
  --repo https://github.com/appOrb/openClaw.git \
  --path k8s/overlays/dev \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace openclaw-test \
  --sync-policy none

# Diff
argocd app diff openclaw-test
```

### **Sync Dry-Run**

```bash
argocd app sync openclaw-dev --dry-run
```

---

## 🆘 Troubleshooting

### **Common Issues**

**Issue: Application out of sync**
```bash
argocd app get openclaw-dev
argocd app sync openclaw-dev
```

**Issue: Health check failing**
```bash
kubectl get pods -n openclaw-dev
kubectl logs -n openclaw-dev <pod-name>
```

**Issue: ArgoCD can't access repo**
```bash
# Verify SSH key
argocd repo get https://github.com/appOrb/openClaw.git

# Re-add repository
argocd repo add https://github.com/appOrb/openClaw.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```

**Issue: Sync keeps failing**
```bash
# Check events
argocd app events openclaw-dev

# Manual sync with force
argocd app sync openclaw-dev --force
```

---

## 📚 Resources

- **ArgoCD Docs:** https://argo-cd.readthedocs.io/
- **GitOps Principles:** https://opengitops.dev/
- **Kustomize Docs:** https://kustomize.io/
- **OpenClaw Repo:** https://github.com/appOrb/openClaw

---

## 🎯 Best Practices

### **1. Use Kustomize Overlays**
- Base manifests in `k8s/base/`
- Environment-specific in `k8s/overlays/`

### **2. Version Everything**
- Production uses tags (v1.0.0)
- Staging uses branches (main)
- Dev uses HEAD

### **3. Notifications**
- Discord for team alerts
- Email for critical issues
- Slack for CI/CD integration

### **4. RBAC**
- Least privilege access
- Separate roles per team
- Automation accounts (Backstage)

### **5. Sync Policies**
- Dev: Full auto-sync
- Staging: Auto-sync with safeguards
- Production: Manual approval

---

## 👥 Contributors

- **OpenClaw Team** - GitOps Implementation
- **reevelobo** - Project Owner

---

**Status:** 🟢 Production-Ready

**Repository:** https://github.com/appOrb/openClaw/tree/feature/production-infrastructure/gitops
