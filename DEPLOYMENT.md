# OpenClaw Cross-Platform Deployment Guide

## 📦 Distribution Options

### Option 1: GitHub Repository + Manual Build
**Best for**: Developers who want full control and latest code

1. **Fork/Clone Repository**
   ```bash
   git clone https://github.com/yourusername/openclaw-enhanced.git
   cd openclaw-enhanced
   ```

2. **Platform-Specific Setup**
   - **Windows**: Ensure winget/chocolatey/scoop installed
   - **macOS**: Ensure brew installed  
   - **Linux**: Standard package managers (apt/yum/pacman)

3. **Build and Run**
   ```bash
   npm install -g pnpm
   pnpm install
   pnpm build
   pnpm ui:build
   pnpm openclaw gateway
   ```

### Option 2: GitHub Releases (Automated Builds)
**Best for**: End users who want pre-built packages

The GitHub Actions workflow creates:
- `openclaw-windows-vX.X.X.zip` (Windows binaries + deps)
- `openclaw-macos-vX.X.X.tar.gz` (macOS Universal)
- `openclaw-linux-vX.X.X.tar.gz` (Linux x64)
- `openclaw-docker-vX.X.X.tar` (Multi-arch Docker image)

### Option 3: Docker Containers
**Best for**: Server deployments and consistent environments

```bash
# Pull from GitHub Container Registry (when released)
docker pull ghcr.io/yourusername/openclaw-enhanced:latest

# Or build locally
docker build -t openclaw-enhanced .
docker run -p 18789:18789 -v ~/.openclaw:/app/.openclaw openclaw-enhanced
```

### Option 4: Package Managers (Future)
**Target for**: Easy installation across platforms

- **Windows**: `winget install openclaw` 
- **macOS**: `brew install openclaw`
- **Linux**: `apt install openclaw` / `snap install openclaw`

## 🚀 Quick Deploy Scripts

### Windows PowerShell
```powershell
# Create deploy-windows.ps1
$ErrorActionPreference = "Stop"

Write-Host "🦞 Deploying OpenClaw for Windows..." -ForegroundColor Green

# Check prerequisites
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Error "Node.js 22+ required. Install from https://nodejs.org/"
}

if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git required. Install from https://git-scm.com/"
}

# Clone and build
git clone https://github.com/yourusername/openclaw-enhanced.git
Set-Location openclaw-enhanced
npm install -g pnpm
pnpm install
pnpm build
pnpm ui:build

Write-Host "✅ OpenClaw deployed successfully!" -ForegroundColor Green
Write-Host "Run: pnpm openclaw gateway" -ForegroundColor Yellow
Write-Host "UI: http://localhost:18789/?token=test-token-12345" -ForegroundColor Yellow
```

### macOS/Linux Bash
```bash
#!/bin/bash
# Create deploy-unix.sh

set -e

echo "🦞 Deploying OpenClaw for $(uname)..."

# Check prerequisites
command -v node >/dev/null 2>&1 || { echo "Node.js 22+ required"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "Git required"; exit 1; }

# Clone and build
git clone https://github.com/yourusername/openclaw-enhanced.git
cd openclaw-enhanced
npm install -g pnpm
pnpm install
pnpm build
pnpm ui:build

echo "✅ OpenClaw deployed successfully!"
echo "Run: pnpm openclaw gateway"
echo "UI: http://localhost:18789/?token=test-token-12345"
```

## 🐳 Docker Deployment

### Dockerfile Optimizations
The included Dockerfile supports:
- Multi-stage builds for smaller images
- Multi-architecture (amd64, arm64)
- Non-root user for security
- Volume mounts for persistent data

### Docker Compose (Production)
```yaml
version: '3.8'
services:
  openclaw:
    build: .
    ports:
      - "18789:18789"
    volumes:
      - ~/.openclaw:/app/.openclaw
      - /var/run/docker.sock:/var/run/docker.sock  # If using Docker skills
    environment:
      - NODE_ENV=production
      - OPENCLAW_CONFIG_PATH=/app/.openclaw/config.json
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:18789/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## 🔧 Platform-Specific Configuration

### Windows
- **Package Managers**: Automatically detects winget → chocolatey → scoop
- **Paths**: Uses Windows-style paths and %USERPROFILE%
- **Services**: Consider running as Windows Service for production

### macOS
- **Code Signing**: For distribution, sign with Apple Developer certificate
- **App Bundle**: Can be packaged as .app for easier distribution
- **Homebrew**: Detects and uses brew for package management

### Linux
- **Systemd**: Create service files for automatic startup
- **AppImage**: Consider packaging as portable AppImage
- **Package Formats**: Support .deb, .rpm, .tar.gz distributions

## 📊 Build Matrix (GitHub Actions)

The automated builds support:

| Platform | Architecture | Package Format |
|----------|--------------|----------------|
| Windows | x64 | .zip + .exe installer |
| macOS | Universal (Intel + Apple Silicon) | .tar.gz + .dmg |
| Linux | x64 | .tar.gz + .AppImage |
| Linux | ARM64 | .tar.gz |
| Docker | Multi-arch | linux/amd64, linux/arm64 |

## 🔐 Security Considerations

### Production Deployment
1. **Change default tokens**: Replace `test-token-12345` with secure random tokens
2. **HTTPS**: Use reverse proxy (nginx/Cloudflare) for SSL termination
3. **Firewall**: Restrict access to port 18789
4. **Updates**: Set up automated security updates
5. **Secrets**: Store API keys in environment variables, not config files

### Docker Security
```dockerfile
# Use non-root user
USER node

# Read-only filesystem where possible
--read-only

# Limit resources
--memory=1g --cpus=1.0

# Drop unnecessary capabilities
--cap-drop=ALL
```

## 📈 Monitoring and Logging

### Health Checks
- **HTTP**: `GET /health` endpoint
- **Skills**: `pnpm openclaw skills status --all`
- **Channels**: `pnpm openclaw channels status --all`

### Log Collection
- **Local**: `~/.openclaw/logs/`
- **Docker**: `docker logs openclaw`
- **Production**: Consider ELK stack or similar

## 🎯 Next Steps

1. **Test the deployment** on target platforms
2. **Set up GitHub repository** with enhanced code
3. **Configure GitHub Actions** for automated builds
4. **Create release documentation**
5. **Package for distribution** (optional installers)
6. **Submit to package managers** (brew, winget, etc.)

## 🆘 Troubleshooting

### Common Issues
- **Node.js version**: Ensure Node.js 22+ is installed
- **Permission errors**: Run as administrator/sudo for global pnpm install
- **Port conflicts**: Check if port 18789 is available
- **Package manager detection**: Verify winget/brew/apt is in PATH

### Platform-Specific Fixes
- **Windows**: Use PowerShell, not CMD
- **macOS**: May need to allow app in Security preferences
- **Linux**: Install build-essential for native dependencies

### Getting Help
- Check logs in `~/.openclaw/logs/`
- Use `pnpm openclaw diagnostics` command
- Report issues with system info: OS, Node.js version, pnpm version