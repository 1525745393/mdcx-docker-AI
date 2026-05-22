# 🚀 本地发布指南 - MDCx VSMETA 功能

## 📋 概述

由于当前环境限制（无 GitHub CLI、网络问题），本指南将帮助你：

1. 准备发布环境
2. 提交所有代码更改
3. 配置 GitHub Secrets
4. 触发 CI/CD 发布
5. 验证发布结果

---

## 🎯 快速开始

### 方式 1: GitHub Web UI（最简单）

#### 步骤 1: 提交代码
在 GitHub 网页上：
1. 进入你的仓库
2. 点击 **Code** → **Upload files**
3. 上传所有文件
4. 创建 commit

#### 步骤 2: 触发 CI/CD
1. 进入 **Actions** 标签
2. 选择 **"MDCx VSMETA - Full CI/CD Pipeline"**
3. 点击 **"Run workflow"**
4. 选择环境：**prod**
5. 点击 **"Run workflow"**

#### 步骤 3: 等待完成
1. 查看 **Actions** 中的运行状态
2. 等待所有 jobs 完成
3. 检查 **Packages** 或 Docker Hub

---

### 方式 2: Git + GitHub CLI（推荐）

#### 前提条件
```bash
# 检查工具
git --version
gh --version
docker --version
docker buildx version
```

#### 步骤 1: 克隆仓库
```bash
git clone https://github.com/northsea4/mdcx-docker.git
cd mdcx-docker
```

#### 步骤 2: 配置 GitHub CLI
```bash
# 登录 GitHub
gh auth login

# 验证登录
gh auth status
```

#### 步骤 3: 准备源码（重要！）
```bash
# 下载 MDCx 源码
bash prepare-src.sh --context build-mdcx --repo Hazard804/mdcx --tag latest

# 这会创建 .mdcx_src 目录，包含所有 VSMETA 代码修改
```

#### 步骤 4: 提交代码
```bash
# 添加所有更改
git add .

# 提交
git commit -m "feat: 添加群晖 VSMETA 元数据支持

- 新增 VSMETA 编码器
- 集成到刮削流程
- 添加单元测试
- 配置 CI/CD 自动化"

# 推送到 GitHub
git push origin main
```

#### 步骤 5: 触发 CI/CD
```bash
# 方式 1: 推送到 main 自动触发
git push origin main

# 方式 2: 手动触发（推荐用于测试）
gh workflow run vsmeta-full-ci-cd.yml \
  --field environment=dev

# 或生产环境
gh workflow run vsmeta-full-ci-cd.yml \
  --field environment=prod
```

#### 步骤 6: 监控进度
```bash
# 查看工作流列表
gh workflow list

# 实时查看运行状态
gh run watch

# 查看特定运行的日志
gh run view <run-id> --log
```

---

### 方式 3: 纯手动 Docker 构建

如果想完全本地构建和发布：

#### 步骤 1: 准备源码
```bash
bash prepare-src.sh --context build-mdcx --repo Hazard804/mdcx --tag latest
```

#### 步骤 2: 构建镜像
```bash
chmod +x build-and-publish.sh
./build-and-publish.sh
```

选择：
- **选项 1**: 本地 amd64 测试
- **选项 3**: 多架构构建并推送（推荐）

#### 步骤 3: 手动推送
```bash
# 登录 Docker Hub
docker login

# 手动打标签
docker tag mdcx-builtin-gui-base:latest \
  stainless403/mdcx-builtin-gui-base:vsmeta-latest

docker tag mdcx-builtin-gui-base:latest \
  stainless403/mdcx-builtin-gui-base:vsmeta-$(date +%Y%m%d)

# 推送
docker push stainless403/mdcx-builtin-gui-base:vsmeta-latest
docker push stainless403/mdcx-builtin-gui-base:vsmeta-$(date +%Y%m%d)
```

---

## 🔧 必需配置

### GitHub Secrets（必须在 GitHub 中配置）

在仓库的 **Settings → Secrets and variables → Actions** 中添加：

#### 1. Docker Hub 认证
```bash
# 创建 Docker Hub Access Token
# https://hub.docker.com/settings/security

DOCKERHUB_USERNAME = your_username
DOCKERHUB_TOKEN = your_access_token
```

#### 2. Telegram 通知（可选）
```bash
TELE_BOT_TOKEN = your_bot_token
TELE_CHAT_ID = your_chat_id
```

---

## 📝 验证发布

### 检查 Docker Hub
```bash
# 查看镜像
docker buildx imagetools inspect \
  stainless403/mdcx-builtin-gui-base:vsmeta-latest

# 拉取镜像
docker pull stainless403/mdcx-builtin-gui-base:vsmeta-latest
```

### 测试运行
```bash
# 启动容器
docker run -d \
  --name mdcx-vsmeta-test \
  -p 5800:5800 \
  stainless403/mdcx-builtin-gui-base:vsmeta-latest

# 检查日志
docker logs mdcx-vsmeta-test

# 检查版本
docker exec mdcx-vsmeta-test cat /app-version

# 停止和清理
docker stop mdcx-vsmeta-test
docker rm mdcx-vsmeta-test
```

### 检查 GitHub Actions
```bash
# 查看所有运行
gh run list

# 查看特定运行
gh run view <run-id>

# 查看日志
gh run view <run-id> --log
```

---

## 🎯 发布检查清单

- [ ] 所有代码已提交到 GitHub
- [ ] GitHub Secrets 已配置
- [ ] Docker Hub 访问正常
- [ ] CI/CD 工作流已触发
- [ ] 所有 Jobs 成功完成
- [ ] 镜像已推送到 Docker Hub
- [ ] 镜像标签正确（vsmeta-*）
- [ ] 本地测试通过

---

## 🐛 常见问题

### 1. GitHub Actions 不触发
**检查**:
- Secrets 是否配置正确
- 是否有 VSMETA 相关文件变更
- 分支是否正确（main/develop）

**解决**:
```bash
# 手动触发
gh workflow run vsmeta-full-ci-cd.yml
```

### 2. Docker Hub 推送失败
**错误**: `unauthorized: authentication required`

**解决**:
```bash
# 重新登录
docker logout
docker login

# 检查 token 权限
```

### 3. 多架构构建失败
**检查**:
- QEMU 是否安装
- Buildx 是否启用

**解决**:
```bash
# 安装 QEMU
docker run --privileged --rm tonistiigi/binfmt --install all

# 启用 buildx
docker buildx install
```

### 4. 测试失败
**检查**:
- 本地运行测试
- 查看详细日志

**解决**:
```bash
cd .mdcx_src
uv run pytest mdcx/tests/core/test_vsmeta.py -v
```

---

## 📞 获取帮助

- **GitHub Actions**: 仓库 → Actions 标签
- **Docker Hub**: https://hub.docker.com/u/stainless403
- **详细指南**: 查看 `CI_CD_AUTOMATION_GUIDE.md`

---

## 🎉 发布成功！

发布完成后，你应该：

1. ✅ Docker Hub 上有新镜像
2. ✅ 镜像标签包含 `vsmeta-*`
3. ✅ GitHub Actions 显示成功
4. ✅ 收到 Telegram 通知（如果配置了）

**然后就可以使用新镜像了：**
```bash
docker pull stainless403/mdcx-builtin-gui-base:vsmeta-latest
```

**享受 VSMETA 功能带来的便利！** 🎬
