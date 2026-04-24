# OpenClaw Backstage Platform

**Production-grade developer platform for OpenClaw deployment and management.**

---

## 🎯 Overview

Backstage provides:
- **Software Catalog** - All OpenClaw components and resources
- **Deployment Templates** - One-click OpenClaw deployments
- **TechDocs** - Comprehensive documentation
- **Cost Insights** - Infrastructure cost tracking
- **Kubernetes Integration** - AKS cluster management
- **Azure Integration** - Azure resource discovery

---

## 🚀 Quick Start

### **Installation**

```bash
# Install Backstage CLI
npm install -g @backstage/cli

# Create Backstage app
npx @backstage/create-app

# Or use this pre-configured setup
cd backstage
npm install
```

### **Configuration**

```bash
# Copy environment template
cp app-config/app-config.yaml app-config.local.yaml

# Set environment variables
export GITHUB_TOKEN="your-github-token"
export AZURE_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
export AZURE_CLIENT_SECRET="your-secret"
export AZURE_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
export AZURE_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
```

### **Run Locally**

```bash
# Start backend
yarn start-backend

# Start frontend (in another terminal)
yarn start

# Access at http://localhost:3000
```

---

## 📁 Directory Structure

```
backstage/
├── app-config/
│   ├── app-config.yaml         # Main configuration
│   └── app-config.production.yaml
├── catalog/
│   └── components/
│       ├── openclaw-platform.yaml  # OpenClaw components
│       └── agents.yaml
├── templates/
│   └── openclaw-deployment/
│       ├── template.yaml       # Deployment template
│       └── skeleton/           # Template files
├── plugins/
│   ├── openclaw-backend/       # Custom backend plugin
│   └── openclaw-frontend/      # Custom frontend plugin
└── docs/
    ├── getting-started.md
    └── deployment-guide.md
```

---

## 🔧 Configuration

### **GitHub Integration**

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

### **Azure Integration**

```yaml
integrations:
  azure:
    - host: portal.azure.com
      credentials:
        - clientId: ${AZURE_CLIENT_ID}
          clientSecret: ${AZURE_CLIENT_SECRET}
          tenantId: ${AZURE_TENANT_ID}
```

### **Kubernetes Integration**

```yaml
kubernetes:
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - url: ${K8S_CLUSTER_URL}
          name: openclaw-aks
          authProvider: 'serviceAccount'
```

---

## 📦 Software Catalog

### **Components Registered:**

1. **openclaw-vm** - VM deployment module
2. **openclaw-aci** - Container Instances module
3. **openclaw-aks** - Kubernetes module
4. **openclaw-backup** - Backup & recovery
5. **openclaw-monitoring** - Observability

### **Discover More:**

```bash
# Discover GitHub repos
backstage-cli catalog:discover

# Discover Azure resources
backstage-cli catalog:discover --provider azure
```

---

## 🎨 Templates

### **OpenClaw Deployment Template**

Deploy new OpenClaw instances through the UI:

1. Navigate to **Create** → **OpenClaw Deployment**
2. Fill in configuration:
   - Instance name
   - Environment (dev/staging/production)
   - Platform (VM/ACI/AKS)
   - Region
   - Agent count
3. Click **Create**
4. Backstage will:
   - Create GitHub PR
   - Run Terraform plan
   - Register in catalog
   - Enable monitoring

**Parameters:**
- `name` - Instance name
- `environment` - dev, staging, production
- `platform` - vm, aci, aks
- `region` - Azure region
- `agentsCount` - Number of agents (1-20)
- `vmSize` - VM SKU (if platform=vm)
- `enableBackup` - Enable backups
- `enableMonitoring` - Enable monitoring

---

## 🔌 Plugins

### **Custom OpenClaw Plugins**

#### **openclaw-backend**
- Azure resource discovery
- Deployment automation
- Cost tracking
- Health monitoring

