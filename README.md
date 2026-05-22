# 🎬 MDCx Docker

[![GitHub stars](https://img.shields.io/github/stars/1525745393/mdcx-docker-AI.svg?style=flat&label=Stars&maxAge=3600)](https://GitHub.com/1525745393/mdcx-docker-AI)
[![GitHub release](https://img.shields.io/github/release/1525745393/mdcx-docker-AI.svg?style=flat&label=Release)](https://github.com/1525745393/mdcx-docker-AI/releases)

---

## ✨ 新增功能：群晖 VSMETA 元数据支持

本项目已添加完整的群晖 Video Station VSMETA 元数据生成功能！

**功能特点：**
- ✅ 自动生成 `.vsmeta` 文件
- ✅ 完美兼容群晖 Video Station
- ✅ 支持海报和背景图嵌入
- ✅ 包含完整元数据（标题、评分、演员、导演、剧情等）
- ✅ 默认启用，开箱即用

---

## 🐳 镜像

| 镜像 | 说明 | 标签 |
| --- | --- | --- |
| `1525745393/mdcx-docker-ai` | GUI 版本（推荐） | `vsmeta-latest`, `vsmeta-v1.0.0` |

---

## 🚀 快速开始

### 使用 Docker Compose

```yaml
version: '3.8'
services:
  mdcx:
    image: 1525745393/mdcx-docker-ai:vsmeta-latest
    container_name: mdcx-vsm
    ports:
      - "5800:5800"
      - "5900:5900"
    volumes:
      - ./mdcx-config:/config:rw
      - ./data:/data:rw
      - ./logs:/logs:rw
    environment:
      - DISPLAY_WIDTH=1280
      - DISPLAY_HEIGHT=720
      - TZ=Asia/Shanghai
    restart: unless-stopped
```

### 使用命令行

```bash
docker run -d \
  --name mdcx-vsm \
  -p 5800:5800 \
  -p 5900:5900 \
  -v ./mdcx-config:/config:rw \
  -v ./data:/data:rw \
  -v ./logs:/logs:rw \
  -e DISPLAY_WIDTH=1280 \
  -e DISPLAY_HEIGHT=720 \
  -e TZ=Asia/Shanghai \
  1525745393/mdcx-docker-ai:vsmeta-latest
```

---

## 📁 目录结构

```
mdcx-docker-AI/
├── .github/workflows/     # CI/CD 工作流
├── gui-base/              # GUI 基础镜像配置
├── docs/                  # 文档
├── build-and-publish.sh   # 一键构建脚本
├── prepare-src.sh         # 源码准备脚本
├── install.sh             # 安装脚本
└── README.md              # 项目说明
```

---

## 🔧 配置

### 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| DISPLAY_WIDTH | 1280 | 显示宽度 |
| DISPLAY_HEIGHT | 720 | 显示高度 |
| TZ | Asia/Shanghai | 时区 |

### 端口

| 端口 | 用途 |
|------|------|
| 5800 | Web UI 访问端口 |
| 5900 | VNC 连接端口 |

---

## 📚 文档

| 文件 | 说明 |
|------|------|
| VSMETA_QUICKSTART.md | VSMETA 功能快速开始 |
| DEPLOYMENT_GUIDE_FINAL.md | 完整部署指南 |
| VSMETA_PATCH_GUIDE.md | 源码修改指南 |
| CI_CD_AUTOMATION_GUIDE.md | CI/CD 自动化指南 |

---

## 🛠️ 本地构建

```bash
# 克隆仓库
git clone https://github.com/1525745393/mdcx-docker-AI.git
cd mdcx-docker-AI

# 运行构建脚本
chmod +x build-and-publish.sh
./build-and-publish.sh
```

---

## 🎉 使用说明

1. 启动容器后，访问 `http://localhost:5800`
2. 在 MDCx 中刮削视频文件
3. 刮削完成后，输出目录会包含：
   - 视频文件
   - `.nfo` 文件（Kodi/Jellyfin 格式）
   - `.vsmeta` 文件（群晖 Video Station 格式）
   - 海报和背景图

4. 将文件复制到群晖的 Video Station 目录，即可享受完整的元数据支持！

---

## 📝 更新日志

### v1.0.0 (VSMETA)
- ✅ 添加群晖 VSMETA 元数据生成功能
- ✅ 自动生成 `.vsmeta` 文件
- ✅ 支持海报和背景图嵌入
- ✅ 默认启用 VSMETA 功能
- ✅ 添加完整的 CI/CD 自动化

---

## 📞 支持

如有问题，请查看项目文档或提交 Issue。

---

**🎉 感谢使用 MDCx Docker！🎬**
