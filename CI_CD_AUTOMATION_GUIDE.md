# 🚀 MDCx VSMETA - 高级 CI/CD 自动化发布指南

## 📋 概述

本项目已配置完整的 GitHub Actions CI/CD 流程，可以自动化完成从代码检查、测试、构建到发布的全部流程。

---

## 🎯 CI/CD 流程架构

```
┌─────────────────────────────────────────────────────────┐
│                    触发条件                              │
├─────────────────────────────────────────────────────────┤
│ • Push to main/develop                                  │
│ • Tag: vsmeta-*                                        │
│ • VSMETA 相关文件变更                                   │
│ • Manual workflow_dispatch                              │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 1: 环境准备和代码检查                               │
│  ✅ 检查 VSMETA 相关变更                                 │
│  ✅ 生成版本标签                                         │
│  ✅ 显示环境信息                                         │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 2: 代码质量检查                                    │
│  🔍 Ruff Lint                                          │
│  🔍 Ruff Format Check                                  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 3: 单元测试                                        │
│  🧪 VSMETA 单元测试                                     │
│  🧪 上传测试结果                                        │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 4: 构建 Base 镜像                                 │
│  🏗️ docker/build-push-action                           │
│  🏗️ Multi-arch: amd64, arm64                           │
│  🏗️ Push to Docker Hub                                 │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 5: 构建 MDCx Binary 镜像                          │
│  🏗️ 准备源码                                           │
│  🏗️ 编译 Python 应用                                   │
│  🏗️ Multi-arch + Push                                  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 6: 构建 GUI Base 镜像                             │
│  🏗️ GUI 基础环境                                       │
│  🏗️ Multi-arch + Push                                  │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 7: 构建最终镜像 (MDCx Builtin GUI Base)            │
│  🎯 集成所有组件                                        │
│  🎯 Multi-arch + Push                                  │
│  🎯 打上 vsmeta-latest 标签                            │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 8: 镜像验证和测试                                  │
│  ✅ 检查镜像元数据                                      │
│  ✅ 运行测试容器                                        │
│  ✅ 验证版本信息                                        │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 9: 创建 GitHub Release (仅生产环境)                │
│  📦 生成发布说明                                        │
│  📦 自动创建 Release                                   │
│  📦 附加变更日志                                       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Job 10: 通知和完成                                    │
│  📢 Telegram 通知 (可选)                               │
│  📢 显示完成总结                                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🔧 配置要求

### 必需的 GitHub Secrets

在 GitHub 仓库的 `Settings → Secrets and variables → Actions` 中添加以下密钥：

| Secret 名称 | 说明 | 获取方式 |
|------------|------|---------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 | Docker Hub 账户设置 |
| `DOCKERHUB_TOKEN` | Docker Hub 访问令牌 | Docker Hub → Account Settings → Security → Access Tokens |
| `TELE_BOT_TOKEN` | Telegram Bot Token | @BotFather 创建 |
| `TELE_CHAT_ID` | Telegram Chat ID | @userinfobot 获取 |

### 可选的 GitHub Variables

| Variable 名称 | 说明 | 默认值 |
|-------------|------|--------|
| `ENABLE_TG_NOTIFICATION` | 启用 Telegram 通知 | `true` |

---

## 🚀 使用方法

### 方式 1: 自动触发

推送到 main 分支或创建 vsmeta-* 标签时会自动触发：

```bash
# 方式 1: Push 到 main 分支
git checkout main
git merge your-vsmeta-branch
git push origin main

# 方式 2: 创建标签
git tag vsmeta-v1.0.0
git push origin vsmeta-v1.0.0
```

### 方式 2: 手动触发（推荐用于测试）

1. 进入 GitHub 仓库页面
2. 点击 **Actions** 标签
3. 选择 **"MDCx VSMETA - Full CI/CD Pipeline"**
4. 点击 **"Run workflow"**
5. 选择环境：`dev` 或 `prod`
6. 可选：跳过测试或构建
7. 点击 **"Run workflow"**

### 方式 3: 手动触发（命令行）

```bash
# 使用 GitHub CLI
gh workflow run vsmeta-full-ci-cd.yml \
  --field environment=prod

