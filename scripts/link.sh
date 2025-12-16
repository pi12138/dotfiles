#!/bin/bash
# ==============================
# Create symbolic links
# ==============================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

DOTFILES_DIR="$(get_dotfiles_dir)"

# Create a symbolic link
create_link() {
    local source="$1"
    local target="$2"

    # Check if source exists
    if [ ! -e "$source" ]; then
        error "Source does not exist: $source"
        return 1
    fi

    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            local current_source=$(readlink "$target")
            if [ "$current_source" = "$source" ]; then
                info "Link already exists: $target -> $source"
                return 0
            else
                warning "Link exists but points to different location: $target -> $current_source"
                if confirm "Remove and relink?"; then
                    rm "$target"
                else
                    return 1
                fi
            fi
        else
            error "Target exists but is not a symbolic link: $target"
            warning "Please backup and remove it manually, or use backup script"
            return 1
        fi
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create the symbolic link
    ln -sf "$source" "$target"
    success "Created link: $target -> $source"
}

# Link configuration files
link_all() {
    info "Creating symbolic links..."

    # Zsh configuration
    create_link "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

    # Alacritty
    create_link "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty"

    # Helix
    create_link "$DOTFILES_DIR/helix" "$HOME/.config/helix"

    # Neovim
    create_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

    # Zellij
    create_link "$DOTFILES_DIR/zellij" "$HOME/.config/zellij"

    # Tmux
    if [ -f "$DOTFILES_DIR/.tmux.conf" ]; then
        create_link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
    fi

    # Vim
    if [ -f "$DOTFILES_DIR/.vimrc" ]; then
        create_link "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
    fi

    success "All links created successfully!"
}

# If script is run directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    link_all
fi
