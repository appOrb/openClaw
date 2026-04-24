# OpenClaw Deployment Standard Operating Procedures (SOPs)

**Official deployment procedures for OpenClaw infrastructure and platform.**

Version: 1.0  
Last Updated: 2026-04-24  
Classification: Internal Use Only

---

## Table of Contents

1. [SOP-001: Development VM Deployment](#sop-001-development-vm-deployment)
2. [SOP-002: Staging ACI Deployment](#sop-002-staging-aci-deployment)
3. [SOP-003: Production AKS Deployment](#sop-003-production-aks-deployment)
4. [SOP-004: Multi-VM Army Deployment](#sop-004-multi-vm-army-deployment)
5. [SOP-005: Backstage IDP Setup](#sop-005-backstage-idp-setup)
6. [SOP-006: Emergency Rollback](#sop-006-emergency-rollback)
7. [SOP-007: Scaling Operations](#sop-007-scaling-operations)
8. [SOP-008: Backup Procedures](#sop-008-backup-procedures)
9. [SOP-009: Monitoring Setup](#sop-009-monitoring-setup)
10. [SOP-010: Decommissioning](#sop-010-decommissioning)

---

## SOP-001: Development VM Deployment

### Purpose
Deploy OpenClaw to a single Azure VM for development and testing.

### Scope
Development environment only. Not for production use.

### Responsible Party
- **Primary:** DevOps Engineer
- **Backup:** Platform Engineer
- **Approval:** Technical Lead

### Prerequisites
- [ ] Azure subscription access
- [ ] Service Principal credentials
- [ ] SSH key pair
- [ ] GitHub repository access
- [ ] Terraform v1.14.9+

### Cost Impact
- **Daily:** $0.44
- **Monthly:** $13.50

### Estimated Duration
15-20 minutes

---

### Procedure

#### Phase 1: Pre-Deployment (5 minutes)

1. **Verify Prerequisites**
   ```bash
   # Check Terraform
   ~/bin/terraform version
   # Expected: v1.14.9 or higher
   
   # Check Azure CLI
   az account show
   # Expected: Correct subscription displayed
   
   # Verify SSH key
   cat ~/.ssh/id_rsa.pub
   # Expected: Valid public key
   ```

2. **Set Environment Variables**
   ```bash
   export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
   export ARM_CLIENT_SECRET="<from-key-vault>"
   export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
   export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
   ```

3. **Navigate to Repository**
   ```bash
   cd /path/to/openClaw
   git status  # Ensure clean working directory
   git pull origin feature/production-infrastructure
   ```

4. **Run Validation**
   ```bash
   ./validate.sh
   ```
   
   **Checkpoint:** All tests must pass before proceeding.

#### Phase 2: Planning (2 minutes)

5. **Generate Terraform Plan**
   ```bash
   ./deploy.sh dev vm plan
   ```
   
   **Review Output:**
   - [ ] Resources to add: ~8-10
   - [ ] No unexpected changes
   - [ ] Cost estimate: ~$0.44/day
   
   **Decision Point:** Proceed? YES / NO

#### Phase 3: Deployment (5 minutes)

6. **Execute Deployment**
   ```bash
   ./deploy.sh dev vm apply
   ```
   
   When prompted:
   ```
   Continue? (yes/no): yes
   ```

7. **Monitor Progress**
   - Watch for resource creation messages
   - Note any warnings or errors
   - Wait for completion (typically 5-8 minutes)

8. **Capture Outputs**
   ```bash
   cd terraform/environments/dev
   ~/bin/terraform output > ~/deployment-outputs.txt
   ```
   
   **Save the following:**
   - Public IP address
   - VM ID
   - SSH connection string

#### Phase 4: Verification (5 minutes)

9. **Verify Azure Resources**
   ```bash
   az vm show \
     --resource-group openclaw-dev-rg \
     --name openclaw-dev-vm \
     --query "provisioningState" \
     --output tsv
   ```
   
   **Expected:** `Succeeded`

10. **Test SSH Access**
    ```bash
    VM_IP=$(~/bin/terraform output -raw public_ip_address)
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
      azureuser@$VM_IP "echo 'SSH OK'"
    ```
    
    **Expected:** `SSH OK` output

11. **Wait for Bootstrap** (5 minutes)
    ```bash
    echo "Waiting for OpenClaw installation..."
    sleep 300
    ```

12. **Verify OpenClaw Installation**
    ```bash
    ssh azureuser@$VM_IP "which openclaw && openclaw --version"
    ```
    
    **Expected:** OpenClaw version displayed

13. **Check Service Status**
    ```bash
    ssh azureuser@$VM_IP "systemctl is-active openclaw"
    ```
    
    **Expected:** `active` or `activating`

14. **Test Health Endpoint**
    ```bash
    curl -f http://$VM_IP:3000/health
    ```
    
    **Expected:** HTTP 200, JSON response

#### Phase 5: Documentation (3 minutes)

15. **Record Deployment**
    
    Create entry in deployment log:
    ```
    Date: YYYY-MM-DD HH:MM UTC
    Environment: dev
    Platform: VM
    VM IP: <IP_ADDRESS>
    Deployed By: <YOUR_NAME>
    Terraform Version: v1.14.9
    Status: SUCCESS
    Notes: <any-notes>
    ```

16. **Update Backstage Catalog** (if applicable)
    - Navigate to Backstage
    - Update openclaw-vm component
    - Add deployment annotation

17. **Notify Team**
    
    Post in Discord #general:
    ```
    ✅ Dev VM Deployed
    IP: <VM_IP>
    Access: ssh azureuser@<VM_IP>
    Health: http://<VM_IP>:3000/health
    ```

### Rollback Procedure

If deployment fails or issues found:

```bash
./deploy.sh dev vm destroy
# Type: DELETE
```

Investigate logs:
```bash
cd terraform/environments/dev
~/bin/terraform show
```

### Success Criteria
- [ ] All resources created successfully
- [ ] VM is running and accessible via SSH
- [ ] OpenClaw service is active
- [ ] Health endpoint responds
- [ ] Team notified

### Failure Handling
1. Capture error logs
2. Run rollback procedure
3. Document issue in GitHub Issues
4. Notify Technical Lead
5. Schedule retry after resolution

---

## SOP-002: Staging ACI Deployment

### Purpose
Deploy OpenClaw to Azure Container Instances for staging environment.

### Scope
Staging environment for UAT and pre-production testing.

### Responsible Party
- **Primary:** Platform Engineer
- **Backup:** DevOps Engineer
- **Approval:** Engineering Manager

### Prerequisites
- [ ] Docker image built and pushed to ACR
- [ ] Azure credentials
- [ ] Keycloak configured
- [ ] Database connection string

### Cost Impact
- **Daily:** $0.40
- **Monthly:** $12.00

### Estimated Duration
10-15 minutes

---

### Procedure

#### Phase 1: Pre-Deployment

1. **Verify Image**
   ```bash
   az acr repository show-tags \
     --name openclawacr \
     --repository openclaw \
     --output table
   ```
   
   **Checkpoint:** Latest tag available

2. **Set Variables**
   ```bash
   export ARM_CLIENT_ID="..."
   export ARM_CLIENT_SECRET="..."
   export ARM_TENANT_ID="..."
   export ARM_SUBSCRIPTION_ID="..."
   ```

3. **Navigate to Repository**
   ```bash
   cd /path/to/openClaw
   git checkout feature/production-infrastructure
   ```

#### Phase 2: Deployment

4. **Generate Plan**
   ```bash
   ./deploy.sh staging aci plan
   ```
   
   **Review:** Resource changes, cost estimate

5. **Deploy**
   ```bash
   ./deploy.sh staging aci apply
   ```
   
   **Confirmation:** Type `yes` when prompted

6. **Monitor**
   ```bash
   az container show \
     --resource-group openclaw-staging-rg \
     --name openclaw-staging-aci \
     --query "provisioningState"
   ```
   
   **Wait for:** `Succeeded`

#### Phase 3: Verification

7. **Get FQDN**
   ```bash
   FQDN=$(cd terraform/environments/staging && \
     ~/bin/terraform output -raw fqdn)
   echo "FQDN: $FQDN"
   ```

8. **Test Health**
   ```bash
   curl -f http://$FQDN/health
   ```
   
   **Expected:** HTTP 200

9. **Check Logs**
   ```bash
   az container logs \
     --resource-group openclaw-staging-rg \
     --name openclaw-staging-aci \
     --tail 50
   ```
   
   **Check for:** No errors

#### Phase 4: UAT Handoff

10. **Notify QA Team**
    ```
    Subject: Staging Environment Ready for UAT
    
    Staging URL: http://<FQDN>
    Health: http://<FQDN>/health
    
    Ready for testing.
    ```

11. **Schedule UAT**
    - Create JIRA ticket
    - Assign to QA lead
    - Set deadline

### Rollback
```bash
./deploy.sh staging aci destroy
# Deploy previous version
```

---

## SOP-003: Production AKS Deployment

### Purpose
Deploy OpenClaw to Azure Kubernetes Service for production workloads.

### Scope
Production environment serving live traffic.

### Responsible Party
- **Primary:** Platform Lead
- **Backup:** Senior DevOps Engineer
- **Approval:** CTO + Engineering Manager

### Prerequisites
- [ ] UAT completed and signed off
- [ ] Production approval received
- [ ] Change request approved
- [ ] Maintenance window scheduled
- [ ] Backup completed
- [ ] Rollback plan documented

### Cost Impact
- **Daily:** $4.31
- **Monthly:** $132.00

### Estimated Duration
30-45 minutes

---

### Procedure

#### Phase 1: Change Management (Day -1)

1. **Create Change Request**
   - Platform: ServiceNow / JIRA
   - Type: Standard Change
   - Risk: Medium
   - Include: Rollback plan

2. **Obtain Approvals**
   - [ ] CTO approval
   - [ ] Engineering Manager approval
   - [ ] Change Advisory Board (if required)

3. **Schedule Maintenance Window**
   - Preferred: Saturday 02:00-04:00 UTC
   - Notify users: 48 hours advance

4. **Backup Current State**
   ```bash
   # See SOP-008
   ```

#### Phase 2: Pre-Deployment (Day 0, H-30min)

5. **Team Assembly**
   - [ ] Platform Lead (primary)
   - [ ] DevOps Engineer (backup)
   - [ ] On-call engineer (standby)

6. **Communication**
   
   Post in #incidents:
   ```
   🚀 Production Deployment Starting
   Window: 02:00-04:00 UTC
   Platform: AKS
   Expected Impact: None (blue-green)
   Status: https://status.openclaw.ai
   ```

7. **Pre-Deployment Checklist**
   - [ ] All tests passed in staging
   - [ ] No P1/P2 incidents open
   - [ ] Team ready
   - [ ] Rollback tested

#### Phase 3: Deployment (H+0)

8. **Deploy AKS Infrastructure**
   ```bash
   ./deploy.sh production aks plan
   # Review carefully
   
   ./deploy.sh production aks apply
   # Type: DEPLOY (production requires this)
   ```

9. **Monitor Progress**
   ```bash
   watch -n 5 'kubectl get pods -n openclaw-production'
   ```

10. **Verify Nodes**
    ```bash
    kubectl get nodes
    # Expected: 3 nodes Ready
    ```

11. **Deploy ArgoCD**
    ```bash
    kubectl apply -f gitops/argocd/argocd-install.yaml
    kubectl get pods -n argocd
    ```

12. **Deploy Applications**
    ```bash
    kubectl apply -f gitops/apps/openclaw.yaml
    ```

13. **Wait for Sync**
    ```bash
    argocd app get openclaw-production
    # Wait for: Healthy, Synced
    ```

#### Phase 4: Verification (H+15min)

14. **Test Application**
    ```bash
    kubectl get svc -n openclaw-production
    # Get LoadBalancer IP
    
    PROD_IP=$(kubectl get svc openclaw -n openclaw-production \
      -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    
    curl -f http://$PROD_IP/health
    ```

15. **Run Smoke Tests**
    ```bash
    # Execute smoke test suite
    npm run test:smoke -- --url http://$PROD_IP
    ```

16. **Check Metrics**
    - Navigate to Grafana
    - Verify: CPU, Memory, Request Rate
    - Check: No error spikes

17. **Check Logs**
    ```bash
    kubectl logs -n openclaw-production \
      -l app=openclaw \
      --tail=100
    ```

#### Phase 5: Post-Deployment (H+30min)

18. **Enable Production Traffic**
    ```bash
    # Update DNS to point to new IP
    az network dns record-set a update \
      --resource-group openclaw-dns-rg \
      --zone-name openclaw.ai \
      --name @ \
      --set aRecords[0].ipv4Address=$PROD_IP
    ```

19. **Monitor for 30 Minutes**
    - Watch error rates
    - Check response times
    - Verify user sessions

20. **Declare Success**
    
    Post in #incidents:
    ```
    ✅ Production Deployment Complete
    Status: Success
    Downtime: 0 minutes
    Issues: None
    Production URL: https://openclaw.ai
    ```

21. **Close Change Request**
    - Update ServiceNow
    - Mark as: Successful
    - Add notes

#### Phase 6: Post-Deployment Tasks

22. **Update Documentation**
    - Production IP
    - Cluster details
    - RunBook updates

23. **Team Debrief**
    - Schedule: Within 24 hours
    - Discuss: What went well, improvements

### Rollback Procedure

**If issues detected within 30 minutes:**

1. **Stop Traffic**
   ```bash
   # Revert DNS
   az network dns record-set a update \
     --resource-group openclaw-dns-rg \
     --zone-name openclaw.ai \
     --name @ \
     --set aRecords[0].ipv4Address=<OLD_IP>
   ```

2. **Rollback ArgoCD**
   ```bash
   argocd app rollback openclaw-production
   ```

3. **Verify Rollback**
   ```bash
   argocd app get openclaw-production
   # Check: Previous version deployed
   ```

4. **Notify**
   ```
   ⚠️ Rollback Executed
   Reason: <REASON>
   Status: Investigating
   ETA: <TIME>
   ```

### Success Criteria
- [ ] All pods running (3/3)
- [ ] Health checks passing
- [ ] Smoke tests passed
- [ ] No error spike in logs
- [ ] Response times normal
- [ ] DNS updated
- [ ] Monitoring active
- [ ] Team notified

---

## SOP-004: Multi-VM Army Deployment

### Purpose
Deploy multiple OpenClaw VMs for distributed workloads.

### Responsible Party
- **Primary:** Infrastructure Engineer

### Prerequisites
- [ ] Army size determined (N VMs)
- [ ] Budget approved
- [ ] Network design reviewed

### Cost Impact
- **Per VM:** $0.88/day
- **N VMs:** $(N * 0.88)/day

### Estimated Duration
20-30 minutes

---

### Procedure

1. **Determine Army Size**
   ```
   Workload requirements → VM count
   Light: 2 VMs
   Medium: 5 VMs
   Heavy: 10 VMs
   ```

2. **Calculate Cost**
   ```
   Daily: $0.88 * N
   Monthly: $27 * N
   ```

3. **Deploy Army**
   ```bash
   ./deploy-army.sh <N>
   # Example: ./deploy-army.sh 5
   ```

4. **Verify All VMs**
   ```bash
   ./army-status.sh
   ```

5. **Test Connectivity**
   ```bash
   # SSH to each VM
   for IP in $(cd army-deployment && \
     ~/bin/terraform output -json vm_ips | \
     python3 -c "import sys,json; print(' '.join(json.load(sys.stdin).values()))"); do
     echo "Testing $IP..."
     ssh azureuser@$IP "hostname && openclaw status"
   done
   ```

6. **Configure Load Balancer** (if needed)
   ```bash
   # Create Azure Load Balancer
   az network lb create \
     --resource-group openclaw-army-rg \
     --name openclaw-army-lb \
     --sku Standard
   ```

### Decommissioning
```bash
./destroy-army.sh
# Type: DELETE
```

---

## SOP-005: Backstage IDP Setup

### Purpose
Install and configure Backstage developer portal.

### Responsible Party
- **Primary:** Platform Engineer

### Prerequisites
- [ ] Node.js 20+
- [ ] GitHub token
- [ ] Azure credentials (optional)

### Estimated Duration
25 minutes

---

### Procedure

1. **Navigate to App**
   ```bash
   cd backstage-app
   ```

2. **Run Setup**
   ```bash
   ./setup.sh
   ```
   
   **Wait:** 5-10 minutes for dependencies

3. **Configure Environment**
   ```bash
   cp .env.example .env
   nano .env
   ```
   
   **Set at minimum:**
   - GITHUB_TOKEN

4. **Start Development**
   ```bash
   yarn dev
   ```

5. **Verify Frontend**
   - Open: http://localhost:3000
   - Check: Page loads

6. **Verify Catalog**
   - Navigate to: Catalog
   - Check: Components visible

7. **Verify Templates**
   - Navigate to: Create
   - Check: Templates load

8. **Production Build** (optional)
   ```bash
   yarn build
   yarn build-image
   ```

---

## SOP-006: Emergency Rollback

### Purpose
Quickly rollback to previous stable state in case of issues.

### Trigger Conditions
- Critical bugs in production
- Performance degradation >50%
- Error rate >5%
- Security incident

### Responsible Party
- **Primary:** On-call Engineer
- **Escalation:** Platform Lead → CTO

### Estimated Duration
5-10 minutes

---

### Procedure

#### Immediate Actions (0-2 minutes)

1. **Declare Incident**
   
   Post in #incidents:
   ```
   🚨 INCIDENT: <DESCRIPTION>
   Severity: P1
   Impact: <USER_IMPACT>
   Action: Initiating rollback
   ```

2. **Stop New Deployments**
   ```bash
   # Pause ArgoCD auto-sync
   argocd app set openclaw-production \
     --sync-policy none
   ```

#### Rollback (2-5 minutes)

3. **Identify Last Good Version**
   ```bash
   argocd app history openclaw-production
   # Note revision number
   ```

4. **Execute Rollback**
   ```bash
   argocd app rollback openclaw-production <REVISION>
   ```

5. **Monitor**
   ```bash
   watch -n 2 'argocd app get openclaw-production'
   ```

6. **Verify**
   ```bash
   curl -f https://openclaw.ai/health
   ```

#### Post-Rollback (5-10 minutes)

7. **Check Metrics**
   - Error rate back to normal?
   - Response times OK?
   - No new errors?

8. **Update Incident**
   ```
   ✅ Rollback Complete
   Version: <PREVIOUS_VERSION>
   Status: Monitoring
   ETA for fix: <TIME>
   ```

9. **Root Cause Analysis**
   - Schedule within 24 hours
   - Document findings
   - Create action items

---

## SOP-007: Scaling Operations

### Purpose
Scale resources up or down based on load.

### Scenarios
- Scale up: Increased traffic expected
- Scale down: Cost optimization

### Responsible Party
- **Primary:** Platform Engineer

---

### Horizontal Pod Autoscaling (AKS)

```bash
# Create HPA
kubectl autoscale deployment openclaw \
  -n openclaw-production \
  --cpu-percent=70 \
  --min=3 \
  --max=10

# Verify
kubectl get hpa -n openclaw-production
```

### Vertical Scaling (VM)

```bash
# Resize VM
az vm resize \
  --resource-group openclaw-dev-rg \
  --name openclaw-dev-vm \
  --size Standard_B4ms

# Restart
az vm restart \
  --resource-group openclaw-dev-rg \
  --name openclaw-dev-vm
```

### Army Scaling

```bash
# Deploy more VMs
./deploy-army.sh 10  # Scales to 10 VMs

# Or destroy and redeploy
./destroy-army.sh
./deploy-army.sh 5  # Scale down to 5
```

---

## SOP-008: Backup Procedures

### Purpose
Ensure data can be recovered in case of disaster.

### Frequency
- Full backup: Daily (02:00 UTC)
- Incremental: Every 6 hours
- Retention: 30 days

### Responsible Party
- **Primary:** Operations Team
- **Verification:** Weekly by Platform Lead

---

### Manual Backup

```bash
# VM Snapshot
az vm snapshot create \
  --resource-group openclaw-dev-rg \
  --name openclaw-dev-vm-snapshot-$(date +%Y%m%d) \
  --source openclaw-dev-vm

# Verify
az snapshot list \
  --resource-group openclaw-dev-rg \
  --output table
```

### Automated Backup

```bash
# Enable Azure Backup
az backup protection enable-for-vm \
  --resource-group openclaw-backup-rg \
  --vault-name openclaw-backup-vault \
  --vm openclaw-dev-vm \
  --policy-name DefaultPolicy
```

### Restore Test

**Frequency:** Monthly

```bash
# See TEST-DR-001 in TEST_PROCEDURES.md
```

---

## SOP-009: Monitoring Setup

### Purpose
Configure monitoring and alerting for production systems.

### Tools
- Azure Monitor
- Application Insights
- Grafana
- Discord webhooks

---

### Application Insights

```bash
# Enable
az monitor app-insights component create \
  --app openclaw-production \
  --location eastus \
  --resource-group openclaw-production-rg
```

### Alert Rules

```bash
# CPU alert
az monitor metrics alert create \
  --name openclaw-high-cpu \
  --resource-group openclaw-production-rg \
  --scopes /subscriptions/.../openclaw-production-vm \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m
```

### Discord Webhook

```bash
# Configure in Azure Monitor
# Action Group → Webhook → Discord URL
```

---

## SOP-010: Decommissioning

### Purpose
Safely remove resources that are no longer needed.

### Trigger
- Project end
- Environment consolidation
- Cost optimization

### Responsible Party
- **Primary:** Infrastructure Engineer
- **Approval:** Engineering Manager

---

### Procedure

1. **Verify No Active Use**
   ```bash
   # Check connections
   az vm show \
     --resource-group openclaw-dev-rg \
     --name openclaw-dev-vm \
     --query "networkProfile"
   ```

2. **Notify Stakeholders**
   - 7 days advance notice
   - Document reason
   - Provide alternatives

3. **Backup Before Removal**
   ```bash
   # Create final backup
   az backup protection backup-now \
     --resource-group openclaw-dev-rg \
     --vault-name openclaw-backup-vault \
     --container-name openclaw-dev-vm \
     --item-name openclaw-dev-vm
   ```

4. **Remove Resources**
   ```bash
   ./deploy.sh dev vm destroy
   # Type: DELETE
   ```

5. **Verify Removal**
   ```bash
   az resource list \
     --resource-group openclaw-dev-rg
   # Expected: Empty or resource group deleted
   ```

6. **Update Documentation**
   - Remove from Backstage catalog
   - Update network diagrams
   - Archive runbooks

7. **Final Report**
   ```
   Decommissioned: openclaw-dev-vm
   Date: YYYY-MM-DD
   Reason: <REASON>
   Cost Savings: $13.50/month
   ```

---

## Document Control

### Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-04-24 | OpenClaw Team | Initial release |

### Approval

**Author:** OpenClaw Platform Team  
**Reviewed By:** ___________________  
**Approved By:** ___________________  
**Date:** ___________________

### Distribution

- Platform Engineering Team
- DevOps Team
- Operations Team
- Management

### Review Schedule

**Frequency:** Quarterly  
**Next Review:** 2026-07-24

---

**End of Standard Operating Procedures**
