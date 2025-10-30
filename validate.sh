#!/bin/bash
# Terraform Validation Script
# Validates all Terraform configurations in the repository

set -e

echo "🔍 Terraform Validation Script"
echo "=============================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform is not installed${NC}"
    echo "Please install Terraform from https://www.terraform.io/downloads"
    exit 1
fi

echo -e "${GREEN}✓ Terraform found:${NC} $(terraform version | head -n1)"
echo ""

# Function to validate a directory
validate_dir() {
    local dir=$1
    echo -e "${YELLOW}Validating: $dir${NC}"
    
    cd "$dir"
    
    # Initialize
    echo "  → Running terraform init..."
    if terraform init -backend=false > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Init successful"
    else
        echo -e "  ${RED}✗${NC} Init failed"
        return 1
    fi
    
    # Validate
    echo "  → Running terraform validate..."
    if terraform validate > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Validation successful"
    else
        echo -e "  ${RED}✗${NC} Validation failed"
        return 1
    fi
    
    # Format check
    echo "  → Checking formatting..."
    if terraform fmt -check -recursive > /dev/null 2>&1; then
        echo -e "  ${GREEN}✓${NC} Formatting correct"
    else
        echo -e "  ${YELLOW}⚠${NC} Formatting issues found (run 'terraform fmt -recursive')"
    fi
    
    cd - > /dev/null
    echo ""
}

# Get repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# Track success
SUCCESS=true

# Validate module
echo "📦 Validating Modules"
echo "--------------------"
if [ -d "modules/vpc" ]; then
    if ! validate_dir "modules/vpc"; then
        SUCCESS=false
    fi
fi
echo ""

# Validate environments
echo "🌍 Validating Environments"
echo "-------------------------"
for env_dir in environments/*/; do
    if [ -d "$env_dir" ] && [ -f "$env_dir/main.tf" ]; then
        if ! validate_dir "$env_dir"; then
            SUCCESS=false
        fi
    fi
done

# Summary
echo "=============================="
if [ "$SUCCESS" = true ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}✗ Some validations failed${NC}"
    exit 1
fi
