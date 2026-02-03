#!/bin/bash
# deploy-openclaw.sh - Cross-platform OpenClaw deployment script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Detect OS
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

print_status "🦞 OpenClaw Enhanced Deployment Script"
print_status "Detected OS: $OS"

# Check prerequisites
print_step "Checking prerequisites..."

# Check Node.js
if ! command -v node &> /dev/null; then
    print_error "Node.js is required but not installed."
    print_error "Please install Node.js 22+ from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    print_error "Node.js 22+ is required. Found version: $(node --version)"
    exit 1
fi
print_status "✅ Node.js $(node --version)"

# Check Git
if ! command -v git &> /dev/null; then
    print_error "Git is required but not installed."
    print_error "Please install Git from https://git-scm.com/"
    exit 1
fi
print_status "✅ Git $(git --version | cut -d' ' -f3)"

# Check/Install pnpm
if ! command -v pnpm &> /dev/null; then
    print_warning "pnpm not found. Installing..."
    npm install -g pnpm
fi
print_status "✅ pnpm $(pnpm --version)"

# Clone repository (or update if exists)
print_step "Setting up OpenClaw Enhanced..."

REPO_URL="https://github.com/yourusername/openclaw-enhanced.git"
OPENCLAW_DIR="openclaw-enhanced"

if [ -d "$OPENCLAW_DIR" ]; then
    print_warning "Directory $OPENCLAW_DIR exists. Updating..."
    cd "$OPENCLAW_DIR"
    git pull origin main
else
    print_status "Cloning repository..."
    git clone "$REPO_URL" "$OPENCLAW_DIR"
    cd "$OPENCLAW_DIR"
fi

# Install dependencies
print_step "Installing dependencies..."
pnpm install

# Build application
print_step "Building OpenClaw..."
pnpm build

# Build UI
print_step "Building UI assets..."
pnpm ui:build

# Check platform-specific package managers
print_step "Checking package managers for $OS..."

case $OS in
    "linux")
        if command -v apt &> /dev/null; then
            print_status "✅ apt package manager available"
        fi
        if command -v yum &> /dev/null; then
            print_status "✅ yum package manager available"
        fi
        if command -v pacman &> /dev/null; then
            print_status "✅ pacman package manager available"
        fi
        ;;
    "macos")
        if command -v brew &> /dev/null; then
            print_status "✅ Homebrew available"
        else
            print_warning "Homebrew not found. Install from https://brew.sh/"
        fi
        ;;
    "windows")
        # Note: These checks work in Git Bash/WSL
        if command -v winget.exe &> /dev/null; then
            print_status "✅ winget available"
        fi
        if command -v choco &> /dev/null; then
            print_status "✅ Chocolatey available"
        fi
        if command -v scoop &> /dev/null; then
            print_status "✅ Scoop available"
        fi
        ;;
esac

# Test the installation
print_step "Testing OpenClaw installation..."

# Create test config if it doesn't exist
if [ ! -f ~/.openclaw/config.json ]; then
    mkdir -p ~/.openclaw
    echo '{"test": true}' > ~/.openclaw/config.json
fi

# Run a quick test
if pnpm openclaw --help &> /dev/null; then
    print_status "✅ OpenClaw CLI working"
else
    print_error "❌ OpenClaw CLI test failed"
    exit 1
fi

# Display completion message
echo ""
print_status "🎉 OpenClaw Enhanced deployed successfully!"
echo ""
print_step "Next steps:"
echo "1. Start the gateway:"
echo -e "   ${BLUE}pnpm openclaw gateway${NC}"
echo ""
echo "2. Access the web UI:"
echo -e "   ${BLUE}http://localhost:18789/?token=test-token-12345${NC}"
echo ""
echo "3. Add your LLM providers (Claude, OpenAI, etc.)"
echo ""
echo "4. Connect messaging channels (WhatsApp, Telegram, etc.)"
echo ""
print_status "📚 Documentation: https://docs.openclaw.ai"
print_status "🐞 Issues: https://github.com/yourusername/openclaw-enhanced/issues"

# Show platform-specific tips
case $OS in
    "windows")
        echo ""
        print_warning "Windows Tips:"
        echo "- Use PowerShell instead of CMD for better experience"
        echo "- Install Windows Terminal for better console experience"
        echo "- Consider WSL2 for more Unix-like experience"
        ;;
    "macos")
        echo ""
        print_warning "macOS Tips:"
        echo "- You may need to allow the app in System Preferences > Security & Privacy"
        echo "- Consider using the macOS app for easier credential management"
        ;;
    "linux")
        echo ""
        print_warning "Linux Tips:"
        echo "- Consider running as systemd service for production"
        echo "- Check firewall settings if accessing from remote machines"
        ;;
esac

print_status "Deployment complete! 🦞"