#### **openclaw-frontend**
- Deployment dashboard
- Agent status view
- Cost insights
- Deployment history

### **Third-Party Plugins**

- **@backstage/plugin-kubernetes** - AKS integration
- **@backstage/plugin-azure-devops** - Azure DevOps
- **@backstage/plugin-cost-insights** - Cost tracking
- **@backstage/plugin-techdocs** - Documentation
- **@backstage/plugin-github-actions** - CI/CD status

---

## 📊 Cost Insights

Track OpenClaw infrastructure costs:

```yaml
costInsights:
  engineerCost: 200000
  products:
    computeEngine:
      name: Compute Engine
      icon: compute
```

**Features:**
- Real-time cost tracking
- Per-environment breakdown
- Cost trends & forecasts
- Budget alerts

---

## 🔐 Authentication

### **GitHub OAuth**

```yaml
auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
```

### **Azure AD**

```yaml
auth:
  providers:
    microsoft:
      development:
        clientId: ${AZURE_CLIENT_ID}
        clientSecret: ${AZURE_CLIENT_SECRET}
        tenantId: ${AZURE_TENANT_ID}
```

---

## 🚀 Deployment

### **Production Deployment**

```bash
# Build for production
yarn build

# Run backend
yarn start-backend

# Serve frontend (Nginx)
nginx -c nginx.conf
```

### **Docker Deployment**

```bash
# Build images
docker build -t openclaw/backstage-backend -f Dockerfile.backend .
docker build -t openclaw/backstage-frontend -f Dockerfile.frontend .

# Run
docker-compose up -d
```

### **Kubernetes Deployment**

```bash
# Apply manifests
kubectl apply -f k8s/backstage/

# Access via ingress
https://backstage.openclaw.ai
```

---

## 📚 Documentation

### **TechDocs**

Enable TechDocs for component documentation:

```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'
  publisher:
    type: 'local'
```

### **Write Docs**

Create `docs/` in component repo:
```
component-repo/
├── catalog-info.yaml
├── docs/
│   ├── index.md
│   ├── architecture.md
│   └── deployment.md
└── mkdocs.yml
```

---

## 🔍 Discovery

### **GitHub Discovery**

```yaml
catalog:
  locations:
    - type: github-discovery
      target: https://github.com/appOrb
```

### **Azure Discovery**

```yaml
catalog:
  locations:
    - type: azure-discovery
      target: subscriptions/${AZURE_SUBSCRIPTION_ID}
```

---

## 🧪 Testing

```bash
# Run tests
yarn test

# Lint
yarn lint

# Type check
yarn tsc
```

---

## 📊 Monitoring

### **Backstage Metrics**

- **Catalog health** - Component freshness
- **Template usage** - Deployment frequency
- **API latency** - Backend performance
- **Auth success rate** - Login metrics

### **Integration**

```yaml
backend:
  metrics:
    enabled: true
    port: 9090
```

---

## 🆘 Troubleshooting

### **Common Issues**

**Issue: GitHub integration not working**
```bash
# Verify token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

**Issue: Azure discovery failing**
```bash
# Check Azure credentials
az login --service-principal \
  -u $AZURE_CLIENT_ID \
  -p $AZURE_CLIENT_SECRET \
  --tenant $AZURE_TENANT_ID
```

**Issue: Catalog not updating**
```bash
# Force refresh
backstage-cli catalog:refresh
```

---

## 🔗 Resources

- **Backstage Docs:** https://backstage.io/docs
- **OpenClaw Docs:** https://openclaw.ai/docs
- **GitHub:** https://github.com/appOrb/openClaw
- **Azure Portal:** https://portal.azure.com

---

## 👥 Contributors

- **OpenClaw Team** - Platform Development
- **reevelobo** - Project Owner

---

**Status:** 🟡 In Development (Configuration complete, plugins pending)

**Repository:** https://github.com/appOrb/openClaw/tree/feature/production-infrastructure/backstage
