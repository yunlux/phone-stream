# Changelog

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
