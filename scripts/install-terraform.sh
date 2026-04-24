#!/bin/bash
# Install Terraform binary (no installation, just download)

set -e

TERRAFORM_VERSION="1.14.9"
INSTALL_DIR="${HOME}/bin"
TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         Terraform Binary Setup (No Installation)         ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Create bin directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download
echo "📥 Downloading Terraform ${TERRAFORM_VERSION}..."
wget -q "$TERRAFORM_URL"

# Extract
echo "📦 Extracting..."
unzip -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Cleanup
rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

# Make executable
chmod +x terraform

# Verify
echo ""
echo "✅ Terraform installed successfully!"
echo ""
./terraform version
echo ""

# Add to PATH if not already
if ! grep -q "${INSTALL_DIR}" ~/.bashrc; then
    echo "📝 Adding to PATH..."
    echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
    echo "✅ Added to ~/.bashrc"
    echo ""
    echo "⚠️  Run: source ~/.bashrc"
    echo "   Then you can use 'terraform' directly"
else
    echo "✅ Already in PATH"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Test with:"
echo "  ~/bin/terraform version"
echo ""
echo "Or after 'source ~/.bashrc':"
echo "  terraform version"
