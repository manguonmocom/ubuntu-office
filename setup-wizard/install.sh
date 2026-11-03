#!/usr/bin/env bash
# Cài Ubu Office (World / Excel / Pdf / Slide) cho user hiện tại.
#
# Env / flags:
#   UBU_OFFICE_LANG=vi|en|…     ngôn ngữ giao diện lần đầu (mặc định: vi)
#   UBU_OFFICE_APPS=world,excel,pdf,slide   danh sách app (mặc định: cả 4)
#   --lang CODE
#   --apps world,excel,pdf,slide
#   --source DIR                thư mục releases/ubu (AppImage + icons)
#
# Nguồn AppImage (ưu tiên):
#   1) --source / UBU_OFFICE_SOURCE
#   2) sibling ../releases/ubu (dev)
#   3) GitHub Releases manguonmocom/ubuntu-office
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
say() { printf '%s\n' "$*"; }
warn() { printf 'Cảnh báo: %s\n' "$*" >&2; }
die() { printf 'Lỗi: %s\n' "$*" >&2; exit 1; }

# Wizard default is Vietnamese; apps themselves default to English when this file is absent.
LANG_CODE="${UBU_OFFICE_LANG:-vi}"
APPS_CSV="${UBU_OFFICE_APPS:-world,excel,pdf,slide}"
SRC="${UBU_OFFICE_SOURCE:-}"
REPO="${UBU_OFFICES_REPO:-manguonmocom/ubuntu-office}"
BASE_URL="${UBU_OFFICES_BASE_URL:-https://github.com/${REPO}/releases/latest/download}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/ubu-office"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang) LANG_CODE="$2"; shift 2 ;;
    --apps) APPS_CSV="$2"; shift 2 ;;
    --source) SRC="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,20p' "$0"
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
# XDG config dirs the apps read for ui.json language
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

find_src() {
  if [[ -n "$SRC" && -d "$SRC" ]]; then
    printf '%s\n' "$SRC"
    return
  fi
  if compgen -G "$ROOT/releases/ubu/appimage/Ubu-*.AppImage" >/dev/null; then
    printf '%s\n' "$ROOT/releases/ubu"
    return
  fi
  mkdir -p "$CACHE/appimage" "$CACHE/icons"
  say "==> Tải từ GitHub: $BASE_URL"
  command -v curl >/dev/null || die "Cần curl."
  local key app dest url ok=0
  for key in "${SELECTED[@]}"; do
    app="${BIN[$key]}"
    dest="$CACHE/appimage/${app}.AppImage"
    if [[ -f "$dest" && -s "$dest" ]]; then
      say "  · cache: $app"
      ok=1
      continue
    fi
    url="${BASE_URL}/${app}-x86_64.AppImage"
    say "  → $app …"
    if curl -fL --retry 2 --connect-timeout 25 -o "$dest.partial" "$url"; then
      mv -f "$dest.partial" "$dest"
      chmod +x "$dest"
      ok=1
      continue
    fi
    rm -f "$dest.partial"
    # API fallback: versioned asset names
    local asset
    asset="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" 2>/dev/null | python3 -c "
import json,sys,re
app=sys.argv[1]
data=json.load(sys.stdin)
pat=re.compile(re.escape(app)+r'-.*x86_64\\.AppImage\$')
for a in data.get('assets') or []:
    n=a.get('name') or ''
    if n in (app+'.AppImage', app+'-x86_64.AppImage') or pat.match(n):
        print(a.get('browser_download_url') or ''); break
" "$app" 2>/dev/null || true)"
    if [[ -n "$asset" ]] && curl -fL --retry 2 --connect-timeout 25 -o "$dest.partial" "$asset"; then
      mv -f "$dest.partial" "$dest"
      chmod +x "$dest"
      ok=1
      say "  ✓ $app (API)"
    else
      rm -f "$dest.partial"
      warn "Không tải được $app"
    fi
  done
  [[ "$ok" -eq 1 ]] || die "Không tải được AppImage nào từ $REPO"
  # icons optional
  for key in "${SELECTED[@]}"; do
    local id="${ID[$key]}"
    local ic="$CACHE/icons/${id}.png"
    [[ -f "$ic" ]] && continue
    curl -fsSL -o "$ic" "${BASE_URL}/${id}.png" 2>/dev/null || true
  done
  printf '%s\n' "$CACHE"
}

