#!/bin/bash

# Architect Review Script
# Performs automated architecture compliance checks before manual review

FEATURE_NAME=${1:-"unknown"}
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║          🏛️  ARCHITECT AUTOMATED REVIEW                         ║"
echo "║          Feature: $FEATURE_NAME"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Helper functions
check_file_exists() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $2 - NOT FOUND: $1"
        ((FAILED++))
        return 1
    fi
}

check_namespace() {
    if grep -q "namespace OfferteMakerApi" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $2 - Correct namespace"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $2 - Invalid or missing namespace in $1"
        ((FAILED++))
        return 1
    fi
}

check_pattern_in_file() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $3"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $3 - Pattern not found in $1"
        ((FAILED++))
        return 1
    fi
}

# ==========================================
# CHECKS
# ==========================================

echo -e "${YELLOW}Checking Entity/Domain Layer...${NC}"
ENTITY_FILE="$PROJECT_ROOT/OfferteMakerApi/Entities/Models/${FEATURE_NAME^}.cs"
check_file_exists "$ENTITY_FILE" "Entity class exists"
if [ -f "$ENTITY_FILE" ]; then
    check_namespace "$ENTITY_FILE" "Entity namespace"
    check_pattern_in_file "$ENTITY_FILE" "public Guid Id" "Entity has Guid Id"
fi

echo ""
echo -e "${YELLOW}Checking Data Access Layer...${NC}"
REPO_INTERFACE="$PROJECT_ROOT/OfferteMakerApi/Contracts/I${FEATURE_NAME^}Repository.cs"
check_file_exists "$REPO_INTERFACE" "Repository interface exists"

REPO_IMPL="$PROJECT_ROOT/OfferteMakerApi/Repository/${FEATURE_NAME^}Repository.cs"
check_file_exists "$REPO_IMPL" "Repository implementation exists"
if [ -f "$REPO_IMPL" ]; then
    check_namespace "$REPO_IMPL" "Repository namespace"
    check_pattern_in_file "$REPO_IMPL" "RepositoryBase" "Repository extends RepositoryBase"
fi

CONFIG_FILE="$PROJECT_ROOT/OfferteMakerApi/Repository/Configuration/${FEATURE_NAME^}Configuration.cs"
check_file_exists "$CONFIG_FILE" "Entity configuration exists"

echo ""
echo -e "${YELLOW}Checking Business Logic Layer...${NC}"
SERVICE_INTERFACE="$PROJECT_ROOT/OfferteMakerApi/Service.Contracts/I${FEATURE_NAME^}Service.cs"
check_file_exists "$SERVICE_INTERFACE" "Service interface exists"

SERVICE_IMPL="$PROJECT_ROOT/OfferteMakerApi/Service/${FEATURE_NAME^}Service.cs"
check_file_exists "$SERVICE_IMPL" "Service implementation exists"
if [ -f "$SERVICE_IMPL" ]; then
    check_namespace "$SERVICE_IMPL" "Service namespace"
    check_pattern_in_file "$SERVICE_IMPL" "IRepositoryManager" "Service uses IRepositoryManager"
fi

echo ""
echo -e "${YELLOW}Checking Presentation Layer...${NC}"
CONTROLLER="$PROJECT_ROOT/OfferteMakerApi/OfferteMakerApi.Presentation/Controllers/${FEATURE_NAME^}sController.cs"
check_file_exists "$CONTROLLER" "Controller exists"
if [ -f "$CONTROLLER" ]; then
    check_namespace "$CONTROLLER" "Controller namespace"
    check_pattern_in_file "$CONTROLLER" "\[ApiController\]" "Controller has [ApiController]"
    check_pattern_in_file "$CONTROLLER" "IServiceManager" "Controller uses IServiceManager"
fi

echo ""
echo -e "${YELLOW}Checking DTOs...${NC}"
DTO_DIR="$PROJECT_ROOT/OfferteMakerApi/Shared/DataTransferObjects"
check_file_exists "$DTO_DIR/${FEATURE_NAME^}Dto.cs" "DTO (read) exists"
check_file_exists "$DTO_DIR/Create${FEATURE_NAME^}Dto.cs" "CreateDTO exists"
check_file_exists "$DTO_DIR/Update${FEATURE_NAME^}Dto.cs" "UpdateDTO exists"

echo ""
echo -e "${YELLOW}Checking AutoMapper...${NC}"
MAPPING_FILE="$PROJECT_ROOT/OfferteMakerApi/OfferteMakerApi/MappingProfile.cs"
if [ -f "$MAPPING_FILE" ]; then
    check_pattern_in_file "$MAPPING_FILE" "${FEATURE_NAME^}" "AutoMapper configured for ${FEATURE_NAME^}"
fi

echo ""
echo -e "${YELLOW}Checking Code Quality...${NC}"
if [ -f "$REPO_IMPL" ]; then
    ! grep -q "CompanyEmployees" "$REPO_IMPL" && echo -e "${GREEN}✓${NC} No old namespaces (CompanyEmployees)" || echo -e "${RED}✗${NC} Old namespace found!"
fi

# ==========================================
# RESULTS
# ==========================================

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
TOTAL=$((PASSED + FAILED))
if [ $FAILED -eq 0 ]; then
    echo -e "║  ${GREEN}✓ PASSED: $PASSED/$TOTAL checks${NC}"
    echo "║  Status: Ready for Architect Agent review"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    exit 0
else
    echo -e "║  ${RED}✗ FAILED: $FAILED/$TOTAL checks${NC}"
    echo "║  ${YELLOW}⚠️  Please fix issues and run again${NC}"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Reference:"
    echo "  - ARCHITECT_CHECKLIST.md"
    echo "  - ARCHITECTURE.md"
    echo "  - DEVELOPMENT_GUIDELINES.md"
    echo ""
    exit 1
fi
