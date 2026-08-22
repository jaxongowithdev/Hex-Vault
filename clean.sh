#!/bin/bash

# Clean script for Diet Diary Flutter project
# This script cleans iOS Pods, Podfile.lock, and Flutter build artifacts

set -e  # Exit on any error

echo "🧹 Starting project cleanup..."

# Navigate to example directory
if [ -d "example" ]; then
    echo "📁 Cleaning example directory..."
    cd example
    
    # Remove iOS Pods
    if [ -d "ios/Pods" ]; then
        echo "  🗑️  Removing ios/Pods..."
        rm -rf ios/Pods
    else
        echo "  ℹ️  ios/Pods not found, skipping..."
    fi
    
    # Remove Podfile.lock
    if [ -f "ios/Podfile.lock" ]; then
        echo "  🗑️  Removing Podfile.lock..."
        rm -rf ios/Podfile.lock
    else
        echo "  ℹ️  Podfile.lock not found, skipping..."
    fi
    
    # Clean Flutter in example directory
    echo "  🧹 Running 'fvm flutter clean' in example..."
    fvm flutter clean
    
    # Return to parent directory
    cd ..
    echo "✅ Example directory cleaned"
else
    echo "⚠️  Warning: example directory not found, skipping..."
fi

# Clean Flutter in root directory
echo "🧹 Running 'fvm flutter clean' in root..."
fvm flutter clean

echo "✨ Project cleanup completed successfully!"

