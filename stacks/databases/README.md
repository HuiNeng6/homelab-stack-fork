# Database Layer

> **Issue: #11** — PostgreSQL + Redis + MariaDB 共享实例

Shared database services for all HomeLab stacks. This layer provides centralized, multi-tenant database services that can be used by Nextcloud, Outline, Gitea, Authentik, Grafana, and other services.

## Services

| Service | Version | Container | Port | Purpose |
|---------|---------|-----------|------|---------|
| PostgreSQL | 16.4-alpine | `homelab-postgres` | 5432 | Primary relational database (multi-tenant) |
| Redis | 7.4.0-alpine | `homelab-redis` | 6379 | Cache & session store |
| MariaDB | 11.5.2 | `homelab-mariadb` | 3306 | MySQL-compatible database |
| pgAdmin | 8.11 | `homelab-pgadmin` | 80 (via Traefik) | PostgreSQL management UI |
| Redis Commander | 0.9.0 | `homelab-redis-commander` | 8081 (via Traefik) | Redis management UI |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        HomeLab Services                              │
│  (Nextcloud, Gitea, Outline, Authentik, Grafana, Vaultwarden, etc.) │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        databases network                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │
│  │ PostgreSQL  │  │    Redis    │  │   MariaDB   │                  │
│  │   :5432     │  │   :6379     │  │   :3306     │                  │
│  └─────────────┘  └─────────────┘  └─────────────┘                  │
│                                                                      │
│  ┌─────────────┐  ┌─────────────────┐                               │
│  │   pgAdmin   │  │ Redis Commander │                               │
│  │   :80       │  │     :8081       │                               │
│  └──────┬──────┘  └───────┬─────────┘                               │
└─────────┼─────────────────┼─────────────────────────────────────────┘
          │                 │
          ▼                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         proxy network                                │
│                    (Traefik reverse proxy)                           │
│                                                                      │
│  pgadmin.${DOMAIN}    → pgAdmin                                      │
│  redis-cmd.${DOMAIN}  → Redis Commander                              │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# 1. Navigate to database stack
cd stacks/databases

# 2. Copy and configure environment
cp .env.example .env
nano .env  # Edit with your passwords and domain

# 3. Start the stack
docker compose up -d

# 4. Verify all services are healthy
docker compose ps

# 5. Initialize databases (if not auto-initialized)
../../scripts/init-databases.sh
```

## Prerequisites

1. **Base Infrastructure** — Traefik and `proxy` network must be running
2. **Domain** — A domain configured with DNS pointing to your server
3. **Passwords** — Strong, unique passwords for all services

## Configuration

### Required Environment Variables

| Variable | Description |
|----------|-------------|
| `DOMAIN` | Your domain (e.g., `example.com`) |
| `POSTGRES_ROOT_PASSWORD` | PostgreSQL root password |
| `REDIS_PASSWORD` | Redis AUTH password |
| `MARIADB_ROOT_PASSWORD` | MariaDB root password |
| `PGADMIN_PASSWORD` | pgAdmin login password |

### Per-Service Database Passwords

| Variable | Default User | Database |
|----------|--------------|----------|
| `NEXTCLOUD_DB_PASSWORD` | `nextcloud` | `nextcloud` |
| `GITEA_DB_PASSWORD` | `gitea` | `gitea` |
| `OUTLINE_DB_PASSWORD` | `outline` | `outline` |
| `AUTHENTIK_DB_PASSWORD` | `authentik` | `authentik` |
| `GRAFANA_DB_PASSWORD` | `grafana` | `grafana` |
| `VAULTWARDEN_DB_PASSWORD` | `vaultwarden` | `vaultwarden` |
| `BOOKSTACK_DB_PASSWORD` | `bookstack` | `bookstack` |

## Service Databases (Auto-created)

The init script (`initdb/01-init-databases.sh`) automatically creates these databases on first start:

### PostgreSQL Databases

| Service | Database | User | Extensions |
|---------|----------|------|------------|
| Nextcloud | `nextcloud` | `nextcloud` | - |
| Gitea | `gitea` | `gitea` | - |
| Outline | `outline` | `outline` | `uuid-ossp` |
| Authentik | `authentik` | `authentik` | - |
| Grafana | `grafana` | `grafana` | - |
| Vaultwarden | `vaultwarden` | `vaultwarden` | - |
| BookStack | `bookstack` | `bookstack` | - |

### MariaDB Databases

| Service | Database | User |
|---------|----------|------|
| BookStack | `bookstack` | `bookstack` |
| Nextcloud (alt) | `nextcloud` | `nextcloud_mysql` |

## Connection Strings

### PostgreSQL

```bash
# Nextcloud
postgresql://nextcloud:<NEXTCLOUD_DB_PASSWORD>@homelab-postgres:5432/nextcloud

# Gitea
postgresql://gitea:<GITEA_DB_PASSWORD>@homelab-postgres:5432/gitea

# Outline
postgresql://outline:<OUTLINE_DB_PASSWORD>@homelab-postgres:5432/outline

# Authentik
postgresql://authentik:<AUTHENTIK_DB_PASSWORD>@homelab-postgres:5432/authentik

# Grafana
postgresql://grafana:<GRAFANA_DB_PASSWORD>@homelab-postgres:5432/grafana

# Vaultwarden
postgresql://vaultwarden:<VAULTWARDEN_DB_PASSWORD>@homelab-postgres:5432/vaultwarden

# BookStack
postgresql://bookstack:<BOOKSTACK_DB_PASSWORD>@homelab-postgres:5432/bookstack
```

### Redis

Redis uses database numbers for service isolation:

```bash
# DB 0 — Authentik
redis://:${REDIS_PASSWORD}@homelab-redis:6379/0

