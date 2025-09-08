# Mira macOS CLI Tool

A native macOS command-line tool to prevent sleep mode when using Onyx Boox Mira e-ink display.

## Features

- 🖥️ Automatically detects Onyx Boox Mira display connection
- 💤 Prevents both system and display sleep
- 🌅 Color temperature control for internal display
- ⏰ Time-based blue light management (morning/evening/night)
- 🎯 Native macOS integration using IOPMAssertion APIs
- 🚀 Single binary with no dependencies
- 📊 Status monitoring for connected displays

## Installation

### Quick Install

```bash
git clone https://github.com/erdalgunes/onyx-boox-mira-macos.git
cd onyx-boox-mira-macos
chmod +x install.sh
./install.sh
```

### Manual Build

```bash
swift build -c release
sudo cp .build/release/mira /usr/local/bin/
```

## Usage

### Start sleep prevention (auto-detects Mira)
```bash
mira start
```

### Force start (even without Mira connected)
```bash
mira start --force
```

### Stop sleep prevention
```bash
mira stop
```

### Check status
```bash
mira status
```

### Color temperature control
```bash
mira temp auto      # Auto-adjust based on time of day
mira temp morning   # Cool temperature (more blue light)
mira temp evening   # Warm temperature (less blue light)
mira temp night     # Very warm temperature
mira temp status    # Show current settings
```

### Get help
```bash
mira help
```

## Example Output

```
$ mira status
=== Mira Display Status ===
Display detected: Yes
Display name: MIRA253
Sleep prevention: Active

Connected displays:
  1. Built-in Retina Display (Primary)
  2. MIRA253

$ mira temp status
=== Color Temperature Status ===
Night Shift enabled: No
Current time period: morning
Recommended: Morning (6AM-6PM): Cool temperature, more blue light

Manual controls:
  mira temp morning  - Disable Night Shift
  mira temp evening  - Enable Night Shift
  mira temp night    - Enable Night Shift
  mira temp auto     - Auto-adjust for time of day
```

## How It Works

The tool uses macOS native APIs:
- **IOPMAssertion**: Creates power management assertions to prevent sleep
- **CoreGraphics**: Detects connected displays
- **IOKit**: Interfaces with display hardware
- **CoreBrightness**: Controls Night Shift and color temperature

### Sleep Prevention
When started, it creates two assertions:
1. `kIOPMAssertionTypeNoIdleSleep` - Prevents system idle sleep
2. `kIOPMAssertionTypeNoDisplaySleep` - Prevents display sleep

### Color Temperature Control
The tool adjusts color temperature based on time of day:
- **Morning (6AM-6PM)**: Disabled Night Shift for more blue light (better alertness)
- **Evening (6PM-10PM)**: Moderate Night Shift for warmer colors
- **Night (10PM-6AM)**: Strong Night Shift for minimal blue light (better sleep)

This works by modifying the CoreBrightness preferences and only affects your internal display, leaving the Mira e-ink display unchanged.

## Requirements

- macOS 11.0 (Big Sur) or later
- Swift 5.9 or later
- Xcode Command Line Tools

## Troubleshooting

### Mira not detected
- Check display cable connection
- Try unplugging and reconnecting the display
- Use `mira start --force` to start anyway

### Permission issues
The tool needs to be installed with sudo to `/usr/local/bin` for system-wide access.

## Development

### Build from source
```bash
swift build
```

### Run tests
```bash
swift test
```

### Debug build
```bash
swift build
./.build/debug/mira status
```

## License

MIT License - See LICENSE file for details

## Author

Erdal Gunes

## Contributing

Pull requests are welcome! Please feel free to submit issues and enhancement requests.
