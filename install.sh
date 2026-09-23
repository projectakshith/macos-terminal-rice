#!/usr/bin/env bash
# ==============================================================================
#  macOS Terminal Rice - Automated Zero-to-Hero Installer
#  Cross-device compatible (Apple Silicon & Intel Macs)
# ==============================================================================
set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

CURRENT_STEP="Initialization"

# Error Trap with Helpful Troubleshooting Info
catch_error() {
  local exit_code=$1
  local line_no=$2
  echo -e "\n${RED}──────────────────────────────────────────────────────────${NC}"
  echo -e "${RED}❌ Error occurred during: ${YELLOW}${CURRENT_STEP}${NC}"
  echo -e "${RED}   Failed on line ${line_no} with exit code ${exit_code}.${NC}"
  echo -e "${RED}──────────────────────────────────────────────────────────${NC}"
  echo -e "${BLUE}💡 Troubleshooting Tips:${NC}"
  echo -e "   1. If Homebrew or a package failed to download, check your internet connection."
  echo -e "   2. If a permission error occurred, ensure you have admin rights on this Mac."
  echo -e "   3. Refer to the Troubleshooting section in README.md for manual step-by-step fixes."
  echo -e "   4. You can safely re-run this script after resolving the issue.\n"
  exit "$exit_code"
}
trap 'catch_error $? $LINENO' ERR

echo -e "${PURPLE}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}│    🚀 macOS Hyprland-Style Terminal Rice Installer     │${NC}"
echo -e "${PURPLE}└────────────────────────────────────────────────────────┘${NC}\n"

# 0. Check OS
CURRENT_STEP="Checking operating system"
if [[ "$(uname)" != "Darwin" ]]; then
  echo -e "${RED}❌ This script is designed for macOS only.${NC}"
  exit 1
fi

# 1. Check & Install Homebrew
CURRENT_STEP="Installing Homebrew"
if ! command -v brew &>/dev/null; then
  echo -e "${CYAN}📦 Installing Homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    echo -e "${RED}❌ Homebrew installation failed. Please check your internet connection and try again.${NC}"
    exit 1
  }
  
  # Configure Homebrew PATH for both Apple Silicon (arm64) and Intel (x86_64)
  if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo -e "${GREEN}✔ Homebrew is installed.${NC}"
fi

# Ensure Homebrew shellenv is active in this session
if command -v brew &>/dev/null; then
  eval "$(brew shellenv)"
fi

# Ensure Homebrew is persistently in PATH on new shells
if [ -f "/opt/homebrew/bin/brew" ]; then
  if ! grep -qs '/opt/homebrew/bin/brew shellenv' "$HOME/.zprofile" "$HOME/.zshrc"; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
elif [ -f "/usr/local/bin/brew" ]; then
  if ! grep -qs '/usr/local/bin/brew shellenv' "$HOME/.zprofile" "$HOME/.zshrc"; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
  fi
fi

# 2. Check Ghostty
CURRENT_STEP="Checking Ghostty application"
if [ ! -d "/Applications/Ghostty.app" ]; then
  echo -e "${YELLOW}👻 Ghostty terminal app not found in /Applications.${NC}"
  echo -e "${CYAN}Attempting to install Ghostty via Homebrew...${NC}"
  brew install --cask ghostty 2>/dev/null || {
    echo -e "${YELLOW}ℹ️ Homebrew cask not available or failed. Please download Ghostty manually from: https://ghostty.org${NC}"
  }
else
  echo -e "${GREEN}✔ Ghostty is already installed.${NC}"
fi

# 3. Install JetBrainsMono Nerd Font & Core CLI Tools
CURRENT_STEP="Installing Nerd Font and CLI utilities"
echo -e "${CYAN}📦 Installing Nerd Font and modern CLI utilities...${NC}"
if ! brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
  echo -e "${BLUE}  -> Installing font-jetbrains-mono-nerd-font...${NC}"
  brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null || {
    echo -e "${YELLOW}⚠️ Failed to install font automatically. You can install it later via: brew install --cask font-jetbrains-mono-nerd-font${NC}"
  }
else
  echo -e "${GREEN}✔ font-jetbrains-mono-nerd-font already installed.${NC}"
fi

for pkg in starship fzf eza bat zoxide fastfetch; do
  if ! brew list "$pkg" &>/dev/null; then
    echo -e "${BLUE}  -> Installing $pkg...${NC}"
    brew install "$pkg"
  else
    echo -e "${GREEN}✔ $pkg already installed.${NC}"
  fi
done

# 4. Silence macOS "Last login" banner
CURRENT_STEP="Configuring hushlogin"
echo -e "${CYAN}🔕 Silencing macOS 'Last login' banner...${NC}"
touch "$HOME/.hushlogin"

# 5. Install Oh My Zsh (if missing)
CURRENT_STEP="Installing Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${CYAN}🐚 Installing Oh My Zsh...${NC}"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
    echo -e "${YELLOW}⚠️ Oh My Zsh install encountered a non-fatal warning. Continuing...${NC}"
  }
else
  echo -e "${GREEN}✔ Oh My Zsh already installed.${NC}"
fi

# 6. Install Zsh Plugins
CURRENT_STEP="Installing Zsh plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

echo -e "${CYAN}🔌 Setting up Zsh plugins...${NC}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || {
    echo -e "${YELLOW}⚠️ Failed to clone zsh-autosuggestions. Check connection.${NC}"
  }
