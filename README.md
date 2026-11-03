<p align="center">
  <img src="images/logos/ubu-office-256.png" alt="Ubu Office logo" width="128" />
</p>

<h1 align="center">Ubu Office</h1>

<p align="center">
  <b>Free open-source office suite for Ubuntu &amp; Linux</b><br/>
  Word processor · Spreadsheet · Presentation · PDF — by
  <a href="https://manguonmo.com">manguonmo.com</a>
</p>

<p align="center">
  <a href="HUONG-DAN.md"><b>🇻🇳 Hướng Dẫn (VI)</b></a>
  &nbsp;·&nbsp;
  <a href="GUIDE.md"><b>🇬🇧 USER GUIDE (EN)</b></a>
  &nbsp;·&nbsp;
  <a href="https://github.com/manguonmocom/ubuntu-office/releases/latest"><b>⬇ Releases</b></a>
</p>

<p align="center">
  <a href="https://github.com/manguonmocom/ubuntu-office/releases/download/v0.1.0/Ubu-Office-Setup-0.1.0-x86_64.AppImage"><img alt="Download Setup AppImage" src="https://img.shields.io/badge/⬇_Download_Setup-Ubu--Office--Setup--0.1.0--x86__64.AppImage-brightgreen?style=for-the-badge" /></a>
</p>

<p align="center">
  <b><a href="https://github.com/manguonmocom/ubuntu-office/releases/download/v0.1.0/Ubu-Office-Setup-0.1.0-x86_64.AppImage">⬇ Tải Setup AppImage (1 click)</a></b>
  — rồi Properties → Allow running as a program → double-click → Install<br/>
  <sub>No Python required · picks language + apps · see <a href="HUONG-DAN.md">HUONG-DAN.md</a> / <a href="GUIDE.md">GUIDE.md</a></sub>
</p>

<p align="center">
  <a href="https://github.com/manguonmocom/ubuntu-office/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/manguonmocom/ubuntu-office?label=release" /></a>
  <a href="LICENSE-MIT"><img alt="License" src="https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-blue" /></a>
  <img alt="Platform" src="https://img.shields.io/badge/platform-Ubuntu%2022.04%2B%20%7C%20Linux%20x86__64-orange" />
  <img alt="UI" src="https://img.shields.io/badge/UI-Vietnamese%20%2B%20English-green" />
</p>

---

**Ubu Office** is a lightweight, private **Ubuntu office suite** (also works on other Linux distros): edit **Word documents**, **Excel spreadsheets**, **PowerPoint slides**, and **PDF files** without a Microsoft 365 subscription or cloud lock-in. Files stay on your PC. Apps default to **English**; the **Setup Wizard** can set Vietnamese (or another language) for first launch. Change language anytime in each app’s Options.

| App | Role | Opens / saves |
|-----|------|----------------|
| **Ubu World** | Word processor | `.docx`, ODT, RTF, Markdown, PDF export |
| **Ubu Excel** | Spreadsheet | `.xlsx`, CSV, ODS |
| **Ubu Slide** | Presentations | `.pptx` |
| **Ubu Pdf** | PDF workbench | `.pdf` (view, annotate, fill, organize) |

<p align="center">
  <img src="images/apps/ubu-world-128.png" width="64" alt="Ubu World" />
  <img src="images/apps/ubu-excel-128.png" width="64" alt="Ubu Excel" />
  <img src="images/apps/ubu-slide-128.png" width="64" alt="Ubu Slide" />
  <img src="images/apps/ubu-pdf-128.png" width="64" alt="Ubu Pdf" />
</p>

## Screenshots

| Ubu World | Ubu Excel |
|-----------|-----------|
| <img src="images/screenshots/ubu-world.jpg" width="420" alt="Ubu World word processor screenshot" /> | <img src="images/screenshots/ubu-excel.jpg" width="420" alt="Ubu Excel spreadsheet screenshot" /> |

| Ubu Slide | Ubu Pdf |
|-----------|---------|
| <img src="images/screenshots/ubu-slide.jpg" width="420" alt="Ubu Slide presentation screenshot" /> | <img src="images/screenshots/ubu-pdf.jpg" width="420" alt="Ubu Pdf welcome screen screenshot" /> |

## Quick install (Ubuntu)

### Easiest — Setup AppImage (recommended)

1. **[Download Ubu-Office-Setup-0.1.0-x86_64.AppImage](https://github.com/manguonmocom/ubuntu-office/releases/download/v0.1.0/Ubu-Office-Setup-0.1.0-x86_64.AppImage)** (direct link).
2. Right-click → **Properties** → enable **“Allow running as a program”** (or `chmod +x` that file).
3. Double-click → pick **language** (default: **Tiếng Việt**) → tick apps (default: **all four**) → Install.

No Python required for the wizard GUI (uses `zenity`, already on Ubuntu Desktop). The wizard downloads the four app AppImages for you.

### Bash Setup (no GUI)

```bash
git clone https://github.com/manguonmocom/ubuntu-office.git
cd ubuntu-office/setup-wizard
./install.sh --lang vi --apps world,excel,pdf,slide
```

### Per-app AppImage / `.deb`

```bash
chmod +x Ubu-World-*-x86_64.AppImage && ./Ubu-World-*-x86_64.AppImage

sudo apt install ./Ubu-World_*_amd64.deb ./Ubu-Excel_*_amd64.deb \
  ./Ubu-Slide_*_amd64.deb ./Ubu-Pdf_*_amd64.deb
```

Full steps: [USER GUIDE (EN)](GUIDE.md) · [Hướng Dẫn (VI)](HUONG-DAN.md).

## Why Ubu Office?

- **Ubuntu-first office suite** — AppImage & `.deb` for x86_64, ready for 22.04+
- **Offline & private** — documents stay local; no account required
- **Familiar ribbon UI** — Word / Excel / PowerPoint / PDF workflows
- **Multi-language UI** — Setup Wizard picks first-run language (default Vietnamese); apps fall back to English
- **Open formats** — `.docx`, `.xlsx`, `.pptx`, `.pdf`, plus ODF / CSV where supported
- **Open source** — MIT OR Apache-2.0 · [manguonmo.com](https://manguonmo.com)

## Requirements

- Ubuntu **22.04+** (or Linux with glibc ≥ 2.35), **x86_64**
- GPU with Vulkan or OpenGL
- Do **not** run AppImages with `sudo`

## License & contact

MIT OR Apache-2.0 — see [LICENSE-MIT](LICENSE-MIT) and [LICENSE-APACHE](LICENSE-APACHE).  
Copyright © 2026 **Ubu Office** · [manguonmo.com](https://manguonmo.com) · offices@manguonmo.com  

Issues: [github.com/manguonmocom/ubuntu-office/issues](https://github.com/manguonmocom/ubuntu-office/issues)
