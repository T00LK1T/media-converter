"""
FFMPEG 로 생성된 비디오 팔레트의 각 색상 값을 무작위로 섞는 스크립트
"""

import random
import sys
from PIL import Image
import numpy as np
import argparse
from pathlib import Path
from tqdm import tqdm


def swap_palette_colors(input_path: Path, output_path: Path) -> None:
    """팔레트의 각 색상을 무작위로 섞음"""
    if not input_path.is_file():
        print(f"입력 파일이 존재하지 않습니다: {input_path}")
        sys.exit(1)

    # 팔레트 이미지 열기
    img = Image.open(input_path).convert("RGBA")
    data = np.array(img)
    shape = data.shape
    flat_data = data.reshape(-1, shape[2])
    unique_colors = np.unique(flat_data, axis=0)
    color_list = unique_colors.tolist()
    random.shuffle(color_list)
    color_map = {
        tuple(orig): tuple(new) for orig, new in zip(unique_colors, color_list)
    }

    # 색상 매핑 적용
    for i in tqdm(range(flat_data.shape[0]), desc="색상 매핑 중"):
        orig_color = tuple(flat_data[i])
        if orig_color in color_map:
            flat_data[i] = color_map[orig_color]
    shuffled_data = flat_data.reshape(shape)
    shuffled_img = Image.fromarray(shuffled_data, mode="RGBA")
    shuffled_img.save(output_path)
    print(f"색상이 섞인 팔레트 저장 완료: {output_path}")


def main():
    # file open
    parser = argparse.ArgumentParser(
        description="FFMPEG 로 생성된 비디오 팔레트의 각 색상 값을 무작위로 섞는 스크립트"
    )
    parser.add_argument("input", type=str, help="입력 팔레트 이미지 파일 경로")
    parser.add_argument("output", type=str, help="출력 팔레트 이미지 파일 경로")
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    swap_palette_colors(input_path, output_path)


if __name__ == "__main__":
    main()
