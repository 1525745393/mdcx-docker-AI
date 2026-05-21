# 发布前准备检查清单

## ✅ 已完成项

### 代码变更
- [x] 新增 `mdcx/core/vsmeta.py` - VSMETA 编码器模块
- [x] 修改 `mdcx/config/enums.py` - 添加 VSMETA 相关枚举
- [x] 修改 `mdcx/core/file.py` - 添加 VSMETA 文件名处理
- [x] 修改 `mdcx/core/scraper.py` - 集成 VSMETA 生成流程
- [x] 修改 `mdcx/config/models.py` - 添加 VSMETA 默认配置
- [x] 新增 `mdcx/tests/core/test_vsmeta.py` - VSMETA 单元测试
- [x] 更新 `changelog.md` - 记录功能变更

### 功能验证
- [x] 核心编码逻辑测试通过 - 生成符合 VSMP 格式的文件
- [x] 魔数检查通过 - `b"VSMP"`
- [x] JSON 解析验证通过
- [x] 字段映射验证通过

---

## 📋 发布前待办项

### 1. 运行完整测试
在 .mdcx_src 目录下运行：
```bash
cd /workspace/.mdcx_src
# 确保已安装 uv
# uv pip install --group dev
# uv run pytest
```

### 2. 代码格式化检查
运行代码检查工具：
```bash
cd /workspace/.mdcx_src
uv run ruff check
uv run ruff format --check
```

### 3. 本地构建测试
在有 Docker 的机器上构建镜像测试：
```bash
# 参见 docs/build.md
```

### 4. 功能测试
运行 MDCx 并实际刮削一个视频，验证：
- VSMETA 文件是否正确生成
- VSMETA 文件格式是否符合要求
- 与 NFO 同时生成功能是否正常
- 配置选项是否可用

### 5. 更新文档
- [ ] 检查 README.md 是否需要更新
- [ ] 检查是否需要添加功能说明文档

---

## 🎯 VSMETA 功能概述

### 新增文件
1. `mdcx/core/vsmeta.py` - VSMETA 编码器核心模块
2. `mdcx/tests/core/test_vsmeta.py` - 单元测试

### 修改文件
1. `mdcx/config/enums.py` - 新增 DownloadableFile.VSMETA 和 KeepableFile.VSMETA
2. `mdcx/config/models.py` - 将 VSMETA 添加到默认下载文件列表
3. `mdcx/core/file.py` - get_output_name 新增 vsmeta_new_path 返回值
4. `mdcx/core/scraper.py` - 集成 write_vsmeta 调用

### 功能特性
- 自动为每个视频生成对应的 .vsmeta 文件
- 嵌入电影元数据（标题、评分、演员、导演等）
- 嵌入海报和背景图（如有）
- 与 NFO 生成流程完全兼容
- 默认启用，可在配置中关闭
- 支持群晖 DS Video 和 Video Station 完美展示
