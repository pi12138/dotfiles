#!/bin/bash
# ==============================
# Backup existing configurations
# ==============================

set -e

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Backup a file or directory
backup_item() {
    local target="$1"

    if [ -e "$target" ] || [ -L "$target" ]; then
        info "Backing up $target"

        # Create backup directory if it doesn't exist
        mkdir -p "$BACKUP_DIR"

        # Get the directory structure for the backup
        local backup_path="$BACKUP_DIR${target}"
        mkdir -p "$(dirname "$backup_path")"

        # Copy the file/directory to backup location
        cp -r "$target" "$backup_path"

        success "Backed up to $backup_path"
        return 0
    else
        info "Skipping $target (does not exist)"
        return 1
    fi
}

# Main backup function
backup_all() {
    info "Starting backup process..."
    info "Backup directory: $BACKUP_DIR"

    # Add items to backup here
    # Example:
    # backup_item "$HOME/.zshrc"
    # backup_item "$HOME/.config/nvim"

    if [ -d "$BACKUP_DIR" ]; then
        success "Backup completed: $BACKUP_DIR"
    else
        warning "No files were backed up"
    fi
}

# If script is run directly (not sourced)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    backup_all
fi
