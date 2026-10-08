#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
EXAMPLE="$ROOT_DIR/Config/Secrets.xcconfig.example"
TARGET="$ROOT_DIR/Config/Secrets.xcconfig"

if [[ -f "$TARGET" ]]; then
  echo "Config/Secrets.xcconfig already exists. Edit it to set TMDB_ACCESS_TOKEN."
  exit 0
fi

cp "$EXAMPLE" "$TARGET"
echo "Created Config/Secrets.xcconfig"
echo "1) Open https://www.themoviedb.org/settings/api"
echo "2) Copy your API Read Access Token (v4)"
echo "3) Paste it into Config/Secrets.xcconfig as TMDB_ACCESS_TOKEN = ..."
echo "4) Rebuild the CineScope Dev scheme (badge should show Dev · Live API)"
