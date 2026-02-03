---
name: video-frames
description: Extract frames or short clips from videos using ffmpeg.
homepage: https://ffmpeg.org
metadata: {"openclaw":{"emoji":"🎞️","requires":{"bins":["ffmpeg"]},"install":[{"id":"brew","kind":"brew","formula":"ffmpeg","bins":["ffmpeg"],"label":"Install ffmpeg (brew)"},{"id":"winget","kind":"winget","package":"Gyan.FFmpeg","bins":["ffmpeg"],"label":"Install ffmpeg (winget)"},{"id":"choco","kind":"choco","package":"ffmpeg","bins":["ffmpeg"],"label":"Install ffmpeg (chocolatey)"},{"id":"scoop","kind":"scoop","package":"ffmpeg","bins":["ffmpeg"],"label":"Install ffmpeg (scoop)"}]}}
---

# Video Frames (ffmpeg)

Extract a single frame from a video, or create quick thumbnails for inspection.

## Quick start

First frame:

```bash
{baseDir}/scripts/frame.sh /path/to/video.mp4 --out /tmp/frame.jpg
```

At a timestamp:

```bash
{baseDir}/scripts/frame.sh /path/to/video.mp4 --time 00:00:10 --out /tmp/frame-10s.jpg
```

## Notes

- Prefer `--time` for “what is happening around here?”.
- Use a `.jpg` for quick share; use `.png` for crisp UI frames.
