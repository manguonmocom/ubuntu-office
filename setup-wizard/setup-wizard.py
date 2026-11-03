#!/usr/bin/env python3
"""Ubu Office Setup Wizard — chọn ngôn ngữ + tick app cần cài (GTK4 + Adwaita)."""

from __future__ import annotations

import os
import re
import signal
import subprocess
import sys
import threading
from pathlib import Path

_ANSI_RE = re.compile(r"\x1b\[[0-9;]*[A-Za-z]")

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, GLib, Gtk  # noqa: E402

ROOT = Path(__file__).resolve().parent
INSTALL_SH = ROOT / "install.sh"
OFFICES_ROOT = ROOT.parent

# (code, label)
LANGUAGES = [
    ("vi", "Tiếng Việt"),
    ("en", "English"),
    ("zh", "中文"),
    ("ja", "日本語"),
    ("ko", "한국어"),
    ("fr", "Français"),
    ("de", "Deutsch"),
    ("es", "Español"),
    ("pt", "Português"),
    ("ru", "Русский"),
]

APPS = [
    ("world", "Ubu World", "Soạn thảo văn bản (.docx, ODT, …)"),
    ("excel", "Ubu Excel", "Bảng tính (.xlsx, CSV, …)"),
    ("pdf", "Ubu Pdf", "Xem và chỉnh PDF"),
    ("slide", "Ubu Slide", "Trình chiếu (.pptx, …)"),
]


