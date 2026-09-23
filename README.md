# 🚀 macOS Hyprland-Style Terminal Rice

An automated, aesthetic terminal rice for macOS powered by **Ghostty**, **Starship**, **Fastfetch**, and modern CLI tools. 

Takes any fresh Mac **from 0 to a fully customized Arch/Hyprland-inspired terminal** in one command.

---

## ✨ Features

* **Top Dropdown Terminal**: Press **`Control + T`** anywhere to smoothly drop down Ghostty from the top of your screen.
* **Frosted Glass Blur**: Translucent blurred acrylic background (`0.85` opacity) in the Catppuccin Mocha theme.
* **Side-by-Side Launch Specs**: System details on the left (`fastfetch`) and a random Pokémon sprite on the right (`pokemon-colorscripts`).
* **Minimal Curved Prompt**: Clean two-line Starship prompt (`╭─  ... ╰─❯`) showing directory, Git status, and language runtimes.
* **Shell Intelligence**: Fish-style autosuggestions (`→` to accept), syntax highlighting (green/red), and interactive fuzzy tab navigation (`fzf-tab`).
* **Modern CLI Replacements**: `eza` (for `ls`), `bat` (for `cat`), `zoxide` (for `cd`), and `fzf` history search (`Ctrl + R`).

---

## 📋 Prerequisites

Before running the installer:

1. **macOS** (Compatible with Apple Silicon M1/M2/M3/M4/M5 and Intel x86_64).
2. **[Ghostty](https://ghostty.org)**:
   * Download and install the Ghostty terminal app: [https://ghostty.org](https://ghostty.org) (the installer will also attempt to install it via Homebrew).
3. **Accessibility Permission (for the `Control + T` shortcut)**:
   * Open **System Settings → Privacy & Security → Accessibility**.
   * Toggle **Ghostty** to **ON** (required by macOS so Ghostty can listen for the global `Control + T` shortcut outside its window).

---

## ⚡ 1-Step Installation

Clone this repository and run the installer:

```bash
git clone https://github.com/your-username/mac-terminal-rice.git
cd mac-terminal-rice
./install.sh
```

> [!IMPORTANT]
> **Admin Password Required:**
> During step 7, the installer will display a clear banner asking for your Mac's administrator (`sudo`) password. This is required to create `/usr/local/bin` and install `pokemon-colorscripts`.

---

## 📂 Repository Structure

```text
mac-terminal-rice/
├── install.sh                  # Crash-proof automated installer with step tracking
├── README.md                   # Setup guide and troubleshooting manual
├── bin/
│   └── poke-fetch              # Python side-by-side specs + pokemon merger
└── config/
    ├── ghostty/
    │   └── config              # Ghostty theme, blur, padding, font 15, and hotkey
    ├── starship.toml           # Starship curved minimal prompt
    └── fastfetch/
        └── config.jsonc        # Fastfetch Catppuccin color scheme & modules
```

---

## ⌨️ Cheatsheet & Keybindings

| Key / Command | What it does |
| :--- | :--- |
| **`Control + T`** | Toggle Ghostty drop-down terminal from anywhere on Mac |
| **`→` (Right Arrow)** | Accept autosuggestion while typing in terminal |
| **`Tab`** | Interactive fuzzy file/folder selection popup with arrow keys |
| **`Ctrl + R`** | Interactive fuzzy search through command history (`fzf`) |
| **`z <folder>`** | Smart teleport to any folder (e.g., `z poke`) |
| **`ls`** | Modern directory listing with file/folder icons (`eza`) |
| **`ll`** | Detailed list with file sizes, permissions, and Git changes |
| **`cat <file>`** | View files with syntax highlighting and line numbers (`bat`) |

---

## 🛠️ Troubleshooting & FAQ

### 1. `Control + T` does not open the terminal
* **Cause**: macOS blocks third-party applications from listening to global hotkeys unless granted Accessibility permissions.
* **Fix**:
  1. Open **System Settings → Privacy & Security → Accessibility**.
  2. Toggle **Ghostty** to **ON**.
  3. **Completely restart Ghostty** (`Cmd + Q` then reopen) so the macOS event tap takes effect.
* **Secure Input note**: If your cursor is active inside a password field or an encrypted messaging app (like WhatsApp Desktop), macOS temporarily disables all global event taps for security. Move your focus to the desktop or another app and try again.

---

### 2. Icons look like broken boxes (`□` or `?`)
* **Cause**: The terminal is using a standard font instead of a Nerd Font.
* **Fix**:
  * In **Ghostty**: Ensure `font-family = "JetBrainsMono Nerd Font"` is set in `~/.config/ghostty/config`.
  * In **Apple Terminal**: Press `Cmd + ,` → **Profiles** → **Text** → click **Change...** under Font → choose **JetBrainsMono Nerd Font**.

---

### 3. `command not found: starship` or `eza`
* **Cause**: Homebrew's binary directory is not in your current shell's `$PATH`.
* **Fix**:
  Run this command depending on your Mac architecture:
  * **Apple Silicon (M1/M2/M3/M4/M5)**:
    ```bash
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    ```
  * **Intel Mac**:
    ```bash
    eval "$(/usr/local/bin/brew shellenv)"
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
    ```

---

### 4. Sudo prompt during installation
* **Why it's needed**: `pokemon-colorscripts` installs into `/usr/local/opt` and symlinks to `/usr/local/bin`. On fresh macOS systems, these directories must be created with `sudo`.
* **If you don't have admin/sudo access**: The installer will gracefully skip `pokemon-colorscripts` without failing the rest of the setup.

---

### 5. Fastfetch or Pokémon art is wrapped / distorted
* `poke-fetch` automatically detects your terminal window width. If your terminal window is narrower than ~85 columns (e.g. split in half on a small laptop screen), it automatically stacks the system details above the Pokémon to avoid text clipping. Simply widen the window to see them side-by-side.

---

### 6. How do I make Ghostty open as a normal window instead of in the background?
* In `~/.config/ghostty/config`, change:
  ```ini
  initial-window = true
  ```
  And restart Ghostty.
