#!/bin/bash
# =============================================================================
# HomeLab PostgreSQL Init Script
# Issue: #11
# Creates per-service databases and users on first container start.
#
# IDEMPOTENT: Safe to re-run — skips existing users/databases.
# =============================================================================

set -euo pipefail

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# =============================================================================
# Helper Functions (Idempotent)
# =============================================================================

# Create user if not exists
create_user() {
    local user="$1"
    local pass="$2"
    
    # Check if user exists
    if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
        -tc "SELECT 1 FROM pg_roles WHERE rolname = '${user}'" | grep -q 1; then
        log_info "User '${user}' already exists, skipping..."
    else
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            -c "CREATE USER ${user} WITH PASSWORD '${pass}';"
        log_info "Created user: ${user}"
    fi
}

# Create database if not exists with proper owner
create_database() {
    local db="$1"
    local owner="$2"
    
    # Check if database exists
    if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
        -tc "SELECT 1 FROM pg_database WHERE datname = '${db}'" | grep -q 1; then
        log_info "Database '${db}' already exists, skipping..."
    else
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            -c "CREATE DATABASE ${db} OWNER ${owner} ENCODING 'UTF8';"
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" \
            -c "GRANT ALL PRIVILEGES ON DATABASE ${db} TO ${owner};"
        log_info "Created database: ${db} (owner: ${owner})"
    fi
}

# Create extension if not exists
create_extension() {
    local db="$1"
    local ext="$2"
    
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "${db}" \
        -c "CREATE EXTENSION IF NOT EXISTS \"${ext}\";" 2>/dev/null || true
    log_info "Ensured extension '${ext}' in database '${db}'"
}

# =============================================================================
# Create Service Databases
# =============================================================================

log_info "Starting database initialization..."
log_info "PostgreSQL version: $(psql --version)"

# Nextcloud
log_info "Setting up Nextcloud database..."
create_user "nextcloud" "${NEXTCLOUD_DB_PASSWORD:-changeme_nextcloud}"
create_database "nextcloud" "nextcloud"

# Gitea
log_info "Setting up Gitea database..."
create_user "gitea" "${GITEA_DB_PASSWORD:-changeme_gitea}"
create_database "gitea" "gitea"

# Outline
log_info "Setting up Outline database..."
create_user "outline" "${OUTLINE_DB_PASSWORD:-changeme_outline}"
create_database "outline" "outline"
create_extension "outline" "uuid-ossp"

# Authentik
log_info "Setting up Authentik database..."
create_user "authentik" "${AUTHENTIK_DB_PASSWORD:-changeme_authentik}"
create_database "authentik" "authentik"

# Grafana
log_info "Setting up Grafana database..."
create_user "grafana" "${GRAFANA_DB_PASSWORD:-changeme_grafana}"
create_database "grafana" "grafana"

# Vaultwarden (optional, uses SQLite by default)
log_info "Setting up Vaultwarden database..."
create_user "vaultwarden" "${VAULTWARDEN_DB_PASSWORD:-changeme_vaultwarden}"
create_database "vaultwarden" "vaultwarden"

# BookStack
log_info "Setting up BookStack database..."
create_user "bookstack" "${BOOKSTACK_DB_PASSWORD:-changeme_bookstack}"
create_database "bookstack" "bookstack"

# =============================================================================
# Summary
# =============================================================================

log_info "=========================================="
log_info "Database initialization complete!"
log_info "Created databases for:"
log_info "  - nextcloud"
log_info "  - gitea"
log_info "  - outline"
log_info "  - authentik"
log_info "  - grafana"
log_info "  - vaultwarden"
log_info "  - bookstack"
log_info "=========================================="