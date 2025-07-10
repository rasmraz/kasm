# Chrome Webtop - Kasm Workspace

This is a Chrome-only webtop based on Kasm Technologies' workspace images. It provides a minimal desktop environment with Google Chrome as the primary application.

## Features

- Google Chrome browser
- Minimal XFCE desktop environment optimized for single application use
- Web-based VNC access
- Security policies and restrictions
- File chooser restrictions for enhanced security

## Quick Start

### Using Docker Compose (Recommended)

1. Build and run the container:
```bash
docker-compose up -d
```

2. Access the webtop in your browser:
   - URL: https://work-1-hefnmwebvwfojncq.prod-runtime.all-hands.dev
   - Password: `password`

### Using Docker directly

1. Build the image:
```bash
docker build -t chrome-webtop .
```

2. Run the container:
```bash
docker run -d \
  --name chrome-webtop \
  -p 12000:6901 \
  -e VNC_PW=password \
  --shm-size=512mb \
  chrome-webtop
```

3. Access the webtop at: https://work-1-hefnmwebvwfojncq.prod-runtime.all-hands.dev

## Environment Variables

- `VNC_PW`: Password for VNC access (default: password)
- `LAUNCH_URL`: URL to open when Chrome starts
- `KASM_URL`: Alternative way to set the startup URL

## Security Features

- URL blocklist policies
- Restricted file chooser
- Single application mode
- No desktop panel for minimal attack surface

## Customization

To customize the Chrome startup behavior, modify the `custom_startup.sh` script in the `install/chrome/` directory.

To add or modify Chrome policies, edit the JSON files in the `install/chrome-managed-policies/` directory.