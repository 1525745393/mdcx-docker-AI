#!/bin/bash
set -e

# ###########################################################################
# MDCx VSMETA 功能 - 完整 Docker 构建和发布脚本
# ###########################################################################

echo "=========================================="
echo "  MDCx VSMETA 功能 - Docker 构建和发布工具"
echo "=========================================="
echo ""

# 配置变量
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-stainless403}"
TAG_SUFFIX="-vsmeta-$(date +%Y%m%d-%H%M%S)"
BASE_TAG="v2-vsmeta-base-pyqt6"
BIN_TAG="v2-vsmeta-bin-pyqt6"

echo "📦 配置信息："
echo "  Docker Hub 用户: $DOCKER_HUB_USERNAME"
echo "  Base 镜像标签: $BASE_TAG"
echo "  Bin 镜像标签: $BIN_TAG"
echo ""

# 检查 Docker 是否可用
if ! command -v docker &> /dev/null; then
    echo "❌ 错误: Docker 未安装或未在 PATH 中"
    echo "  请先在你的机器上安装 Docker"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ 错误: Docker 守护进程未运行"
    exit 1
fi

# 检查是否登录到 Docker Hub
echo "🔑 检查 Docker Hub 登录状态..."
if ! docker info 2>/dev/null | grep -q "Username"; then
    echo "⚠️  未检测到已登录状态"
    echo "请运行 'docker login' 登录到 Docker Hub"
    echo ""
    read -p "是否现在登录？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    fi
fi

echo "✅ Docker 环境检查通过"
echo ""

# 选择构建方式
echo "请选择构建方式："
echo "1) 本地单架构 (linux/amd64) - 适合本地测试"
echo "2) 本地单架构 (linux/arm64) - 适合 ARM 设备测试"
echo "3) 多架构 (linux/amd64,linux/arm64) 并推送 - 适合生产发布"
echo ""
read -p "请输入选项 (1-3): " -n 1 -r
echo

# 定义构建函数
build_amd64() {
    echo ""
    echo "🔨 开始构建 linux/amd64 镜像..."
    echo ""

    # 1. Build base
    echo "📌 步骤 1/4: 构建 base 镜像"
    docker buildx build \
        --platform linux/amd64 \
        --load \
        -t "$DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG" \
        -f build-mdcx/Dockerfile.build-mdcx-base \
        .
    echo "✅ 完成"
    echo ""

    # 2. Build bin
    echo "📌 步骤 2/4: 构建 bin 镜像"
    docker buildx build \
        --platform linux/amd64 \
        --build-arg BASE_IMAGE_TAG="$BASE_TAG" \
        --load \
        -t "$DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG" \
        -f build-mdcx/Dockerfile.build-mdcx \
        .
    echo "✅ 完成"
    echo ""

    # 3. Build gui base
    echo "📌 步骤 3/4: 构建 gui-base 镜像"
    docker buildx build \
        --platform linux/amd64 \
        --load \
        -t "$DOCKER_HUB_USERNAME/gui-base:$BASE_TAG" \
        -f gui-base/Dockerfile.gui-base \
        .
    echo "✅ 完成"
    echo ""

    # 4. Build mdcx-builtin-gui-base
    echo "📌 步骤 4/4: 构建 mdcx-builtin-gui-base 镜像"
    docker buildx build \
        --platform linux/amd64 \
        --build-arg MDCX_BIN_IMAGE_TAG="$BIN_TAG" \
        --build-arg BASE_IMAGE_TAG="$BASE_TAG" \
        --load \
        -t "$DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG" \
        -f gui-base/Dockerfile.mdcx-builtin-gui-base \
        .
    echo "✅ 完成"
    echo ""

    echo "🎉 所有镜像构建成功！"
    echo ""
    echo "📦 已构建的镜像："
    echo "  $DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG"
    echo "  $DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG"
    echo "  $DOCKER_HUB_USERNAME/gui-base:$BASE_TAG"
    echo "  $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG"
    echo ""
    echo "💡 你可以运行以下命令测试："
    echo "  docker run --rm $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG cat /app-version"
}

