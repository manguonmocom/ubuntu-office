#!/usr/bin/env bash
# Ubu Office Setup Wizard — pure bash + zenity (no Python required).
# Used by the Setup AppImage and as a fallback when python3-gi is missing.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
INSTALL="$HERE/install.sh"
[[ -x "$INSTALL" ]] || INSTALL="bash $HERE/install.sh"

die() { printf '%s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

if ! have zenity; then
  die "Cần zenity (sudo apt install zenity) — hoặc dùng bản Python: python3 setup-wizard.py"
fi

zenity --info --width=480 --title="Ubu Office Setup" \
  --text="<b>Ubu Office</b>\nBộ ứng dụng văn phòng cho Ubuntu\n(World · Excel · Pdf · Slide)\n\nTiếp theo: chọn ngôn ngữ và thành phần cần cài." \
  || true

# Language (default Vietnamese)
LANG_PICK="$(zenity --list --radiolist --title="Ubu Office — Ngôn ngữ" --width=420 --height=420 \
  --text="Ngôn ngữ giao diện mặc định:" \
  --column="" --column="Ngôn ngữ" --column="Mã" \
  TRUE "Tiếng Việt" vi \
  FALSE "English" en \
  FALSE "中文" zh \
  FALSE "日本語" ja \
  FALSE "한국어" ko \
  FALSE "Français" fr \
  FALSE "Deutsch" de \
  FALSE "Español" es \
  FALSE "Português" pt \
  FALSE "Русский" ru \
  --print-column=3)" || exit 1
LANG_CODE="${LANG_PICK:-vi}"

# Apps (default all checked)
APP_PICK="$(zenity --list --checklist --title="Ubu Office — Thành phần" --width=520 --height=360 \
  --text="Chọn ứng dụng cần cài (mặc định: tất cả):" \
  --column="" --column="Ứng dụng" --column="Mã" \
  TRUE "Ubu World — Soạn thảo" world \
  TRUE "Ubu Excel — Bảng tính" excel \
  TRUE "Ubu Pdf — PDF" pdf \
  TRUE "Ubu Slide — Trình chiếu" slide \
  --print-column=3 --separator=',')" || exit 1
[[ -n "$APP_PICK" ]] || die "Chưa chọn ứng dụng nào."

zenity --question --width=440 --title="Ubu Office Setup" \
  --text="Cài đặt với:\n• Ngôn ngữ: <b>$LANG_CODE</b>\n• Apps: <b>$APP_PICK</b>\n\nTiếp tục?" \
  || exit 1

LOG="$(mktemp /tmp/ubu-office-setup.XXXXXX.log)"
(
  echo "==> Ubu Office Setup"
  echo "lang=$LANG_CODE apps=$APP_PICK"
  # Prefer bundled/local packages next to this script's parent releases/
  SRC_ARGS=()
  if [[ -d "$HERE/../releases/ubu/appimage" ]]; then
    SRC_ARGS=(--source "$HERE/../releases/ubu")
  elif [[ -d "$HERE/releases/ubu/appimage" ]]; then
    SRC_ARGS=(--source "$HERE/releases/ubu")
  fi
  # shellcheck disable=SC2086
  bash "$HERE/install.sh" --lang "$LANG_CODE" --apps "$APP_PICK" "${SRC_ARGS[@]}"
) 2>&1 | tee "$LOG" | zenity --progress --pulsate --auto-close --width=480 \
  --title="Ubu Office — Đang cài" --text="Đang tải / cài đặt…" || true

if grep -q 'Hoàn tất' "$LOG"; then
  zenity --info --width=440 --title="Ubu Office" \
    --text="<b>Cài đặt xong.</b>\nNgôn ngữ: $LANG_CODE\n\nMở menu ứng dụng và chạy Ubu World / Excel / Pdf / Slide.\n\nNhật ký: $LOG"
else
  zenity --error --width=480 --title="Ubu Office" \
    --text="Cài đặt chưa hoàn tất. Xem log:\n$LOG\n\n$(tail -20 "$LOG" | sed 's/&/\&amp;/g')"
  exit 1
fi
