#!/bin/bash
# Terraform Validation Test Script
# This script validates all Terraform configurations without deploying anything

set -e  # Exit on error

echo "======================================"
echo "Terraform Backend Validation Tests"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track results
PASSED=0
FAILED=0

# Function to print test results
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED${NC}: $2"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED${NC}: $2"
        ((FAILED++))
    fi
}

# Get the repository root
REPO_ROOT="/home/runner/work/ehr-aws-environment-pipelines/ehr-aws-environment-pipelines"
cd "$REPO_ROOT"

echo "Repository Root: $REPO_ROOT"
echo ""

# Test 1: Check Terraform installation
echo "Test 1: Terraform Installation"
if terraform version &> /dev/null; then
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_result 0 "Terraform installed (version: $TERRAFORM_VERSION)"
else
    print_result 1 "Terraform not found"
    exit 1
fi
echo ""

# Test 2: Format check
echo "Test 2: Terraform Format Check"
cd "$REPO_ROOT"
FORMAT_OUTPUT=$(terraform fmt -check -recursive 2>&1) || true
if [ -z "$FORMAT_OUTPUT" ]; then
    print_result 0 "All Terraform files properly formatted"
else
    echo "Files need formatting:"
    echo "$FORMAT_OUTPUT"
    print_result 1 "Some files need formatting (run: terraform fmt -recursive)"
fi
echo ""

# Test 3: Bootstrap module validation
echo "Test 3: Bootstrap Configuration Validation"
cd "$REPO_ROOT/infra/bootstrap"

# Clean any previous state
rm -rf .terraform 2>/dev/null || true
rm -f .terraform.lock.hcl 2>/dev/null || true

if terraform init -backend=false &> /tmp/bootstrap_init.log; then
    print_result 0 "Bootstrap init successful"
else
    print_result 1 "Bootstrap init failed"
    cat /tmp/bootstrap_init.log
fi

if terraform validate &> /tmp/bootstrap_validate.log; then
    print_result 0 "Bootstrap configuration valid"
else
    print_result 1 "Bootstrap validation failed"
    cat /tmp/bootstrap_validate.log
fi
echo ""

# Test 4: tfstate-bucket module validation
echo "Test 4: S3 State Bucket Module Validation"
cd "$REPO_ROOT/infra/modules/tfstate-bucket"

# Create a temporary test wrapper
mkdir -p /tmp/test-tfstate-bucket
cat > /tmp/test-tfstate-bucket/main.tf << 'EOF'
module "test" {
  source = "/home/runner/work/ehr-aws-environment-pipelines/ehr-aws-environment-pipelines/infra/modules/tfstate-bucket"
  
  bucket_name = "test-bucket"
  environment = "test"
}
EOF

cd /tmp/test-tfstate-bucket
if terraform init &> /tmp/bucket_init.log && terraform validate &> /tmp/bucket_validate.log; then
    print_result 0 "S3 bucket module valid"
else
    print_result 1 "S3 bucket module validation failed"
    cat /tmp/bucket_validate.log
fi

# Clean up
rm -rf /tmp/test-tfstate-bucket
echo ""

# Test 5: DynamoDB Lock Table Module Validation
echo "Test 5: DynamoDB Lock Table Module Validation"
cd "$REPO_ROOT/infra/modules/tfstate-lock"

# Create a temporary test wrapper
mkdir -p /tmp/test-tfstate-lock
cat > /tmp/test-tfstate-lock/main.tf << 'EOF'
module "test" {
  source = "/home/runner/work/ehr-aws-environment-pipelines/ehr-aws-environment-pipelines/infra/modules/tfstate-lock"
  
  table_name  = "test-table"
  environment = "test"
}
EOF

cd /tmp/test-tfstate-lock
if terraform init &> /tmp/lock_init.log && terraform validate &> /tmp/lock_validate.log; then
    print_result 0 "DynamoDB lock module valid"
else
    print_result 1 "DynamoDB lock module validation failed"
    cat /tmp/lock_validate.log
