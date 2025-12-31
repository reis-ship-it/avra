#!/bin/bash
# Build Rust library for iOS platforms
# Part of Patent #31: Topological Knot Theory for Personality Representation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RUST_DIR="$PROJECT_ROOT/native/knot_math"

cd "$RUST_DIR"

echo "🔨 Building Rust library for iOS..."

# Check if Rust targets are installed
check_target() {
    local target=$1
    if ! rustup target list --installed | grep -q "^$target$"; then
        echo "⚠️  Target $target not installed. Installing..."
        rustup target add "$target"
    fi
}

# Install targets if needed
check_target aarch64-apple-ios
check_target x86_64-apple-ios
check_target aarch64-apple-ios-sim

# Build for iOS device (ARM64)
echo "📦 Building for aarch64-apple-ios (iOS device)..."
cargo build --target aarch64-apple-ios --release

# Build for iOS simulator (Intel)
echo "📦 Building for x86_64-apple-ios (iOS simulator Intel)..."
cargo build --target x86_64-apple-ios --release

# Build for iOS simulator (Apple Silicon)
echo "📦 Building for aarch64-apple-ios-sim (iOS simulator Apple Silicon)..."
cargo build --target aarch64-apple-ios-sim --release

echo "✅ iOS libraries built successfully"
echo "📂 Libraries are in:"
echo "   - Device: target/aarch64-apple-ios/release/libknot_math.a"
echo "   - Simulator (Intel): target/x86_64-apple-ios/release/libknot_math.a"
echo "   - Simulator (Apple Silicon): target/aarch64-apple-ios-sim/release/libknot_math.a"
