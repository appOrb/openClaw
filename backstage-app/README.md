# OpenClaw Backstage

**Developer portal for OpenClaw multi-agent platform.**

---

## 🚀 Quick Start

### **Prerequisites**

- Node.js 20 or 22
- yarn or npm
- GitHub token
- Azure credentials (optional)

### **Installation**

```bash
# Install dependencies
yarn install

# Start development server
yarn dev

# Or start components separately
yarn start-backend  # Backend (port 7007)
yarn start          # Frontend (port 3000)
```

### **Access**

- Frontend: http://localhost:3000
- Backend API: http://localhost:7007/api
- Health: http://localhost:7007/healthcheck

---

## 🔧 Configuration

### **Environment Variables**

Create `.env` file:

```bash
# GitHub Integration
GITHUB_TOKEN=your_github_pat

# Azure Integration (optional)
AZURE_CLIENT_ID=f2410d10-07d1-49e2-af61-dba86cc9b441
AZURE_CLIENT_SECRET=your_secret
AZURE_TENANT_ID=1b9184b9-e785-4727-a33d-f9526fe07006

# Auth (GitHub OAuth)
AUTH_GITHUB_CLIENT_ID=your_oauth_client_id
AUTH_GITHUB_CLIENT_SECRET=your_oauth_client_secret

# Kubernetes (optional)
K8S_CLUSTER_URL=https://your-aks-cluster
K8S_SA_TOKEN=your_service_account_token

# ArgoCD (optional)
ARGOCD_URL=https://argocd.openclaw.ai
ARGOCD_USERNAME=admin
ARGOCD_PASSWORD=your_password

# OpenClaw URLs
OPENCLAW_DEV_URL=http://openclaw-dev.eastus.azurecontainer.io
OPENCLAW_STAGING_URL=http://openclaw-staging.eastus.azurecontainer.io
OPENCLAW_PROD_URL=http://openclaw-production.eastus.cloudapp.azure.com
```

---

## 📦 Features

### **Software Catalog**

- View all OpenClaw components
- Track deployments across environments
- API documentation
- Dependency tracking

### **Templates**

- Deploy new OpenClaw instances
- Choose platform (VM/ACI/AKS)
- Automated Terraform deployment
- Auto-catalog registration

### **TechDocs**

- Component documentation
- Architecture diagrams
- Deployment guides
- API references

### **Kubernetes**

- View AKS cluster status
- Pod logs and metrics
- Resource utilization
- Deployment history

### **ArgoCD**

- Sync status
- Deployment timeline
- Application health
- GitOps workflows

### **Cost Insights**

- Infrastructure costs
- Per-environment breakdown
- Trend analysis
- Budget alerts

---

## 🎨 Customization

### **Add a Component**

Create `catalog-info.yaml` in your repo:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-component
  description: My component description
  tags:
    - openclaw
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: openclaw
```

Register in Backstage catalog.

### **Add a Template**

Create template in `backstage/templates/`:

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: my-template
  title: My Template
spec:
  parameters:
    # Your parameters
  steps:
    # Your steps
```

---

## 🔌 Plugins

### **Installed Plugins**

- @backstage/plugin-catalog
- @backstage/plugin-scaffolder
- @backstage/plugin-techdocs
- @backstage/plugin-kubernetes
- @backstage/plugin-github-actions
- @backstage/plugin-azure-devops
- @backstage/plugin-cost-insights

### **Add Custom Plugin**

```bash
yarn backstage-cli create-plugin
```

---

## 🚢 Deployment

### **Docker**

```bash
# Build image
yarn build-image

# Run
docker run -p 7007:7007 openclaw/backstage
```

### **Kubernetes**

```bash
kubectl apply -f k8s/backstage/
```

---

## 📊 Monitoring

### **Health Check**

```bash
curl http://localhost:7007/healthcheck
```

### **Metrics**

Prometheus metrics available at:
```
http://localhost:7007/metrics
```

---

## 🆘 Troubleshooting

### **Port already in use**

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
PORT=3001 yarn start
```

### **Database errors**

```bash
# Reset database
rm -rf .backstage
yarn dev
```

### **Plugin errors**

```bash
# Clear cache
yarn clean
yarn install
yarn dev
```

---

## 📚 Documentation

- [Backstage Docs](https://backstage.io/docs)
- [OpenClaw Docs](https://docs.openclaw.ai)
- [Architecture](../DEPLOYMENT_README.md)

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

---

**Status:** 🟡 In Development  
**Version:** 1.0.0  
**License:** MIT
