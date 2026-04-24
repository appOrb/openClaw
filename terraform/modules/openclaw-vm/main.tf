# OpenClaw VM Deployment Module
# Deploys OpenClaw on Azure VM with all 9 agents

# Virtual Network
resource "azurerm_virtual_network" "openclaw" {
  name                = "${var.environment}-openclaw-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}

# Subnet
resource "azurerm_subnet" "openclaw" {
  name                 = "${var.environment}-openclaw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.openclaw.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "openclaw" {
  name                = "${var.environment}-openclaw-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # SSH access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"  # TODO: Restrict to specific IPs in production
    destination_address_prefix = "*"
  }
  
  # HTTP access
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
  
  # HTTPS access
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
  
  tags = var.tags
}

# Public IP
resource "azurerm_public_ip" "openclaw" {
  name                = "${var.environment}-openclaw-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domain_label
  
  tags = var.tags
}

# Network Interface
resource "azurerm_network_interface" "openclaw" {
  name                = "${var.environment}-openclaw-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.openclaw.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.openclaw.id
  }
  
  tags = var.tags
}

# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "openclaw" {
  network_interface_id      = azurerm_network_interface.openclaw.id
  network_security_group_id = azurerm_network_security_group.openclaw.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "openclaw" {
  name                = "${var.environment}-openclaw-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  
  disable_password_authentication = true
  
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }
  
  network_interface_ids = [
    azurerm_network_interface.openclaw.id,
  ]
  
  os_disk {
    name                 = "${var.environment}-openclaw-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Standard for cost savings
    disk_size_gb         = 30
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  # Bootstrap script
  custom_data = base64encode(templatefile("${path.module}/scripts/bootstrap.sh", {
    github_token  = var.github_token
    copilot_token = var.copilot_token
    agents_count  = var.agents_count
    environment   = var.environment
  }))
  
  # Auto-shutdown (dev only)
  dynamic "auto_shutdown_config" {
    for_each = var.enable_auto_shutdown ? [1] : []
    content {
      enabled = true
      timezone = "UTC"
      notification_settings {
        enabled = false
      }
      daily_recurrence_time = var.auto_shutdown_time
    }
  }
  
  tags = var.tags
}

# Managed Identity (for Azure access)
resource "azurerm_user_assigned_identity" "openclaw" {
  name                = "${var.environment}-openclaw-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  tags = var.tags
}