build_arm64() {
    echo ""
    echo "🔨 开始构建 linux/arm64 镜像..."
    echo ""

    # 1. Build base
    echo "📌 步骤 1/4: 构建 base 镜像"
    docker buildx build \
        --platform linux/arm64 \
        --load \
        -t "$DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG" \
        -f build-mdcx/Dockerfile.build-mdcx-base \
        .
    echo "✅ 完成"
    echo ""

    # 2. Build bin
    echo "📌 步骤 2/4: 构建 bin 镜像"
    docker buildx build \
        --platform linux/arm64 \
        --build-arg BASE_IMAGE_TAG="$BASE_TAG" \
        --load \
        -t "$DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG" \
        -f build-mdcx/Dockerfile.build-mdcx \
        .
    echo "✅ 完成"
    echo ""

    # 3. Build gui base
    echo "📌 步骤 3/4: 构建 gui-base 镜像"
    docker buildx build \
        --platform linux/arm64 \
        --load \
        -t "$DOCKER_HUB_USERNAME/gui-base:$BASE_TAG" \
        -f gui-base/Dockerfile.gui-base \
        .
    echo "✅ 完成"
    echo ""

    # 4. Build mdcx-builtin-gui-base
    echo "📌 步骤 4/4: 构建 mdcx-builtin-gui-base 镜像"
    docker buildx build \
        --platform linux/arm64 \
        --build-arg MDCX_BIN_IMAGE_TAG="$BIN_TAG" \
        --build-arg BASE_IMAGE_TAG="$BASE_TAG" \
        --load \
        -t "$DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG" \
        -f gui-base/Dockerfile.mdcx-builtin-gui-base \
        .
    echo "✅ 完成"
    echo ""

    echo "🎉 所有镜像构建成功！"
    echo ""
    echo "📦 已构建的镜像："
    echo "  $DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG"
    echo "  $DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG"
    echo "  $DOCKER_HUB_USERNAME/gui-base:$BASE_TAG"
    echo "  $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG"
}

build_multi_arch() {
    echo ""
    echo "🔨 开始构建多架构镜像 (linux/amd64, linux/arm64) 并推送..."
    echo ""

    # 1. Build base
    echo "📌 步骤 1/4: 构建并推送 base 镜像"
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --push \
        -t "$DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG" \
        -f build-mdcx/Dockerfile.build-mdcx-base \
        .
    echo "✅ 完成"
    echo ""

    # 2. Build bin
    echo "📌 步骤 2/4: 构建并推送 bin 镜像"
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg BASE_IMAGE_TAG="$BASE_TAG" \
        --push \
        -t "$DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG" \
        -f build-mdcx/Dockerfile.build-mdcx \
        .
    echo "✅ 完成"
    echo ""

    # 3. Build gui base
    echo "📌 步骤 3/4: 构建并推送 gui-base 镜像"
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --push \
        -t "$DOCKER_HUB_USERNAME/gui-base:$BASE_TAG" \
        -f gui-base/Dockerfile.gui-base \
        .
    echo "✅ 完成"
    echo ""

    # 4. Build mdcx-builtin-gui-base
    echo "📌 步骤 4/4: 构建并推送 mdcx-builtin-gui-base 镜像"
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --build-arg MDCX_BIN_IMAGE_TAG="$BIN_TAG" \
        --build-arg BASE_IMAGE_TAG="$BASE_TAG" \
        --push \
        -t "$DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG" \
        -f gui-base/Dockerfile.mdcx-builtin-gui-base \
        .
    echo "✅ 完成"
    echo ""

    echo "🎉 所有镜像构建和推送成功！"
    echo ""
    echo "📦 已发布的镜像："
    echo "  $DOCKER_HUB_USERNAME/build-mdcx-base:$BASE_TAG"
    echo "  $DOCKER_HUB_USERNAME/build-mdcx:$BIN_TAG"
    echo "  $DOCKER_HUB_USERNAME/gui-base:$BASE_TAG"
    echo "  $DOCKER_HUB_USERNAME/mdcx-builtin-gui-base:$BIN_TAG"
}

# 执行选择
case $REPLY in
    1)
        build_amd64
        ;;
    2)
        build_arm64
        ;;
    3)
        build_multi_arch
        ;;
    *)
        echo "❌ 无效的选项"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "  构建完成！"
echo "=========================================="

