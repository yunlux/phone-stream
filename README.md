# 手机串流 (phone-stream)

Linux 桌面端的小工具：通过 USB / 无线 ADB 把 **Android 手机的声音、麦克风、相机、屏幕**串流到电脑，并提供一个**卡片式图形控制窗**。

- **自动发现**：mDNS 扫描同网段的无线调试设备，自动记住上次的设备（换 IP/端口也能连）
- **手动添加**：直接填 `IP:端口`
- **一张卡片一台设备**：卡片内显示播放器 / 曲名 / 播放状态，并提供播放控制
- **一键切换**：麦克风 / 相机 / 屏幕 各自独立开关，可与声音流同时使用
- **纯命令行也可用**：脚本可独立运行，方便脚本化

---

## 依赖

| 用途 | 软件包（Arch 命名） |
| --- | --- |
| 图形界面 | `python`（含 tkinter，即 `tk`） |
| 串流 | `scrcpy` |
| ADB | `android-tools` |
| mDNS 发现 | `avahi`（提供 `avahi-browse`） |
| 进程/端口辅助 | `bash`、`coreutils`、`util-linux`（`flock`、`timeout`） |
| 音频路由（可选） | `pipewire` / `pulseaudio` |

> 手机端需开启「开发者选项 → 无线调试」（Android 11+），首次需在手机上确认配对。

## 安装

```bash
git clone <本仓库地址> phone-stream
cd phone-stream
./install.sh
```

`install.sh` 会把脚本复制到 `~/.local/bin`（确保该目录在 `PATH` 中），然后：

```bash
phone_media_controller      # 打开控制窗
```

只想要命令行：

```bash
phone_audio_scrcpy <序列号|IP:端口> [显示名] [缓冲ms] [flac|opus|aac] [码率bps] [output|playback|mic]
phone_video_scrcpy <序列号|IP:端口> <screen|camera|camera-back> [显示名]
```

## 使用

### 图形界面

启动 `phone_media_controller`，点 **⟳ 扫描** 或 **＋ 手动添加** 找到设备。每张卡片右上角：

| 按钮 | 作用 |
| --- | --- |
| 连接 / 断开 | 开启 / 关闭该手机的声音串流（断开前会自动暂停播放） |
| 🖥 | 屏幕镜像（弹窗） |
| 📷 | 前置相机（弹窗） |
| 🎤 | 麦克风声音流 |
| ⚙ | 设置：延迟 / 编解码 / 码率 / 音频源 |

按钮带 ✓ 表示已开启。`连接`保存的音视频设置会写入 `~/.config/phone-stream/stream_devices.json`，下次打开自动显示。

### 音频源说明

| 源 | 含义 |
| --- | --- |
| `output` | 转发整个系统音频输出（会禁用手机本地播放） |
| `playback` | 捕获 App 播放（Android 13+，App 可退出捕获） |
| `mic` | 捕获麦克风 |

> 不同机型对源的支持不同：若某台手机 `output` 无声，改用 `playback` 通常可用。

### 输出到指定 PipeWire 虚拟设备（可选）

默认声音播放到系统默认输出。若想让串流进入某个虚拟 sink（例如把手机声音单独混到直播链路），设置环境变量：

```bash
export PHONE_STREAM_SINK=virtual_A
phone_media_controller
```

## 目录与文件

| 路径 | 说明 |
| --- | --- |
| `~/.config/phone-stream/stream_devices.json` | 设备列表与每设备设置 |
| `~/.config/phone-stream/stream_<id>.{pid,addr,lock}` | 各流的运行时状态 |
| `PHONE_STREAM_HOME` | 覆盖配置目录 |

## 已知注意事项

- **同一台手机同时只保留一条 scrcpy 音频流**：多个 session 抢同一设备采集会互相冲突导致静音；切换前先断开旧流。
- 无线调试在**手机每次重启后都要重新打开**，端口会变；本工具用 mDNS 自动发现新端口。
- 部分机型开启「双 WLAN/网络加速」会更换 Wi-Fi IP，本工具会自动跟随。
- 相机/屏幕采用有线或稳定 Wi-Fi 效果最好。

## License

MIT，见 [LICENSE](LICENSE)。
