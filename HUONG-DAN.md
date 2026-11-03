# Ubu Office — Hướng dẫn cài đặt (Tiếng Việt)

> [🇬🇧 USER GUIDE (EN)](GUIDE.md) · [README](README.md) · [⬇ Tải Release](https://github.com/manguonmocom/ubuntu-office/releases/latest)

## ⬇ Tải Setup (1 click — khuyến nghị cho người mới)

**[Ubu-Office-Setup-0.1.0-x86_64.AppImage](https://github.com/manguonmocom/ubuntu-office/releases/download/v0.1.0/Ubu-Office-Setup-0.1.0-x86_64.AppImage)**

Sau khi tải: chuột phải → **Thuộc tính** → bật **Cho phép chạy như chương trình** → nhấp đúp → chọn ngôn ngữ → tick app → **Install**.

---

**Ubu Office** là bộ ứng dụng văn phòng **miễn phí, mã nguồn mở** cho Ubuntu/Linux:

| Ứng dụng | Việc chính | Định dạng |
|----------|------------|-----------|
| **Ubu World** | Soạn thảo (kiểu Word) | `.docx`, ODT, RTF… |
| **Ubu Excel** | Bảng tính | `.xlsx`, CSV… |
| **Ubu Slide** | Trình chiếu | `.pptx` |
| **Ubu Pdf** | Xem / chỉnh PDF | `.pdf` |

- Ứng dụng **mặc định English**.
- Cài bằng **Setup Wizard** → chọn ngôn ngữ (mặc định **Tiếng Việt**) cho lần mở đầu.
- File nằm trên máy — không bắt buộc tài khoản đám mây.

---

## Cách 1 — Setup Wizard AppImage (khuyến nghị)

Không cần Python. Chỉ cần Ubuntu Desktop (có `zenity`).

### Bước từng bước

1. Tải trực tiếp: **[Ubu-Office-Setup-0.1.0-x86_64.AppImage](https://github.com/manguonmocom/ubuntu-office/releases/download/v0.1.0/Ubu-Office-Setup-0.1.0-x86_64.AppImage)**  
   (hoặc mở [Release mới nhất](https://github.com/manguonmocom/ubuntu-office/releases/latest)).
2. Chuột phải file → **Properties / Thuộc tính** → bật **Allow executing file as program** / **Cho phép chạy như chương trình**.  
   Hoặc Terminal:

   ```bash
   chmod +x Ubu-Office-Setup-*-x86_64.AppImage
   ```

3. **Nhấp đúp** file Setup (hoặc `./Ubu-Office-Setup-*-x86_64.AppImage`).
4. Chọn **ngôn ngữ giao diện** (mặc định: Tiếng Việt).
5. Tick ứng dụng cần cài (mặc định: **cả 4**).
6. Xác nhận — Setup tải/cài AppImage, tạo shortcut menu, ghi `~/.config/ubu-office/language`.

Sau đó mở **Ubu World / Excel / Pdf / Slide** từ menu ứng dụng.

> Thiếu zenity? `sudo apt install zenity`

---

## Cách 2 — Bash (CLI), không GUI

Clone hoặc tải script Setup, rồi chạy `install.sh`:

```bash
# Ví dụ: lấy từ repo
git clone https://github.com/manguonmocom/ubuntu-office.git
cd ubuntu-office/setup-wizard

# Cài cả 4 app, ngôn ngữ Tiếng Việt (mặc định của wizard)
./install.sh --lang vi --apps world,excel,pdf,slide

# Chỉ Excel + World, English
./install.sh --lang en --apps world,excel

# Dùng gói AppImage đã tải sẵn (thư mục có appimage/ + icons/)
./install.sh --lang vi --apps world,excel,pdf,slide --source /đường/dẫn/releases/ubu
```

Hoặc wizard CLI bằng zenity:

```bash
./wizard.sh
```

**Biến môi trường hữu ích:**

| Biến | Ý nghĩa |
|------|---------|
| `UBU_OFFICE_LANG` | Mã ngôn ngữ (`vi`, `en`, …) |
| `UBU_OFFICE_APPS` | `world,excel,pdf,slide` |
| `UBU_OFFICE_SOURCE` | Thư mục chứa `appimage/` |

Setup ghi:

- `~/.config/ubu-office/language` — ngôn ngữ suite (app đọc khi chưa có prefs riêng)
- `~/.local/share/ubu-office/bin/Ubu-*.AppImage`
- shortcut `~/.local/share/applications/com.manguonmo.ubu-*.desktop`
- symlink `~/.local/bin/Ubu-World` …

---

## Cách 3 — AppImage từng phần mềm (thủ công)

1. Tải `Ubu-World-…AppImage`, `Ubu-Excel-…`, `Ubu-Slide-…`, `Ubu-Pdf-…`.
2. Properties → **Allow running as a program**, rồi nhấp đúp.

```bash
chmod +x Ubu-World-*-x86_64.AppImage
./Ubu-World-*-x86_64.AppImage
```

Muốn ngôn ngữ Tiếng Việt khi chưa qua Setup:

```bash
mkdir -p ~/.config/ubu-office
echo vi > ~/.config/ubu-office/language
# hoặc mỗi lần chạy:
UBU_OFFICE_LANG=vi ./Ubu-World-*-x86_64.AppImage
```

---

## Cách 4 — Gói `.deb`

```bash
sudo apt install ./Ubu-World_*_amd64.deb
sudo apt install ./Ubu-Excel_*_amd64.deb
sudo apt install ./Ubu-Slide_*_amd64.deb
sudo apt install ./Ubu-Pdf_*_amd64.deb
```

Lệnh: `ubu-world`, `ubu-excel`, `ubu-slide`, `ubu-pdf`.

---

## Đổi ngôn ngữ sau khi cài

- Trong app: **Options / Preferences → Interface language**.
- Reset về lựa chọn Setup (xóa prefs từng app):

```bash
rm -f ~/.config/wordcraft/ui.json \
      ~/.config/gridcraft/ui.json \
      ~/.config/pdfcraft/ui.json
# Giữ ~/.config/ubu-office/language nếu muốn Setup language vẫn áp dụng lần mở sau
```

> **Ubu Slide:** giao diện hiện chủ yếu English (upstream chưa có bộ dịch UI đầy đủ). World / Excel / Pdf hỗ trợ Tiếng Việt.

---

## Ảnh chụp màn hình

![Ubu World](images/screenshots/ubu-world.jpg)

![Ubu Excel](images/screenshots/ubu-excel.jpg)

![Ubu Slide](images/screenshots/ubu-slide.jpg)

![Ubu Pdf](images/screenshots/ubu-pdf.jpg)

---

## Mẹo & sự cố

- Vulkan: `sudo apt install mesa-vulkan-drivers`
- Cửa sổ không hiện: `WGPU_BACKEND=gl ./Ubu-World-*.AppImage`
- **Không** chạy AppImage bằng `sudo`
- Checksum: file `checksums.sha256` trong Release

## Gỡ cài

```bash
rm -f ~/.local/share/ubu-office/bin/Ubu-*.AppImage
rm -f ~/.local/share/applications/com.manguonmo.ubu-*.desktop
rm -f ~/.local/bin/Ubu-{World,Excel,Pdf,Slide}
# .deb:
sudo apt remove ubu-world ubu-excel ubu-slide ubu-pdf
```

## Hỗ trợ

- https://manguonmo.com  
- https://github.com/manguonmocom/ubuntu-office/issues  

Giấy phép: MIT OR Apache-2.0 · © 2026 Ubu Office (manguonmo.com)
