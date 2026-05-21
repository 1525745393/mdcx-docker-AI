#!/usr/bin/env python3
"""
VSMETA 编码器简单测试脚本
"""
import sys
import os
import struct
import json

# 测试 VSMETA 编码器的核心功能
# 不依赖 MDCx 项目的完整依赖


class SimpleVSMetaEncoder:
    """简单的 VSMETA 编码器，用于测试"""

    CONTENT_TYPE_MOVIE = 1
    CONTENT_TYPE_TV = 2

    MAGIC = b"VSMP"
    VERSION = 0x0100

    def encode(
        self,
        content_type,
        title,
        original_title,
        year,
        release_date,
        rating,
        content_rating,
        plot,
        poster_data=None,
        backdrop_data=None,
        actors=None,
        directors=None,
        genres=None,
        writers=None,
        tmdb_id=None,
        imdb_id=None,
        locked=False,
        **kwargs
    ):
        data = {
            "type": content_type,
            "title": title,
            "originalTitle": original_title,
            "year": year,
            "releaseDate": release_date,
            "rating": rating,
            "contentRating": content_rating,
            "plot": plot,
            "actors": actors or [],
            "directors": directors or [],
            "genres": genres or [],
            "writers": writers or [],
            "tmdbId": tmdb_id,
            "imdbId": imdb_id,
            "locked": locked,
        }

        if content_type == self.CONTENT_TYPE_TV:
            data["season"] = kwargs.get("season", 1)
            data["episode"] = kwargs.get("episode", 1)
            data["episodeTitle"] = kwargs.get("episode_title", "")

        json_str = json.dumps(data, ensure_ascii=False, separators=(",", ":"))
        json_bytes = json_str.encode("utf-8")

        buffer = bytearray()
        buffer.extend(self.MAGIC)
        buffer.extend(struct.pack(">H", self.VERSION))
        buffer.extend(b"\x00\x00")
        buffer.extend(struct.pack("<I", len(json_bytes)))
        buffer.extend(json_bytes)

        if poster_data:
            buffer.extend(struct.pack("<I", len(poster_data)))
            buffer.extend(poster_data)
        else:
            buffer.extend(struct.pack("<I", 0))

        if backdrop_data:
            buffer.extend(struct.pack("<I", len(backdrop_data)))
            buffer.extend(backdrop_data)
        else:
            buffer.extend(struct.pack("<I", 0))

        return bytes(buffer)


def test_vsmeta():
    print("测试 VSMETA 编码器核心功能...")

    encoder = SimpleVSMetaEncoder()

    try:
        vsmeta_data = encoder.encode(
            content_type=encoder.CONTENT_TYPE_MOVIE,
            title="测试电影",
            original_title="Test Movie",
            year=2024,
            release_date="2024-01-01",
            rating=8.5,
            content_rating="PG-13",
            plot="这是一个测试电影的描述。",
            poster_data=None,
            backdrop_data=None,
            actors=["演员1", "演员2"],
            directors=["导演1"],
            genres=["剧情", "动作"],
            writers=["编剧1"],
            tmdb_id=None,
            imdb_id="tt1234567",
            locked=False
        )

        print(f"✓ 成功生成 VSMETA 数据，大小：{len(vsmeta_data)} 字节")
        print(f"  魔数: {vsmeta_data[:4]!r}")

        # 解析验证
        assert vsmeta_data[:4] == encoder.MAGIC
        version = struct.unpack(">H", vsmeta_data[4:6])[0]
        print(f"  版本: {version:#04x}")

        json_len = struct.unpack("<I", vsmeta_data[8:12])[0]
        print(f"  JSON 数据长度: {json_len} 字节")

        json_data = vsmeta_data[12:12+json_len]
        parsed = json.loads(json_data.decode("utf-8"))
        print(f"  解析成功: title={parsed['title']}")

        with open("test_simple.vsmeta", "wb") as f:
            f.write(vsmeta_data)
        print(f"✓ 测试文件已保存：test_simple.vsmeta")

        print("\n🎉 所有测试通过！")
        return True

    except Exception as e:
        print(f"✗ 测试失败: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    success = test_vsmeta()
    sys.exit(0 if success else 1)
