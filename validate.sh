#!/bin/bash
# OpenClaw Infrastructure Validation Script
# Tests all configurations before deployment

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TERRAFORM_BIN="${HOME}/bin/terraform"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      OpenClaw Infrastructure Validation Tests           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo -e "${GREEN}✅ $1${NC}"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}❌ $1${NC}"
    ((TESTS_FAILED++))
}

info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Test 1: Terraform binary
echo "Test 1: Terraform Binary"
if [ -f "$TERRAFORM_BIN" ]; then
    VERSION=$($TERRAFORM_BIN version | head -1)
    pass "Terraform found: $VERSION"
else
    fail "Terraform not found at $TERRAFORM_BIN"
fi
echo ""

# Test 2: Directory structure
echo "Test 2: Directory Structure"
REQUIRED_DIRS=(
    "terraform/environments/dev"
    "terraform/environments/staging"
    "terraform/environments/production"
    "terraform/modules/openclaw-vm"
    "terraform/modules/openclaw-aci"
    "terraform/modules/openclaw-aks"
    "terraform/modules/backup"
    "terraform/modules/monitoring"
    "backstage"
    "gitops"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "${ROOT_DIR}/${dir}" ]; then
        pass "$dir exists"
    else
        fail "$dir missing"
    fi
done
echo ""

# Test 3: Required files
echo "Test 3: Required Files"
REQUIRED_FILES=(
    "deploy.sh"
    "DEPLOYMENT_GUIDE.md"
    "terraform/environments/dev/main.tf"
    "terraform/environments/dev/variables.tf"
    "terraform/environments/dev/terraform.tfvars.example"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${ROOT_DIR}/${file}" ]; then
        pass "$file exists"
    else
        fail "$file missing"
    fi
done
echo ""

# Test 4: Terraform validation (all environments)
echo "Test 4: Terraform Configuration Validation"
for env in dev staging production; do
    ENV_DIR="${ROOT_DIR}/terraform/environments/${env}"
    cd "$ENV_DIR"
    
    info "Validating $env environment..."
    
    # Clean init
    rm -rf .terraform .terraform.lock.hcl 2>/dev/null || true
    
    # Init
    if $TERRAFORM_BIN init -backend=false > /dev/null 2>&1; then
        pass "$env: terraform init succeeded"
    else
        fail "$env: terraform init failed"
        continue
    fi
    
    # Validate
    if $TERRAFORM_BIN validate > /dev/null 2>&1; then
        pass "$env: terraform validate succeeded"
    else
        fail "$env: terraform validate failed"
        $TERRAFORM_BIN validate
    fi
done
echo ""

# Test 5: Module validation
echo "Test 5: Module Validation"
MODULES=("openclaw-vm" "openclaw-aci" "openclaw-aks" "backup" "monitoring")
for module in "${MODULES[@]}"; do
    MODULE_DIR="${ROOT_DIR}/terraform/modules/${module}"
    if [ -f "${MODULE_DIR}/main.tf" ] && \
       [ -f "${MODULE_DIR}/variables.tf" ] && \
       [ -f "${MODULE_DIR}/outputs.tf" ]; then
        pass "Module $module has all required files"
    else
        fail "Module $module missing required files"
    fi
done
echo ""

# Test 6: Deployment script
echo "Test 6: Deployment Script"
if [ -x "${ROOT_DIR}/deploy.sh" ]; then
    pass "deploy.sh is executable"
else
    fail "deploy.sh is not executable"
fi

# Test help output
if "${ROOT_DIR}/deploy.sh" 2>&1 | grep -q "Usage:"; then
    pass "deploy.sh shows help message"
else
    fail "deploy.sh help message not working"
fi
echo ""

# Test 7: Documentation
echo "Test 7: Documentation"
DOCS=(
    "README.md"
    "DEPLOYMENT_README.md"
    "DEPLOYMENT_GUIDE.md"
    "terraform/README.md"
    "backstage/README.md"
    "gitops/README.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "${ROOT_DIR}/${doc}" ]; then
        WORD_COUNT=$(wc -w < "${ROOT_DIR}/${doc}")
        if [ "$WORD_COUNT" -gt 100 ]; then
            pass "$doc exists (${WORD_COUNT} words)"
        else
            fail "$doc exists but seems incomplete (${WORD_COUNT} words)"
        fi
    else
        fail "$doc missing"
    fi
done
echo ""

# Test 8: Terraform format
echo "Test 8: Terraform Formatting"
cd "${ROOT_DIR}/terraform"
if $TERRAFORM_BIN fmt -check -recursive > /dev/null 2>&1; then
    pass "All Terraform files are properly formatted"
else
    fail "Some Terraform files need formatting (run: terraform fmt -recursive)"
fi
echo ""

# Summary
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Test Summary                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Infrastructure is ready for deployment.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some tests failed. Please fix the issues before deploying.${NC}"
    exit 1
fi
