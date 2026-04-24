#!/bin/bash
# OpenClaw Infrastructure Deployment Script
# Usage: ./deploy.sh [environment] [platform] [action]
# Example: ./deploy.sh dev vm apply

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TERRAFORM_BIN="${HOME}/bin/terraform"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_ROOT="${SCRIPT_DIR}/terraform"

# Functions
print_banner() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║         OpenClaw Infrastructure Manager                   ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${GREEN}ℹ️  $1${NC}"
}

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Terraform
    if [ ! -f "$TERRAFORM_BIN" ]; then
        print_error "Terraform not found at $TERRAFORM_BIN"
        print_info "Run: ./scripts/install-terraform.sh"
        exit 1
    fi
    print_success "Terraform found: $($TERRAFORM_BIN version | head -1)"
    
    # Check Azure credentials
    if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ] || [ -z "$ARM_TENANT_ID" ] || [ -z "$ARM_SUBSCRIPTION_ID" ]; then
        print_error "Azure credentials not set"
        print_info "Required environment variables:"
        echo "  - ARM_CLIENT_ID"
        echo "  - ARM_CLIENT_SECRET"
        echo "  - ARM_TENANT_ID"
        echo "  - ARM_SUBSCRIPTION_ID"
        exit 1
    fi
    print_success "Azure credentials configured"
}

validate_inputs() {
    local env=$1
    local platform=$2
    local action=$3
    
    # Validate environment
    if [[ ! "$env" =~ ^(dev|staging|production)$ ]]; then
        print_error "Invalid environment: $env"
        print_info "Valid options: dev, staging, production"
        exit 1
    fi
    
    # Validate platform
    if [[ ! "$platform" =~ ^(vm|aci|aks|all)$ ]]; then
        print_error "Invalid platform: $platform"
        print_info "Valid options: vm, aci, aks, all"
        exit 1
    fi
    
    # Validate action
    if [[ ! "$action" =~ ^(plan|apply|destroy)$ ]]; then
        print_error "Invalid action: $action"
        print_info "Valid options: plan, apply, destroy"
        exit 1
    fi
    
    print_success "Input validation passed"
}

confirm_action() {
    local env=$1
    local platform=$2
    local action=$3
    
    echo ""
    print_warning "═══════════════════════════════════════════════"
    print_warning "  CONFIRM ACTION"
    print_warning "═══════════════════════════════════════════════"
    echo "  Environment: $env"
    echo "  Platform: $platform"
    echo "  Action: $action"
    print_warning "═══════════════════════════════════════════════"
    echo ""
    
    if [ "$action" == "destroy" ]; then
        print_error "⚠️  WARNING: This will DELETE all resources!"
        echo -n "Type 'DELETE' to confirm: "
        read confirmation
        if [ "$confirmation" != "DELETE" ]; then
            print_info "Aborted"
            exit 0
        fi
    elif [ "$action" == "apply" ] && [ "$env" == "production" ]; then
        print_warning "⚠️  Deploying to PRODUCTION"
        echo -n "Type 'DEPLOY' to confirm: "
        read confirmation
        if [ "$confirmation" != "DEPLOY" ]; then
            print_info "Aborted"
            exit 0
        fi
    else
        echo -n "Continue? (yes/no): "
        read confirmation
        if [ "$confirmation" != "yes" ]; then
            print_info "Aborted"
            exit 0
        fi
    fi
}

show_cost_estimate() {
    local env=$1
    local platform=$2
    
    print_info "Estimated monthly costs:"
    
    case "$platform" in
        vm)
            if [ "$env" == "dev" ]; then
                echo "  VM (B1s): ~\$13.50/month (~\$0.44/day)"
            else
                echo "  VM (B2s): ~\$27/month (~\$0.88/day)"
            fi
            ;;
        aci)
            echo "  ACI: ~\$12/month (~\$0.40/day)"
            ;;
        aks)
            echo "  AKS (3 nodes): ~\$132/month (~\$4.31/day)"
            ;;
        all)
            echo "  VM: ~\$13.50/month"
            echo "  ACI: ~\$12/month"
            echo "  AKS: ~\$132/month"
            echo "  Backup: ~\$5/month"
            echo "  Monitoring: ~\$10/month"
            echo "  ─────────────────────"
            echo "  Total: ~\$172.50/month (~\$5.75/day)"
            ;;
    esac
    echo ""
}

run_terraform() {
    local env=$1
    local platform=$2
    local action=$3
    
    local env_dir="${TERRAFORM_ROOT}/environments/${env}"
    
    if [ ! -d "$env_dir" ]; then
        print_error "Environment directory not found: $env_dir"
        exit 1
    fi
    
    cd "$env_dir"
    
    print_info "Working directory: $env_dir"
    
    # Initialize Terraform
    if [ ! -d ".terraform" ]; then
        print_info "Initializing Terraform..."
        $TERRAFORM_BIN init
        print_success "Terraform initialized"
    fi
    
    # Determine target
    local target_flag=""
    if [ "$platform" != "all" ]; then
        target_flag="-target=module.openclaw_${platform}"
    fi
    
    # Run Terraform action
    case "$action" in
        plan)
            print_info "Running Terraform plan..."
            $TERRAFORM_BIN plan $target_flag
            ;;
        apply)
            print_info "Running Terraform apply..."
            $TERRAFORM_BIN apply $target_flag -auto-approve
            print_success "Deployment complete!"
            show_outputs
            ;;
        destroy)
            print_warning "Running Terraform destroy..."
            $TERRAFORM_BIN destroy $target_flag -auto-approve
            print_success "Resources destroyed!"
            ;;
    esac
}

show_outputs() {
    print_info "Deployment outputs:"
    $TERRAFORM_BIN output -json | python3 -m json.tool || echo "No outputs available"
}

save_deployment_info() {
    local env=$1
    local platform=$2
    local action=$3
    
    local log_file="${SCRIPT_DIR}/deployments.log"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
    
    echo "[$timestamp] $action: $env/$platform" >> "$log_file"
    print_success "Logged to $log_file"
}

# Main
main() {
    print_banner
    
    # Parse arguments
    local env=${1:-}
    local platform=${2:-}
    local action=${3:-}
    
    if [ -z "$env" ] || [ -z "$platform" ] || [ -z "$action" ]; then
        print_error "Usage: $0 <environment> <platform> <action>"
        echo ""
        echo "Environments: dev, staging, production"
        echo "Platforms: vm, aci, aks, all"
        echo "Actions: plan, apply, destroy"
        echo ""
        echo "Examples:"
        echo "  $0 dev vm plan          # Plan VM deployment to dev"
        echo "  $0 dev vm apply         # Deploy VM to dev"
        echo "  $0 dev vm destroy       # Destroy dev VM"
        echo "  $0 production all plan  # Plan all resources in production"
        exit 1
    fi
    
    # Validate and confirm
    check_prerequisites
    validate_inputs "$env" "$platform" "$action"
    show_cost_estimate "$env" "$platform"
    confirm_action "$env" "$platform" "$action"
    
    # Execute
    print_info "Starting deployment process..."
    run_terraform "$env" "$platform" "$action"
    save_deployment_info "$env" "$platform" "$action"
    
    print_success "All done! 🎉"
}

# Run main
main "$@"
