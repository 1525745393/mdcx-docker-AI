# VSMETA 功能完整补丁指南

## 概述

这是一个完整的 VSMETA 功能源码补丁指南，包含你需要手动应用到 MDCx 源码中的所有修改！

---

## 1️⃣ 获取 MDCx 源码

你需要先获取 MDCx 项目的源代码。可以使用以下方法之一：

### 方法 A：使用 sqzw-x/mdcx 或 Hazard804/mdcx 仓库
```bash
# 克隆仓库
git clone https://github.com/sqzw-x/mdcx.git
cd mdcx
```

---

## 2️⃣ 应用源码修改

现在在 MDCx 源码目录中，进行以下修改！

---

### 文件 1：新增 `mdcx/core/vsmeta.py`（VSMETA 编码器）

在源码目录中创建文件 `mdcx/core/vsmeta.py`，内容如下：

```python
"""
Synology Video Station VSMETA encoder
Supports generating VSMETA files for Synology DS Video
"""

import json
import struct
import os
from typing import Dict, Optional, List, Any


class VSMetaEncoder:
    """Synology VSMETA binary format encoder"""

    # VSMETA file header magic bytes
    MAGIC = b"VSMP"
    VERSION = 1

    def __init__(self, metadata: Dict[str, Any]):
        """
        Initialize VSMETA encoder
        Args:
            metadata: Dictionary containing metadata fields
        """
        self.metadata = metadata

    def encode(self, poster_data: Optional[bytes] = None,
               backdrop_data: Optional[bytes] = None) -> bytes:
        """
        Encode VSMETA binary data
        Args:
            poster_data: Poster image bytes (optional)
            backdrop_data: Backdrop image bytes (optional)
        Returns:
            Encoded VSMETA bytes
        """
        json_data = json.dumps(self.metadata, ensure_ascii=False).encode("utf-8")
        result = bytearray()
        result.extend(self.MAGIC)
        result.extend(struct.pack("<HH", self.VERSION, 0))
        result.extend(struct.pack("<I", len(json_data)))
        result.extend(json_data)
        if poster_data:
            result.extend(struct.pack("<I", len(poster_data)))
            result.extend(poster_data)
        else:
            result.extend(struct.pack("<I", 0))
        if backdrop_data:
            result.extend(struct.pack("<I", len(backdrop_data)))
            result.extend(backdrop_data)
        else:
            result.extend(struct.pack("<I", 0))
        return bytes(result)

    def write_file(self, filepath: str,
                   poster_path: Optional[str] = None,
                   backdrop_path: Optional[str] = None):
        poster_data = None
        if poster_path and os.path.exists(poster_path):
            with open(poster_path, "rb") as f:
                poster_data = f.read()
        backdrop_data = None
        if backdrop_path and os.path.exists(backdrop_path):
            with open(backdrop_path, "rb") as f:
                backdrop_data = f.read()
        vsmeta_data = self.encode(poster_data, backdrop_data)
        with open(filepath, "wb") as f:
            f.write(vsmeta_data)


def write_vsmeta(metadata: Dict[str, Any],
                 output_path: str,
                 poster_path: Optional[str] = None,
                 backdrop_path: Optional[str] = None):
    encoder = VSMetaEncoder(metadata)
    encoder.write_file(output_path, poster_path, backdrop_path)
```

---

### 文件 2：修改 `mdcx/config/enums.py`

在源码目录中找到 `mdcx/config/enums.py`，进行以下两处修改：

#### 修改 A：在 DownloadableFile 枚举中添加 VSMETA

找到这部分代码（大约在文件开头附近）：

```python
class DownloadableFile(Enum):
    POSTER = "poster"
    THUMB = "thumb"
    FANART = "fanart"
    EXTRAFANART = "extrafanart"
    TRAILER = "trailer"
    NFO = "nfo"
    EXTRAFANART_EXTRAS = "extrafanart_extras"
    EXTRAFANART_COPY = "extrafanart_copy"
    THEME_VIDEOS = "theme_videos"
```

在 `NFO = "nfo"` 后面添加一行：

```python
    VSMETA = "vsmeta"
```

#### 修改 B：更新 DownloadableFile.names()

在 `names()` 函数中添加 "VSMETA"：

```python
    @classmethod
    def names(cls):
        return [
            "海报",
            "缩略图",
            "剧照",
            "额外剧照",
            "预告片",
            "Nfo",
            "VSMETA",   # ← 新增这一行
            "额外剧照扩展",
            "额外剧照复制",
            ...
```

#### 修改 C：在 KeepableFile 枚举中添加 VSMETA

