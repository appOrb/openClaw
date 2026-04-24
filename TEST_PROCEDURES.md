# OpenClaw Test Procedures

**Comprehensive testing documentation for OpenClaw infrastructure and platform.**

Version: 1.0  
Last Updated: 2026-04-24

---

## Table of Contents

1. [Pre-Deployment Testing](#pre-deployment-testing)
2. [Infrastructure Testing](#infrastructure-testing)
3. [Application Testing](#application-testing)
4. [Integration Testing](#integration-testing)
5. [Performance Testing](#performance-testing)
6. [Security Testing](#security-testing)
7. [Disaster Recovery Testing](#disaster-recovery-testing)
8. [Test Sign-Off](#test-sign-off)

---

## Pre-Deployment Testing

### TEST-PRE-001: Environment Validation

**Objective:** Verify all prerequisites are met before deployment.

**Prerequisites:**
- Azure subscription active
- Service Principal created
- GitHub repository access
- Node.js 20+ installed
- Terraform binary available

**Test Steps:**

1. **Verify Azure Credentials**
   ```bash
   az login --service-principal \
     -u $ARM_CLIENT_ID \
     -p $ARM_CLIENT_SECRET \
     --tenant $ARM_TENANT_ID
   
   az account show
   ```
   
   **Expected:** Login successful, correct subscription displayed
   
   **Pass Criteria:** ✅ Subscription ID matches, no errors

2. **Verify Terraform**
   ```bash
   ~/bin/terraform version
   ```
   
   **Expected:** `Terraform v1.14.9`
   
   **Pass Criteria:** ✅ Version 1.14.9 or higher

3. **Verify GitHub Access**
   ```bash
   gh auth status
   git ls-remote https://github.com/appOrb/openClaw.git
   ```
   
   **Expected:** Authentication successful, repository accessible
   
   **Pass Criteria:** ✅ No authentication errors

4. **Verify SSH Keys**
   ```bash
   ls -la ~/.ssh/id_rsa.pub
   cat ~/.ssh/id_rsa.pub
   ```
   
   **Expected:** Public key exists and is readable
   
   **Pass Criteria:** ✅ Key exists, format valid

5. **Run Validation Script**
   ```bash
   cd /path/to/openClaw
   ./validate.sh
   ```
   
   **Expected:** All tests pass
   
   **Pass Criteria:** ✅ 50+ tests passed, 0 failed

**Test Result:** [ ] PASS [ ] FAIL  
**Tester:** ___________  
**Date:** ___________  
**Issues:** ___________

---

### TEST-PRE-002: Cost Verification

**Objective:** Verify cost estimates are accurate and acceptable.

**Test Steps:**

1. **Generate Cost Estimate**
   ```bash
   ./deploy.sh dev vm plan
   ```
   
   **Expected:**
   ```
   Estimated monthly costs:
     VM (B1s): ~$13.50/month (~$0.44/day)
   ```
   
   **Pass Criteria:** ✅ Cost displayed matches documentation

2. **Verify Azure Pricing**
   - Navigate to Azure Pricing Calculator
   - Configure: B1s VM, Ubuntu 22.04, East US
   - Compare with estimate
   
   **Pass Criteria:** ✅ Within 10% of estimate

3. **Budget Alert Check**
   ```bash
   az consumption budget list \
     --resource-group openclaw-dev-rg
   ```
   
   **Expected:** Budget configured (if applicable)
   
   **Pass Criteria:** ✅ Budget exists or N/A

**Test Result:** [ ] PASS [ ] FAIL  
**Tester:** ___________  
**Date:** ___________

---

## Infrastructure Testing

### TEST-INF-001: Single VM Deployment

**Objective:** Deploy single VM to dev environment and verify all resources.

**Duration:** 15 minutes  
**Cost:** ~$0.44/day

**Test Steps:**

1. **Set Credentials**
   ```bash
   export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
   export ARM_CLIENT_SECRET="your-secret"
   export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
   export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"
   ```
   
   **Pass Criteria:** ✅ All variables set

2. **Terraform Plan**
   ```bash
   ./deploy.sh dev vm plan
   ```
   
   **Expected:** Plan succeeds, shows resources to create
   
   **Pass Criteria:** ✅ Plan: X to add, 0 to change, 0 to destroy

3. **Deploy VM**
   ```bash
   ./deploy.sh dev vm apply
   # Type: yes
   ```
   
   **Expected:** Apply completes successfully
   
   **Pass Criteria:** ✅ Resources created: 8-10
   **Pass Criteria:** ✅ Outputs show IP address

4. **Verify Azure Resources**
   
   Navigate to Azure Portal → Resource Groups → openclaw-dev-rg
   
   **Expected Resources:**
   - [ ] Resource Group: openclaw-dev-rg
   - [ ] Virtual Machine: openclaw-dev-vm
   - [ ] Network Interface: openclaw-dev-nic
   - [ ] Public IP: openclaw-dev-pip
   - [ ] Virtual Network: dev-openclaw-vnet
   - [ ] Subnet: dev-openclaw-subnet
   - [ ] NSG: dev-openclaw-nsg
   - [ ] OS Disk: openclaw-dev-osdisk
   
   **Pass Criteria:** ✅ All resources present and running

5. **Get Outputs**
   ```bash
   cd terraform/environments/dev
   ~/bin/terraform output
   ```
   
   **Expected:**
   ```
   public_ip_address = "20.X.X.X"
   ssh_connection = "ssh azureuser@20.X.X.X"
   vm_id = "/subscriptions/.../openclaw-dev-vm"
   ```
   
   **Pass Criteria:** ✅ All outputs present

6. **Test SSH Access**
   ```bash
   VM_IP=$(~/bin/terraform output -raw public_ip_address)
   ssh -o StrictHostKeyChecking=no azureuser@$VM_IP echo "SSH OK"
   ```
   
   **Expected:** "SSH OK" printed
   
   **Pass Criteria:** ✅ SSH connection successful

7. **Verify Bootstrap**
   ```bash
   ssh azureuser@$VM_IP 'which node && which openclaw'
   ```
   
   **Expected:** Paths to node and openclaw
   
   **Pass Criteria:** ✅ Both installed

8. **Check OpenClaw Service**
   ```bash
   ssh azureuser@$VM_IP 'systemctl is-active openclaw'
   ```
   
   **Expected:** `active` or `activating`
   
   **Pass Criteria:** ✅ Service running or starting

9. **Test Health Endpoint**
   ```bash
   curl -f http://$VM_IP:3000/health
   ```
   
   **Expected:** JSON response with status: ok
   
   **Pass Criteria:** ✅ HTTP 200, valid JSON

10. **Cleanup**
    ```bash
    ./deploy.sh dev vm destroy
    # Type: DELETE
    ```
    
    **Expected:** All resources destroyed
    
    **Pass Criteria:** ✅ Destroy: X destroyed

**Test Result:** [ ] PASS [ ] FAIL  
**Tester:** ___________  
**Date:** ___________  
**VM IP:** ___________  
**Issues:** ___________

---

### TEST-INF-002: Multi-VM Army Deployment

**Objective:** Deploy 2-VM army and verify networking.

**Duration:** 20 minutes  
**Cost:** ~$1.76/day

**Test Steps:**

1. **Deploy Army**
   ```bash
   ./deploy-army.sh 2
   # Type: yes
   ```
   
   **Expected:** 2 VMs deployed successfully
   
   **Pass Criteria:** ✅ Resources: 13 added

2. **Verify VM IPs**
   ```bash
   cd army-deployment
   ~/bin/terraform output vm_ips
   ```
   
   **Expected:** 2 IP addresses
   
   **Pass Criteria:** ✅ Both IPs present

3. **Test SSH to Both VMs**
   ```bash
   for IP in $(~/bin/terraform output -json vm_ips | python3 -c "import sys,json; print(' '.join(json.load(sys.stdin).values()))"); do
     echo "Testing $IP..."
     ssh -o StrictHostKeyChecking=no azureuser@$IP echo "OK"
   done
   ```
   
   **Expected:** "OK" from both VMs
   
   **Pass Criteria:** ✅ Both SSH connections work

4. **Verify Network Connectivity**
   ```bash
   # Get IPs
   IP1=$(~/bin/terraform output -json vm_ips | python3 -c "import sys,json; data=json.load(sys.stdin); print(list(data.values())[0])")
   IP2=$(~/bin/terraform output -json vm_ips | python3 -c "import sys,json; data=json.load(sys.stdin); print(list(data.values())[1])")
   
   # Test VM1 → VM2
   ssh azureuser@$IP1 "ping -c 3 10.0.2.4"
   ```
   
   **Expected:** Successful ping
   
   **Pass Criteria:** ✅ VMs can communicate

5. **Check Army Status**
   ```bash
   ./army-status.sh
   ```
   
   **Expected:** Both VMs healthy
   
   **Pass Criteria:** ✅ All checks green

6. **Cleanup**
   ```bash
   ./destroy-army.sh
   # Type: DELETE
   ```
   
   **Expected:** All resources destroyed
   
   **Pass Criteria:** ✅ Clean removal

**Test Result:** [ ] PASS [ ] FAIL  
**Tester:** ___________  
**Date:** ___________  
**VM1 IP:** ___________  
**VM2 IP:** ___________

---

### TEST-INF-003: ACI Deployment

**Objective:** Deploy to Azure Container Instances.

**Duration:** 10 minutes  
**Cost:** ~$0.40/day

**Test Steps:**

1. **Deploy ACI**
   ```bash
   ./deploy.sh staging aci apply
   ```
   
   **Expected:** Container instance created
   
   **Pass Criteria:** ✅ Resources added

2. **Get FQDN**
   ```bash
   cd terraform/environments/staging
   ~/bin/terraform output fqdn
   ```
   
   **Expected:** FQDN like `openclaw-staging.eastus.azurecontainer.io`
   
   **Pass Criteria:** ✅ FQDN present

3. **Test Health**
   ```bash
   FQDN=$(~/bin/terraform output -raw fqdn)
   curl -f http://$FQDN/health
   ```
   
   **Expected:** Health check responds
   
   **Pass Criteria:** ✅ HTTP 200

4. **Check Logs**
   ```bash
   az container logs \
     --resource-group openclaw-staging-rg \
     --name openclaw-staging-aci
   ```
   
   **Expected:** Application logs visible
   
   **Pass Criteria:** ✅ No errors in logs

5. **Cleanup**
   ```bash
   ./deploy.sh staging aci destroy
   ```

**Test Result:** [ ] PASS [ ] FAIL

---

## Application Testing

### TEST-APP-001: Backstage Installation

**Objective:** Install and verify Backstage IDP.

**Duration:** 20 minutes  
**Cost:** $0

**Test Steps:**

1. **Run Setup**
   ```bash
   cd backstage-app
   ./setup.sh
   ```
   
   **Expected:** Installation completes
   
   **Pass Criteria:** ✅ "Setup complete" message

2. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with GITHUB_TOKEN
   ```
   
   **Pass Criteria:** ✅ .env exists with token

3. **Start Server**
   ```bash
   yarn dev
   ```
   
   **Expected:** Both frontend and backend start
   
   **Pass Criteria:** ✅ Port 3000 and 7007 listening

4. **Test Frontend**
   ```bash
   curl -f http://localhost:3000
   ```
   
   **Expected:** HTML response
   
   **Pass Criteria:** ✅ HTTP 200

5. **Test Backend**
   ```bash
   curl -f http://localhost:7007/healthcheck
   ```
   
   **Expected:** `{"status":"ok"}`
   
   **Pass Criteria:** ✅ Health check passes

6. **Verify Catalog**
   
   Open browser: http://localhost:3000/catalog
   
   **Expected:** Components visible
   
   **Pass Criteria:** ✅ 5+ components listed

7. **Verify Templates**
   
   Navigate to: http://localhost:3000/create
   
   **Expected:** OpenClaw template visible
   
   **Pass Criteria:** ✅ Template loads

8. **Test Template Form**
   
   - Click OpenClaw template
   - Fill form (don't submit)
   - Verify validation
   
   **Pass Criteria:** ✅ Form validates

**Test Result:** [ ] PASS [ ] FAIL  
**Screenshots:** [ ] Attached

---

## Integration Testing

### TEST-INT-001: End-to-End Deployment

**Objective:** Deploy VM, verify in Backstage, test full workflow.

**Duration:** 30 minutes  
**Cost:** ~$0.02 (1 hour test)

**Test Steps:**

1. **Deploy VM**
   ```bash
   ./deploy.sh dev vm apply
   ```

2. **Get VM Details**
   ```bash
   VM_IP=$(cd terraform/environments/dev && ~/bin/terraform output -raw public_ip_address)
   echo "VM IP: $VM_IP"
   ```

3. **Wait for Bootstrap** (5 minutes)
   ```bash
   sleep 300
   ```

4. **Verify OpenClaw**
   ```bash
   ssh azureuser@$VM_IP openclaw status
   ```
   
   **Expected:** Status output
   
   **Pass Criteria:** ✅ Gateway running

5. **Test API**
   ```bash
   curl http://$VM_IP:3000/api/health
   ```
   
   **Expected:** JSON response
   
   **Pass Criteria:** ✅ HTTP 200

6. **Verify in Backstage**
   
   - Open http://localhost:3000/catalog
   - Find openclaw-vm component
   - Check deployment info
   
   **Pass Criteria:** ✅ Component shows as deployed

7. **Cleanup**
   ```bash
   ./deploy.sh dev vm destroy
   ```

**Test Result:** [ ] PASS [ ] FAIL

---

## Performance Testing

### TEST-PERF-001: Load Testing

**Objective:** Verify system handles expected load.

**Duration:** 30 minutes

**Test Steps:**

1. **Deploy VM**
2. **Install Load Testing Tool**
   ```bash
   npm install -g artillery
   ```

3. **Create Load Test Config**
   ```yaml
   # load-test.yml
   config:
     target: "http://<VM_IP>:3000"
     phases:
       - duration: 60
         arrivalRate: 10
   scenarios:
     - flow:
         - get:
             url: "/health"
   ```

4. **Run Test**
   ```bash
   artillery run load-test.yml
   ```

5. **Analyze Results**
   
   **Expected:**
   - RPS: 10
   - Latency p95: < 200ms
   - Error rate: < 1%
   
   **Pass Criteria:** ✅ All metrics within limits

**Test Result:** [ ] PASS [ ] FAIL

---

## Security Testing

### TEST-SEC-001: Security Audit

**Objective:** Verify security controls are in place.

**Test Steps:**

1. **Check NSG Rules**
   ```bash
   az network nsg rule list \
     --resource-group openclaw-dev-rg \
     --nsg-name openclaw-dev-nsg \
     --output table
   ```
   
   **Expected:** Only required ports open
   
   **Pass Criteria:** ✅ SSH (22), HTTP (80), HTTPS (443), OpenClaw (3000)

2. **Verify SSH Key Auth**
   ```bash
   # Try password auth (should fail)
   ssh -o PreferredAuthentications=password azureuser@$VM_IP
   ```
   
   **Expected:** Authentication failure
   
   **Pass Criteria:** ✅ Password auth disabled

3. **Check SSL/TLS**
   ```bash
   nmap --script ssl-enum-ciphers -p 443 $VM_IP
   ```
   
   **Expected:** Strong ciphers only
   
   **Pass Criteria:** ✅ No weak ciphers

4. **Verify Updates**
   ```bash
   ssh azureuser@$VM_IP 'sudo apt update && apt list --upgradable'
   ```
   
   **Expected:** System up to date
   
   **Pass Criteria:** ✅ No critical updates pending

**Test Result:** [ ] PASS [ ] FAIL

---

## Disaster Recovery Testing

### TEST-DR-001: Backup and Restore

**Objective:** Verify backup and restore procedures work.

**Duration:** 45 minutes

**Test Steps:**

1. **Create Backup**
   ```bash
   az backup protection backup-now \
     --resource-group openclaw-dev-rg \
     --vault-name openclaw-backup-vault \
     --container-name openclaw-dev-vm \
     --item-name openclaw-dev-vm \
     --backup-management-type AzureIaasVM
   ```

2. **Verify Backup**
   ```bash
   az backup recoverypoint list \
     --resource-group openclaw-dev-rg \
     --vault-name openclaw-backup-vault \
     --container-name openclaw-dev-vm \
     --item-name openclaw-dev-vm \
     --backup-management-type AzureIaasVM
   ```
   
   **Expected:** Recent backup listed
   
   **Pass Criteria:** ✅ Backup within 24 hours

3. **Test Restore** (on test VM)
   ```bash
   # Follow RESTORE_GUIDE.md
   ```

4. **Verify Restored Data**
   
   **Pass Criteria:** ✅ Data intact after restore

**Test Result:** [ ] PASS [ ] FAIL

---

## Test Sign-Off

### Test Summary

| Test ID | Test Name | Result | Tester | Date |
|---------|-----------|--------|--------|------|
| TEST-PRE-001 | Environment Validation | [ ] | | |
| TEST-PRE-002 | Cost Verification | [ ] | | |
| TEST-INF-001 | Single VM Deployment | [ ] | | |
| TEST-INF-002 | Multi-VM Army | [ ] | | |
| TEST-INF-003 | ACI Deployment | [ ] | | |
| TEST-APP-001 | Backstage Installation | [ ] | | |
| TEST-INT-001 | End-to-End | [ ] | | |
| TEST-PERF-001 | Load Testing | [ ] | | |
| TEST-SEC-001 | Security Audit | [ ] | | |
| TEST-DR-001 | Backup/Restore | [ ] | | |

### Overall Status

**Total Tests:** 10  
**Passed:** ___  
**Failed:** ___  
**Blocked:** ___

**Overall Result:** [ ] PASS [ ] FAIL

### Sign-Off

**Test Lead:** _____________________  
**Date:** _____________________  
**Signature:** _____________________

**Project Manager:** _____________________  
**Date:** _____________________  
**Signature:** _____________________

---

**End of Test Procedures Document**
