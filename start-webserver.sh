#!/bin/bash
# A script to start a web server and rebuild the web bundle on changes.
set -euo pipefail

echo "🔨 Initial build..."
bazelisk build //web:copy_web_bundle

echo "🚀 Starting web server..."
cd bazel-bin/web
python3 -m http.server 8080 &
BROWSER_PID=$!

# Trap Ctrl+C to kill browser-sync on exit
trap "echo '🧹 Cleaning up...'; kill $BROWSER_PID" SIGINT

# Watch source files and rebuild on changes
cd ../..
echo "👀 Watching source files for changes..."
while true; do
  find main/ web/ -type f \( -name '*.cc' -o -name '*.proto' -o -name '*.html' -o -name '*.js' \) \
    | entr -d bazelisk build //web:copy_web_bundle
done
