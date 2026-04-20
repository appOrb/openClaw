module "resource_group" {
  source   = "./modules/resource-group"
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = local.tags
}

module "networking" {
  source              = "./modules/networking"
  prefix              = var.prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  dns_label           = var.dns_label
  ssh_source_cidr     = var.ssh_source_cidr
  tags                = local.tags
}

module "vm" {
  source              = "./modules/vm"
  prefix              = var.prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = file(var.ssh_public_key_path)
  nic_id              = module.networking.nic_id
  tags                = local.tags
}

# ── Bootstrap: run vm-setup.sh on the VM after it's created ──────────────────

resource "null_resource" "bootstrap" {
  depends_on = [module.vm]

  triggers = {
    vm_id            = module.vm.vm_id
    setup_script_sha = filesha256("${path.root}/../vm-setup.sh")
  }

  connection {
    type        = "ssh"
    host        = module.networking.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
    timeout     = "10m"
  }

  provisioner "file" {
    source      = "${path.root}/../vm-setup.sh"
    destination = "/tmp/vm-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/vm-setup.sh",
      "sudo bash /tmp/vm-setup.sh",
    ]
  }
}

# ── Secrets: write GITHUB_TOKEN to VM (never stored in state or logs) ─────────
# The token is marked sensitive=true in variables.tf. It is written to a
# chmod-600 file that only azureuser can read. The openclaw.service loads it
# via EnvironmentFile (set in vm-setup.sh).

resource "null_resource" "secrets" {
  depends_on = [null_resource.bootstrap]

  triggers = {
    vm_id = module.vm.vm_id
  }

  connection {
    type        = "ssh"
    host        = module.networking.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.openclaw",
      # Write secrets file readable only by azureuser
      "install -m 600 /dev/null ~/.openclaw/.env",
      "echo 'GITHUB_TOKEN=${var.github_token}' > ~/.openclaw/.env",
      "chmod 600 ~/.openclaw/.env",
      # Restart openclaw so it picks up the new env
      "sudo systemctl restart openclaw || true",
    ]
  }
}

# ── Deploy OpenClaw config + skills ──────────────────────────────────────────

resource "null_resource" "openclaw_config" {
  depends_on = [null_resource.secrets]

  triggers = {
    config_sha = filesha256("${path.root}/../../openclaw/config.json")
  }

  connection {
    type        = "ssh"
    host        = module.networking.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.root}/../../openclaw/config.json"
    destination = "/tmp/openclaw.json"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.openclaw/skills",
      "mv /tmp/openclaw.json ~/.openclaw/openclaw.json",
    ]
  }
}

resource "null_resource" "openclaw_skills" {
  depends_on = [null_resource.openclaw_config]

  triggers = {
    skills_sha = sha256(join("", [
      for f in fileset("${path.root}/../../openclaw/skills", "*.md") :
      filesha256("${path.root}/../../openclaw/skills/${f}")
    ]))
  }

  connection {
    type        = "ssh"
    host        = module.networking.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.root}/../../openclaw/skills/"
    destination = "/home/${var.admin_username}/.openclaw/skills"
  }

  provisioner "remote-exec" {
    inline = ["sudo systemctl restart openclaw || true"]
  }
}

# ── Deploy Paperclip company config ──────────────────────────────────────────

resource "null_resource" "paperclip_config" {
  depends_on = [null_resource.bootstrap]

  triggers = {
    company_sha = filesha256("${path.root}/../../paperclip/company.yaml")
  }

  connection {
    type        = "ssh"
    host        = module.networking.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.root}/../../paperclip/company.yaml"
    destination = "/home/${var.admin_username}/paperclip/company.yaml"
  }
}

# ── Deploy Nginx config ───────────────────────────────────────────────────────

resource "null_resource" "nginx_config" {
  depends_on = [null_resource.bootstrap]

  triggers = {
    nginx_sha = filesha256("${path.root}/../../nginx/openclaw.conf")
  }

  connection {
    type        = "ssh"
    host        = module.networking.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.root}/../../nginx/openclaw.conf"
    destination = "/tmp/openclaw.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/openclaw.conf /etc/nginx/sites-available/openclaw",
      "sudo ln -sf /etc/nginx/sites-available/openclaw /etc/nginx/sites-enabled/openclaw",
      "sudo nginx -t && sudo systemctl reload nginx",
    ]
  }
}

# ── Locals ────────────────────────────────────────────────────────────────────

locals {
  tags = {
    project     = "openclaw"
    environment = var.environment
    managed_by  = "terraform"
  }
}
