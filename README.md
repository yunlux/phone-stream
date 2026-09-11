# Phone Stream

**English** | [简体中文](README.zh-CN.md)

A small Linux desktop tool: stream an **Android phone's audio, microphone, camera and screen** to your computer over USB / wireless ADB, with a **card-based GUI controller**.

- **Auto-discovery**: mDNS scan for wireless-debug devices; remembers devices (survives IP/port changes)
- **Manual add**: enter `IP:port` directly
- **One card per device**: player / title / playback state + playback controls
- **One-click toggles**: microphone / camera / screen, each independent and can run alongside the audio stream
- **Also usable from the CLI**: the scripts work standalone

> The GUI defaults to English but can be switched at any time with the **中文 / EN** button in the top bar (remembered in `settings.json`); `PHONE_STREAM_LANG=zh` also works.

---

## Dependencies

| Purpose | Package (Arch naming) |
| --- | --- |
| GUI | `python` (with tkinter) |
| Streaming | `scrcpy` |
| ADB | `android-tools` |
| mDNS discovery | `avahi` (provides `avahi-browse`) |
| Helpers | `bash`, `coreutils`, `util-linux` (`flock`, `timeout`) |
| Audio routing (optional) | `pipewire` / `pulseaudio` |

> The phone needs **Developer options → Wireless debugging** (Android 11+); first pairing is confirmed on the phone.

## Install

```bash
git clone <this repo> phone-stream
cd phone-stream
./install.sh
```

`install.sh` copies the scripts to `~/.local/bin` (make sure it is on your `PATH`), then:

```bash
phone_media_controller      # open the GUI
```

CLI only:

```bash
phone_audio_scrcpy <serial|IP:port> [name] [buffer_ms] [flac|opus|aac] [bitrate] [output|playback|mic]
phone_video_scrcpy <serial|IP:port> <screen|camera|camera-back> [name] [size] [fps] [bitrate_mbps] [codec]
```

## Usage

### GUI

Start `phone_media_controller`, click **Scan** or **Add** to find a device. On each card's top-right:

| Button | Action |
| --- | --- |
| Connect / Disconnect | Toggle that phone's audio stream (pauses playback before disconnecting) |
| 🖥 | Screen mirror (opens a window) |
| 📷 | Front camera (opens a window) |
| 🎤 | Microphone stream |
| ⚙ | Settings: name / delay / codec / bitrate / audio source |

A ✓ marks an enabled toggle. Settings are saved to `~/.config/phone-stream/stream_devices.json`.

### Audio sources

| Source | Meaning |
| --- | --- |
| `output` | Forward the whole audio output (disables local playback) |
| `playback` | Capture app playback (Android 13+, apps may opt out) |
| `mic` | Capture the microphone |

> Support varies by device: if a phone yields silence with `output`, try `playback`.

### Connection: USB or WiFi

Each stream (audio / mic / screen / camera) can independently use **USB** or **WiFi ADB**. Set it per device in **⚙ Settings → Connection (ADB)**:

| Value | Meaning |
| --- | --- |
| `auto` | use USB when the phone is plugged in, otherwise WiFi (default) |
| `wifi` | always wireless debugging (mDNS discovery) |
| `usb` | always USB (`usb:<serial>`) |

Delay / codec / bitrate are configured twice — one group for **WiFi** and one for **USB** — and each stream uses the group that matches its connection.

### Streaming into a specific PipeWire sink (optional)

By default audio plays to the system default output. To route it into a virtual sink
(e.g. a live-streaming chain), set:

```bash
export PHONE_STREAM_SINK=virtual_A
phone_media_controller
```

## Files

| Path | Description |
| --- | --- |
| `~/.config/phone-stream/stream_devices.json` | device list and per-device settings |
| `~/.config/phone-stream/settings.json` | saved UI language (set by the top-bar button) |
| `~/.config/phone-stream/stream_<id>.{pid,addr,lock}` | per-stream runtime state |
| `PHONE_STREAM_HOME` | override the config directory |
| `PHONE_STREAM_LANG` | UI language (`en` default, `zh` optional) |

## Known notes

- **Only one scrcpy audio stream per phone at a time**: multiple sessions capturing the same device conflict and go silent; disconnect the old stream first.
- Wireless debugging must be **re-enabled after every phone reboot**; the port changes. This tool re-discovers it via mDNS.
- Xiaomi "dual WiFi" may change the phone's Wi-Fi IP; the tool follows it.
- Camera/screen work best over USB or a stable Wi-Fi link.

## License

MIT, see [LICENSE](LICENSE).
