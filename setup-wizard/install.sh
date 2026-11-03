#!/usr/bin/env bash
# Cài Ubu Office (World / Excel / Pdf / Slide) cho user hiện tại.
#
#   ./install.sh [--lang vi] [--apps world,excel,pdf,slide] [--source DIR]
#
# Setup AppImage chỉ chứa wizard (~1MB). App người dùng chọn được tải
# từ GitHub Releases (chỉ các app trong --apps), không bundle sẵn.
#
# Nguồn AppImage (ưu tiên):
#   1) --source / UBU_OFFICE_SOURCE
#   2) sibling ../releases/ubu (dev monorepo)
#   3) GitHub Releases manguonmocom/ubuntu-office (API + curl) — chỉ SELECTED
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
# Repo root when scripts live in setup-wizard/; inside AppImage this is usr/share (unused for packages).
ROOT="$(cd "$HERE/.." && pwd)"

say() { printf '%s\n' "$*" >&2; }
warn() { printf 'Cảnh báo: %s\n' "$*" >&2; }
die() { printf 'Lỗi: %s\n' "$*" >&2; exit 1; }

LANG_CODE="${UBU_OFFICE_LANG:-vi}"
APPS_CSV="${UBU_OFFICE_APPS:-world,excel,pdf,slide}"
SRC="${UBU_OFFICE_SOURCE:-}"
REPO="${UBU_OFFICES_REPO:-manguonmocom/ubuntu-office}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/ubu-office"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang) LANG_CODE="$2"; shift 2 ;;
    --apps) APPS_CSV="$2"; shift 2 ;;
    --source) SRC="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *) die "unknown arg: $1" ;;
  esac
done

declare -A BIN=(
  [world]=Ubu-World
  [excel]=Ubu-Excel
  [pdf]=Ubu-Pdf
  [slide]=Ubu-Slide
)
declare -A ID=(
  [world]=com.manguonmo.ubu-world
  [excel]=com.manguonmo.ubu-excel
  [pdf]=com.manguonmo.ubu-pdf
  [slide]=com.manguonmo.ubu-slide
)
declare -A NAME=(
  [world]="Ubu World"
  [excel]="Ubu Excel"
  [pdf]="Ubu Pdf"
  [slide]="Ubu Slide"
)
declare -A CFG=(
  [world]=wordcraft
  [excel]=gridcraft
  [pdf]=pdfcraft
  [slide]=deckcraft
)

IFS=',' read -r -a WANT <<<"$APPS_CSV"
SELECTED=()
for a in "${WANT[@]}"; do
  a="$(echo "$a" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"
  [[ -n "$a" ]] || continue
  [[ -n "${BIN[$a]:-}" ]] || die "unknown app: $a (world|excel|pdf|slide)"
  SELECTED+=("$a")