class Wizard(Adw.ApplicationWindow):
    def __init__(self, app: Adw.Application) -> None:
        super().__init__(application=app, title="Ubu Office Setup", default_width=640, default_height=520)
        self.set_resizable(True)

        self.lang_code = "vi"
        self.app_checks: dict[str, Gtk.CheckButton] = {}
        self.proc: subprocess.Popen[str] | None = None
        self._log_buffer: Gtk.TextBuffer | None = None
        self._status: Gtk.Label | None = None
        self._progress: Gtk.ProgressBar | None = None
        self._stack: Gtk.Stack | None = None
        self._btn_back: Gtk.Button | None = None
        self._btn_next: Gtk.Button | None = None
        self._pages = ["welcome", "language", "apps", "progress"]
        self._page = 0

        header = Adw.HeaderBar()
        self._btn_back = Gtk.Button(label="Quay lại")
        self._btn_back.connect("clicked", self._on_back)
        self._btn_next = Gtk.Button(label="Tiếp tục")
        self._btn_next.add_css_class("suggested-action")
        self._btn_next.connect("clicked", self._on_next)
        header.pack_start(self._btn_back)
        header.pack_end(self._btn_next)

        self._stack = Gtk.Stack(transition_type=Gtk.StackTransitionType.SLIDE_LEFT_RIGHT)
        self._stack.add_named(self._page_welcome(), "welcome")
        self._stack.add_named(self._page_language(), "language")
        self._stack.add_named(self._page_apps(), "apps")
        self._stack.add_named(self._page_progress(), "progress")

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        box.append(header)
        box.append(self._stack)
        self.set_content(box)
        self._refresh_nav()

    def _page_welcome(self) -> Gtk.Widget:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16, margin_top=40, margin_bottom=24, margin_start=32, margin_end=32)
        title = Gtk.Label(label="Ubu Office")
        title.add_css_class("title-1")
        sub = Gtk.Label(
            label="Bộ ứng dụng văn phòng mã nguồn mở cho Ubuntu/Linux\n"
            "(Ubu World · Ubu Excel · Ubu Pdf · Ubu Slide)\n\n"
            "Trình này giúp chọn ngôn ngữ giao diện và các thành phần cần cài.",
            wrap=True,
            justify=Gtk.Justification.CENTER,
        )
        sub.add_css_class("dim-label")
        box.append(title)
        box.append(sub)
        return box

    def _page_language(self) -> Gtk.Widget:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=24, margin_bottom=24, margin_start=32, margin_end=32)
        head = Gtk.Label(label="Ngôn ngữ giao diện", xalign=0.0)
        head.add_css_class("title-2")
        hint = Gtk.Label(
            label="Áp dụng khi mở app lần đầu (có thể đổi sau trong tùy chọn).",
            xalign=0.0,
            wrap=True,
        )
        hint.add_css_class("dim-label")
        box.append(head)
        box.append(hint)

        group = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        first: Gtk.CheckButton | None = None
        for code, label in LANGUAGES:
            btn = Gtk.CheckButton(label=f"{label}  ({code})")
            if first is None:
                first = btn
                btn.set_active(code == "vi")
            else:
                btn.set_group(first)
                if code == "vi":
                    btn.set_active(True)
            btn.connect("toggled", self._on_lang, code)
            group.append(btn)
        box.append(group)
        return box

    def _on_lang(self, btn: Gtk.CheckButton, code: str) -> None:
        if btn.get_active():
            self.lang_code = code

    def _page_apps(self) -> Gtk.Widget:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=24, margin_bottom=24, margin_start=32, margin_end=32)
        head = Gtk.Label(label="Chọn thành phần", xalign=0.0)
        head.add_css_class("title-2")
        hint = Gtk.Label(label="Mặc định cài cả bốn ứng dụng.", xalign=0.0)
        hint.add_css_class("dim-label")
        box.append(head)
        box.append(hint)

        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=8)
        all_btn = Gtk.Button(label="Chọn tất cả")
        none_btn = Gtk.Button(label="Bỏ chọn")
        all_btn.connect("clicked", lambda *_: self._set_all(True))
        none_btn.connect("clicked", lambda *_: self._set_all(False))
        row.append(all_btn)
        row.append(none_btn)
        box.append(row)

        for key, name, desc in APPS:
            cb = Gtk.CheckButton(label=f"{name} — {desc}")
            cb.set_active(True)
            self.app_checks[key] = cb
            box.append(cb)
        return box

    def _set_all(self, on: bool) -> None:
        for cb in self.app_checks.values():
            cb.set_active(on)

    def _page_progress(self) -> Gtk.Widget:
        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=24, margin_bottom=24, margin_start=24, margin_end=24)
        self._status = Gtk.Label(label="Sẵn sàng cài đặt…", xalign=0.0)
        self._progress = Gtk.ProgressBar(show_text=False)
        scroll = Gtk.ScrolledWindow(vexpand=True, hexpand=True, min_content_height=260)
        view = Gtk.TextView(editable=False, monospace=True, wrap_mode=Gtk.WrapMode.WORD_CHAR)
        self._log_buffer = view.get_buffer()
        scroll.set_child(view)
        box.append(self._status)
        box.append(self._progress)
        box.append(scroll)
        return box

    def _refresh_nav(self) -> None:
        assert self._stack and self._btn_back and self._btn_next
        name = self._pages[self._page]
        self._stack.set_visible_child_name(name)
        self._btn_back.set_sensitive(self._page > 0 and name != "progress")
        if name == "welcome":
            self._btn_next.set_label("Tiếp tục")
        elif name == "language":
            self._btn_next.set_label("Tiếp tục")
        elif name == "apps":
            self._btn_next.set_label("Cài đặt")
        else:
            self._btn_next.set_label("Đóng")
            self._btn_next.set_sensitive(self.proc is None)

    def _on_back(self, *_a) -> None:
        if self._page > 0 and self._pages[self._page] != "progress":
            self._page -= 1
            self._refresh_nav()

    def _on_next(self, *_a) -> None:
        name = self._pages[self._page]
        if name == "progress":
            if self.proc is None:
                self.close()
            return
        if name == "apps":
            selected = [k for k, cb in self.app_checks.items() if cb.get_active()]
            if not selected:
                self._toast("Hãy chọn ít nhất một ứng dụng.")
                return
            self._page = self._pages.index("progress")
            self._refresh_nav()
            self._start_install(selected)
            return
        if self._page < len(self._pages) - 1:
            self._page += 1
            self._refresh_nav()

    def _toast(self, msg: str) -> None:
        # Lightweight: also append to log if visible
        dlg = Adw.AlertDialog(heading="Ubu Office", body=msg)
        dlg.add_response("ok", "OK")
        dlg.present(self)

    def _append(self, text: str) -> None:
        if not self._log_buffer:
            return
        text = _ANSI_RE.sub("", text)
        end = self._log_buffer.get_end_iter()
        self._log_buffer.insert(end, text)

    def _start_install(self, selected: list[str]) -> None:
        if not INSTALL_SH.is_file():
            self._append(f"Thiếu {INSTALL_SH}\n")
            return
        apps = ",".join(selected)
        args = ["bash", str(INSTALL_SH), "--lang", self.lang_code, "--apps", apps]
        # Prefer local built packages when present
        local = OFFICES_ROOT / "releases" / "ubu"
        if (local / "appimage").is_dir():
            args += ["--source", str(local)]

        if self._status:
            self._status.set_label(f"Đang cài ({apps}), ngôn ngữ={self.lang_code}…")
        if self._progress:
            self._progress.pulse()
            GLib.timeout_add(120, self._pulse)

        self._append("$ " + " ".join(args) + "\n\n")
        if self._btn_next:
            self._btn_next.set_sensitive(False)
        if self._btn_back:
            self._btn_back.set_sensitive(False)

        def worker() -> None:
            try:
                self.proc = subprocess.Popen(
                    args,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,
                    text=True,
                    bufsize=1,
                    cwd=str(ROOT),
                    start_new_session=True,
                    env={**os.environ, "UBU_OFFICE_LANG": self.lang_code, "UBU_OFFICE_APPS": apps},
                )
                assert self.proc.stdout is not None
                for line in self.proc.stdout:
                    GLib.idle_add(self._append, line)
                code = self.proc.wait()
            except OSError as e:
                GLib.idle_add(self._append, f"\nLỗi: {e}\n")
                code = 1
            GLib.idle_add(self._finish, code)

        threading.Thread(target=worker, daemon=True).start()

    def _pulse(self) -> bool:
        if self.proc is None:
            return False
        if self._progress:
            self._progress.pulse()
        return True

    def _finish(self, code: int) -> None:
        self.proc = None
        ok = code == 0
        if self._status:
            self._status.set_label("Hoàn tất." if ok else f"Thất bại (mã {code}).")
        if self._progress:
            self._progress.set_fraction(1.0 if ok else 0.0)
        if self._btn_next:
            self._btn_next.set_sensitive(True)
            self._btn_next.set_label("Đóng")
        self._append("\n✔ Xong.\n" if ok else f"\n✖ Exit {code}\n")


class App(Adw.Application):
    def __init__(self) -> None:
        super().__init__(application_id="com.manguonmo.ubu-office-setup")
        self.connect("activate", self._activate)

    def _activate(self, *_a) -> None:
        win = Wizard(self)
        win.present()


def main() -> int:
    if not INSTALL_SH.is_file():
        print(f"Thiếu {INSTALL_SH}", file=sys.stderr)
        return 1
    return App().run(sys.argv)


if __name__ == "__main__":
    raise SystemExit(main())
