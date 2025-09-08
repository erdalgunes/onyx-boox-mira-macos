#!/bin/bash

# Mira CLI Tool Installation Script

set -e

echo "Installing Mira CLI tool..."

# Build the project
echo "Building project..."
swift build --configuration release

# Create /usr/local/bin if it doesn't exist
sudo mkdir -p /usr/local/bin

# Copy the executable
echo "Installing to /usr/local/bin..."
sudo cp .build/release/mira /usr/local/bin/

# Make it executable
sudo chmod +x /usr/local/bin/mira

echo "✓ Mira CLI tool installed successfully!"
echo ""
echo "You can now use 'mira' from anywhere in your terminal."
echo "Run 'mira help' to see available commands."
