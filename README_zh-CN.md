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

Docker PostgreSQL 镜像，提供标准化的容器基础，具有灵活的入口点系统、多架构支持以及跨 Alpine、Debian 和 Rocky Linux 发行版的一致配置模式。

## 概述

PostgreSQL 容器提供：

- **标准化的 Dockerfile**，包含 OCI 注解和最佳实践
- **灵活的入口点系统**，支持自定义初始化脚本
- **一致的环境变量配置**，适用于所有变体
- **多架构支持**，适用于多样化的硬件平台
- **用户/组管理**，支持 PUID/PGID 进行权限处理
- **三种发行版变体**：Alpine（轻量级）、Debian（默认/广泛兼容）、Rocky（企业级）

## 快速开始

```bash
# 拉取并运行默认的 Debian 变体
docker pull snowdreamtech/postgresql:debian
docker run -d --name=postgresql -p 5432:5432 -e TZ=Asia/Shanghai snowdreamtech/postgresql:debian

# 或使用 docker compose
docker compose up -d
```

## 发行版变体

### Debian（默认）

推荐用于大多数用例的变体，提供广泛的兼容性和丰富的软件包可用性。

```bash
docker run -d \
  --name=postgresql \
  -p 5432:5432 \
  -e TZ=Asia/Shanghai \
  --restart unless-stopped \
  snowdreamtech/postgresql:debian
```

**支持的架构**：amd64、arm32v7、arm64、ppc64le、riscv64、s390x

**基础镜像**：`snowdreamtech/debian:13.6.0`

### Alpine

轻量级变体，针对最小镜像大小和快速启动时间进行了优化。

```bash
docker run -d \
  --name=postgresql \
  -p 5432:5432 \
  -e TZ=Asia/Shanghai \
  --restart unless-stopped \
  snowdreamtech/postgresql:alpine
```

**支持的架构**：386、amd64、arm/v6、arm/v7、arm64、ppc64le、riscv64、s390x

**基础镜像**：`snowdreamtech/alpine:3.24.1`

### Rocky

基于 Rocky Linux 的企业级 Linux 变体，适用于需要 RHEL 兼容性的企业环境。

```bash
docker run -d \
  --name=postgresql \
  -p 5432:5432 \
  -e TZ=Asia/Shanghai \
  --restart unless-stopped \
  snowdreamtech/postgresql:rocky
```

**支持的架构**：amd64、arm64、ppc64le、s390x

**基础镜像**：`snowdreamtech/rocky:10.2.0`

## 从源码构建

克隆仓库并使用 Docker Buildx 构建：

```bash
# 克隆仓库
git clone https://github.com/snowdreamtech/postgresql.git
cd postgresql

# 构建特定变体（例如 Debian）
docker build -t snowdreamtech/postgresql:debian ./docker/debian/

# 多平台构建
docker buildx build \
  --platform=linux/amd64,linux/arm64 \
  -t snowdreamtech/postgresql:debian \
  ./docker/debian/ \
  --load
```

## 环境变量

所有变体均支持以下环境变量进行运行时配置：

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `KEEPALIVE` | `1` | 保持容器运行（1=启用，0=禁用） |
| `CAP_NET_BIND_SERVICE` | `0` | 允许绑定特权端口（<1024） |
| `LANG` | `C.UTF-8` | 区域设置，支持 UTF-8 字符 |
| `UMASK` | `022` | 默认文件创建掩码 |
| `DEBUG` | `false` | 在入口点脚本中启用调试输出 |
| `PGID` | `0` | 自定义用户创建的主组 ID |
| `PUID` | `0` | 自定义用户创建的用户 ID |
| `USER` | `root` | 自定义用户创建的用户名 |
| `WORKDIR` | `/root` | 工作目录路径 |
| `TZ` | - | 时区（例如 `Asia/Shanghai`、`America/New_York`） |
| `POSTGRES_ROOT_PWD` | 随机生成 | 默认 `postgres` 超级用户的密码 |
| `POSTGRES_USER` | - | 要创建的自定义 PostgreSQL 用户名 |
| `POSTGRES_PWD` | 随机生成 | 自定义 PostgreSQL 用户的密码 |
| `POSTGRES_DB` | - | 要创建并授权给 `POSTGRES_USER` 的数据库名 |
| `POSTGRES_PORT` | `5432` | PostgreSQL 监听端口 |
| `POSTGRES_HOST_AUTHMETHOD` | `trust` | pg_hba.conf 中的客户端认证方法 |
| `POSTGRES_DISALLOW_USER_LOGIN_REMOTELY` | `0` | 设为 `1` 时禁止远程用户登录 |
| `POSTGRES_MAX_CONNECTIONS` | `0` | postgresql.conf 中的最大连接数设置 |

**Debian 专属**：

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `DEBIAN_FRONTEND` | `noninteractive` | Debian 软件包安装模式 |

## Docker Compose 示例

### 简单配置

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

### 高级配置

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

## 语义化版本标签

镜像遵循语义化版本控制，格式为：`{major}.{minor}.{patch}-{variant}`

示例：

- `snowdreamtech/postgresql:17.11.0-debian`
- `snowdreamtech/postgresql:18.6.0-alpine`
- `snowdreamtech/postgresql:18.6.0-rocky`

此格式允许：

- **完整版本固定**：`<version>-debian`（精确版本）
- **变体最新标签**：`latest-debian`（跟踪 Debian 最新版本）
- **全局最新标签**：`latest`（跟踪最新版本，默认指向 Debian）

## 架构支持

每个发行版变体都支持多种 CPU 架构，以便跨多样化的硬件平台进行部署：

| 变体 | 架构 |
|------|------|
| **Debian** | amd64、arm32v7、arm64、ppc64le、riscv64、s390x |
| **Alpine** | 386、amd64、arm/v6、arm/v7、arm64、ppc64le、riscv64、s390x |
| **Rocky** | amd64、arm64、ppc64le、s390x |

拉取镜像时，Docker 会自动为您的平台选择适当的架构。

## 入口点系统

PostgreSQL 镜像包含灵活的入口点系统，在启动 PostgreSQL 前执行自定义初始化脚本。

### 工作原理

1. `docker-entrypoint.sh` 脚本在容器启动时运行
2. 它按字典顺序执行 `/usr/local/bin/entrypoint.d/` 中的所有可执行脚本
3. 每个脚本都会接收容器的命令行参数
4. 如果任何脚本失败，容器将停止（快速失败行为）

### 添加自定义初始化

在派生的 Dockerfile 中创建自定义初始化脚本：

```dockerfile
FROM snowdreamtech/postgresql:debian

# 添加自定义初始化脚本
COPY my-init.sh /usr/local/bin/entrypoint.d/20-my-init.sh
RUN chmod +x /usr/local/bin/entrypoint.d/20-my-init.sh

# 应用程序设置
COPY app /app
CMD ["/app/start.sh"]
```

### 调试模式

启用调试输出以排查入口点执行问题：

```bash
docker run -e DEBUG=true snowdreamtech/postgresql:debian
```

## 联系方式

* 邮箱: <sn0wdr1am@qq.com>
* QQ: 3217680847
* QQ群: 949022145
* WeChat/微信群: sn0wdr1am

## 许可协议

MIT
