"""
팔레트 변형 통합 스크립트
- rand: RGB 값을 무작위로 변경
- swap: 색상을 무작위로 섞음
"""

import argparse
import sys
from pathlib import Path
from rand_palette import randomize_palette
from swap_palette import swap_palette_colors


def main():
    parser = argparse.ArgumentParser(
        description="FFMPEG 팔레트를 변형하는 통합 스크립트",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
사용 예시:
  # 색상 값을 랜덤하게 변경
  %(prog)s input.png output.png --mode rand

  # 색상 값을 랜덤하게 변경 (범위 지정)
  %(prog)s input.png output.png --mode rand --r-min -100 --r-max 100

  # 색상을 무작위로 섞음
  %(prog)s input.png output.png --mode swap
        """,
    )

    parser.add_argument("input", type=str, help="입력 팔레트 이미지 파일 경로")
    parser.add_argument("output", type=str, help="출력 팔레트 이미지 파일 경로")
    parser.add_argument(
        "--mode",
        type=str,
        choices=["rand", "swap"],
        default="rand",
        help="변형 모드 (rand: RGB 값 랜덤 변경, swap: 색상 섞기, 기본: rand)",
    )

    # rand 모드 전용 옵션
    rand_group = parser.add_argument_group("rand 모드 옵션")
    rand_group.add_argument(
        "--r-min", type=int, default=-50, help="R 값 최소 변화량 (기본: -50)"
    )
    rand_group.add_argument(
        "--r-max", type=int, default=50, help="R 값 최대 변화량 (기본: 50)"
    )
    rand_group.add_argument(
        "--g-min", type=int, default=-50, help="G 값 최소 변화량 (기본: -50)"
    )
    rand_group.add_argument(
        "--g-max", type=int, default=50, help="G 값 최대 변화량 (기본: 50)"
    )
    rand_group.add_argument(
        "--b-min", type=int, default=-50, help="B 값 최소 변화량 (기본: -50)"
    )
    rand_group.add_argument(
        "--b-max", type=int, default=50, help="B 값 최대 변화량 (기본: 50)"
    )

    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.is_file():
        print(f"입력 파일이 존재하지 않습니다: {input_path}")
        sys.exit(1)

    print(f"모드: {args.mode}")
    print(f"입력: {input_path}")
    print(f"출력: {output_path}")
    print()

    if args.mode == "rand":
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
    elif args.mode == "swap":
        swap_palette_colors(input_path, output_path)


if __name__ == "__main__":
    main()