done
[[ ${#SELECTED[@]} -gt 0 ]] || die "Không chọn app nào."

# Resolve download URL for one AppImage via GitHub Releases API (versioned names).
github_asset_url() {
  local app=$1
  command -v curl >/dev/null || die "Cần curl."
  command -v python3 >/dev/null || die "Cần python3 (để đọc GitHub API)."
  curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | python3 -c "
import json,sys,re
app=sys.argv[1]
data=json.load(sys.stdin)
pat=re.compile(re.escape(app)+r'-.*x86_64\\.AppImage\$')
for a in data.get('assets') or []:
    n=a.get('name') or ''
    if n==app+'.AppImage' or n==app+'-x86_64.AppImage' or pat.match(n):
        print(a.get('browser_download_url') or '')
        break
" "$app"
}

download_app() {
  local app=$1 dest=$2
  local url
  if [[ -f "$dest" && -s "$dest" ]]; then
    # Reject tiny/corrupt leftovers
    local sz
    sz=$(wc -c <"$dest" | tr -d ' ')
    if [[ "$sz" -gt 1000000 ]]; then
      say "  · cache: $app ($(numfmt --to=iec "$sz" 2>/dev/null || echo "${sz}B"))"
      return 0
    fi
    warn "cache hỏng ($app, ${sz}B) — tải lại"
    rm -f "$dest"
  fi
  url="$(github_asset_url "$app" || true)"
  [[ -n "$url" ]] || { warn "Không tìm thấy asset GitHub cho $app"; return 1; }
  say "  → $app …"
  if curl -fL --retry 3 --connect-timeout 30 -o "$dest.partial" "$url"; then
    mv -f "$dest.partial" "$dest"
    chmod +x "$dest"
    say "  ✓ $app"
    return 0
  fi
  rm -f "$dest.partial"
  return 1
}

# Prints ONLY the source directory path on stdout (logs go to stderr).
find_src() {
  if [[ -n "$SRC" && -d "$SRC" ]]; then
    printf '%s\n' "$SRC"
    return 0
  fi
  if compgen -G "$ROOT/releases/ubu/appimage/Ubu-*.AppImage" >/dev/null; then
    printf '%s\n' "$ROOT/releases/ubu"
    return 0
  fi
  # AppImage layout: optional bundled packages under usr/share/ubu-office-setup/packages
  if compgen -G "$HERE/packages/appimage/Ubu-*.AppImage" >/dev/null; then
    printf '%s\n' "$HERE/packages"
    return 0
  fi

  mkdir -p "$CACHE/appimage" "$CACHE/icons"
  say "==> Tải từ GitHub Releases: $REPO"
  local key app dest ok=0
  for key in "${SELECTED[@]}"; do
    app="${BIN[$key]}"
    dest="$CACHE/appimage/${app}.AppImage"
    if download_app "$app" "$dest"; then
      ok=1
    else
      warn "Không tải được $app"
    fi
  done
  [[ "$ok" -eq 1 ]] || die "Không tải được AppImage nào từ https://github.com/${REPO}/releases"

  for key in "${SELECTED[@]}"; do
    local id="${ID[$key]}"
    local ic="$CACHE/icons/${id}.png"
    [[ -f "$ic" && -s "$ic" ]] && continue
    # Repo ships images/apps/ubu-{world,excel,pdf,slide}-256.png
    if curl -fsSL -o "$ic.partial" \
         "https://raw.githubusercontent.com/${REPO}/main/images/apps/ubu-${key}-256.png" 2>/dev/null \
       || curl -fsSL -o "$ic.partial" \
         "https://raw.githubusercontent.com/${REPO}/main/images/apps/${id##*.}-256.png" 2>/dev/null; then
      mv -f "$ic.partial" "$ic"
    else
      rm -f "$ic.partial" "$ic"
    fi
  done
  printf '%s\n' "$CACHE"
}

# Ensure user hicolor theme is usable (GNOME needs index.theme + cache).
ensure_hicolor_theme() {
  local base=$1
  mkdir -p "$base"
  if [[ ! -f "$base/index.theme" ]]; then
    cat >"$base/index.theme" <<'EOF'
[Icon Theme]
Name=Hicolor
Comment=Local fallback icon theme
Directories=48x48/apps,128x128/apps,256x256/apps

[48x48/apps]
Size=48
Context=Applications
Type=Threshold

[128x128/apps]
Size=128
Context=Applications
Type=Threshold

[256x256/apps]
Size=256
Context=Applications
Type=Threshold
EOF
  fi
}

# Install PNG into hicolor sizes; print absolute path to 256px icon (stdout).
install_app_icon() {
  local id=$1 key=$2
  local src="" size dir dest
  for cand in \
    "$SRC_DIR/icons/${id}.png" \
    "$SRC_DIR/icons/ubu-${key}-256.png" \
    "$CACHE/icons/${id}.png"
  do
    if [[ -f "$cand" && -s "$cand" ]]; then src="$cand"; break; fi
  done
  # Last resort: fetch from GitHub even when AppImages came from --source
  if [[ -z "$src" ]]; then
    mkdir -p "$CACHE/icons"
    local ic="$CACHE/icons/${id}.png"
    if curl -fsSL -o "$ic.partial" \
         "https://raw.githubusercontent.com/${REPO}/main/images/apps/ubu-${key}-256.png" 2>/dev/null; then
      mv -f "$ic.partial" "$ic"
      src="$ic"
    else
      rm -f "$ic.partial"
    fi
  fi
  [[ -n "$src" ]] || { printf '\n'; return 0; }

  ensure_hicolor_theme "$DEST_ICON"
  for size in 48 128 256; do
    dir="$DEST_ICON/${size}x${size}/apps"
    mkdir -p "$dir"
    dest="$dir/${id}.png"
    if command -v convert >/dev/null 2>&1 && [[ "$size" -ne 256 ]]; then
      convert "$src" -resize "${size}x${size}" "$dest" 2>/dev/null || install -m 644 "$src" "$dest"
    else
      install -m 644 "$src" "$dest"
    fi
  done
  printf '%s\n' "$DEST_ICON/256x256/apps/${id}.png"
}

SRC_DIR="$(find_src)"
say "==> Nguồn: $SRC_DIR"

DEST_BIN="${XDG_DATA_HOME:-$HOME/.local/share}/ubu-office/bin"
DEST_APP="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DEST_ICON="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
SUITE_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/ubu-office"
mkdir -p "$DEST_BIN" "$DEST_APP" "$HOME/.local/bin" "$SUITE_CFG"

printf '%s\n' "$LANG_CODE" >"$SUITE_CFG/language"
say "  · suite language → $SUITE_CFG/language ($LANG_CODE)"

write_lang_pref() {
  local key=$1
  local cfg_name="${CFG[$key]}"
  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/$cfg_name"
  mkdir -p "$dir"
  local ui="$dir/ui.json"
  # Per-app ui.json (World / Excel / Slide). PdfCraft primarily uses app.ron — patched below.
  if command -v python3 >/dev/null; then
    python3 - "$ui" "$LANG_CODE" <<'PY'
import json, sys
from pathlib import Path
path, lang = Path(sys.argv[1]), sys.argv[2]
data = {}
if path.is_file():
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        data = {}
if not isinstance(data, dict):
    data = {}
data["language"] = lang
path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
  else
    printf '{\n  "language": "%s"\n}\n' "$LANG_CODE" >"$ui"
  fi

  # PdfCraft persists language inside eframe's app.ron (JSON keys + RON egui/window blobs).
  # Patch the escaped \"language\":\"…\" inside the pdfcraft string without parsing RON.
  if [[ "$cfg_name" == "pdfcraft" ]] && command -v python3 >/dev/null; then
    python3 - "$dir/app.ron" "$LANG_CODE" <<'PY'
import re, sys
from pathlib import Path
path, lang = Path(sys.argv[1]), sys.argv[2]
if not path.is_file():
    raise SystemExit(0)
text = path.read_text(encoding="utf-8")
new, n = re.subn(
    r'\\"language\\":\\"[^"\\]*\\"',
    f'\\\\"language\\\\":\\\\"{lang}\\\\"',
    text,
    count=1,
)
if n == 0:
    # No language field yet: insert as first key of the pdfcraft JSON object.
    new, n = re.subn(
        r'("pdfcraft"\s*:\s*")\{',
        rf'\1{{\\"language\\":\\"{lang}\\",',
        text,
        count=1,
    )
if n:
    path.write_text(new, encoding="utf-8")
PY
  fi
}

resolve_ai() {
  local app=$1
  local ai=""
  if [[ -f "$SRC_DIR/appimage/${app}.AppImage" ]]; then
    ai="$SRC_DIR/appimage/${app}.AppImage"
  else
    ai="$(ls "$SRC_DIR/appimage/${app}"-*-x86_64.AppImage 2>/dev/null | head -1 || true)"
  fi
  printf '%s\n' "$ai"
}

installed=0
for key in "${SELECTED[@]}"; do
  app="${BIN[$key]}"
  id="${ID[$key]}"
  name="${NAME[$key]}"
  ai="$(resolve_ai "$app")"
  if [[ -z "$ai" || ! -f "$ai" ]]; then
    warn "Thiếu $app trong $SRC_DIR/appimage — bỏ qua"
    continue
  fi
  install -m 755 "$ai" "$DEST_BIN/${app}.AppImage"
  ln -sfn "$DEST_BIN/${app}.AppImage" "$HOME/.local/bin/$app"

  # Absolute Icon= path so GNOME shows the PNG even if icon theme cache lags.
  icon_file="$(install_app_icon "$id" "$key")"
  icon_field="$id"
  [[ -n "$icon_file" && -f "$icon_file" ]] && icon_field="$icon_file"

  cat >"$DEST_APP/${id}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${name}
Comment=${name} — Ubu Office (manguonmo.com)
Exec=env UBU_OFFICE_LANG=${LANG_CODE} ${DEST_BIN}/${app}.AppImage %F
Icon=${icon_field}
Terminal=false
Categories=Office;
StartupNotify=true
StartupWMClass=${id}
Keywords=ubu;office;manguonmo;
EOF
  write_lang_pref "$key"
  say "  ✓ $name"
  installed=$((installed + 1))
done

[[ "$installed" -gt 0 ]] || die "Không cài được app nào."
update-desktop-database "$DEST_APP" 2>/dev/null || true
if [[ -f "$DEST_ICON/index.theme" ]]; then
  gtk-update-icon-cache -f -t "$DEST_ICON" 2>/dev/null || true
fi
# Nudge GNOME / desktop shells to rescan .desktop + icons
if command -v xdg-desktop-menu >/dev/null 2>&1; then
  xdg-desktop-menu forceupdate 2>/dev/null || true
fi
say "Hoàn tất: đã cài $installed app — ngôn ngữ mặc định: $LANG_CODE"
say "Menu ứng dụng + ~/.local/bin/Ubu-{World,Excel,Pdf,Slide}"
exit 0
