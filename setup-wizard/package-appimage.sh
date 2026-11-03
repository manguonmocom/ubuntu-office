#!/usr/bin/env bash
# Build Ubu-Office-Setup-x86_64.AppImage (bash+zenity wizard — no bundled Python).
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
# Optional: ship local AppImages inside Setup when building a fat installer
# (default: download from GitHub Releases at install time).

ICON_SRC="$ROOT/releases/ubu/icons/com.manguonmo.ubu-office.png"
[[ -f "$ICON_SRC" ]] || ICON_SRC="$ROOT/branding/icons/ubu-office.png"
if [[ -f "$ICON_SRC" ]]; then
  install -Dm644 "$ICON_SRC" "$APPDIR/com.manguonmo.ubu-office.png"
  install -Dm644 "$ICON_SRC" "$APPDIR/usr/share/icons/hicolor/256x256/apps/com.manguonmo.ubu-office.png"
  ln -sfn com.manguonmo.ubu-office.png "$APPDIR/.DirIcon"
fi

cat >"$APPDIR/ubu-office-setup.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Ubu Office Setup
Name[vi]=Cài đặt Ubu Office
Comment=Install Ubu World, Excel, Pdf, Slide — choose language and apps
Comment[vi]=Cài Ubu World, Excel, Pdf, Slide — chọn ngôn ngữ và ứng dụng
Exec=ubu-office-setup
Icon=com.manguonmo.ubu-office
Categories=Office;Settings;
Terminal=false
StartupNotify=true
EOF
cp "$APPDIR/ubu-office-setup.desktop" "$APPDIR/usr/share/ubu-office-setup/" 2>/dev/null || true

cat >"$APPDIR/AppRun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
export PATH="$HERE/usr/bin:$PATH"
# zenity is expected on the host (Ubuntu GNOME); show a clear message otherwise.
if ! command -v zenity >/dev/null 2>&1; then
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "Ubu Office Setup" "Cần gói zenity: sudo apt install zenity"
  fi
  echo "Cần zenity: sudo apt install zenity" >&2
  # Still allow headless CLI install
  if [[ "${1:-}" == "--cli" ]]; then
    shift
    exec bash "$HERE/usr/share/ubu-office-setup/install.sh" "$@"
  fi
  exit 1
fi
exec bash "$HERE/usr/share/ubu-office-setup/wizard.sh" "$@"
EOF
chmod +x "$APPDIR/AppRun"
ln -sfn usr/share/ubu-office-setup/wizard.sh "$APPDIR/usr/bin/ubu-office-setup"

# Locate appimagetool
TOOL=""
for c in appimagetool "$HOME/.local/bin/appimagetool" /usr/bin/appimagetool; do
  if command -v "$c" >/dev/null 2>&1 || [[ -x "$c" ]]; then TOOL="$c"; break; fi
done
if [[ -z "$TOOL" ]]; then
  # reuse from any app's cargo target if package.sh downloaded it
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
echo "wrote $DEST"
ls -lh "$DEST"
