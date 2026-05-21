#!/usr/bin/env python3
"""
VSMETA 编码器测试脚本
"""
import sys
import os

# 添加源代码路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '.mdcx_src'))

from mdcx.core.vsmeta import VSMetaEncoder


def test_vsmeta_encoder():
    """测试 VSMETA 编码器"""
    print("测试 VSMETA 编码器...")
    
    encoder = VSMetaEncoder()
    
    # 测试电影 VSMETA 编码
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
        
        # 写入测试文件
        with open("test_movie.vsmeta", "wb") as f:
            f.write(vsmeta_data)
        print(f"✓ 测试文件已保存：test_movie.vsmeta")
        
    except Exception as e:
        print(f"✗ VSMETA 编码失败：{e}")
        import traceback
        traceback.print_exc()
        return False
    
    print("\nVSMETA 编码器测试完成！")
    return True


if __name__ == "__main__":
    success = test_vsmeta_encoder()
    sys.exit(0 if success else 1)
