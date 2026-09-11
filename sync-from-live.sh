#!/bin/bash
# 把 ~/.local/bin 下的实机脚本同步进本仓库（自动通用化：去个人路径/sink）。
# 用法: ./sync-from-live.sh   之后 git diff/commit 记录版本。
set -e
SRC="$HOME/.local/bin"
DST="$(cd "$(dirname "$0")" && pwd)/bin"
mkdir -p "$DST"

# 1) 控制器：k80_media_controller -> phone_media_controller
sed -e 's#CONF_DIR = os.path.expanduser("~/.config/adb-scrcpy")#CONF_DIR = os.environ.get("PHONE_STREAM_HOME") or os.path.expanduser("~/.config/phone-stream")#' \
    -e 's#"k80_media_controller.lock"#"phone_media_controller.lock"#' \
    -e 's#os\.path\.expanduser("~/.local/bin/phone_audio_scrcpy")#os.path.join(_HERE, "phone_audio_scrcpy")#' \
    -e 's#os\.path\.expanduser("~/.local/bin/phone_video_scrcpy")#os.path.join(_HERE, "phone_video_scrcpy")#' \
    "$SRC/k80_media_controller" > "$DST/phone_media_controller"

# 2) 视频脚本：配置目录通用化
sed -e 's#${XDG_CONFIG_HOME:-$HOME/.config}/adb-scrcpy#${PHONE_STREAM_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/phone-stream}#' \
    "$SRC/phone_video_scrcpy" > "$DST/phone_video_scrcpy"

# 3) 音频脚本：配置目录 + 输出 sink 通用化
sed -e 's#${XDG_CONFIG_HOME:-$HOME/.config}/adb-scrcpy#${PHONE_STREAM_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/phone-stream}#' \
    "$SRC/phone_audio_scrcpy" > "$DST/phone_audio_scrcpy"
python3 - "$DST/phone_audio_scrcpy" <<'PY'
import sys, re
p = sys.argv[1]
s = open(p).read()
pat = re.compile(r'    PIPEWIRE_PROPS="\{ \\"target\.object\\": \\"virtual_A\\".*?\n        scrcpy .*?\n', re.S)
rep = ('    ENVP=()\n'
       '    if [[ -n ${PHONE_STREAM_SINK:-} ]]; then\n'
       '        ENVP=(env PIPEWIRE_PROPS="{ \\"target.object\\": \\"${PHONE_STREAM_SINK}\\", \\"node.name\\": \\"stream_${ID}\\", \\"node.description\\": \\"${SAFE_NAME}\\" }")\n'
       '    fi\n'
       '    "${ENVP[@]}" scrcpy --window-title="$SAFE_NAME" -s "$ADDR" --no-video --no-window "${AUDIO_ARGS[@]}"\n')
s2 = pat.sub(rep, s, count=1)
open(p, "w").write(s2)
print("audio sink 通用化:", "ok" if s2 != s else "未匹配(需手动检查)")
PY

# 4) 控制器里补 _HERE 定义（若替换后用到了 _HERE 但没定义）
python3 - "$DST/phone_media_controller" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
if "_HERE" in s and "_HERE = " not in s:
    s = s.replace('CONF_DIR = ', '_HERE = os.path.dirname(os.path.abspath(__file__))\nCONF_DIR = ', 1)
    open(p, "w").write(s)
    print("已补 _HERE 定义")
PY

# 5) 统一把配置目录名替换彻底
sed -i 's#adb-scrcpy#phone-stream#g' "$DST/phone_media_controller" "$DST/phone_audio_scrcpy" "$DST/phone_video_scrcpy"

# 6) 其它通用化：示例 IP、注释
sed -i 's#192\.168\.2\.50#192.168.1.50#g' "$DST/phone_media_controller"
sed -i 's#→ PipeWire virtual_A#（可选输出到指定 PipeWire sink）#' "$DST/phone_audio_scrcpy"

chmod +x "$DST"/*
echo "同步完成 -> $DST"
