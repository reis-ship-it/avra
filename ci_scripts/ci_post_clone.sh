#!/bin/bash
set -e

echo "🚀 Starting Flutter setup for Xcode Cloud..."

# Set CI_WORKSPACE if not set (Xcode Cloud should set this, but we'll default to current directory)
CI_WORKSPACE=${CI_WORKSPACE:-$(pwd)}
cd "$CI_WORKSPACE"

# Check if Flutter is available (Xcode Cloud doesn't have it pre-installed)
if ! command -v flutter &> /dev/null; then
    echo "📥 Flutter not found. Installing Flutter from GitHub..."
    
    # Install Flutter using git (stable channel)
    # Xcode Cloud provides git, so we can clone Flutter
    if [ ! -d "$HOME/flutter" ]; then
        echo "📦 Cloning Flutter repository..."
        git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
    else
        echo "✅ Flutter directory exists, updating..."
        cd "$HOME/flutter"
        git pull
        cd "$CI_WORKSPACE"
    fi
    
    # Add Flutter to PATH for this session and export for subsequent commands
    export PATH="$HOME/flutter/bin:$PATH"
    
    # Verify Flutter is now available
    if ! command -v flutter &> /dev/null; then
        echo "❌ Error: Flutter installation failed"
        exit 1
    fi
    
    echo "✅ Flutter installed successfully"
else
    echo "✅ Flutter found in PATH"
fi

# Ensure Flutter is in PATH (in case it was found but PATH wasn't exported)
export PATH="$HOME/flutter/bin:${PATH:-}"

# Verify Flutter version
echo "✅ Flutter version: $(flutter --version | head -n 1)"

# Accept Flutter licenses (required for first-time setup)
echo "📝 Accepting Flutter licenses..."
flutter doctor --android-licenses 2>/dev/null || echo "⚠️  Android licenses skipped (iOS build only)"

# Pre-cache Flutter dependencies (speeds up pub get)
echo "📦 Pre-caching Flutter dependencies..."
flutter precache --ios || echo "⚠️  Pre-cache warning (continuing...)"

# Get Flutter dependencies (creates Generated.xcconfig)
echo "📦 Running flutter pub get..."
flutter pub get

# Verify Generated.xcconfig was created
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "❌ Error: Generated.xcconfig not created by flutter pub get"
    echo "Flutter dependencies may not have been set up correctly."
    exit 1
fi

echo "✅ Generated.xcconfig created"

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."
cd ios

# Check if pod is available
if ! command -v pod &> /dev/null; then
    echo "📥 CocoaPods not found. Installing CocoaPods..."
    
    # Check if gem is available (Ruby's package manager)
    if ! command -v gem &> /dev/null; then
        echo "❌ Error: gem (Ruby) not found. CocoaPods requires Ruby."
        echo "Xcode Cloud should have Ruby available, but it's not in PATH."
        exit 1
    fi
    
    # Install CocoaPods using gem
    echo "📦 Installing CocoaPods via gem..."
    gem install cocoapods --no-document || {
        echo "⚠️  gem install cocoapods failed, trying with sudo..."
        sudo gem install cocoapods --no-document || {
            echo "❌ Error: CocoaPods installation failed"
            exit 1
        }
    }
    
    echo "✅ CocoaPods installed successfully"
else
    echo "✅ CocoaPods found in PATH"
fi

# Run pod install
echo "📦 Running pod install..."
pod install --repo-update || pod install || {
    echo "❌ Error: pod install failed"
    exit 1
}

cd ..

# Verify Pods directory was created
if [ ! -d "ios/Pods" ]; then
    echo "❌ Error: Pods directory not created by pod install"
    echo "CocoaPods installation may have failed."
    exit 1
fi

echo "✅ CocoaPods dependencies installed"
echo "✅ Flutter setup complete!"
