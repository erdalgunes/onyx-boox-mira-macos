# Mira macOS CLI Tool

A native macOS command-line tool to prevent sleep mode when using Onyx Boox Mira e-ink display.

## Features

- 🖥️ Automatically detects Onyx Boox Mira display connection
- 💤 Prevents both system and display sleep
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
```

## How It Works

The tool uses macOS native APIs:
- **IOPMAssertion**: Creates power management assertions to prevent sleep
- **CoreGraphics**: Detects connected displays
- **IOKit**: Interfaces with display hardware

When started, it creates two assertions:
1. `kIOPMAssertionTypeNoIdleSleep` - Prevents system idle sleep
2. `kIOPMAssertionTypeNoDisplaySleep` - Prevents display sleep

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
