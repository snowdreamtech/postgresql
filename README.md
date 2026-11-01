# PostgreSQL

[![CI Pipeline](https://img.shields.io/github/actions/workflow/status/snowdreamtech/postgresql/ci.yml?branch=main&label=CI%20Pipeline)](https://github.com/snowdreamtech/postgresql/actions/workflows/ci.yml)
[![CD Pipeline](https://img.shields.io/github/actions/workflow/status/snowdreamtech/postgresql/cd.yml?branch=main&label=CD%20Pipeline)](https://github.com/snowdreamtech/postgresql/actions/workflows/cd.yml)
[![CodeQL](https://img.shields.io/github/actions/workflow/status/snowdreamtech/postgresql/codeql.yml?branch=main&label=CodeQL&logo=github)](https://github.com/snowdreamtech/postgresql/actions/workflows/codeql.yml)
[![Security Audit](https://img.shields.io/badge/Security-Zizmor%20%7C%20Trivy%20%7C%20Gitleaks-brightgreen)](https://github.com/snowdreamtech/postgresql/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/MIT)
![Docker Image Version](https://img.shields.io/docker/v/snowdreamtech/postgresql)
![Docker Image Size](https://img.shields.io/docker/image-size/snowdreamtech/postgresql/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/snowdreamtech/postgresql)
![Docker Stars](https://img.shields.io/docker/stars/snowdreamtech/postgresql)

[English](README.md) | [简体中文](README_zh-CN.md)

Docker image for PostgreSQL providing standardized container foundations with flexible entrypoint systems, multi-architecture support, and consistent configuration patterns across Alpine, Debian, and Rocky Linux distributions.

## Overview

The PostgreSQL container provides:

- **Standardized Dockerfiles** with OCI annotations and best practices
- **Flexible entrypoint system** supporting custom initialization scripts
- **Consistent environment variable configuration** across all variants
- **Multi-architecture support** for diverse hardware platforms
- **User/group management** with PUID/PGID support for permission handling
- **Three distribution variants**: Alpine (lightweight), Debian (default/widely-compatible), Rocky (enterprise)

## Quick Start

```bash
# Pull and run the default Debian variant
docker pull snowdreamtech/postgresql:debian
docker run -d --name=postgresql -p 5432:5432 -e TZ=Asia/Shanghai snowdreamtech/postgresql:debian

# Or use docker compose
docker compose up -d
```

## Distribution Variants

### Debian (Default)

The recommended variant for most use cases, providing wide compatibility and extensive package availability.

```bash
docker run -d \
  --name=postgresql \
  -p 5432:5432 \
  -e TZ=Asia/Shanghai \
  --restart unless-stopped \
  snowdreamtech/postgresql:debian
```

**Supported Architectures**: amd64, arm32v7, arm64, ppc64le, riscv64, s390x

**Base Image**: `snowdreamtech/debian:13.6.0`

### Alpine

Lightweight variant optimized for minimal image size and fast startup times.

```bash
docker run -d \
  --name=postgresql \
  -p 5432:5432 \
  -e TZ=Asia/Shanghai \
  --restart unless-stopped \
  snowdreamtech/postgresql:alpine
```

**Supported Architectures**: 386, amd64, arm/v6, arm/v7, arm64, ppc64le, riscv64, s390x

**Base Image**: `snowdreamtech/alpine:3.24.1`

### Rocky

Enterprise Linux variant based on Rocky Linux, suitable for enterprise environments requiring RHEL compatibility.

```bash
docker run -d \
  --name=postgresql \
  -p 5432:5432 \
  -e TZ=Asia/Shanghai \
  --restart unless-stopped \
  snowdreamtech/postgresql:rocky
```

**Supported Architectures**: amd64, arm64, ppc64le, s390x

**Base Image**: `snowdreamtech/rocky:10.2.0`

## Build from Source

Clone the repository and build using Docker Buildx:

```bash
# Clone repository
git clone https://github.com/snowdreamtech/postgresql.git
cd postgresql

# Build specific variant (e.g., Debian)
docker build -t snowdreamtech/postgresql:debian ./docker/debian/

# Multi-platform build
docker buildx build \
  --platform=linux/amd64,linux/arm64 \
  -t snowdreamtech/postgresql:debian \
  ./docker/debian/ \
  --load
```

## Environment Variables

All variants support the following environment variables for runtime configuration:

| Variable | Default | Description |
|----------|---------|-------------|
| `KEEPALIVE` | `1` | Keep container running (1=enabled, 0=disabled) |
| `CAP_NET_BIND_SERVICE` | `0` | Enable binding to privileged ports (<1024) |
| `LANG` | `C.UTF-8` | Locale setting for UTF-8 character support |
| `UMASK` | `022` | Default file creation mask |
| `DEBUG` | `false` | Enable debug output in entrypoint scripts |
| `PGID` | `0` | Primary group ID for custom user creation |
| `PUID` | `0` | User ID for custom user creation |
| `USER` | `root` | Username for custom user creation |
| `WORKDIR` | `/root` | Working directory path |
| `TZ` | - | Timezone (e.g., `Asia/Shanghai`, `America/New_York`) |
| `POSTGRES_ROOT_PWD` | Random | Password for default `postgres` user |
| `POSTGRES_USER` | - | Custom PostgreSQL user to create |
| `POSTGRES_PWD` | Random | Password for custom PostgreSQL user |
| `POSTGRES_DB` | - | Database to create and grant privileges to `POSTGRES_USER` |
| `POSTGRES_PORT` | `5432` | PostgreSQL listening port |
| `POSTGRES_HOST_AUTHMETHOD` | `trust` | Client authentication method in pg_hba.conf |
| `POSTGRES_DISALLOW_USER_LOGIN_REMOTELY` | `0` | Disallow remote user logins when set to `1` |
| `POSTGRES_MAX_CONNECTIONS` | `0` | Maximum connections setting in postgresql.conf |

**Debian-specific**:

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBIAN_FRONTEND` | `noninteractive` | Debian package installation mode |

## Docker Compose Examples

### Simple Configuration

```yaml
services:
  postgresql:
    image: snowdreamtech/postgresql:debian
    container_name: postgresql
    ports:
      - "5432:5432"
    environment:
      - TZ=Asia/Shanghai
      - POSTGRES_ROOT_PWD=my_secret_password
    restart: unless-stopped
```

### Advanced Configuration

```yaml
services:
  postgresql:
    image: snowdreamtech/postgresql:debian
    container_name: postgresql
    ports:
      - "5432:5432"
    environment:
      - TZ=Asia/Shanghai
      - DEBUG=true
      - KEEPALIVE=1
      - POSTGRES_ROOT_PWD=root_secret
      - POSTGRES_USER=appuser
      - POSTGRES_PWD=user_secret
      - POSTGRES_DB=appdb
    volumes:
      - /path/to/data:/var/lib/postgresql/data
    restart: unless-stopped
```

## Semantic Versioning Tags

Images follow semantic versioning with the format: `{major}.{minor}.{patch}-{variant}`

Examples:

- `snowdreamtech/postgresql:17.11.0-debian`
- `snowdreamtech/postgresql:18.6.0-alpine`
- `snowdreamtech/postgresql:18.6.0-rocky`

This format allows:

- **Full version pinning**: `<version>-debian` (exact version)
- **Variant latest tag**: `latest-debian` (tracks most recent release for Debian)
- **Global latest tag**: `latest` (tracks most recent release, defaults to Debian)

## Architecture Support

Each distribution variant supports multiple CPU architectures for deployment across diverse hardware platforms:

| Variant | Architectures |
|---------|---------------|
| **Debian** | amd64, arm32v7, arm64, ppc64le, riscv64, s390x |
| **Alpine** | 386, amd64, arm/v6, arm/v7, arm64, ppc64le, riscv64, s390x |
| **Rocky** | amd64, arm64, ppc64le, s390x |

Docker automatically selects the appropriate architecture for your platform when pulling images.

## Entrypoint System

The PostgreSQL container includes a flexible entrypoint system that executes custom initialization scripts before starting PostgreSQL.

### How It Works

1. The `docker-entrypoint.sh` script runs at container startup
2. It executes all executable scripts in `/usr/local/bin/entrypoint.d/` in lexical order
3. Each script receives the container's command-line arguments
4. If any script fails, the container stops (fail-fast behavior)

### Adding Custom Initialization

Create custom initialization scripts in your derived Dockerfile:

```dockerfile
FROM snowdreamtech/postgresql:debian

# Add your custom initialization script
COPY my-init.sh /usr/local/bin/entrypoint.d/20-my-init.sh
RUN chmod +x /usr/local/bin/entrypoint.d/20-my-init.sh

# Your application setup
COPY app /app
CMD ["/app/start.sh"]
```

### Debug Mode

Enable debug output to troubleshoot entrypoint execution:

```bash
docker run -e DEBUG=true snowdreamtech/postgresql:debian
```

## Contact

* Email: <sn0wdr1am@qq.com>
* QQ: 3217680847
* QQ群: 949022145
* WeChat/微信群: sn0wdr1am

## License

MIT
