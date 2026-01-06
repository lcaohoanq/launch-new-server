#!/bin/bash
set -euo pipefail

# Version
RP_VERSION='15.1.0'
ATUIN_VERSION='18.10.0'
ZOXIDE_VERSION='0.9.8'
FZF_VERSION='0.67.0'

# Màu mè tí cho chuyên nghiệp
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[*] Bắt đầu thiết lập Server Survival Kit...${NC}"

# Detect current shell and RC file
detect_shell() {
  local shell_name=$(basename "$SHELL")
  local rc_file=""
  local binding_file=""

  case "$shell_name" in
  zsh)
    rc_file="$HOME/.zshrc"
    binding_file=".fzf-key-bindings.zsh"
    ;;
  bash)
    rc_file="$HOME/.bashrc"
    binding_file=".fzf-key-bindings.bash"
    ;;
  fish)
    rc_file="$HOME/.config/fish/config.fish"
    binding_file=".fzf-key-bindings.fish"
    ;;
  *)
    echo -e "${YELLOW}[!] Shell không được hỗ trợ: $shell_name${NC}"
    echo -e "${YELLOW}[!] Chỉ hỗ trợ: bash, zsh, fish${NC}"
    return 1
    ;;
  esac

  echo "$shell_name|$rc_file|$binding_file"
}

# Parse shell info
SHELL_INFO=$(detect_shell)
if [ $? -ne 0 ]; then
  echo -e "${YELLOW}[!] Tiếp tục cài đặt nhưng bỏ qua phần cấu hình shell...${NC}"
  SHELL_DETECTED=false
else
  SHELL_DETECTED=true
  SHELL_NAME=$(echo "$SHELL_INFO" | cut -d'|' -f1)
  RC_FILE=$(echo "$SHELL_INFO" | cut -d'|' -f2)
  BINDING_FILE=$(echo "$SHELL_INFO" | cut -d'|' -f3)
  echo -e "${GREEN}[*] Phát hiện shell: $SHELL_NAME${NC}"
  echo -e "${GREEN}[*] RC file: $RC_FILE${NC}"
fi

# 1. Hàm backup và copy file
install_dotfile() {
  local file=$1
  if [ -f ~/$file ]; then
    echo "    - Backup $file cũ sang $file.bak"
    mv ~/$file ~/$file.bak
  fi
  echo "    - Copy $file mới"
  cp $file ~/$file
}

# 2. Cài đặt Configs (Tmux, Vim)
install_dotfile ".tmux.conf"
install_dotfile ".vimrc"

# 3. Reload tmux nếu đang chạy
if pgrep tmux >/dev/null; then
  tmux source-file ~/.tmux.conf
  echo -e "${GREEN}[*] Đã reload cấu hình Tmux${NC}"
fi

# 4. Tải và cài đặt Tools (Ripgrep, FZF) - Binary tĩnh
ARCH=$(uname -m)
OS=$(uname -s)

if [[ "$OS" == "Linux" && "$ARCH" == "x86_64" ]]; then
  echo -e "${GREEN}[*] Đang tải các tools portable (Ripgrep, FZF)...${NC}"

  # --- Ripgrep ---
  if ! command -v rg &>/dev/null; then
    echo "    -> Installing Ripgrep..."
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/${RP_VERSION}/ripgrep-${RP_VERSION}-x86_64-unknown-linux-musl.tar.gz
    tar -xzf ripgrep-${RP_VERSION}-x86_64-unknown-linux-musl.tar.gz
    sudo mv ripgrep-${RP_VERSION}-x86_64-unknown-linux-musl/rg /usr/local/bin/
    rm -rf ripgrep-${RP_VERSION}*
  else
    echo "    -> Ripgrep đã cài đặt."
  fi

  # --- Zoxide ---
  if ! command -v zoxide &>/dev/null; then
    echo "    -> Installing Zoxide..."
    curl -LO https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}/zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz
    tar -xzf zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz
    sudo mv zoxide /usr/local/bin/
    rm -f zoxide-${ZOXIDE_VERSION}-x86_64-unknown-linux-musl.tar.gz

    # Cấu hình Zoxide cho shell hiện tại
    if [ "$SHELL_DETECTED" = true ] && [ -f "$RC_FILE" ]; then
      if ! grep -q "zoxide init" "$RC_FILE"; then
        echo "    -> Cấu hình Zoxide cho $SHELL_NAME"
        cat <<EOT >>"$RC_FILE"