fi

# Clean up
rm -rf /tmp/test-tfstate-lock
echo ""

# Test 6-9: Environment configurations
ENVIRONMENTS=("dev" "qa" "prod" "courses")
ENV_NUM=6

for ENV in "${ENVIRONMENTS[@]}"; do
    echo "Test $ENV_NUM: $ENV Environment Configuration"
    cd "$REPO_ROOT/infra/live/$ENV"
    
    # Clean any previous state
    rm -rf .terraform 2>/dev/null || true
    rm -f .terraform.lock.hcl 2>/dev/null || true
    
    if terraform init -backend=false &> /tmp/${ENV}_init.log; then
        print_result 0 "$ENV environment init successful"
    else
        print_result 1 "$ENV environment init failed"
        cat /tmp/${ENV}_init.log
    fi
    
    if terraform validate &> /tmp/${ENV}_validate.log; then
        print_result 0 "$ENV environment configuration valid"
    else
        print_result 1 "$ENV environment validation failed"
        cat /tmp/${ENV}_validate.log
    fi
    
    # Check backend configuration exists
    if [ -f "backend.tf" ]; then
        print_result 0 "$ENV backend.tf exists"
    else
        print_result 1 "$ENV backend.tf missing"
    fi
    
    # Check main.tf exists
    if [ -f "main.tf" ]; then
        print_result 0 "$ENV main.tf exists"
    else
        print_result 1 "$ENV main.tf missing"
    fi
    
    echo ""
    ((ENV_NUM++))
done

# Test: Check documentation files
echo "Test: Documentation Files"
DOCS=(
    "README.md"
    "docs/terraform-backend.md"
    "docs/QUICK_START.md"
    "docs/IMPLEMENTATION_SUMMARY.md"
    "docs/VERIFICATION_CHECKLIST.md"
    "infra/bootstrap/README.md"
)

for DOC in "${DOCS[@]}"; do
    if [ -f "$REPO_ROOT/$DOC" ]; then
        print_result 0 "$DOC exists"
    else
        print_result 1 "$DOC missing"
    fi
done
echo ""

# Test: Check tfvars files
echo "Test: Bootstrap tfvars Files"
TFVARS=(
    "infra/bootstrap/terraform.tfvars.dev"
    "infra/bootstrap/terraform.tfvars.qa"
    "infra/bootstrap/terraform.tfvars.prod"
    "infra/bootstrap/terraform.tfvars.courses"
)

for TFVAR in "${TFVARS[@]}"; do
    if [ -f "$REPO_ROOT/$TFVAR" ]; then
        print_result 0 "$TFVAR exists"
    else
        print_result 1 "$TFVAR missing"
    fi
done
echo ""

# Test: Check .gitignore
echo "Test: Git Configuration"
if [ -f "$REPO_ROOT/.gitignore" ]; then
    print_result 0 ".gitignore exists"
    
    # Check for important patterns
    if grep -q "\.terraform" "$REPO_ROOT/.gitignore"; then
        print_result 0 ".gitignore includes .terraform"
    else
        print_result 1 ".gitignore missing .terraform pattern"
    fi
    
    if grep -q "\.tfstate" "$REPO_ROOT/.gitignore"; then
        print_result 0 ".gitignore includes .tfstate"
    else
        print_result 1 ".gitignore missing .tfstate pattern"
    fi
else
    print_result 1 ".gitignore missing"
fi
echo ""

# Test: Syntax validation
echo "Test: HCL Syntax Check"
cd "$REPO_ROOT"
HCL_ERRORS=0
while IFS= read -r -d '' file; do
    if ! terraform fmt -check "$file" &> /dev/null; then
        ((HCL_ERRORS++))
    fi
done < <(find . -name "*.tf" -type f -print0)

if [ $HCL_ERRORS -eq 0 ]; then
    print_result 0 "All HCL files have correct syntax"
else
    print_result 1 "Some HCL files have syntax errors"
fi
echo ""

# Summary
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the output above.${NC}"
    exit 1
fi
