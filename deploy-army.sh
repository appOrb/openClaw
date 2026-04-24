#!/bin/bash
# OpenClaw Army Deployment Script
# Deploy multiple OpenClaw VMs

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

VM_COUNT=${1:-2}
TERRAFORM_BIN="${HOME}/bin/terraform"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         OpenClaw Army Deployment                         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Deploying $VM_COUNT OpenClaw VMs..."
echo ""

# Check prerequisites
if [ -z "$ARM_CLIENT_ID" ] || [ -z "$ARM_CLIENT_SECRET" ]; then
    echo "❌ Azure credentials not set"
    echo "Required: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID"
    exit 1
fi

echo "✅ Azure credentials configured"
echo ""

# Create army directory
ARMY_DIR="${SCRIPT_DIR}/army-deployment"
mkdir -p "$ARMY_DIR"

# Generate Terraform config for army
cat > "${ARMY_DIR}/main.tf" << 'EOF'
terraform {
  required_version = ">= 1.5"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Resource Group
resource "azurerm_resource_group" "army" {
  name     = "openclaw-army-rg"
  location = var.location
  
  tags = {
    Project     = "OpenClaw Army"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "army" {
  name                = "openclaw-army-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.army.location
  resource_group_name = azurerm_resource_group.army.name
  
  tags = azurerm_resource_group.army.tags
}

# Subnets (one per VM)
resource "azurerm_subnet" "army" {
  count                = var.vm_count
  name                 = "openclaw-army-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.army.name
  virtual_network_name = azurerm_virtual_network.army.name
  address_prefixes     = ["10.0.${count.index + 1}.0/24"]
}

# NSG
resource "azurerm_network_security_group" "army" {
  name                = "openclaw-army-nsg"
  location            = azurerm_resource_group.army.location
  resource_group_name = azurerm_resource_group.army.name
  
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "OpenClaw"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = azurerm_resource_group.army.tags
}

# Public IPs
resource "azurerm_public_ip" "army" {
  count               = var.vm_count
  name                = "openclaw-army-pip-${count.index + 1}"
  location            = azurerm_resource_group.army.location
  resource_group_name = azurerm_resource_group.army.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "openclaw-army-${count.index + 1}"
  
  tags = azurerm_resource_group.army.tags
}

# NICs
resource "azurerm_network_interface" "army" {
  count               = var.vm_count
  name                = "openclaw-army-nic-${count.index + 1}"
  location            = azurerm_resource_group.army.location
  resource_group_name = azurerm_resource_group.army.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.army[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.army[count.index].id
  }
  
  tags = azurerm_resource_group.army.tags
}

# NSG associations
resource "azurerm_network_interface_security_group_association" "army" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.army[count.index].id
  network_security_group_id = azurerm_network_security_group.army.id
}

# VMs
resource "azurerm_linux_virtual_machine" "army" {
  count               = var.vm_count
  name                = "openclaw-army-${format("%02d", count.index + 1)}"
  location            = azurerm_resource_group.army.location
  resource_group_name = azurerm_resource_group.army.name
  size                = var.vm_size
  admin_username      = var.admin_username
  
  network_interface_ids = [
    azurerm_network_interface.army[count.index].id,
  ]
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
  
  os_disk {
    name                 = "openclaw-army-osdisk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  custom_data = base64encode(templatefile("${path.module}/bootstrap.sh", {
    vm_number     = count.index + 1
    github_token  = var.github_token
    copilot_token = var.copilot_token
  }))
  
  tags = merge(
    azurerm_resource_group.army.tags,
    {
      VM = "openclaw-army-${format("%02d", count.index + 1)}"
    }
  )
}
EOF

# Create variables file
cat > "${ARMY_DIR}/variables.tf" << 'EOF'
variable "subscription_id" {
  type      = string
  sensitive = true
}

variable "tenant_id" {
  type      = string
  sensitive = true
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_count" {
  type    = number
  default = 2
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}