# --- Zoxide (Enhanced cd) ---
eval "\$(zoxide init $SHELL_NAME)"
# -----------------------------
EOT
      else
        echo "    -> $RC_FILE đã có cấu hình Zoxide. Bỏ qua."
      fi
    fi
  else
    echo "    -> Zoxide đã cài đặt."
  fi

  # --- Atuin (Terminal History) ---
  if ! command -v atuin &>/dev/null; then
    echo "    -> Installing Atuin..."
    curl -LO https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VERSION}/atuin-x86_64-unknown-linux-gnu.tar.gz
    tar -xzf atuin-x86_64-unknown-linux-gnu.tar.gz
    sudo mv atuin-x86_64-unknown-linux-gnu/atuin /usr/local/bin/
    rm -rf atuin-x86_64-unknown-linux-gnu*

    # Cấu hình Atuin cho shell hiện tại
    if [ "$SHELL_DETECTED" = true ] && [ -f "$RC_FILE" ]; then
      if ! grep -q "atuin init" "$RC_FILE"; then
        echo "    -> Cấu hình Atuin cho $SHELL_NAME"
        cat <<EOT >>"$RC_FILE"
# --- Atuin Terminal History ---
eval "\$(atuin init $SHELL_NAME)"
# -----------------------------
EOT
      else
        echo "    -> $RC_FILE đã có cấu hình Atuin. Bỏ qua."
      fi
    fi
  else
    echo "    -> Atuin đã cài đặt."
  fi

  # --- FZF Binary ---
  if ! command -v fzf &>/dev/null; then
    echo "    -> Installing FZF Binary..."
    curl -LO https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz
    tar -xzf fzf-${FZF_VERSION}-linux_amd64.tar.gz
    sudo mv fzf /usr/local/bin/
    rm -f fzf-${FZF_VERSION}-linux_amd64.tar.gz
  else
    echo "    -> FZF Binary đã cài đặt."
  fi

  # --- FZF Integration (Key Bindings & Ripgrep Config) ---
  if [ "$SHELL_DETECTED" = true ]; then
    echo -e "${GREEN}[*] Đang cấu hình FZF Integration cho $SHELL_NAME...${NC}"

    # Tải script key-bindings tương ứng với shell
    if [ "$SHELL_NAME" = "zsh" ]; then
      curl -sL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh -o ~/$BINDING_FILE
    elif [ "$SHELL_NAME" = "bash" ]; then
      curl -sL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.bash -o ~/$BINDING_FILE
    elif [ "$SHELL_NAME" = "fish" ]; then
      mkdir -p ~/.config/fish
      curl -sL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.fish -o ~/$BINDING_FILE
    fi

    # Thêm config vào RC file
    if [ -f "$RC_FILE" ]; then
      if ! grep -q "FZF_DEFAULT_COMMAND" "$RC_FILE"; then
        echo "    -> Thêm cấu hình FZF vào $RC_FILE"

        if [ "$SHELL_NAME" = "fish" ]; then
          # Fish shell syntax khác
          cat <<EOT >>"$RC_FILE"

# --- FZF & RIPGREP CONFIG ---
set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow --glob "!.git/*"'
set -x FZF_CTRL_T_COMMAND "\$FZF_DEFAULT_COMMAND"
[ -f ~/$BINDING_FILE ]; and source ~/$BINDING_FILE
# ----------------------------
EOT
        else
          # Bash/Zsh syntax
          cat <<EOT >>"$RC_FILE"

# --- FZF & RIPGREP CONFIG ---
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="\$FZF_DEFAULT_COMMAND"
[ -f ~/$BINDING_FILE ] && source ~/$BINDING_FILE
# ----------------------------
EOT
        fi
      else
        echo "    -> $RC_FILE đã có cấu hình FZF. Bỏ qua."
      fi
    fi
  fi

else
  echo -e "${YELLOW}(!) Kiến trúc máy không phải x86_64 hoặc không phải Linux. Bỏ qua bước tải Binary.${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            SETUP HOÀN TẤT!                             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"

if [ "$SHELL_DETECTED" = true ]; then
  echo -e "${GREEN}Để áp dụng các thay đổi, chạy lệnh:${NC}"
  echo -e "${YELLOW}  source $RC_FILE${NC}"
  echo ""
  echo -e "${GREEN}Hoặc mở terminal mới và thử các phím tắt:${NC}"
  echo "  • Ctrl+T  : Tìm file nhanh với FZF"
  echo "  • Ctrl+R  : Tìm lịch sử lệnh"
  echo "  • z <dir> : Nhảy nhanh đến thư mục với Zoxide"
else
  echo -e "${YELLOW}Lưu ý: Không thể tự động cấu hình shell.${NC}"
  echo -e "${YELLOW}Vui lòng tự thêm config vào shell RC file của bạn.${NC}"
fi
