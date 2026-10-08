#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PACKAGE_DIR="$ROOT_DIR/Packages/CineScopeCore"
OUTPUT_DIR="$ROOT_DIR/Artifacts"
DERIVED="$OUTPUT_DIR/DerivedData"
XCFRAMEWORK_PATH="$OUTPUT_DIR/CineScopeCore.xcframework"

echo "Building CineScopeCore.xcframework..."
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

cd "$PACKAGE_DIR"

build_platform() {
  local name="$1"
  local destination="$2"
  echo "$name ($destination)"
  xcodebuild build \
    -scheme CineScopeCore \
    -destination "$destination" \
    -derivedDataPath "$DERIVED/$name" \
    -configuration Release \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO \
    ONLY_ACTIVE_ARCH=NO
}

build_platform "ios" "generic/platform=iOS"
build_platform "ios-simulator" "generic/platform=iOS Simulator"
build_platform "tvos" "generic/platform=tvOS"
build_platform "tvos-simulator" "generic/platform=tvOS Simulator"
build_platform "macos" "generic/platform=macOS"
build_platform "visionos" "generic/platform=visionOS"
build_platform "visionos-simulator" "generic/platform=visionOS Simulator"

find_framework() {
  local root="$1"
  find "$root" -name "CineScopeCore.framework" -print | head -n 1
}

IOS_FW=$(find_framework "$DERIVED/ios")
IOS_SIM_FW=$(find_framework "$DERIVED/ios-simulator")
TV_FW=$(find_framework "$DERIVED/tvos")
TV_SIM_FW=$(find_framework "$DERIVED/tvos-simulator")
MAC_FW=$(find_framework "$DERIVED/macos")
VISION_FW=$(find_framework "$DERIVED/visionos")
VISION_SIM_FW=$(find_framework "$DERIVED/visionos-simulator")

ARGS=()
for fw in "$IOS_FW" "$IOS_SIM_FW" "$TV_FW" "$TV_SIM_FW" "$MAC_FW" "$VISION_FW" "$VISION_SIM_FW"; do
  if [[ -n "$fw" && -d "$fw" ]]; then
    ARGS+=(-framework "$fw")
  else
    echo "Warning: missing framework slice for one platform" >&2
  fi
done

if [[ ${#ARGS[@]} -lt 2 ]]; then
  echo "Unable to locate enough built frameworks to create an XCFramework." >&2
  echo "Ensure Xcode can resolve the CineScopeCore package scheme." >&2
  exit 1
fi

xcodebuild -create-xcframework "${ARGS[@]}" -output "$XCFRAMEWORK_PATH"
echo "Created $XCFRAMEWORK_PATH"
