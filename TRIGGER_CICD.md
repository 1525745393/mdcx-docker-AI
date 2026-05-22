# 🚀 触发 CI/CD 构建指南

---

## ✅ 恭喜！GitHub Secrets 已配置！

---

## 📋 现在触发构建（浏览器中完成，2 分钟）

---

### 方法 1：通过 GitHub Actions 手动触发（推荐，最简单）

1. **打开 Actions 页面：** https://github.com/1525745393/mdcx-docker-AI/actions

2. **选择工作流：**
   在左侧列表中，选择 **"MDCx VSMETA - Full CI/CD Pipeline"**

3. **点击 Run workflow：**
   在页面右上角，点击 **"Run workflow"** 按钮

4. **配置选项：**
   - Branch：选择 **main**
   - Environment：选择 **prod**
   - （其他保持默认）

5. **点击 Run workflow：**
   点击绿色的 **"Run workflow"** 按钮

6. **等待：**
   完整构建约需 **90 分钟**！

---

### 方法 2：通过创建 git tag 触发（简单）

在你的本地仓库中：
```bash
cd mdcx-docker-AI
git tag -a vsmeta-v1.0.1 -m "VSMETA 功能正式发布"
git push origin vsmeta-v1.0.1
```

---

### 方法 3：通过 GitHub CLI（如果你安装了的话）

如果你安装了 GitHub CLI：
```bash
cd mdcx-docker-AI
gh workflow run vsmeta-full-ci-cd.yml --field environment=prod
```

---

## 📊 构建后的镜像标签

成功后，Docker Hub 上会有：
- `vsmeta-latest`
- `vsmeta-YYYYMMDD`
- `vsmeta-v1.0.0`

---

## 🎉 构建完成后

你就能用带 VSMETA 功能的 MDCx 了！

**📚 查看：DEPLOYMENT_GUIDE_FINAL.md（最终部署指南）**
