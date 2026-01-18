# Video Thumbnail Extraction Scripts

이 스크립트들은 비디오 파일에서 첫 번째 I-frame을 추출하여 썸네일로 저장합니다.

## 사용 방법

### Bash 스크립트

```bash
# 실행 권한 부여
chmod +x thumbnail.sh

# 썸네일 추출
./thumbnail.sh input-video.mp4 thumbnail.png
```

### Node.js 스크립트

```bash
# 썸네일 추출
node thumbnail.js input-video.mp4 thumbnail.png
```

## FFmpeg 명령어 설명

### 첫 번째 I-frame 추출
```bash
ffmpeg -i input.mp4 -vf "select='eq(pict_type,I)'" -vframes 1 -q:v 2 thumbnail.png -y
```

**옵션 설명:**
- `-i input.mp4`: 입력 비디오 파일
- `-vf "select='eq(pict_type,I)'"`: I-frame만 선택하는 필터
- `-vframes 1`: 첫 번째 프레임만 추출
- `-q:v 2`: 출력 품질 (1-31, 낮을수록 고품질)
- `-y`: 기존 파일 덮어쓰기

### 특정 시간의 프레임 추출
```bash
ffmpeg -i input.mp4 -ss 00:00:05 -vframes 1 thumbnail.png
```

**옵션 설명:**
- `-ss 00:00:05`: 5초 지점으로 이동
- `-vframes 1`: 1개의 프레임만 추출

### 썸네일 크기 조절
```bash
ffmpeg -i input.mp4 -vf "select='eq(pict_type,I)',scale=640:-1" -vframes 1 thumbnail.png
```

**옵션 설명:**
- `scale=640:-1`: 너비 640px, 높이는 비율 유지

### 고품질 썸네일
```bash
ffmpeg -i input.mp4 -vf "select='eq(pict_type,I)'" -vframes 1 -q:v 1 thumbnail.jpg
```

## 배치 처리 예제

여러 비디오 파일에서 썸네일 추출:

```bash
# 현재 디렉토리의 모든 mp4 파일에서 썸네일 추출
for video in *.mp4; do
  ./thumbnail.sh "$video" "${video%.mp4}.png"
done
```

## 웹 프로젝트에서 사용

프로젝트의 static 폴더에 썸네일을 저장하려면:

```bash
node thumbnail.js path/to/video.mp4 ../web/static/thumbnails/thumb.png
```

또는 npm script로 추가:

```json
{
  "scripts": {
    "thumb": "node scripts/thumbnail.js"
  }
}
```

실행:
```bash
npm run thumb -- video.mp4 static/thumb.png
```
