# Deploy OpenClaw Enhanced - Windows PowerShell Script
# deploy-openclaw.ps1

param(
    [Parameter(HelpMessage="Skip confirmation prompts")]
    [switch]$Force,
    
    [Parameter(HelpMessage="Installation directory")]
    [string]$InstallDir = "openclaw-enhanced",
    
    [Parameter(HelpMessage="Repository URL")]
    [string]$RepoUrl = "https://github.com/yourusername/openclaw-enhanced.git"
)

# Set error handling
$ErrorActionPreference = "Stop"

# Colors for output
function Write-Info($Message) { Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn($Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Error($Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-Step($Message) { Write-Host "[STEP] $Message" -ForegroundColor Blue }

Write-Info "🦞 OpenClaw Enhanced - Windows Deployment Script"
Write-Info "PowerShell Version: $($PSVersionTable.PSVersion)"

# Check prerequisites
Write-Step "Checking prerequisites..."

# Check Node.js
try {
    $nodeVersion = node --version
    $nodeMajorVersion = [int]($nodeVersion -replace 'v(\d+).*', '$1')
    if ($nodeMajorVersion -lt 22) {
        Write-Error "Node.js 22+ is required. Found: $nodeVersion"
        Write-Error "Please install from https://nodejs.org/"
        exit 1
    }
    Write-Info "✅ Node.js $nodeVersion"
} catch {
    Write-Error "Node.js is not installed or not in PATH"
    Write-Error "Please install Node.js 22+ from https://nodejs.org/"
    exit 1
}

# Check Git
try {
    $gitVersion = git --version
    Write-Info "✅ $gitVersion"
} catch {
    Write-Error "Git is not installed or not in PATH"
    Write-Error "Please install Git from https://git-scm.com/"
    exit 1
}

# Check/Install pnpm
try {
    $pnpmVersion = pnpm --version
    Write-Info "✅ pnpm $pnpmVersion"
} catch {
    Write-Warn "pnpm not found. Installing globally..."
    npm install -g pnpm
    $pnpmVersion = pnpm --version
    Write-Info "✅ Installed pnpm $pnpmVersion"
}

# Check package managers
Write-Step "Checking Windows package managers..."

# Check winget (Windows Package Manager)
try {
    $wingetVersion = winget --version
    Write-Info "✅ Windows Package Manager: $wingetVersion"
} catch {
    Write-Warn "winget not found. Install from Microsoft Store or GitHub."
}

# Check Chocolatey
try {
    $chocoVersion = choco --version
    Write-Info "✅ Chocolatey: $chocoVersion"
} catch {
    Write-Warn "Chocolatey not found. Install from https://chocolatey.org/"
}

# Check Scoop
try {
    $scoopVersion = scoop --version
    Write-Info "✅ Scoop: $scoopVersion"
} catch {
    Write-Warn "Scoop not found. Install from https://scoop.sh/"
}

# Clone or update repository
Write-Step "Setting up OpenClaw Enhanced..."

if (Test-Path $InstallDir) {
    if (-not $Force) {
        $response = Read-Host "Directory '$InstallDir' exists. Update? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Info "Deployment cancelled."
            exit 0
        }
    }
    
    Write-Info "Updating existing installation..."
    Set-Location $InstallDir
    git pull origin main
} else {
    Write-Info "Cloning repository..."
    git clone $RepoUrl $InstallDir
    Set-Location $InstallDir
}

# Install dependencies
Write-Step "Installing dependencies..."
try {
    pnpm install
    Write-Info "✅ Dependencies installed"
} catch {
    Write-Error "Failed to install dependencies: $($_.Exception.Message)"
    exit 1
}

# Build application
Write-Step "Building OpenClaw..."
try {
    pnpm build
    Write-Info "✅ Build completed"
} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}

# Build UI
Write-Step "Building UI assets..."
try {
    pnpm ui:build
    Write-Info "✅ UI assets built"
} catch {
    Write-Error "UI build failed: $($_.Exception.Message)"
    exit 1
}

# Create OpenClaw directory if it doesn't exist
$openclawDir = Join-Path $env:USERPROFILE ".openclaw"
if (-not (Test-Path $openclawDir)) {
    New-Item -ItemType Directory -Path $openclawDir -Force | Out-Null
    Write-Info "✅ Created OpenClaw config directory"
}

# Test installation
Write-Step "Testing OpenClaw installation..."
try {
    pnpm openclaw --help | Out-Null
    Write-Info "✅ OpenClaw CLI test passed"
} catch {
    Write-Error "OpenClaw CLI test failed: $($_.Exception.Message)"
    exit 1
}

# Create desktop shortcut (optional)
if (-not $Force) {
    $createShortcut = Read-Host "Create desktop shortcut? (Y/n)"
    if ($createShortcut -ne 'n' -and $createShortcut -ne 'N') {
        try {
            $shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "OpenClaw Gateway.lnk"
            $targetPath = "powershell.exe"
            $arguments = "-Command `"cd '$pwd'; pnpm openclaw gateway`""
            
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $targetPath
            $shortcut.Arguments = $arguments
            $shortcut.WorkingDirectory = $pwd
            $shortcut.Description = "Start OpenClaw Gateway"
            $shortcut.Save()
            
            Write-Info "✅ Desktop shortcut created"
        } catch {
            Write-Warn "Could not create desktop shortcut: $($_.Exception.Message)"
        }
    }
}

# Display completion message
Write-Host ""
Write-Info "🎉 OpenClaw Enhanced deployed successfully on Windows!"
Write-Host ""

Write-Step "Quick Start:"
Write-Host "1. Start the gateway:" -ForegroundColor Blue
Write-Host "   pnpm openclaw gateway" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Open the web interface:" -ForegroundColor Blue
Write-Host "   http://localhost:18789/?token=test-token-12345" -ForegroundColor Cyan
Write-Host ""

Write-Step "Next Steps:"
Write-Host "• Configure your LLM providers (Claude, OpenAI)" -ForegroundColor White
Write-Host "• Set up messaging channels (WhatsApp, Telegram)" -ForegroundColor White  
Write-Host "• Install skills from the web interface" -ForegroundColor White
Write-Host ""

Write-Step "Windows-Specific Features:"
Write-Host "✅ Native winget/chocolatey/scoop support" -ForegroundColor Green
Write-Host "✅ Fixed 'brew not installed' error" -ForegroundColor Green
Write-Host "✅ All bundled skills unlocked" -ForegroundColor Green
Write-Host ""

Write-Info "📚 Documentation: https://docs.openclaw.ai"
Write-Info "🐞 Issues: https://github.com/yourusername/openclaw-enhanced/issues"

Write-Host ""
Write-Warn "Windows Tips:"
Write-Host "• Use Windows Terminal for the best experience" -ForegroundColor Yellow
Write-Host "• Consider Windows Subsystem for Linux (WSL2) for advanced features" -ForegroundColor Yellow
Write-Host "• Run PowerShell as Administrator if you encounter permission issues" -ForegroundColor Yellow

Write-Info "Deployment complete! 🦞"
Write-Host "Current directory: $pwd" -ForegroundColor Gray