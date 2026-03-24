#!/usr/bin/env bash
# =============================================================================
# HomeLab Database Initialization Script
# Issue: #11
# Manually initialize all databases in the shared database layer.
#
# Usage:
#   ./scripts/init-databases.sh [--force]
#
# Options:
#   --force  Re-run initialization even if databases exist
#
# Prerequisites:
#   - Database containers must be running
#   - .env file must be configured with all passwords
# =============================================================================

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_step()  { echo -e "${BLUE}[STEP]${NC} $*"; }

# Load environment
load_env() {
    if [[ -f "$ENV_FILE" ]]; then
        log_info "Loading environment from $ENV_FILE"
        set -a
        source "$ENV_FILE"
        set +a
    else
        log_error "Environment file not found: $ENV_FILE"
        log_error "Please copy .env.example to .env and configure it"
        exit 1
    fi
}

# Check if containers are running
check_containers() {
    log_step "Checking database containers..."
    
    local containers=("homelab-postgres" "homelab-redis" "homelab-mariadb")
    local missing=()
    
    for container in "${containers[@]}"; do
        if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            missing+=("$container")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing running containers: ${missing[*]}"
        log_error "Please start the database stack first: cd stacks/databases && docker compose up -d"
        exit 1
    fi
    
    log_info "All database containers are running"
}

# Initialize PostgreSQL databases
init_postgres() {
    log_step "Initializing PostgreSQL databases..."
    
    local postgres_user="${POSTGRES_ROOT_USER:-postgres}"
    local databases=("nextcloud" "gitea" "outline" "authentik" "grafana" "vaultwarden" "bookstack")
    
    for db in "${databases[@]}"; do
        local db_password_var="${db^^}_DB_PASSWORD"
        local db_password="${!db_password_var:-changeme_${db}}"
        
        # Check if database exists
        if docker exec homelab-postgres psql -U "$postgres_user" -lqt | cut -d \| -f 1 | grep -qw "$db"; then
            log_info "PostgreSQL database '$db' already exists"
        else
            log_info "Creating PostgreSQL database '$db'..."
            docker exec homelab-postgres psql -U "$postgres_user" -c "CREATE USER $db WITH PASSWORD '${db_password}';" 2>/dev/null || true
            docker exec homelab-postgres psql -U "$postgres_user" -c "CREATE DATABASE $db OWNER $db ENCODING 'UTF8';"
            docker exec homelab-postgres psql -U "$postgres_user" -c "GRANT ALL PRIVILEGES ON DATABASE $db TO $db;"
            log_info "Created PostgreSQL database: $db"
        fi
    done
    
    # Install uuid-ossp extension for Outline
    log_info "Installing uuid-ossp extension for Outline..."
    docker exec homelab-postgres psql -U "$postgres_user" -d outline -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" 2>/dev/null || true
    
    log_info "PostgreSQL initialization complete"
}

# Initialize MariaDB databases
init_mariadb() {
    log_step "Initializing MariaDB databases..."
    
    local root_password="${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD is required}"
    
    # BookStack
    log_info "Setting up BookStack MySQL database..."
    docker exec homelab-mariadb mariadb -u root -p"$root_password" -e "
        CREATE DATABASE IF NOT EXISTS bookstack CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS 'bookstack'@'%' IDENTIFIED BY '${BOOKSTACK_DB_PASSWORD:-changeme}';
        GRANT ALL PRIVILEGES ON bookstack.* TO 'bookstack'@'%';
        FLUSH PRIVILEGES;
    " 2>/dev/null
    
    log_info "MariaDB initialization complete"
}

# Verify Redis
verify_redis() {
    log_step "Verifying Redis connection..."
    
    if docker exec homelab-redis redis-cli -a "${REDIS_PASSWORD}" --no-auth-warning ping | grep -q "PONG"; then
        log_info "Redis is responding correctly"
    else
        log_error "Redis is not responding"
        exit 1
    fi
}

# Show summary
show_summary() {
    echo ""
    log_info "=========================================="
    log_info "Database Initialization Summary"
    log_info "=========================================="
    echo ""
    echo "PostgreSQL Databases:"
    echo "  - nextcloud    (user: nextcloud)"
    echo "  - gitea        (user: gitea)"
    echo "  - outline      (user: outline, +uuid-ossp)"
    echo "  - authentik    (user: authentik)"
    echo "  - grafana      (user: grafana)"
    echo "  - vaultwarden  (user: vaultwarden)"
    echo "  - bookstack    (user: bookstack)"
    echo ""
    echo "MariaDB Databases:"
    echo "  - bookstack    (user: bookstack)"
    echo ""
    echo "Redis DB Allocation:"
    echo "  - DB 0: Authentik"
    echo "  - DB 1: Outline"
    echo "  - DB 2: Gitea"
    echo "  - DB 3: Nextcloud"
    echo "  - DB 4: Grafana sessions"
    echo ""
    log_info "=========================================="
}

# Main
main() {
    log_info "Starting database initialization..."
    
    load_env
    check_containers
    init_postgres
    init_mariadb
    verify_redis
    show_summary
    
    log_info "Database initialization completed successfully!"
}

main "$@"