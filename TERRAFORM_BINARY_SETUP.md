# Terraform Quick Setup (No Installation Required)

## Download Terraform Binary

```bash
# Create terraform directory
mkdir -p ~/bin

# Download latest Terraform (Linux AMD64)
cd ~/bin
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip

# Extract
unzip terraform_1.7.5_linux_amd64.zip

# Make executable
chmod +x terraform

# Verify
./terraform version
```

## Use Terraform Binary

```bash
# Navigate to your environment
cd ~/projects/appOrb/openClaw/terraform/environments/dev

# Initialize (using binary)
~/bin/terraform init

# Plan
~/bin/terraform plan

# Apply
~/bin/terraform apply
```

## Add to PATH (Optional)

```bash
# Add to .bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Now you can use 'terraform' directly
terraform version
```

## Quick Deployment Commands

```bash
# Set credentials
export ARM_CLIENT_ID="f2410d10-07d1-49e2-af61-dba86cc9b441"
export ARM_CLIENT_SECRET="your-secret"
export ARM_TENANT_ID="1b9184b9-e785-4727-a33d-f9526fe07006"
export ARM_SUBSCRIPTION_ID="05a43f56-f126-4bf1-bb97-9ca4d91dfcb5"

# Deploy VM (dev)
cd ~/projects/appOrb/openClaw/terraform/environments/dev
~/bin/terraform init
~/bin/terraform plan
~/bin/terraform apply -auto-approve

# Cost: ~$0.44/day
```

## No Installation Needed!

✅ Just download, extract, and run  
✅ No sudo/root required  
✅ Works in sandboxed environments  
✅ Portable across machines