SRC="$(find_src)"
say "==> Nguồn: $SRC"

DEST_BIN="${XDG_DATA_HOME:-$HOME/.local/share}/ubu-office/bin"
DEST_APP="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
DEST_ICON="${XDG_DATA_HOME:-$HOME/.local/share}/icons/hicolor"
SUITE_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/ubu-office"
mkdir -p "$DEST_BIN" "$DEST_APP" "$HOME/.local/bin" "$SUITE_CFG"

# Suite-wide language (apps read this on first run when they have no per-app prefs yet).
printf '%s\n' "$LANG_CODE" >"$SUITE_CFG/language"
say "  · suite language → $SUITE_CFG/language ($LANG_CODE)"

write_lang_pref() {
  local key=$1
  local cfg_name="${CFG[$key]}"
  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/$cfg_name"
  mkdir -p "$dir"
  # Minimal ui.json — apps merge/replace on next save. Prefer not to clobber rich prefs.
  local ui="$dir/ui.json"
  if [[ -f "$ui" ]] && command -v python3 >/dev/null; then
    python3 - "$ui" "$LANG_CODE" <<'PY'
import json,sys
path, lang = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path, encoding="utf-8"))
except Exception:
    data = {}
if not isinstance(data, dict):
    data = {}
data["language"] = lang
json.dump(data, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print("updated", path)
PY
  else
    printf '{\n  "language": "%s"\n}\n' "$LANG_CODE" >"$ui"
    say "  · ngôn ngữ $LANG_CODE → $ui"
  fi
}

installed=0
for key in "${SELECTED[@]}"; do
  app="${BIN[$key]}"
  id="${ID[$key]}"
  name="${NAME[$key]}"
  ai=""
  if [[ -f "$SRC/appimage/${app}.AppImage" ]]; then
    ai="$SRC/appimage/${app}.AppImage"
  else
    ai="$(ls "$SRC/appimage/${app}"-*-x86_64.AppImage 2>/dev/null | head -1 || true)"
  fi
  if [[ -z "$ai" || ! -f "$ai" ]]; then
    warn "Thiếu $app — bỏ qua"
    continue
  fi
  install -m 755 "$ai" "$DEST_BIN/${app}.AppImage"
  ln -sfn "$DEST_BIN/${app}.AppImage" "$HOME/.local/bin/$app"
  cat >"$DEST_APP/${id}.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=${name}
Comment=${name} — Ubu Office (manguonmo.com)
Exec=env UBU_OFFICE_LANG=${LANG_CODE} ${DEST_BIN}/${app}.AppImage %F
Icon=${id}
Terminal=false
Categories=Office;
StartupNotify=true
StartupWMClass=${id}
Keywords=ubu;office;manguonmo;
EOF
  if [[ -f "$SRC/icons/${id}.png" ]]; then
    mkdir -p "$DEST_ICON/256x256/apps"
    install -m 644 "$SRC/icons/${id}.png" "$DEST_ICON/256x256/apps/${id}.png"
  fi
  write_lang_pref "$key"
  say "  ✓ $name"
  installed=$((installed + 1))
done

[[ "$installed" -gt 0 ]] || die "Không cài được app nào."
update-desktop-database "$DEST_APP" 2>/dev/null || true
say "Hoàn tất: đã cài $installed app — ngôn ngữ mặc định: $LANG_CODE"
say "Menu ứng dụng + ~/.local/bin/{Ubu-World,Ubu-Excel,Ubu-Pdf,Ubu-Slide}"
exit 0
