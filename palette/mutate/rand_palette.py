"""
FFMPEG 로 생성된 비디오 팔레트의 각 색상 값을 무작위로 변경하는 스크립트
"""

import random
import sys
from PIL import Image
import numpy as np
import argparse
from pathlib import Path
from tqdm import tqdm


def randomize_palette(
    input_path: Path,
    output_path: Path,
    r_min: int = -50,
    r_max: int = 50,
    g_min: int = -50,
    g_max: int = 50,
    b_min: int = -50,
    b_max: int = 50,
) -> None:
    """팔레트의 각 색상 값을 무작위로 변경"""
    if not input_path.is_file():
        print(f"입력 파일이 존재하지 않습니다: {input_path}")
        sys.exit(1)

    # 팔레트 이미지 열기
    img = Image.open(input_path).convert("RGBA")
    data = np.array(img, dtype=np.int32)  # int32로 변환하여 overflow 방지

    print(f"R 변화량: {r_min} ~ {r_max}")
    print(f"G 변화량: {g_min} ~ {g_max}")
    print(f"B 변화량: {b_min} ~ {b_max}")

    # 각 픽셀의 RGB 값을 랜덤하게 증감
    for i in tqdm(range(data.shape[0]), desc="색상 변경 중"):
        for j in range(data.shape[1]):
            # R 채널
            data[i, j, 0] += random.randint(r_min, r_max)
            # G 채널
            data[i, j, 1] += random.randint(g_min, g_max)
            # B 채널
            data[i, j, 2] += random.randint(b_min, b_max)
            # A 채널은 그대로 유지

    # 0-255 범위로 클리핑
    data = np.clip(data, 0, 255).astype(np.uint8)

    modified_img = Image.fromarray(data, mode="RGBA")
    modified_img.save(output_path)
    print(f"변경된 팔레트 저장 완료: {output_path}")


def main():
    # file open
    parser = argparse.ArgumentParser(
        description="FFMPEG 로 생성된 비디오 팔레트의 각 색상 값을 무작위로 변경하는 스크립트"
    )
    parser.add_argument("input", type=str, help="입력 팔레트 이미지 파일 경로")
    parser.add_argument("output", type=str, help="출력 팔레트 이미지 파일 경로")
    parser.add_argument(
        "--r-min", type=int, default=-50, help="R 값 최소 변화량 (기본: -50)"
    )
    parser.add_argument(
        "--r-max", type=int, default=50, help="R 값 최대 변화량 (기본: 50)"
    )
    parser.add_argument(
        "--g-min", type=int, default=-50, help="G 값 최소 변화량 (기본: -50)"
    )
    parser.add_argument(
        "--g-max", type=int, default=50, help="G 값 최대 변화량 (기본: 50)"
    )
    parser.add_argument(
        "--b-min", type=int, default=-50, help="B 값 최소 변화량 (기본: -50)"
    )
    parser.add_argument(
        "--b-max", type=int, default=50, help="B 값 최대 변화량 (기본: 50)"
    )
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    randomize_palette(
        input_path,
        output_path,
        args.r_min,
        args.r_max,
        args.g_min,
        args.g_max,
        args.b_min,
        args.b_max,
    )


if __name__ == "__main__":
    main()
