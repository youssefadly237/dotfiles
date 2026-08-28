#!/usr/bin/env bash
set -e

PREFIX="/usr/local"
NIRI="$HOME/repos/niri"
SATELLITE="$HOME/repos/xwayland-satellite"

case "$1" in
niri)
    echo "Building niri..."
    cd "$NIRI"

    cargo build --release

    echo "Installing niri..."
    sudo install -Dm755 "$NIRI/target/release/niri" \
        "$PREFIX/bin/niri"
    sudo install -Dm755 "$NIRI/resources/niri-session" \
        "$PREFIX/bin/niri-session"
    sudo install -Dm644 "$NIRI/resources/niri.desktop" \
        "$PREFIX/share/wayland-sessions/niri.desktop"
    sudo install -Dm644 "$NIRI/resources/niri-portals.conf" \
        "$PREFIX/share/xdg-desktop-portal/niri-portals.conf"
    sudo install -Dm644 "$NIRI/resources/niri.service" \
        "/usr/lib/systemd/user/niri.service"
    sudo install -Dm644 "$NIRI/resources/niri-shutdown.target" \
        "/usr/lib/systemd/user/niri-shutdown.target"

    systemctl --user daemon-reload

    echo "Done: $(niri --version)"
    ;;

satellite)
    echo "Building xwayland-satellite..."
    cd "$SATELLITE"

    cargo build --release

    echo "Installing xwayland-satellite..."
    sudo install -Dm755 "$SATELLITE/target/release/xwayland-satellite" \
        "$PREFIX/bin/xwayland-satellite"

    echo "Done: $(xwayland-satellite -version)"
    ;;

*)
    echo "Usage: $0 {niri|satellite}"
    exit 1
    ;;
esac

echo "Remember to run 'cargo clean' if you don't need the build artifacts."
