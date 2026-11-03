#!/usr/bin/env bash
# Build Ubu-Office-Setup-x86_64.AppImage (bash+zenity wizard — no bundled Python).
# Icon: official Ubu Office suite logo (colorful “U” squircle).
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
OUT="${1:-$ROOT/releases/ubu/appimage}"
ARCH="$(uname -m)"
[[ "$ARCH" == "x86_64" || "$ARCH" == "aarch64" ]] || { echo "unsupported arch $ARCH" >&2; exit 2; }

WORKDIR="$(mktemp -d /tmp/ubu-office-setup-appdir.XXXXXX)"
APPDIR="$WORKDIR/UbuOfficeSetup.AppDir"
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT

mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/ubu-office-setup"
install -m 755 "$HERE/install.sh" "$APPDIR/usr/share/ubu-office-setup/install.sh"
install -m 755 "$HERE/wizard.sh" "$APPDIR/usr/share/ubu-office-setup/wizard.sh"
install -m 755 "$HERE/AppRun" "$APPDIR/AppRun"

# Official Ubu Office logo (prefer high-res suite mark, then 256, then release icon).
ICON_SRC=""
for cand in \
  "$HERE/ubu-office.png" \
  "$HERE/ubu-office-256.png" \
  "$ROOT/branding/icons/ubu-office.png" \
  "$ROOT/branding/icons/ubu-office-1024.png" \
  "$ROOT/images/logos/ubu-office.png" \
  "$ROOT/images/logos/ubu-office-256.png" \
  "$ROOT/releases/ubu/icons/com.manguonmo.ubu-office.png"
do
  if [[ -f "$cand" ]]; then ICON_SRC="$cand"; break; fi
done
[[ -n "$ICON_SRC" ]] || { echo "Ubu Office logo not found" >&2; exit 1; }

ICON256="$WORKDIR/ubu-office-256.png"
if command -v convert >/dev/null 2>&1; then
  convert "$ICON_SRC" -resize 256x256 "$ICON256"
else
  # Source may already be 256; otherwise copy as-is (still the suite logo).
  install -m 644 "$ICON_SRC" "$ICON256"
fi

# AppImage icon: root PNG + real .DirIcon (not symlink — file managers/thumbnailers).
install -Dm644 "$ICON256" "$APPDIR/com.manguonmo.ubu-office.png"
install -Dm644 "$ICON256" "$APPDIR/.DirIcon"
install -Dm644 "$ICON256" "$APPDIR/usr/share/icons/hicolor/256x256/apps/com.manguonmo.ubu-office.png"
install -Dm644 "$ICON256" "$APPDIR/usr/share/icons/hicolor/128x128/apps/com.manguonmo.ubu-office.png"
# Also ship beside wizard for zenity --window-icon
install -Dm644 "$ICON256" "$APPDIR/usr/share/ubu-office-setup/ubu-office.png"

cat >"$APPDIR/ubu-office-setup.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Ubu Office Setup
Name[vi]=Cài đặt Ubu Office
Comment=Install Ubu World, Excel, Pdf, Slide — choose language and apps
Comment[vi]=Cài Ubu World, Excel, Pdf, Slide — chọn ngôn ngữ và ứng dụng
Exec=ubu-office-setup
Icon=com.manguonmo.ubu-office
Categories=Office;
Terminal=false
StartupNotify=true
StartupWMClass=ubu-office-setup
Keywords=ubu;office;setup;install;manguonmo;
EOF
ln -sfn usr/share/ubu-office-setup/wizard.sh "$APPDIR/usr/bin/ubu-office-setup"

# Locate appimagetool
TOOL=""
for c in appimagetool "$HOME/.local/bin/appimagetool" /usr/bin/appimagetool; do
  if command -v "$c" >/dev/null 2>&1 || [[ -x "$c" ]]; then TOOL="$c"; break; fi
done
if [[ -z "$TOOL" ]]; then
  CAND=$(find "$ROOT" -name 'appimagetool*' -type f 2>/dev/null | head -1 || true)
  [[ -n "$CAND" ]] && TOOL="$CAND"
fi
[[ -n "$TOOL" ]] || { echo "appimagetool not found" >&2; exit 1; }

mkdir -p "$OUT"
VERSION="${UBU_SETUP_VERSION:-0.1.0}"
DEST="$OUT/Ubu-Office-Setup-${VERSION}-${ARCH}.AppImage"
ARCH="$ARCH" "$TOOL" -n "$APPDIR" "$DEST"
chmod +x "$DEST"
ln -sfn "$(basename "$DEST")" "$OUT/Ubu-Office-Setup.AppImage"
echo "wrote $DEST (icon: $ICON_SRC)"
ls -lh "$DEST"