# 查看运行状态
gh run watch
```

---

## 📊 版本标签规则

### 开发环境 (dev)
```
vsmeta-dev-YYYYMMDD-HHMMSS
示例: vsmeta-dev-20260521-143052
```

### 生产环境 (prod)
```
vsmeta-YYYYMMDD
示例: vsmeta-20260521
```

### 从标签触发
```
使用标签名称作为版本
示例: vsmeta-v1.0.0
```

---

## 🔍 监控和日志

### 查看工作流运行

1. **GitHub Web UI**
   - 仓库 → Actions → 选择工作流运行

2. **命令行**
   ```bash
   # 查看最近的工作流运行
   gh run list

   # 查看特定运行的详情
   gh run view <run-id>

   # 实时查看日志
   gh run watch <run-id>
   ```

### 查看 Docker 镜像

```bash
# 查看已构建的镜像
docker buildx imagetools inspect \
  stainless403/mdcx-builtin-gui-base:vsmeta-latest
```

---

## 🧪 测试和验证

### 本地测试 CI/CD

```bash
# 在本地模拟部分 CI/CD 流程

# 1. 代码检查
cd .mdcx_src
uv run ruff check mdcx/

# 2. 格式化检查
uv run ruff format --check mdcx/

# 3. 运行测试
uv run pytest mdcx/tests/core/test_vsmeta.py -v

# 4. 本地构建镜像（需要 Docker）
docker buildx build \
  --platform linux/amd64 \
  --load \
  -t mdcx-vsmeta:test \
  -f gui-base/Dockerfile.mdcx-builtin-gui-base \
  .

# 5. 测试镜像
docker run --rm mdcx-vsmeta:test cat /app-version
```

---

## 🔧 高级配置

### 跳过特定阶段

在手动触发时可以选择：

- **Skip Tests**: 跳过单元测试（不推荐）
- **Skip Build**: 跳过构建（用于测试其他部分）

### 自定义构建参数

修改 `.env.versions` 文件来自定义版本号：

```bash
# 更新版本号
echo "GUI_BASE_MDCX_BUILTIN_VERSION=vsmeta-$(date +%Y%m%d)" >> .env.versions
git add .env.versions
git commit -m "chore: update version"
```

### 多架构构建

默认支持：
- ✅ `linux/amd64` - Intel/AMD 64位处理器
- ✅ `linux/arm64` - ARM 64位处理器（树莓派、Mac M系列等）

---

## ⚠️ 常见问题

### 1. Docker Hub 认证失败

**错误**: ` unauthorized: authentication required`

**解决**:
1. 检查 `DOCKERHUB_TOKEN` 是否正确
2. 确保 Token 有仓库推送权限
3. 重新生成 Token

### 2. 构建超时

**错误**: `ERROR: Job executing took longer than 6h0m0s`

**解决**:
1. 减少构建的架构数量（只构建 amd64）
2. 使用缓存优化构建速度
3. 检查网络连接

### 3. 测试失败

**错误**: `pytest exited with code 1`

**解决**:
1. 查看测试日志了解失败原因
2. 本地运行测试复现问题
3. 修复代码后重新触发

---

## 📝 工作流配置详解

### 触发条件优先级

1. **手动触发 (workflow_dispatch)** - 最高优先级
2. **标签推送 (tags: vsmeta-\*)** - 发布版本
3. **分支推送 (branches: main/develop)** - 自动构建
4. **文件变更 (paths)** - VSMETA 相关文件

### 环境变量

| 变量 | 说明 |
|------|------|
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 |
| `VSMETA_VERSION` | VSMETA 版本 |
| `PYPI_MIRROR` | PyPI 镜像源 |

### 镜像标签策略

```
stainless403/mdcx-builtin-gui-base:vsmeta-latest  # 总是指向最新
stainless403/mdcx-builtin-gui-base:vsmeta-20260521  # 日期版本
stainless403/mdcx-builtin-gui-base:vsmeta-v1.0.0  # 标签版本
```

---

## 🎯 最佳实践

### 1. 开发阶段
- 使用 `dev` 环境进行测试
- 创建 `vsmeta-*` 标签触发 CI/CD
- 充分利用手动触发功能

### 2. 生产发布
- 合并到 `main` 分支触发自动构建
- 创建正式标签（如 `vsmeta-v1.0.0`）
- 确保所有测试通过

### 3. 监控和维护
- 定期检查 Actions 日志
- 关注 Telegram 通知
- 保持版本号更新

---

## 📞 获取帮助

- **GitHub Issues**: https://github.com/northsea4/mdcx-docker/issues
- **GitHub Discussions**: https://github.com/northsea4/mdcx-docker/discussions
- **文档**: 查看 `DOCKER_PUBLISH_GUIDE.md`

---

**🎉 完整的 CI/CD 自动化系统已配置完成！**

