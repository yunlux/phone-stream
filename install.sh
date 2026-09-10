#!/bin/bash
# phone-stream 安装脚本
set -e

HERE="$(cd "$(dirname "$0")" && pwd)"
BIN="${1:-$HOME/.local/bin}"

echo "==> 安装到 $BIN"
mkdir -p "$BIN"
for f in phone_media_controller phone_audio_scrcpy phone_video_scrcpy; do
    install -m 0755 "$HERE/bin/$f" "$BIN/$f"
    echo "    $f"
done

echo
echo "==> 依赖检查"
for cmd in adb scrcpy avahi-browse; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "    [ok] $cmd"
    else
        echo "    [缺失] $cmd"
    fi
done
python3 - <<'EOF' 2>/dev/null || echo "    [缺失] python3-tk (tkinter)"
import tkinter  # noqa: F401
print("    [ok] python3-tk")
EOF

cat <<'EOF'

安装完成。运行：
    phone_media_controller

提示：确保 ~/.local/bin 在 PATH 中：
    export PATH="$HOME/.local/bin:$PATH"
EOF
