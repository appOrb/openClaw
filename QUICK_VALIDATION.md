# Quick Validation Checklist

**Use this for rapid validation during testing.**

---

## Infrastructure (10 min)

```bash
# 1. Validation script
./validate.sh
# ✅ All tests pass

# 2. Set credentials
export ARM_CLIENT_ID="..."
export ARM_CLIENT_SECRET="..."
export ARM_TENANT_ID="..."
export ARM_SUBSCRIPTION_ID="..."

# 3. Plan (dry run)
./deploy.sh dev vm plan
# ✅ Plan succeeds

# 4. Deploy
./deploy.sh dev vm apply
# Type: yes
# ✅ Resources created

# 5. Get IP
cd terraform/environments/dev
~/bin/terraform output public_ip_address
# Note IP: _____________

# 6. Test SSH
ssh azureuser@<IP>
# ✅ SSH works

# 7. Test health
curl http://<IP>:3000/health
# ✅ Returns JSON

# 8. Destroy
./deploy.sh dev vm destroy
# Type: DELETE
# ✅ Resources deleted
```

**Infrastructure: [ ] PASS [ ] FAIL**

---

## IDP/Backstage (15 min)

```bash
# 1. Install
cd backstage-app
./setup.sh
# ✅ Setup complete

# 2. Configure
cp .env.example .env
# Edit .env with GITHUB_TOKEN
# ✅ .env configured

# 3. Start
yarn dev
# ✅ Server starts

# 4. Access UI
# Open: http://localhost:3000
# ✅ Page loads

# 5. Check catalog
# Navigate to: Catalog
# ✅ Components visible (5+)

# 6. Check templates
# Navigate to: Create
# ✅ OpenClaw template visible

# 7. Test template form
# Fill form (don't submit)
# ✅ Form validates
```

**IDP/Backstage: [ ] PASS [ ] FAIL**

---

## Quick Test (Full E2E - 20 min)

```bash
# 1. Deploy
./deploy.sh dev vm apply
# ✅ Deployed

# 2. Get outputs
cd terraform/environments/dev
~/bin/terraform output
# ✅ IP: ___________

# 3. Wait for bootstrap (5 min)
sleep 300

# 4. Test
ssh azureuser@<IP>
openclaw status
# ✅ OpenClaw running

# 5. Verify in Backstage
# Open http://localhost:3000
# Catalog → openclaw-vm
# ✅ Shows deployment info

# 6. Cleanup
./deploy.sh dev vm destroy
# ✅ Cleaned up
```

**E2E: [ ] PASS [ ] FAIL**

---

## Final Status

**Infrastructure:** ___________  
**Backstage:** ___________  
**E2E Test:** ___________

**Overall:** [ ] ✅ PASS [ ] ❌ FAIL

**Issues:**
1. ________________________
2. ________________________

**Notes:**
________________________
________________________
