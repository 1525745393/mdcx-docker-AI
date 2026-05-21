# MDCx Docker 项目 Code Wiki

## 目录

- [项目概述](#项目概述)
- [整体架构](#整体架构)
- [主要模块职责](#主要模块职责)
- [镜像类型和构建流程](#镜像类型和构建流程)
- [关键类与函数说明](#关键类与函数说明)
- [依赖关系](#依赖关系)
- [项目运行方式](#项目运行方式)
- [CI/CD 工作流](#cicd-工作流)

---

## 项目概述

**MDCx Docker** 是一个将 [MDCx](https://github.com/Hazard804/mdcx) 应用容器化的项目，提供了两种部署方式：
1. **轻量版 (GUI Base)** - 基于 `jlesage/baseimage-gui`，只显示应用窗口
2. **桌面版 (WebTop Base)** - 基于 `linuxserver/webtop`，提供完整桌面环境

### 项目版本

当前项目版本: `0.9.1` (见 `.env.versions`)

MDCx 应用版本: `220260511`

---

## 整体架构

```
mdcx-docker/
├── .github/              # GitHub 工作流和问题模板
├── build-mdcx/           # 构建 MDCx 二进制的 Dockerfile 和脚本
├── gui-base/             # GUI 基础镜像配置
├── webtop-base/          # WebTop 基础镜像配置
├── scripts/              # 通用脚本
├── docs/                 # 文档
├── demo/                 # 演示
├── prepare-src.sh        # 准备应用源码脚本
├── install.sh            # 一键安装脚本
└── .env.versions         # 版本配置文件
```

### 镜像层次结构

```
build-mdcx-base
  └── build-mdcx (构建 MDCx 二进制)
  
gui-base (jlesage/baseimage-gui)
  └── mdcx-builtin-gui-base (内置 MDCx)

webtop-base (linuxserver/webtop)
  └── mdcx-builtin-webtop-base (内置 MDCx)
```

---

## 主要模块职责

### 1. 核心模块

#### `build-mdcx/` - 构建模块
- **职责**: 负责编译打包 MDCx 应用为二进制文件
- **关键文件**:
  - `Dockerfile.build-mdcx-base`: 构建基础镜像，安装 Python 3.13、uv、构建工具等
  - `Dockerfile.build-mdcx`: 使用 PyInstaller 构建 MDCx 二进制文件

#### `gui-base/` - GUI 基础镜像模块
- **职责**: 提供轻量级的 Web 访问界面
- **关键文件**:
  - `Dockerfile.gui-base`: 基于 `jlesage/baseimage-gui`，安装必要库（libgl1、libegl1、字体、X11/xcb 库）
  - `Dockerfile.mdcx-builtin-gui-base`: 集成编译好的 MDCx 二进制文件
  - `mdcx-builtin.md`: 部署说明文档

#### `webtop-base/` - WebTop 基础镜像模块
- **职责**: 提供完整的桌面环境
- **关键文件**:
  - `Dockerfile.webtop-base`: 基于 `linuxserver/webtop`
  - `Dockerfile.mdcx-builtin-webtop-base`: 集成编译好的 MDCx 二进制文件
  - `mdcx-builtin.md`: 部署说明文档

### 2. 脚本模块

#### `scripts/` - 脚本目录
- **职责**: 提供通用的辅助脚本
- **关键文件**:
  - `base.sh`: 时间处理和版本比较工具函数
  - `github.sh`: GitHub 相关工具
  - `release-utils.sh`: 发布相关工具
  - `run-bin.sh`: 运行 MDCx 二进制的启动脚本
  - `run-nothing.sh`: 空运行脚本（用于基础镜像）
  - `update-bin.sh`: 更新二进制文件脚本

### 3. 部署模块

#### 根目录脚本
- **prepare-src.sh**: 从 GitHub 下载 MDCx 源码并解压
- **install.sh**: 一键安装部署脚本，引导用户完成配置

---

## 镜像类型和构建流程

### 1. `build-mdcx-base` - 构建基础镜像

**基础**: `jlesage/baseimage-gui:ubuntu-24.04-v4`

**关键依赖**:
- Python 3.13 (通过 uv 安装)
- uv (Python 包管理工具)
- 基础构建工具 (binutils, curl, unrar 等)

### 2. `build-mdcx` - 构建 MDCx 二进制镜像

**基础**: `stainless403/build-mdcx-base`

**构建流程**:
1. 复制 MDCx 源码到 `/tmp/mdcx`
2. 使用 `uv sync` 安装依赖
3. 使用 `PyInstaller` 打包为单个二进制文件
4. 使用 `alpine:latest` 作为最终轻量镜像

**PyInstaller 配置**:
```bash
uv run pyinstaller -n MDCx \
  -F -w main.py \
  --add-data "resources:resources" \
  --add-data "libs:." \
  --hidden-import socks \
  --hidden-import urllib3 \
  --hidden-import _cffi_backend \
  --hidden-import PIL \
  --hidden-import PyQt6 \
  --collect-all PyQt6 \
  --collect-all curl_cffi
```

### 3. `gui-base` - GUI 基础镜像

**基础**: `jlesage/baseimage-gui:ubuntu-24.04-v4`

**关键特性**:
- 启用 CJK 字体支持 (`ENABLE_CJK_FONT=1`)
- 安装了图形库 (libgl1, libegl1)
- 安装了中文字体 (fonts-wqy-zenhei, fonts-noto-color-emoji)
- 安装了完整的 X11/xcb 库

**环境变量**:
- `DISPLAY_WIDTH`: 1200 (窗口宽度)
- `DISPLAY_HEIGHT`: 750 (窗口高度)
- `USER_ID`: 1000
- `GROUP_ID`: 1000

### 4. `mdcx-builtin-gui-base` - 内置 MDCx 的 GUI 镜像

**基础**: `stainless403/gui-base`

**关键特性**:
- 从 `build-mdcx` 镜像复制编译好的二进制文件
- 创建配置目录 `/mdcx-config`
- 写入配置标记文件 `/app/MDCx.config`
- 使用 `run-bin.sh` 作为启动脚本

### 5. `webtop-base` - WebTop 基础镜像

**基础**: `linuxserver/webtop:ubuntu-kde-version-409dbb60`

**关键特性**:
- 提供完整的 KDE 桌面环境
- 安装了中文字体和必要库
- 支持文件管理和浏览器

### 6. `mdcx-builtin-webtop-base` - 内置 MDCx 的 WebTop 镜像

**基础**: `stainless403/webtop-base`

**关键特性**:
- 从 `build-mdcx` 镜像复制编译好的二进制文件
- 创建配置目录 `/mdcx-config`
- 写入配置标记文件 `/app/MDCx.config`

---

## 关键类与函数说明

### `prepare-src.sh` 关键函数

| 函数名 | 说明 |
|--------|------|
| `get_default_release_tag_by_repo(repo)` | 获取仓库默认的 release tag |
| `generate_app_version(published_at)` | 从发布时间生成版本号 |
| `find_release_by_tag_name(repo, tag)` | 查找指定 tag 的 release |
| `fetch_release_info(repo, tag)` | 获取 release 信息 |
| `get_release_info(repo, tag)` | 获取完整的 release 信息，返回 JSON |
| `download_and_extract(url, version)` | 下载并解压源码 |

### `install.sh` 关键函数

| 函数名 | 说明 |
|--------|------|
| `check_dependencies()` | 检查依赖 (jq, unzip, docker, docker-compose) |
| `choose_template()` | 用户选择部署模版 |
| `download_and_extract_template()` | 下载并解压模版文件 |
| `setup_project_directory()` | 设置项目目录 |
| `collect_runtime_inputs()` | 收集运行参数 (端口、UID/GID、卷映射) |
| `apply_replacements()` | 替换配置文件中的变量 |
| `pull_images()` | 拉取 Docker 镜像 |
| `start_or_create_container()` | 启动或创建容器 |

### `scripts/` 工具函数 (base.sh)

| 函数名 | 说明 |
|--------|------|
| `isoTimeToInt(time_str)` | ISO 8601 时间转时间戳 |
| `timestampToDatetime(timestamp)` | 时间戳转可读日期时间 |
| `compareVersion(v1, v2)` | 比较版本号 (0=相等, 1=v1>v2, -1=v1<v2) |

---

## 依赖关系

### 外部依赖

| 依赖 | 用途 |
|------|------|
| `jlesage/baseimage-gui` | GUI 基础镜像，提供 Web VNC 访问 |
| `linuxserver/webtop` | WebTop 基础镜像，提供完整桌面 |
| `alpine:latest` | 轻量级最终镜像 |
| Python 3.13 | 构建 MDCx 应用 |
| uv | Python 包管理工具 |
| PyInstaller | Python 应用打包工具 |

### 镜像依赖图

```
jlesage/baseimage-gui
├── build-mdcx-base
│   └── build-mdcx
└── gui-base
    └── mdcx-builtin-gui-base (依赖 build-mdcx)

linuxserver/webtop
└── webtop-base
    └── mdcx-builtin-webtop-base (依赖 build-mdcx)
```

---

## 项目运行方式

### 方式 1: 一键安装脚本 (推荐)

```bash
# 使用 curl
bash -c "$(curl -fsSL https://raw.githubusercontent.com/northsea4/mdcx-docker/main/install.sh)"

# 使用 wget
bash -c "$(wget https://raw.githubusercontent.com/northsea4/mdcx-docker/main/install.sh -O -)"
```

### 方式 2: 手动部署 - mdcx-builtin-gui-base

```bash
# 创建项目目录
MDCX_DOCKER_DIR=/path/to/mdcx-docker
mkdir -p $MDCX_DOCKER_DIR && cd $MDCX_DOCKER_DIR

# 创建必要目录
mkdir -p mdcx-config logs data

# 创建配置标记文件
echo "/mdcx-config/config.v2.json" > mdcx-config/MDCx.config

# 启动容器
docker run -d --name mdcx \
  -p 5800:5800 \
  -p 5900:5900 \
  -v $(pwd)/data:/config \
  -v $(pwd)/mdcx-config:/mdcx-config \
  -v $(pwd)/mdcx-config/MDCx.config:/app/MDCx.config \
  -v $(pwd)/logs:/app/Log \
  -v /path/to/movies:/movies \
  -e TZ=Asia/Shanghai \
  -e DISPLAY_WIDTH=1200 \
  -e DISPLAY_HEIGHT=750 \
  -e VNC_PASSWORD= \
  -e USER_ID=$(id -u) \
  -e GROUP_ID=$(id -g) \
  --restart unless-stopped \
  stainless403/mdcx-builtin-gui-base:v2-latest
```

访问: `http://your-server-ip:5800`

### 方式 3: 手动部署 - mdcx-builtin-webtop-base

```bash
# 创建项目目录
MDCX_DOCKER_DIR=/path/to/mdcx-docker
mkdir -p $MDCX_DOCKER_DIR && cd $MDCX_DOCKER_DIR

# 创建必要目录
mkdir -p mdcx-config logs data

# 创建配置标记文件
echo "/mdcx-config/config.v2.json" > mdcx-config/MDCx.config

# 启动容器
docker run -d --name mdcx \
  -p 3000:3000 \
  -p 3001:3001 \
  -v $(pwd)/data:/config \
  -v $(pwd)/mdcx-config:/mdcx-config \
  -v $(pwd)/mdcx-config/MDCx.config:/app/MDCx.config \
  -v $(pwd)/logs:/app/Log \
  -v /path/to/movies:/movies \
  -e TZ=Asia/Shanghai \
  -e AUTO_LOGIN=false \
  -e PUID=$(id -u) \
  -e PGID=$(id -g) \
  --restart unless-stopped \
  stainless403/mdcx-builtin-webtop-base:v2-latest
```

访问: `http://your-server-ip:3000`

### Docker Compose 部署

项目提供了 docker-compose 配置，可以使用以下命令:
```bash
# 启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 更新
docker-compose pull
docker-compose up -d
```

---

## CI/CD 工作流

### GitHub Actions 工作流

项目包含以下工作流:

| 工作流 | 说明 |
|--------|------|
| `build-mdcx-base.yml` | 构建 build-mdcx-base 镜像 |
| `build-mdcx.yml` | 构建 build-mdcx 镜像 (编译 MDCx) |
| `gui-base.yml` | 构建 gui-base 和 mdcx-builtin-gui-base 镜像 |
| `webtop-base.yml` | 构建 webtop-base 和 mdcx-builtin-webtop-base 镜像 |
| `watch-mdcx.yml` | 监视上游 MDCx 仓库的更新 |
| `github-release.yml` | 创建 GitHub 发布 |
| `docker-hub-docs.yml` | 更新 Docker Hub 文档 |

### build-mdcx.yml 工作流关键步骤

1. **Checkout**: 检出代码
2. **Install apt packages**: 安装 unrar
3. **Prepare App source**: 使用 `prepare-src.sh` 下载源码
4. **Prepare Version Values**: 加载 `.env.versions` 中的版本号
5. **Set up QEMU**: 支持多平台构建
6. **Set up Docker Buildx**: 配置 Docker Buildx
7. **Login to DockerHub**: 登录 Docker Hub
8. **Produce docker image tags**: 生成镜像标签
9. **Build and push**: 构建并推送镜像 (支持 linux/amd64, linux/arm64)
10. **TG Notification**: 发送 Telegram 通知 (可选)

---

## 卷映射说明

| 容器内路径 | 说明 | 主机路径示例 |
|-----------|------|-------------|
| `/config` | 容器系统数据 | `./data` |
| `/mdcx-config` | MDCx 配置文件目录 | `./mdcx-config` |
| `/app/MDCx.config` | 配置文件目录标记文件 | `./mdcx-config/MDCx.config` |
| `/app/Log` | 应用日志目录 | `./logs` |
| `/movies` (或其他) | 影片媒体目录 | `/path/to/movies` |

---

## 环境变量

### GUI 版本

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `TZ` | 时区 | `Asia/Shanghai` |
| `DISPLAY_WIDTH` | 窗口宽度 | `1200` |
| `DISPLAY_HEIGHT` | 窗口高度 | `750` |
| `VNC_PASSWORD` | 访问密码 | 空 |
| `USER_ID` | 运行用户的 UID | `1000` |
| `GROUP_ID` | 运行用户的 GID | `1000` |

### WebTop 版本

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `TZ` | 时区 | `Asia/Shanghai` |
| `AUTO_LOGIN` | 是否自动登录 | `false` |
| `PUID` | 运行用户的 UID | `1000` |
| `PGID` | 运行用户的 GID | `1000` |

---

## 安全建议

1. **设置访问密码**: 如需要公网访问，务必设置强密码
2. **限制端口访问**: 使用防火墙限制访问来源 IP
3. **定期更新镜像**: 使用 watchtower 或定期手动更新
4. **使用非 root 用户**: 设置合适的 USER_ID/GROUP_ID

---

## 常见问题

请参考项目中的 [FAQ.md](./FAQ.md) 文件获取详细的常见问题解答。

---

## 许可证

本项目在 GPL v3 许可下发布。详见 [LICENSE.md](./LICENSE.md)。