variable "copilot_token" {
  type      = string
  sensitive = true
}
EOF

# Create outputs
cat > "${ARMY_DIR}/outputs.tf" << 'EOF'
output "resource_group_name" {
  value = azurerm_resource_group.army.name
}

output "vm_ips" {
  value = {
    for idx, pip in azurerm_public_ip.army : 
    "openclaw-army-${format("%02d", idx + 1)}" => pip.ip_address
  }
}

output "vm_fqdns" {
  value = {
    for idx, pip in azurerm_public_ip.army : 
    "openclaw-army-${format("%02d", idx + 1)}" => pip.fqdn
  }
}

output "ssh_commands" {
  value = {
    for idx, pip in azurerm_public_ip.army : 
    "openclaw-army-${format("%02d", idx + 1)}" => "ssh azureuser@${pip.ip_address}"
  }
}
EOF

# Create bootstrap script
cat > "${ARMY_DIR}/bootstrap.sh" << 'EOF'
#!/bin/bash
set -e

echo "OpenClaw Army VM ${vm_number} Bootstrap Starting..."

# Update system
apt-get update
apt-get install -y curl wget git build-essential

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install OpenClaw
npm install -g openclaw

# Configure OpenClaw
mkdir -p /home/azureuser/.openclaw
cat > /home/azureuser/.openclaw/config.json << CONFIG
{
  "vm_number": ${vm_number},
  "agents": 9,
  "github_token": "${github_token}",
  "copilot_token": "${copilot_token}"
}
CONFIG

chown -R azureuser:azureuser /home/azureuser/.openclaw

# Create systemd service
cat > /etc/systemd/system/openclaw.service << SERVICE
[Unit]
Description=OpenClaw Agent Platform
After=network.target

[Service]
Type=simple
User=azureuser
WorkingDirectory=/home/azureuser
ExecStart=/usr/bin/openclaw gateway start
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable openclaw
systemctl start openclaw

echo "OpenClaw Army VM ${vm_number} Bootstrap Complete!"
EOF

# Create tfvars
cat > "${ARMY_DIR}/terraform.tfvars" << EOF
subscription_id = "${ARM_SUBSCRIPTION_ID}"
tenant_id       = "${ARM_TENANT_ID}"
client_id       = "${ARM_CLIENT_ID}"
client_secret   = "${ARM_CLIENT_SECRET}"
vm_count        = ${VM_COUNT}
ssh_public_key  = "$(cat ~/.ssh/id_rsa.pub 2>/dev/null || echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... azureuser@openclaw')"
github_token    = "${GITHUB_TOKEN:-ghp_placeholder}"
copilot_token   = "${COPILOT_TOKEN:-placeholder}"
EOF

# Deploy
cd "$ARMY_DIR"

echo "Initializing Terraform..."
$TERRAFORM_BIN init

echo ""
echo "Planning deployment..."
$TERRAFORM_BIN plan

echo ""
echo -e "${YELLOW}Ready to deploy $VM_COUNT OpenClaw VMs${NC}"
echo "Estimated cost: \$$(echo "$VM_COUNT * 0.88" | bc)/day"
echo ""
read -p "Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo "Deploying army..."
$TERRAFORM_BIN apply -auto-approve

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         OpenClaw Army Deployed!                          ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "VM IPs:"
$TERRAFORM_BIN output -json vm_ips | python3 -m json.tool

echo ""
echo "SSH Commands:"
$TERRAFORM_BIN output -json ssh_commands | python3 -m json.tool

echo ""
echo "Access VMs:"
for i in $(seq 1 $VM_COUNT); do
    IP=$($TERRAFORM_BIN output -json vm_ips | python3 -c "import sys,json; data=json.load(sys.stdin); print(data['openclaw-army-$(printf '%02d' $i)'])" 2>/dev/null || echo "pending")
    echo "  VM $i: ssh azureuser@$IP"
done
