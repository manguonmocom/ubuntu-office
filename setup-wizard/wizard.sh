#!/usr/bin/env bash
# Ubu Office Setup Wizard — bash + zenity (no Python/GTK bindings required).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
INSTALL="$HERE/install.sh"

die() { printf '%s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

# Official Ubu Office logo for zenity window chrome.
WIN_ICON=""
for cand in \
  "$HERE/ubu-office.png" \
  "$HERE/ubu-office-256.png" \
  "$HERE/../com.manguonmo.ubu-office.png" \
  "$HERE/../../com.manguonmo.ubu-office.png"
do
  if [[ -f "$cand" ]]; then WIN_ICON="$cand"; break; fi
done
ZICON=()
[[ -n "$WIN_ICON" ]] && ZICON=(--window-icon="$WIN_ICON")

if ! have zenity; then
  die "Cần zenity: sudo apt install zenity"
fi

# Plain text (zenity 4 / libadwaita is picky about markup).
zenity --info --width=480 --title="Ubu Office Setup" "${ZICON[@]}" \
  --text="Ubu Office — bộ ứng dụng văn phòng cho Ubuntu
(World · Excel · Pdf · Slide)

Tiếp theo: chọn ngôn ngữ và thành phần cần cài." \
  || true

LANG_PICK="$(zenity --list --radiolist \
  --title="Ubu Office — Ngôn ngữ" \
  --width=420 --height=420 \
  "${ZICON[@]}" \
  --text="Ngôn ngữ giao diện lần đầu (app mặc định English nếu bỏ qua Setup):" \
  --column="Chọn" --column="Ngôn ngữ" --column="Mã" \
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
  --hide-column=3 --print-column=3)" || exit 1
LANG_CODE="${LANG_PICK:-vi}"

APP_PICK="$(zenity --list --checklist \
  --title="Ubu Office — Thành phần" \
  --width=520 --height=360 \
  "${ZICON[@]}" \
  --text="Chọn ứng dụng cần cài (mặc định: tất cả):" \
  --column="Cài" --column="Ứng dụng" --column="Mã" \
  TRUE "Ubu World — Soạn thảo" world \
  TRUE "Ubu Excel — Bảng tính" excel \
  TRUE "Ubu Pdf — PDF" pdf \
  TRUE "Ubu Slide — Trình chiếu" slide \
  --hide-column=3 --print-column=3 --separator=',')" || exit 1
[[ -n "${APP_PICK:-}" ]] || die "Chưa chọn ứng dụng nào."

zenity --question --width=440 --title="Ubu Office Setup" "${ZICON[@]}" \
  --text="Cài đặt với:
• Ngôn ngữ: ${LANG_CODE}
• Apps: ${APP_PICK}

Tiếp tục?" \
  || exit 1

LOG="$(mktemp /tmp/ubu-office-setup.XXXXXX.log)"
(
  echo "==> Ubu Office Setup"
  echo "lang=$LANG_CODE apps=$APP_PICK"
  SRC_ARGS=()
  if [[ -d "$HERE/../releases/ubu/appimage" ]]; then
    SRC_ARGS=(--source "$HERE/../releases/ubu")
  elif [[ -d "$HERE/packages/appimage" ]]; then
    SRC_ARGS=(--source "$HERE/packages")
  fi
  bash "$INSTALL" --lang "$LANG_CODE" --apps "$APP_PICK" "${SRC_ARGS[@]}"
) >"$LOG" 2>&1 &
PID=$!

# Progress UI (do not fail the install if zenity progress is closed early).
(
  while kill -0 "$PID" 2>/dev/null; do
    echo "# Đang tải / cài đặt…"
    sleep 0.4
  done
) | zenity --progress --pulsate --auto-close --no-cancel --width=480 \
  --title="Ubu Office — Đang cài" --text="Đang tải / cài đặt…" \
  "${ZICON[@]}" 2>/dev/null || true

wait "$PID" || true
RC=0
if ! grep -q 'Hoàn tất' "$LOG"; then
  RC=1
fi

if [[ "$RC" -eq 0 ]]; then
  zenity --info --width=440 --title="Ubu Office" "${ZICON[@]}" \
    --text="Cài đặt xong.
Ngôn ngữ: ${LANG_CODE}

Mở menu ứng dụng → Ubu World / Excel / Pdf / Slide.

Nhật ký: ${LOG}" || true
  exit 0
fi

DETAIL="$(tail -25 "$LOG" | sed 's/&/\&amp;/g; s/</\&lt;/g')"
zenity --error --width=520 --title="Ubu Office" "${ZICON[@]}" \
  --text="Cài đặt chưa hoàn tất.

Log: ${LOG}

${DETAIL}" || true
exit 1
