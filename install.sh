#!/bin/bash

set -e

echo "Installing Mira CLI tool for macOS..."
echo

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This tool is only for macOS"
    exit 1
fi

# Build the tool
echo "Building the tool..."
swift build -c release

# Create bin directory if it doesn't exist
mkdir -p /usr/local/bin

# Copy the binary
echo "Installing to /usr/local/bin/mira..."
sudo cp .build/release/mira /usr/local/bin/mira

# Make it executable
sudo chmod +x /usr/local/bin/mira

echo
echo "✓ Installation complete!"
echo
echo "You can now use the 'mira' command from anywhere."
echo "Run 'mira help' to see available commands."