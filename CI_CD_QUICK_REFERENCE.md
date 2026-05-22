# 🎯 MDCx VSMETA CI/CD 快速参考

## ⚡ 一分钟启动

### 首次配置
```bash
# 1. 添加 GitHub Secrets
# Settings → Secrets → Actions → New repository secret
DOCKERHUB_USERNAME=your_username
DOCKERHUB_TOKEN=your_token
TELE_BOT_TOKEN=your_bot_token
TELE_CHAT_ID=your_chat_id

# 2. 推送代码触发 CI/CD
git add .
git commit -m "feat: add VSMETA support"
git push origin main
```

### 手动触发
```bash
gh workflow run vsmeta-full-ci-cd.yml --field environment=prod
```

---

## 🔥 常用命令

### GitHub CLI
```bash
# 查看工作流
gh workflow list

# 运行工作流
gh workflow run vsmeta-full-ci-cd.yml

# 查看运行状态
gh run list

# 查看运行日志
gh run view <run-id> --log

# 实时监控
gh run watch <run-id>
```

### Docker 操作
```bash
# 查看镜像
docker buildx imagetools inspect stainless403/mdcx-builtin-gui-base:vsmeta-latest

# 拉取镜像
docker pull stainless403/mdcx-builtin-gui-base:vsmeta-latest

# 运行测试
docker run -d --name test-mdcx stainless403/mdcx-builtin-gui-base:vsmeta-latest
```

---

## 📋 版本标签

| 触发方式 | 版本格式 | 示例 |
|---------|---------|------|
| Push main | `vsmeta-YYYYMMDD` | `vsmeta-20260521` |
| Push develop | `vsmeta-dev-YYYYMMDD-HHMMSS` | `vsmeta-dev-20260521-143052` |
| Tag vsmeta-* | 使用标签名 | `vsmeta-v1.0.0` |
| Manual dev | `vsmeta-dev-YYYYMMDD-HHMMSS` | `vsmeta-dev-20260521-143052` |
| Manual prod | `vsmeta-YYYYMMDD` | `vsmeta-20260521` |

---

## 🔑 必需的 Secrets

```
DOCKERHUB_USERNAME     → Docker Hub 用户名
DOCKERHUB_TOKEN        → Docker Hub Access Token
TELE_BOT_TOKEN        → Telegram Bot Token (可选)
TELE_CHAT_ID          → Telegram Chat ID (可选)
```

---

## 📊 工作流阶段

| # | Job | 耗时 | 说明 |
|---|-----|------|------|
| 1 | 环境准备 | ~10s | 检查变更、生成版本 |
| 2 | 代码质量 | ~2min | Ruff lint & format |
| 3 | 单元测试 | ~5min | pytest 测试 |
| 4 | Base 镜像 | ~15min | 多架构构建推送 |
| 5 | MDCx Binary | ~30min | 编译 Python 应用 |
| 6 | GUI Base | ~15min | GUI 环境 |
| 7 | 最终镜像 | ~20min | 集成所有组件 |
| 8 | 镜像验证 | ~1min | 测试运行 |
| 9 | GitHub Release | ~30s | 创建发布 |
| 10 | 通知 | ~5s | Telegram 通知 |

**预计总耗时**: ~90 分钟（多架构）

---

## 🎨 状态徽章

在 README.md 中添加：

```markdown
[![VSMETA CI/CD](https://github.com/northsea4/mdcx-docker/actions/workflows/vsmeta-full-ci-cd.yml/badge.svg)](https://github.com/northsea4/mdcx-docker/actions/workflows/vsmeta-full-ci-cd.yml)
```

---

## 🐛 故障排除

### 构建失败
```bash
# 查看详细日志
gh run view <run-id> --log-failed

# 重新运行
gh run rerun <run-id>
```

### 镜像拉取失败
```bash
# 检查 Docker Hub 登录状态
docker login

# 手动拉取
docker pull stainless403/mdcx-builtin-gui-base:vsmeta-latest
```

### 测试失败
```bash
# 本地运行测试
cd .mdcx_src
uv run pytest mdcx/tests/core/test_vsmeta.py -v

# 修复后重新触发
gh workflow run vsmeta-full-ci-cd.yml
```

---

## 📝 提交流程

```bash
# 1. 创建功能分支
git checkout -b feature/vsmeta-enhancement

# 2. 开发并提交
git add .
git commit -m "feat: enhance VSMETA encoder"

# 3. 推送到远程
git push origin feature/vsmeta-enhancement

# 4. 创建 PR 到 main
gh pr create --base main --head feature/vsmeta-enhancement

# 5. 合并后自动触发 CI/CD
# 或者手动触发进行测试
gh workflow run vsmeta-full-ci-cd.yml --field environment=dev
```

---

## 🎯 发布流程

### 开发版
```bash
# 1. 手动触发 dev 环境
gh workflow run vsmeta-full-ci-cd.yml \
  --field environment=dev

# 2. 测试镜像
docker run -d -p 5800:5800 --name mdcx-dev \
  stainless403/mdcx-builtin-gui-base:vsmeta-latest

# 3. 测试 VSMETA 功能
# ...

# 4. 停止测试容器
docker stop mdcx-dev && docker rm mdcx-dev
```

### 生产版
```bash
# 1. 合并到 main
git checkout main
git merge feature/vsmeta-enhancement
git push origin main

# 2. 或创建标签
git tag vsmeta-v1.0.0
git push origin vsmeta-v1.0.0

# 3. 等待 CI/CD 完成
gh run watch

# 4. 验证发布
docker pull stainless403/mdcx-builtin-gui-base:vsmeta-v1.0.0
```

---

## 📞 常用链接

- **Actions**: `https://github.com/northsea4/mdcx-docker/actions`
- **Workflow**: `https://github.com/northsea4/mdcx-docker/actions/workflows/vsmeta-full-ci-cd.yml`
- **Docker Hub**: `https://hub.docker.com/u/stainless403`
- **镜像**: `https://hub.docker.com/r/stainless403/mdcx-builtin-gui-base`

---

**💡 提示**: 使用 `gh workflow run vsmeta-full-ci-cd.yml --field environment=dev` 快速测试！

