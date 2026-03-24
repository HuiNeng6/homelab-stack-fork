#!/usr/bin/env bash
# =============================================================================
# HomeLab Database Backup Script
# Issue: #11
# Backs up PostgreSQL, Redis, and MariaDB to timestamped archives.
#
# Usage:
#   ./scripts/backup-databases.sh [--postgres|--redis|--mariadb|--all]
#   ./scripts/backup-databases.sh --cleanup
#
# Options:
#   --postgres   Backup only PostgreSQL
#   --redis      Backup only Redis
#   --mariadb    Backup only MariaDB
#   --all        Backup all databases (default)
#   --cleanup    Remove backups older than retention period
#
# Environment:
#   BACKUP_DIR       - Backup directory (default: ./backups/databases)
#   RETENTION_DAYS   - Days to keep backups (default: 7)
# =============================================================================

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env}"
BACKUP_DIR="${BACKUP_DIR:-$ROOT_DIR/backups/databases}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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
        set -a
        source "$ENV_FILE"
        set +a
    fi
}

# Create backup directory
prepare_backup_dir() {
    mkdir -p "$BACKUP_DIR"
    log_info "Backup directory: $BACKUP_DIR"
}

# Backup PostgreSQL
backup_postgres() {
    log_step "Backing up PostgreSQL..."
    
    local container="homelab-postgres"
    local user="${POSTGRES_ROOT_USER:-postgres}"
    local backup_file="$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz"
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log_error "PostgreSQL container not running: $container"
        return 1
    fi
    
    # Create backup using pg_dumpall
    log_info "Creating PostgreSQL backup..."
    docker exec "$container" pg_dumpall -U "$user" | gzip > "$backup_file"
    
    local size
    size=$(du -sh "$backup_file" | cut -f1)
    log_info "PostgreSQL backup created: $backup_file ($size)"
    
    # Verify backup
    if gzip -t "$backup_file" 2>/dev/null; then
        log_info "PostgreSQL backup verified successfully"
    else
        log_error "PostgreSQL backup verification failed"
        rm -f "$backup_file"
        return 1
    fi
    
    return 0
}

# Backup Redis
backup_redis() {
    log_step "Backing up Redis..."
    
    local container="homelab-redis"
    local password="${REDIS_PASSWORD:?REDIS_PASSWORD is required}"
    local backup_file="$BACKUP_DIR/redis_${TIMESTAMP}.rdb"
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log_error "Redis container not running: $container"
        return 1
    fi
    
    # Trigger BGSAVE
    log_info "Triggering Redis BGSAVE..."
    docker exec "$container" redis-cli -a "$password" --no-auth-warning BGSAVE
    
    # Wait for BGSAVE to complete
    log_info "Waiting for BGSAVE to complete..."
    local retries=30
    local count=0
    while [[ $count -lt $retries ]]; do
        local bgsave_in_progress
        bgsave_in_progress=$(docker exec "$container" redis-cli -a "$password" --no-auth-warning LASTSAVE)
        sleep 1
        ((count++))
    done
    
    # Copy dump.rdb from container
    docker cp "$container":/data/dump.rdb "$backup_file"
    
    local size
    size=$(du -sh "$backup_file" | cut -f1)
    log_info "Redis backup created: $backup_file ($size)"
    
    return 0
}

# Backup MariaDB
backup_mariadb() {
    log_step "Backing up MariaDB..."
    
    local container="homelab-mariadb"
    local password="${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD is required}"
    local backup_file="$BACKUP_DIR/mariadb_${TIMESTAMP}.sql.gz"
    
    # Check if container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
        log_error "MariaDB container not running: $container"
        return 1
    fi
    
    # Create backup using mariadb-dump
    log_info "Creating MariaDB backup..."
    docker exec "$container" mariadb-dump --all-databases -u root -p"$password" 2>/dev/null | gzip > "$backup_file"
    
    local size
    size=$(du -sh "$backup_file" | cut -f1)
    log_info "MariaDB backup created: $backup_file ($size)"
    
    # Verify backup
    if gzip -t "$backup_file" 2>/dev/null; then
        log_info "MariaDB backup verified successfully"
    else
        log_error "MariaDB backup verification failed"
        rm -f "$backup_file"
        return 1
    fi
    
    return 0
}

# Cleanup old backups
cleanup_old_backups() {
    log_step "Cleaning up old backups..."
    
    local count=0
    
    # Find and delete backups older than retention period
    while IFS= read -r -d '' file; do
        rm -f "$file"
        ((count++))
        log_info "Deleted old backup: $file"
    done < <(find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -print0 2>/dev/null)
    while IFS= read -r -d '' file; do
        rm -f "$file"
        ((count++))
        log_info "Deleted old backup: $file"
    done < <(find "$BACKUP_DIR" -name "*.rdb" -mtime +$RETENTION_DAYS -print0 2>/dev/null)
    
    log_info "Cleaned up $count old backup(s)"
}

# Show backup summary
show_summary() {
    echo ""
    log_info "=========================================="
    log_info "Backup Summary"
    log_info "=========================================="
    echo ""
    echo "Backup directory: $BACKUP_DIR"
    echo "Retention period: $RETENTION_DAYS days"
    echo ""
    echo "Recent backups:"
    ls -lht "$BACKUP_DIR" 2>/dev/null | head -n 10 || echo "  (none)"
    echo ""
    
    # Calculate total size
    local total_size
    total_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
    log_info "Total backup size: $total_size"
    log_info "=========================================="
}

# Create combined archive
create_combined_archive() {
    log_step "Creating combined backup archive..."
    
    local archive_file="$BACKUP_DIR/full_backup_${TIMESTAMP}.tar.gz"
    local temp_dir="$BACKUP_DIR/temp_${TIMESTAMP}"
    
    mkdir -p "$temp_dir"
    
    # Copy individual backups to temp directory
    cp "$BACKUP_DIR"/postgres_${TIMESTAMP}.sql.gz "$temp_dir/" 2>/dev/null || true
    cp "$BACKUP_DIR"/redis_${TIMESTAMP}.rdb "$temp_dir/" 2>/dev/null || true
    cp "$BACKUP_DIR"/mariadb_${TIMESTAMP}.sql.gz "$temp_dir/" 2>/dev/null || true
    
    # Create tar.gz archive
    tar -czf "$archive_file" -C "$temp_dir" .
    rm -rf "$temp_dir"
    
    local size
    size=$(du -sh "$archive_file" | cut -f1)
    log_info "Combined archive created: $archive_file ($size)"
}

# Main
main() {
    local mode="${1:---all}"
    
    load_env
    prepare_backup_dir
    
    case "$mode" in
        --postgres)
            backup_postgres
            ;;
        --redis)
            backup_redis
            ;;
        --mariadb)
            backup_mariadb
            ;;
        --cleanup)
            cleanup_old_backups
            ;;
        --all|*)
            local failed=0
            
            backup_postgres || ((failed++))
            backup_redis || ((failed++))
            backup_mariadb || ((failed++))
            
            if [[ $failed -eq 0 ]]; then
                create_combined_archive
            fi
            
            cleanup_old_backups
            show_summary
            
            if [[ $failed -gt 0 ]]; then
                log_error "$failed backup(s) failed"
                exit 1
            fi
            ;;
    esac
    
    log_info "Backup completed successfully!"
}

main "$@"