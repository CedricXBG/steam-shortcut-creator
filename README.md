# Steam Shortcut Creator

A lightweight GTK3 / x86_64 Assembly utility to retrieve game metadata from the Steam API and generate standard Linux `.desktop` shortcuts.

---

## Features

- **Steam API Integration:** Fetches accurate game titles directly from Steam servers via `libcurl`.
- **Local Asset Resolution:** Automatically pairs shortcut configurations with local Steam game icons.
- **GTK3 GUI:** Native, lightweight graphical user interface built directly in Assembly.
- **Zero Overhead:** Written in pure NASM x86_64 assembly for instant startup and minimal footprint.

---

## Prerequisites

Ensure you have the required build tools and libraries installed. On **Arch Linux**:

```bash
sudo pacman -S nasm binutils gtk3 curl make
```

---

## Building and installation

Clone the repository and compile using the provided `Makefile`:

```bash
# Clone the repository
git clone git@github.com:CedricXBG/steam-shortcut-creator.git
cd steam-shortcut-creator

# Build the project

# Clean build artifacts
make clean
```

The compiled binary will be available in the `build/` directory.

---

## Usage

1. Run the executable from your terminal or application launcher:
    ```bash
    ./build/steam-shortcut-creator
    ```
2. Enter the **Steam AppID** in the GTK prompt.
3. Click **Generate** to create the corresponding `.desktop` entry.

--- 

## Technical Overview

- **Language:** Assembly x86_64 (NASM)
- **Linker:** GNU `ld` (direct dynamic linking to GTK3 and `libcurl`)
- **GUI Toolkit:** GTK+ 3.0 (C ABI bindings)
- **Networkings:** `libcurl`

---

## License

Distributed under the MIT License. See `LICENSE` for details.
