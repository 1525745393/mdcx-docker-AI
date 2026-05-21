# 🐳 MDCx VSMETA 功能 - Docker 构建和发布指南

## 📦 快速开始

### 前置条件
1. 已安装 Docker 和 Docker Buildx
2. 已登录到 Docker Hub
3. 已克隆此项目到本地

### 一键构建和发布

使用提供的脚本进行构建和发布：

```bash
# 1. 设置脚本可执行权限
chmod +x build-and-publish.sh

# 2. 运行构建脚本
./build-and-publish.sh
```

脚本将引导你完成以下步骤：
- 检查 Docker 环境
- 登录到 Docker Hub（如果需要）
- 选择构建方式（单架构或多架构）
- 自动构建和推送镜像

## 🛠️ 手动构建步骤

如果你想手动执行构建，请按照以下步骤操作。

### 0. 设置环境变量

```bash
export DOCKER_HUB_USERNAME=stainless403
export BASE_TAG=v2-vsmeta-base-pyqt6
export BIN_TAG=v2-vsmeta-bin-pyqt6
```

### 1. 构建本地单架构（适用于测试）

#### Linux/AMD64 架构
```bash
# 步骤 1: 构建 base 镜像
docker buildx build \
    --platform linux/amd64 \
    --load \
    -t $DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG \
    -f build-mdcx/Dockerfile.build-mdcx-base \
    .

# 步骤 2: 构建 bin 镜像
docker buildx build \
    --platform linux/amd64 \
    --build-arg BASE_IMAGE_TAG=$BASE_TAG \
    --load \
    -t $DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG \
    -f build-mdcx/Dockerfile.build-mdcx \
    .

# 步骤 3: 构建 gui-base 镜像
docker buildx build \
    --platform linux/amd64 \
    --load \
    -t $DOCKER_HUB_USERNAME/gui-base:$BASE_TAG \
    -f gui-base/Dockerfile.gui-base \
    .

# 步骤 4: 构建 mdcx-builtin-gui-base 镜像
docker buildx build \
    --platform linux/amd64 \
    --build-arg MDCX_BIN_IMAGE_TAG=$BIN_TAG \
    --build-arg BASE_IMAGE_TAG=$BASE_TAG \
    --load \
    -t $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG \
    -f gui-base/Dockerfile.mdcx-builtin-gui-base \
    .
```

#### Linux/ARM64 架构（适用于树莓派、Mac M 系列等）
```bash
# 步骤 1: 构建 base 镜像
docker buildx build \
    --platform linux/arm64 \
    --load \
    -t $DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG \
    -f build-mdcx/Dockerfile.build-mdcx-base \
    .

# 步骤 2: 构建 bin 镜像
docker buildx build \
    --platform linux/arm64 \
    --build-arg BASE_IMAGE_TAG=$BASE_TAG \
    --load \
    -t $DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG \
    -f build-mdcx/Dockerfile.build-mdcx \
    .

# 步骤 3: 构建 gui-base 镜像
docker buildx build \
    --platform linux/arm64 \
    --load \
    -t $DOCKER_HUB_USERNAME/gui-base:$BASE_TAG \
    -f gui-base/Dockerfile.gui-base \
    .

# 步骤 4: 构建 mdcx-builtin-gui-base 镜像
docker buildx build \
    --platform linux/arm64 \
    --build-arg MDCX_BIN_IMAGE_TAG=$BIN_TAG \
    --build-arg BASE_IMAGE_TAG=$BASE_TAG \
    --load \
    -t $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG \
    -f gui-base/Dockerfile.mdcx-builtin-gui-base \
    .
```

### 2. 构建多架构并推送到 Docker Hub（适用于生产）

```bash
# 步骤 1: 构建并推送 base 镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    -t $DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG \
    -f build-mdcx/Dockerfile.build-mdcx-base \
    .

# 步骤 2: 构建并推送 bin 镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg BASE_IMAGE_TAG=$BASE_TAG \
    --push \
    -t $DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG \
    -f build-mdcx/Dockerfile.build-mdcx \
    .

# 步骤 3: 构建并推送 gui-base 镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    -t $DOCKER_HUB_USERNAME/gui-base:$BASE_TAG \
    -f gui-base/Dockerfile.gui-base \
    .

# 步骤 4: 构建并推送 mdcx-builtin-gui-base 镜像
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --build-arg MDCX_BIN_IMAGE_TAG=$BIN_TAG \
    --build-arg BASE_IMAGE_TAG=$BASE_TAG \
    --push \
    -t $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG \
    -f gui-base/Dockerfile.mdcx-builtin-gui-base \
    .
```

## 🧪 测试镜像

构建完成后，你可以测试镜像是否正常工作：

```bash
# 测试版本信息
docker run --rm \
    $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG \
    cat /app-version

# 测试运行容器（可选）
docker run -d \
    --name mdcx-vsmeta-test \
    -p 5800:5800 \
    $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG
```

## 📋 完整镜像列表

成功构建后，你将拥有以下镜像：

| 镜像名称 | 标签 | 用途 |
|---------|------|------|
| `build-mdcx-base` | `v2-vsmeta-base-pyqt6` | 基础构建环境 |
| `build-mdcx` | `v2-vsmeta-bin-pyqt6` | 包含构建好的 MDCx 二进制文件 |
| `gui-base` | `v2-vsmeta-base-pyqt6` | GUI 基础镜像 |
| `mdcx-builtin-gui-base` | `v2-vsmeta-bin-pyqt6` | **最终运行镜像** ✨ |

## 🚀 使用 VSMETA 功能的镜像

使用新构建的镜像运行：

```bash
docker run -d \
    --name mdcx-vsmeta \
    -p 5800:5800 \
    -v /path/to/your/config:/config \
    -v /path/to/your/videos:/videos \
    -e TZ=Asia/Shanghai \
    $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG
```

VSMETA 功能已在默认配置中启用，将自动为群晖 Video Station 生成元数据文件！

## 🔍 验证多架构镜像

构建多架构镜像后，你可以验证：

```bash
# 检查镜像信息
docker buildx imagetools inspect $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG
```

输出应该包含两个架构的信息：`linux/amd64` 和 `linux/arm64`。