# DB 1 — Outline
redis://:${REDIS_PASSWORD}@homelab-redis:6379/1

# DB 2 — Gitea
redis://:${REDIS_PASSWORD}@homelab-redis:6379/2

# DB 3 — Nextcloud
redis://:${REDIS_PASSWORD}@homelab-redis:6379/3

# DB 4 — Grafana sessions
redis://:${REDIS_PASSWORD}@homelab-redis:6379/4
```

### MariaDB

```bash
# BookStack
mysql://bookstack:<BOOKSTACK_DB_PASSWORD>@homelab-mariadb:3306/bookstack

# Nextcloud (MySQL alternative)
mysql://nextcloud_mysql:<NEXTCLOUD_DB_PASSWORD>@homelab-mariadb:3306/nextcloud
```

## Management UIs

### pgAdmin

- **URL**: `https://pgadmin.${DOMAIN}`
- **Login**: Email and password from `PGADMIN_EMAIL` / `PGADMIN_PASSWORD`

**Adding a Server:**
1. Right-click "Servers" → "Register" → "Server"
2. General tab: Name = "HomeLab"
3. Connection tab:
   - Host: `homelab-postgres`
   - Port: `5432`
   - Username: `postgres`
   - Password: `POSTGRES_ROOT_PASSWORD`

### Redis Commander

- **URL**: `https://redis-cmd.${DOMAIN}`
- **Login**: User and password from `REDIS_COMMANDER_USER` / `REDIS_COMMANDER_PASSWORD`

## Health Checks

All services include health checks:

```bash
# Check all services
docker compose ps

# Check specific service health
docker inspect --format='{{.State.Health.Status}}' homelab-postgres
docker inspect --format='{{.State.Health.Status}}' homelab-redis
docker inspect --format='{{.State.Health.Status}}' homelab-mariadb
```

## Backup & Restore

### Create Backup

```bash
# Backup all databases
./scripts/backup-databases.sh

# Backup specific database
./scripts/backup-databases.sh --postgres
./scripts/backup-databases.sh --redis
./scripts/backup-databases.sh --mariadb

# Cleanup old backups (retention: 7 days by default)
./scripts/backup-databases.sh --cleanup
```

### Restore PostgreSQL

```bash
# Restore from backup
gunzip -c backups/databases/postgres_YYYYMMDD_HHMMSS.sql.gz | \
  docker exec -i homelab-postgres psql -U postgres
```

### Restore Redis

```bash
# Stop Redis, restore RDB, start Redis
docker compose stop redis
docker cp backups/databases/redis_YYYYMMDD_HHMMSS.rdb homelab-redis:/data/dump.rdb
docker compose start redis
```

### Restore MariaDB

```bash
# Restore from backup
gunzip -c backups/databases/mariadb_YYYYMMDD_HHMMSS.sql.gz | \
  docker exec -i homelab-mariadb mariadb -u root -p"${MARIADB_ROOT_PASSWORD}"
```

## Network Isolation

Database services are **NOT** exposed to the host machine. They are only accessible:

1. **Internally** — Via the `databases` Docker network
2. **Management UIs** — Via Traefik on the `proxy` network

```bash
# Services on databases network only
docker network inspect databases

# Management UIs on both networks
docker network inspect proxy | grep -A5 pgadmin
docker network inspect proxy | grep -A5 redis-commander
```

## Resource Limits

Default resource limits:

| Service | Memory Limit | Memory Reservation |
|---------|--------------|-------------------|
| PostgreSQL | 1GB | 256MB |
| Redis | 768MB | 128MB |
| MariaDB | 1GB | 256MB |
| pgAdmin | 512MB | 128MB |
| Redis Commander | 256MB | 64MB |

Adjust in `docker-compose.yml` as needed.

## Troubleshooting

### PostgreSQL won't start

```bash
# Check logs
docker logs homelab-postgres

# Common issues:
# - Permissions on volume
# - Corrupted data directory
docker volume rm homelab-postgres-data  # WARNING: deletes all data
```

### Redis AUTH fails

```bash
# Verify password
docker exec homelab-redis redis-cli -a "${REDIS_PASSWORD}" ping

# Check if AUTH is required
docker exec homelab-redis redis-cli CONFIG GET requirepass
```

### MariaDB connection refused

```bash
# Wait for initialization (can take 30+ seconds)
docker logs -f homelab-mariadb

# Check health
docker exec homelab-mariadb healthcheck.sh --connect
```

### pgAdmin shows "connection refused"

```bash
# Verify PostgreSQL is healthy
docker inspect homelab-postgres --format='{{.State.Health.Status}}'

# Check network connectivity
docker exec homelab-pgadmin ping homelab-postgres
```

## Security Notes

1. **Change all passwords** — Use strong, unique passwords
2. **No host exposure** — Databases are not exposed to host ports
3. **Internal network** — Database services communicate via isolated Docker network
4. **TLS enabled** — Management UIs are served over HTTPS via Traefik
5. **Redis AUTH** — Password authentication is required for all Redis connections

## Files

```
stacks/databases/
├── docker-compose.yml        # Main compose file
├── .env.example              # Environment template
├── initdb/
│   └── 01-init-databases.sh  # PostgreSQL init script (idempotent)
├── initdb-mysql/
│   └── 01-init-databases.sql # MariaDB init script
└── README.md                 # This file

scripts/
├── init-databases.sh         # Manual init script
└── backup-databases.sh       # Backup script
```