找到 `KeepableFile` 枚举：

```python
class KeepableFile(Enum):
    POSTER = "poster"
    THUMB = "thumb"
    FANART = "fanart"
    EXTRAFANART = "extrafanart"
    TRAILER = "trailer"
    NFO = "nfo"
```

在 `NFO = "nfo"` 后面添加：
```python
    VSMETA = "vsmeta"
```

#### 修改 D：更新 KeepableFile.names()

同样在 `names()` 函数中添加 "VSMETA"。

---

### 文件 3：修改 `mdcx/config/models.py`

找到 `mdcx/config/models.py` 文件，找到默认的 `download_files` 列表，添加 VSMETA：

找到类似这样的代码：

```python
    download_files: list[DownloadableFile] = Field(
        default_factory=lambda: [
            DownloadableFile.POSTER,
            DownloadableFile.THUMB,
            DownloadableFile.FANART,
            DownloadableFile.EXTRAFANART,
            DownloadableFile.TRAILER,
            DownloadableFile.NFO,
```

在 `DownloadableFile.NFO,` 后面添加一行：
```python
            DownloadableFile.VSMETA,
```

---

### 文件 4：修改 `mdcx/core/file.py`

找到 `mdcx/core/file.py` 中的 `get_output_name()` 函数：

#### 修改 A：在返回值列表中添加 vsmeta_new_path

找到这样的代码：
```python
def get_output_name(...):
    ...
    return (
        folder_new_path,
        file_new_path,
        nfo_new_path,
        poster_new_path_with_filename,
        thumb_new_path_with_filename,
        fanart_new_path_with_filename,
        naming_rule,
        poster_final_path,
        thumb_final_path,
        fanart_final_path,
    )
```

在 `fanart_final_path,` 后面添加一行：
```python
        vsmeta_new_path,
```

#### 修改 B：生成 vsmeta_new_path

在 `nfo_new_path = folder_new_path / nfo_new_name` 后面添加：
```python
    vsmeta_new_name = naming_rule + ".vsmeta"
    vsmeta_new_path = folder_new_path / vsmeta_new_name
```

---

### 文件 5：修改 `mdcx/core/scraper.py`

这是最重要的修改！

#### 修改 A：导入 VSMETA 模块

在文件顶部导入部分，找到 `from .nfo import ...`，添加一行：
```python
from .vsmeta import write_vsmeta
```

#### 修改 B：更新 get_output_name() 解包

找到调用 `get_output_name()` 的地方，添加 `vsmeta_new_path` 到返回值：

```python
    (
        folder_new_path,
        file_new_path,
        nfo_new_path,
        poster_new_path_with_filename,
        thumb_new_path_with_filename,
        fanart_new_path_with_filename,
        naming_rule,
        poster_final_path,
        thumb_final_path,
        fanart_final_path,
        vsmeta_new_path,  # ← 新增这一行
    ) = get_output_name(...)
```

#### 修改 C：添加 VSMETA 生成代码

在 `await write_nfo(file_info, res, nfo_new_path, folder_new_path, update_nfo)` 后面添加：

```python
    # Generate VSMETA file
    if DownloadableFile.VSMETA in manager.config.download_files:
        vsmeta_metadata = {
            "title": res.title,
            "originalTitle": res.originaltitle,
            "year": res.year,
            "rating": res.score,
            "outline": res.outline,
            "plot": res.plot,
            "director": res.director,
            "actor": res.actor,
            "tag": res.tag,
            "genre": res.genre,
            "studio": res.studio,
            "publisher": res.publisher,
        }
        poster_path = poster_final_path if await aiofiles.os.path.exists(poster_final_path) else None
        fanart_path = fanart_final_path if await aiofiles.os.path.exists(fanart_final_path) else None
        write_vsmeta(
            vsmeta_metadata,
            vsmeta_new_path,
            poster_path,
            fanart_path
        )
```

---

## 3️⃣ 使用修改后的源码

### 方法 A：如果你使用 build-mdcx Docker 构建
1. 把修改后的源码放在 Docker 构建上下文的正确位置
2. 按照 `DOCKER_PUBLISH_GUIDE.md` 文档中的步骤构建 Docker 镜像

### 方法 B：使用本仓库的 CI/CD
1. 把修改后的源码正确放置在 mdcx-docker 仓库中（通常通过 prepare-src.sh 脚本或 git submodule）
2. 配置好 GitHub Secrets
3. 触发 GitHub Actions 构建

---

## 🎉 完成！

按照以上步骤完成修改后，你就拥有了完整的 VSMETA 功能！现在可以构建镜像并在群晖上使用了！
