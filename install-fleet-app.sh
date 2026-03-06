#!/bin/bash
# Frappe Fleet Management System - Installation Script
# ======================================================
# This script installs the Fleet Management System app on Frappe/ERPNext

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Fleet Management System - Installer${NC}"
echo -e "${GREEN}=========================================${NC}"

# Configuration
FRAPPE_VERSION="${FRAPPE_VERSION:-v15}"
FLEET_APP_REPO="https://github.com/navariltd/Fleet-Management-System.git"
SITE_NAME="${SITE_NAME:-fleetmanagement}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-AdminChangeMe2024!}"

echo -e "${YELLOW}Step 1: Waiting for Frappe to be ready...${NC}"
sleep 30

echo -e "${YELLOW}Step 2: Getting into Frappe container...${NC}"
docker exec -it frappe_backend bench version

echo -e "${YELLOW}Step 3: Creating site if not exists...${NC}"
docker exec -it frappe_backend bench new-site \
  --db-name erpnext \
  --db-password "${MARIADB_PASSWORD:-ChangeMeUserPassword2024!}" \
  --admin-password "${ADMIN_PASSWORD}" \
  --root-login root \
  --root-password "${MARIADB_ROOT_PASSWORD:-ChangeMeRootPassword2024!}" \
  "${SITE_NAME}.local" || echo "Site may already exist"

echo -e "${YELLOW}Step 4: Installing ERPNext...${NC}"
docker exec -it frappe_backend bench --site "${SITE_NAME}.local" install-app erpnext || echo "ERPNext may already be installed"

echo -e "${YELLOW}Step 5: Installing Fleet Management System app...${NC}"
# Clone the Fleet Management System app
docker exec -it frappe_backend bench get-app \
  --overwrite \
  "${FLEET_APP_REPO}" || echo "App clone may have issues"

echo -e "${YELLOW}Step 6: Installing Fleet app to site...${NC}"
docker exec -it frappe_backend bench --site "${SITE_NAME}.local" install-app vsd_fleet_ms || echo "App installation may have issues"

echo -e "${YELLOW}Step 7: Running migrations...${NC}"
docker exec -it frappe_backend bench --site "${SITE_NAME}.local" migrate

echo -e "${YELLOW}Step 8: Building assets...${NC}"
docker exec -it frappe_backend bench --site "${SITE_NAME}.local" build

echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${GREEN}Access your Fleet Management System:${NC}"
echo -e "  URL: http://${SERVER_IP:-localhost}"
echo -e "  Site: ${SITE_NAME}.local"
echo -e "  Admin Password: ${ADMIN_PASSWORD}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Configure your DNS/hosts file"
echo -e "  2. Set up Transport Settings in ERPNext"
echo -e "  3. Configure master data (vehicles, drivers, routes)"
echo ""
