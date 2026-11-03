# Ubu Office — English guide

**Ubu Office** is a free office suite for Ubuntu: **World** (documents), **Excel** (spreadsheets), **Slide** (presentations), and **Pdf** (PDF).

Published by [manguonmo.com](https://manguonmo.com).

## Download

Open the [latest Release](https://github.com/manguonmocom/ubuntu-office/releases/latest) and pick:

| File | Use when |
|------|----------|
| `Ubu-*-x86_64.AppImage` | Portable — no install, no root |
| `Ubu-*_amd64.deb` | System install via `apt` / Software |

Verify checksums with `SHA256SUMS.txt` in the same release.

## Install AppImage

```bash
chmod +x Ubu-World-*-x86_64.AppImage
./Ubu-World-*-x86_64.AppImage
```

Optional: move the AppImage to `~/.local/bin/` and create a desktop shortcut.

## Install .deb

```bash
sudo apt install ./Ubu-World_*_amd64.deb
sudo apt install ./Ubu-Excel_*_amd64.deb
sudo apt install ./Ubu-Slide_*_amd64.deb
sudo apt install ./Ubu-Pdf_*_amd64.deb
```

Binaries: `ubu-world`, `ubu-excel`, `ubu-slide`, `ubu-pdf` (and `*-cli` tools).

## Apps at a glance

### Ubu World
Word-style editor. Open/save `.docx`, export PDF, ribbon UI, styles, tables.

### Ubu Excel
Spreadsheet. Open/save `.xlsx`, formulas, charts, sheets.

### Ubu Slide
Presentations. Open/save `.pptx`, slide show, themes.

### Ubu Pdf
Read and work with PDF files on the desktop.

## Screenshots

![Ubu World](images/ubu-world.jpg)

![Ubu Excel](images/ubu-excel.jpg)

![Ubu Slide](images/ubu-slide.jpg)

![Ubu Pdf](images/ubu-pdf.jpg)

## Logos

<p>
  <img src="../images/apps/ubu-world-128.png" width="64" alt="World" />
  <img src="../images/apps/ubu-excel-128.png" width="64" alt="Excel" />
  <img src="../images/apps/ubu-slide-128.png" width="64" alt="Slide" />
  <img src="../images/apps/ubu-pdf-128.png" width="64" alt="Pdf" />
</p>

Suite mark: ![Ubu Office](../images/logos/ubu-office-256.png)

## Tips

- Prefer **Vulkan** GPU drivers (`mesa-vulkan-drivers` on Ubuntu).
- If the window does not appear: try `WGPU_BACKEND=gl ./Ubu-World.AppImage`.
- Files stay on your machine — no cloud account required.

## Uninstall

- **AppImage:** delete the file (and any `.desktop` you created).
- **.deb:** `sudo apt remove ubu-world ubu-excel ubu-slide ubu-pdf`

## Support

- Site: https://manguonmo.com  
- Issues: https://github.com/manguonmocom/ubuntu-office/issues  

## License

MIT OR Apache-2.0 · Copyright (c) 2026 Ubu Office (manguonmo.com)
