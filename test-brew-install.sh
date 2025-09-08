#!/bin/bash

echo "Testing local Homebrew formula installation..."

# Test the formula locally
echo "1. Testing formula syntax..."
brew audit --strict ./homebrew-mira/Formula/mira.rb

echo ""
echo "2. Testing installation from local formula..."
brew install --build-from-source ./homebrew-mira/Formula/mira.rb

echo ""
echo "3. Testing installed binary..."
mira help

echo ""
echo "4. Running formula tests..."
brew test mira

echo ""
echo "✓ Local Homebrew formula test complete!"
echo ""
echo "To publish this as a tap:"
echo "1. Create GitHub repo: homebrew-mira"
echo "2. Push the homebrew-mira directory contents"
echo "3. Users can then: brew tap erdalgunes/mira && brew install mira"