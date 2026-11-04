#!/usr/bin/env bash
# Install Amp for Raycast:
#   curl -fsSL https://raw.githubusercontent.com/pc-style/raycast-amp/main/install.sh | bash
# Set RAYCAST_AMP_DIR to choose where the source lives (default: ~/.raycast-amp).
set -euo pipefail

repo="https://github.com/pc-style/raycast-amp"
dir="${RAYCAST_AMP_DIR:-$HOME/.raycast-amp}"

say() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = Darwin ] || die "Raycast extensions run on macOS only."
[ -d /Applications/Raycast.app ] || [ -d "$HOME/Applications/Raycast.app" ] || die "Install Raycast first: https://raycast.com"
command -v node >/dev/null || die "Install Node.js 22.22 or later first: https://nodejs.org"
node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>22||(a===22&&b>=22)?0:1)' \
  || die "Node.js 22.22 or later is required (found $(node -v))."
command -v amp >/dev/null || command -v "$HOME/.amp/bin/amp" >/dev/null \
  || say "Amp CLI not found. Install it from https://ampcode.com/install and run 'amp login'."

if [ -d "$dir/.git" ]; then
  say "Updating $dir"
  git -C "$dir" pull --ff-only --quiet
elif command -v git >/dev/null; then
  say "Cloning into $dir"
  git clone --quiet --depth 1 "$repo.git" "$dir"
else
  say "Downloading into $dir"
  mkdir -p "$dir"
  curl -fsSL "$repo/archive/refs/heads/main.tar.gz" | tar -xz -C "$dir" --strip-components 1
fi

cd "$dir"
say "Installing dependencies"
npm ci --no-audit --no-fund --loglevel=error

# `ray develop` builds the extension and imports it into Raycast, which keeps it after the
# dev server stops. Stop it as soon as the first build succeeds.
say "Importing into Raycast"
log="$(mktemp)"
open -g -a Raycast
npx ray develop >"$log" 2>&1 &
pid=$!
for _ in $(seq 1 120); do
  if grep -q "built extension successfully" "$log"; then
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
    say "Done. Open Raycast and search for \"Amp\"."
    exit 0
  fi
  kill -0 "$pid" 2>/dev/null || break
  sleep 1
done
kill "$pid" 2>/dev/null || true
cat "$log" >&2
die "The build did not finish. Run 'cd $dir && npm run dev' to see what went wrong."