else
  echo -e "${GREEN}✔ zsh-autosuggestions already installed.${NC}"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || {
    echo -e "${YELLOW}⚠️ Failed to clone zsh-syntax-highlighting. Check connection.${NC}"
  }
else
  echo -e "${GREEN}✔ zsh-syntax-highlighting already installed.${NC}"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab" || {
    echo -e "${YELLOW}⚠️ Failed to clone fzf-tab. Check connection.${NC}"
  }
else
  echo -e "${GREEN}✔ fzf-tab already installed.${NC}"
fi

# 7. Install pokemon-colorscripts
CURRENT_STEP="Installing pokemon-colorscripts"
if ! command -v pokemon-colorscripts &>/dev/null; then
  echo -e "\n${YELLOW}┌──────────────────────────────────────────────────────────────────┐${NC}"
  echo -e "${YELLOW}│ 🔑 Administrator (sudo) Password Required:                       │${NC}"
  echo -e "${YELLOW}│    Installing pokemon-colorscripts requires creating             │${NC}"
  echo -e "${YELLOW}│    symlinks and directories in /usr/local/bin & /usr/local/opt.  │${NC}"
  echo -e "${YELLOW}└──────────────────────────────────────────────────────────────────┘${NC}\n"
  
  echo -e "${CYAN}Please enter your Mac administrator password when prompted:${NC}"
  if ! sudo -v; then
    echo -e "${RED}❌ Sudo authentication failed. Administrator privileges are required to install pokemon-colorscripts.${NC}"
    exit 1
  fi

  # Keep sudo timestamp updated until this step completes
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!

  echo -e "${BLUE}  -> Creating /usr/local directories and installing pokemon-colorscripts...${NC}"
  sudo mkdir -p /usr/local/bin /usr/local/opt
  TEMP_POKE=$(mktemp -d)
  git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git "$TEMP_POKE/pokemon-colorscripts"
  (cd "$TEMP_POKE/pokemon-colorscripts" && sudo ./install.sh)
  rm -rf "$TEMP_POKE"

  kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  echo -e "${GREEN}✔ pokemon-colorscripts installed successfully.${NC}"
else
  echo -e "${GREEN}✔ pokemon-colorscripts already installed.${NC}"
fi

# 8. Deploy Configs
CURRENT_STEP="Deploying configurations"
echo -e "${CYAN}📁 Deploying configurations...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.config/ghostty"
mkdir -p "$HOME/.config/fastfetch"
mkdir -p "$HOME/.local/bin"

if [ -f "$SCRIPT_DIR/config/ghostty/config" ]; then
  cp "$SCRIPT_DIR/config/ghostty/config" "$HOME/.config/ghostty/config"
  cp "$SCRIPT_DIR/config/starship.toml" "$HOME/.config/starship.toml"
  cp "$SCRIPT_DIR/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  cp "$SCRIPT_DIR/bin/poke-fetch" "$HOME/.local/bin/poke-fetch"
  chmod +x "$HOME/.local/bin/poke-fetch"
else
  echo -e "${RED}❌ Could not locate config templates in $SCRIPT_DIR/config${NC}"
  exit 1
fi

# 9. Configure ~/.zshrc (Idempotent & Safe)
CURRENT_STEP="Configuring ~/.zshrc"
echo -e "${CYAN}⚙️ Configuring ~/.zshrc...${NC}"

# Ensure PATH includes /usr/local/bin and ~/.local/bin
if ! grep -qs 'export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"' "$HOME/.zshrc"; then
  echo 'export PATH="/usr/local/bin:$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

# Disable default Oh My Zsh theme to maximize Starship prompt speed
perl -i -pe 's/^ZSH_THEME=.*/ZSH_THEME=""/' "$HOME/.zshrc" 2>/dev/null || true

# Update plugins list in ~/.zshrc if fzf-tab not present
if ! grep -qs "fzf-tab" "$HOME/.zshrc"; then
  perl -i -0777 -pe 's/plugins=\([^)]*\)/plugins=(\n  git\n  fzf-tab\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n)/s' "$HOME/.zshrc" 2>/dev/null || true
fi

# Append custom startup hooks and aliases (only once)
if ! grep -qs "poke-fetch" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# Display system info + random pokemon side-by-side on launch
poke-fetch

# Initialize Starship prompt
eval "$(starship init zsh)"

# Initialize zoxide (smart cd)
eval "$(zoxide init zsh)"

# Initialize fzf keybindings & fuzzy completion
source <(fzf --zsh)

# fzf-tab interactive styling with eza previews
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath'

# Modern CLI Replacements & Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --icons --group-directories-first --git"
alias la="eza -lah --icons --group-directories-first --git"
alias lt="eza --tree --level=2 --icons"
alias cat="bat --paging=never"
EOF
fi

CURRENT_STEP="Finished"
echo -e "\n${GREEN}══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 All done! Your macOS terminal rice is ready.${NC}"
echo -e "${GREEN}══════════════════════════════════════════════════════════${NC}\n"
echo -e "${BLUE}Next Steps:${NC}"
echo -e "1. ${PURPLE}Grant Accessibility Permission${NC}: Open System Settings → Privacy & Security → Accessibility, and toggle Ghostty to ON."
echo -e "2. ${PURPLE}Restart Ghostty${NC} or run ${CYAN}source ~/.zshrc${NC}."
echo -e "3. Press ${CYAN}Control + T${NC} to drop down your new terminal from anywhere!\n"
