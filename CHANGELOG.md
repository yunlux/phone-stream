# Changelog

## v0.2.12 (2026-09-11)

### Added
- **PC Gain** slider on a card, shown only when its audio source is `playback` (playback capture ignores the phone volume); it attenuates the stream on the PC side via `pactl`
- Card ♥: when there is no media-notification like action, it now taps an on-screen like/favorite button through MCP accessibility (e.g. Xiaohongshu) instead of opening and closing the notification shade

### Changed
- Microphone and audio can run **at the same time** again (the v0.2.11 mutual exclusion was reverted)
- MIC / CAM / SCR / SET are now flat "indicator" chips: dim = off, filled with the stream's accent colour = on (no more `✓` suffix)
- Settings uses a dark ttk theme; WiFi / USB parameter groups are framed boxes with right-aligned labels
- State chips are repainted only when they change (no more flicker)

### Fixed
- The ♥ button passed the wrong argument and silently did nothing
- MCP sessions are now closed on exit / SIGTERM and created under a lock, so they no longer pile up on the phone (which caused `503 Too many active sessions`)
- Running streams are detected from the process list and stale pid files are ignored (fixes camera/screen chips showing "on" and stops killing a recycled pid)

## v0.2.11 (2026-09-11)

### Fixed
- Streams are detected from the live process list, so the audio / mic / screen / camera buttons reflect reality even if a pid file went missing; stopping kills the process group (TERM → KILL) and clears orphans before a new start
- Audio and microphone are mutually exclusive per phone (they conflict on the same device): starting one stops the other
- Scripts run scrcpy in the background and `wait`, so a stop takes effect immediately (the old foreground run delayed the TERM trap, which left orphaned processes and made the mic button appear stuck)

## v0.2.10 (2026-09-11)

### Changed
- Screen/camera window titles now include the connection type, e.g. `k80 screen (USB)` / `k90 camera (WiFi)`

## v0.2.9 (2026-09-11)

### Fixed
- Selecting **USB** no longer makes a stream silently do nothing when the phone is not actually on USB — it now falls back to WiFi (`wifi` still forces wireless)

## v0.2.8 (2026-09-11)

### Changed
- Screen / camera parameters are now dropdowns with preset options for easy selection:
  - screen size = long-edge px list (`0` = native); camera size = `WxH` list
  - fps, bitrate and video codec (h264 / h265 / av1 / vp8 / vp9) are selectable too

## v0.2.7 (2026-09-11)

### Changed
- Settings dialog is now **tabbed** (General / Audio / Microphone / Screen / Camera / Connection) instead of one long page
- Every stream has its own parameters in two columns — **WiFi** and **USB** — and uses the group matching its connection:
  - audio / mic: delay, codec, bitrate
  - screen / camera: size, fps, bitrate, video codec

### Added
- `phone_video_scrcpy` accepts optional `size`, `fps`, `bitrate (Mbps)`, `codec`

## v0.2.6 (2026-09-11)

### Added
- Per-stream **USB / WiFi ADB** selection (`auto` / `wifi` / `usb`) in each device's settings; a `· USB` marker shows when the device is connected over USB
- Scripts accept a `usb:<serial>` target to use a USB-connected device directly (no mDNS/discovery)

### Changed
- adb control commands automatically use the USB serial when the device is connected over USB

## v0.2.5 (2026-09-11)

### Removed
- The stop (⏹) button on each card (meaningless for these audio/video streams)

## v0.2.4 (2026-09-11)

### Added
- A ♥ button on each card to like/collect the current track: it fires the media notification's like action via the phone-side MCP (`android_notification_list` + `android_notification_action`), falling back to expanding the notification shade and tapping it via adb

## v0.2.3 (2026-09-11)

### Changed
- Audio stream nodes are named `<device> audio` / `<device> mic` (e.g. `k80 audio`); `application.name` and `node.description` are set to that name and `media.name` is emptied, so qpwgraph shows exactly that name (no `scrcpy/... [scrcpy]`)

### Fixed
- A stable per-device/role node name lets qpwgraph remember the node position (previously the name changed on every connection, so new nodes were dropped far away)

## v0.2.2 (2026-09-11)

### Added
- In-app language switch: a **中文 / EN** button in the top bar; the choice is saved to `settings.json` and remembered next launch

### Changed
- Language resolution order: saved setting > `PHONE_STREAM_LANG` > English

## v0.2.1 (2026-09-11)

### Changed
- UI text defaults to English; set `PHONE_STREAM_LANG=zh` for Chinese
- All code comments translated to English
- Docs: English default with Chinese versions (`README.zh-CN.md`, `CHANGELOG.zh-CN.md`)

### Fixed
- Restored the volume +/- buttons (they use relative volume keys, which work where `volume --set` does not)
- Volume slider uses relative volume keys by delta
- Poll anti-overlap to stop the card flickering while a video is paused

## v0.2.0 (2026-09-11)

### Added
- Card-based UI: one card per device (device info + media info + playback controls + settings)
- Microphone / camera / screen toggle buttons (independent streams, coexisting with audio)
- Settings: name, delay, codec, bitrate, audio source
- Volume slider
- MCP fallback: for apps without a MediaSession (e.g. Xiaohongshu), read the on-screen title/artist via the phone-side MCP accessibility service; shows `MCP offline` when unreachable
- Disconnect everything (audio / mic / camera / screen) when the program closes
- `sync-from-live.sh`: sync the deployed scripts into this repo with automatic de-sensitization

### Changed
- Merged Connect / Disconnect into a single toggle button
- Card buttons keep priority so they are not clipped when the window shrinks
- Smaller playback buttons, volume slider moved onto the same row

### Fixed
- Prefer the live scanned address for a device (stale stream cache caused missing media)
- Filter out KDE Connect mirrored sessions (PC media was shown as phone media)

## v0.1.0

- Initial release: mDNS auto-discovery / manual add, audio streaming controller window, generic `phone_audio_scrcpy` / `phone_video_scrcpy`
