#!/usr/bin/env bash

set -e

SRC_DIR="$HOME/repos/niri"
BUILD_DIR="$SRC_DIR/target/release"
PREFIX="/usr/local"
SYSTEMD_DIR="/usr/lib/systemd/user"
WAYLAND_SESSIONS="$PREFIX/share/wayland-sessions"
PORTALS_DIR="$PREFIX/share/xdg-desktop-portal"

echo "Building niri..."
cd "$SRC_DIR"

NIRI_BUILD_COMMIT="$(git rev-parse --short HEAD)"
export NIRI_BUILD_COMMIT

cargo build --release

echo "Installing..."
sudo install -Dm755 "$BUILD_DIR/niri" "$PREFIX/bin/niri"
sudo install -Dm755 "$SRC_DIR/resources/niri-session" "$PREFIX/bin/niri-session"
sudo install -Dm644 "$SRC_DIR/resources/niri.desktop" "$WAYLAND_SESSIONS/niri.desktop"
sudo install -Dm644 "$SRC_DIR/resources/niri-portals.conf" "$PORTALS_DIR/niri-portals.conf"
sudo install -Dm644 "$SRC_DIR/resources/niri.service" "$SYSTEMD_DIR/niri.service"
sudo install -Dm644 "$SRC_DIR/resources/niri-shutdown.target" "$SYSTEMD_DIR/niri-shutdown.target"

sudo systemctl daemon-reload --user 2>/dev/null || systemctl --user daemon-reload

echo "Done. Run 'niri --version' to verify."
