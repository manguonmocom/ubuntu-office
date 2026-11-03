# Ubu Office — Hướng dẫn tiếng Việt

**Ubu Office** là bộ ứng dụng văn phòng miễn phí cho Ubuntu: **World** (soạn thảo), **Excel** (bảng tính), **Slide** (trình chiếu) và **Pdf** (PDF).

Phát hành bởi [manguonmo.com](https://manguonmo.com).

## Tải về

Mở [Release mới nhất](https://github.com/manguonmocom/ubuntu-office/releases/latest) và chọn:

| File | Khi nào dùng |
|------|----------------|
| `Ubu-*-x86_64.AppImage` | Chạy ngay, không cần cài, không cần root |
| `Ubu-*_amd64.deb` | Cài vào hệ thống bằng `apt` |

Kiểm tra checksum trong `SHA256SUMS.txt` cùng release.

## Cài AppImage

```bash
chmod +x Ubu-World-*-x86_64.AppImage
./Ubu-World-*-x86_64.AppImage
```

Hoặc: chuột phải → Properties → cho phép chạy như chương trình → nhấp đúp.

## Cài file .deb

```bash
sudo apt install ./Ubu-World_*_amd64.deb
sudo apt install ./Ubu-Excel_*_amd64.deb
sudo apt install ./Ubu-Slide_*_amd64.deb
sudo apt install ./Ubu-Pdf_*_amd64.deb
```

Lệnh chạy: `ubu-world`, `ubu-excel`, `ubu-slide`, `ubu-pdf`.

## Các ứng dụng

### Ubu World
Soạn thảo kiểu Word — mở/lưu `.docx`, xuất PDF, ribbon, kiểu chữ, bảng.

### Ubu Excel
Bảng tính — `.xlsx`, công thức, biểu đồ, nhiều sheet.

### Ubu Slide
Trình chiếu — `.pptx`, chiếu slide, theme.

### Ubu Pdf
Xem và làm việc với file PDF trên máy.

## Ảnh chụp màn hình

![Ubu World](images/ubu-world.jpg)

![Ubu Excel](images/ubu-excel.jpg)

![Ubu Slide](images/ubu-slide.jpg)

![Ubu Pdf](images/ubu-pdf.jpg)

## Logo ứng dụng

<p>
  <img src="../images/apps/ubu-world-128.png" width="64" alt="World" />
  <img src="../images/apps/ubu-excel-128.png" width="64" alt="Excel" />
  <img src="../images/apps/ubu-slide-128.png" width="64" alt="Slide" />
  <img src="../images/apps/ubu-pdf-128.png" width="64" alt="Pdf" />
</p>

Logo bộ: ![Ubu Office](../images/logos/ubu-office-256.png)

## Mẹo

- Nên có driver **Vulkan** (`sudo apt install mesa-vulkan-drivers`).
- Cửa sổ không hiện: thử `WGPU_BACKEND=gl ./Ubu-World.AppImage`.
- File của bạn ở trên máy — không cần tài khoản đám mây.

## Gỡ cài đặt

- **AppImage:** xoá file (và shortcut `.desktop` nếu có).
- **.deb:** `sudo apt remove ubu-world ubu-excel ubu-slide ubu-pdf`

## Hỗ trợ

- Website: https://manguonmo.com  
- Báo lỗi: https://github.com/manguonmocom/ubuntu-office/issues  

## Giấy phép

MIT OR Apache-2.0 · Copyright (c) 2026 Ubu Office (manguonmo.com)
