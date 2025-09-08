# Mira CLI Installation Guide

## Quick Install (via Homebrew)

Once the tap is published:
```bash
brew tap erdalgunes/mira
brew install mira
```

## Manual Installation

### From Source
```bash
# Clone the repository
git clone https://github.com/erdalgunes/onyx-boox-mira-macos.git
cd onyx-boox-mira-macos

# Build and install
./install.sh
```

### Direct Binary Download
```bash
# Download the latest release
curl -L https://github.com/erdalgunes/onyx-boox-mira-macos/releases/latest/download/mira-v1.1.0-macos.tar.gz -o mira.tar.gz

# Extract
tar -xzf mira.tar.gz

# Install to /usr/local/bin
sudo mv mira-v1.1.0-macos /usr/local/bin/mira
sudo chmod +x /usr/local/bin/mira
```

## Dependencies

### Required
- macOS 11.0 or later
- Onyx Boox Mira e-ink display

### Optional (for color temperature control)
```bash
brew install --cask betterdisplay
```

## Verify Installation

```bash
# Check version
mira --version

# View help
mira help

# Check status
mira status
```

## Plugin System

Mira uses a plugin architecture for color temperature control:

1. **BetterDisplay Plugin** (Recommended)
   - Per-display control
   - Leaves e-ink display unaffected
   - Install: `brew install --cask betterdisplay`

2. **Night Shift Plugin** (Fallback)
   - System-wide color adjustment
   - Built into macOS
   - Automatically used if BetterDisplay is not available

## Troubleshooting

### Permission Issues
If you get permission errors:
```bash
sudo chmod +x /usr/local/bin/mira
```

### BetterDisplay Not Detected
1. Ensure BetterDisplay is installed
2. Start BetterDisplay application
3. Try running `mira temp status`

### Display Not Detected
1. Ensure Mira display is connected via USB
2. Check System Information > USB
3. Try unplugging and reconnecting

## Uninstallation

### Via Homebrew
```bash
brew uninstall mira
brew untap erdalgunes/mira
```

### Manual
```bash
sudo rm /usr/local/bin/mira
```