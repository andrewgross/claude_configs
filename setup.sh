#!/bin/bash

# Claude Configuration Setup Script
#
# Commands, agents, and hooks in this repository now install as Claude Code
# plugins instead of symlinks:
#
#   /plugin marketplace add andrewgross/claude_configs
#   /plugin install dev-workflow@claude-configs
#
# This script handles the two pieces plugins cannot provide:
#   - the global CLAUDE.md guidelines (linked to ~/.claude/CLAUDE.md)
#   - the custom statusline (linked to ~/.claude/statusline-custom.sh and
#     registered in ~/.claude/settings.json)
#
# It also removes symlinks left behind by the old pre-plugin layout.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the absolute path of this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Claude configurations from: $SCRIPT_DIR"

# Ensure ~/.claude exists
mkdir -p ~/.claude

# Function to remove a symlink if it points into this repository
remove_stale_link() {
    local target="$1"

    if [[ -L "$target" ]]; then
        local dest=$(readlink "$target")
        if [[ "$dest" == "$SCRIPT_DIR"* ]]; then
            rm "$target"
            echo -e "${YELLOW}Removed old link: $target -> $dest${NC}"
        fi
    fi
}

# Clean up links from the old pre-plugin layout. Commands and agents are now
# provided by the dev-workflow plugin, so links into the old commands/ and
# agents/ directories are stale.
echo ""
echo "Cleaning up links from the old layout..."

# Whole-directory links (from the old "link entire directories" setup)
remove_stale_link ~/.claude/commands
remove_stale_link ~/.claude/agents

# Per-file links (from the old setup.sh)
for dir in ~/.claude/commands ~/.claude/agents; do
    if [[ -d "$dir" && ! -L "$dir" ]]; then
        for f in "$dir"/*; do
            remove_stale_link "$f"
        done
    fi
done

# Function to safely create symbolic link
create_link() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [[ ! -f "$source" ]]; then
        echo -e "${RED}Warning: Source file not found: $source${NC}"
        return 1
    fi

    # Check if target is already a symlink pointing to our source
    if [[ -L "$target" ]]; then
        local current_target=$(readlink "$target")
        if [[ "$current_target" == "$source" ]]; then
            echo -e "${GREEN}✓ $description already linked correctly${NC}"
            return 0
        fi
        rm "$target"
        echo -e "${YELLOW}Removed existing link: $target${NC}"
    elif [[ -f "$target" ]]; then
        echo -e "${YELLOW}Warning: Regular file exists at $target, removing...${NC}"
        rm "$target"
    fi

    # Create the symbolic link
    ln -sf "$source" "$target"
    echo -e "${GREEN}✓ Linked $description${NC}"

    return 0
}

# Link configuration files
echo ""
echo "Linking configuration files..."

create_link "$SCRIPT_DIR/configs/CLAUDE.md" ~/.claude/CLAUDE.md "CLAUDE.md"
create_link "$SCRIPT_DIR/statusline/statusline-custom.sh" ~/.claude/statusline-custom.sh "statusline script"

echo ""
echo "Verifying installation..."

# Verify all links are working
verification_failed=0
for file in ~/.claude/CLAUDE.md ~/.claude/statusline-custom.sh; do
    if [[ -L "$file" && -f "$file" ]]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file${NC}"
        verification_failed=1
    fi
done

# Function to update settings.json with statusline configuration
update_settings_json() {
    local settings_file="$HOME/.claude/settings.json"
    local statusline_path="$HOME/.claude/statusline-custom.sh"

    # Check if the statusline script is properly linked
    if [[ ! -L "$statusline_path" || ! -f "$statusline_path" ]]; then
        echo -e "${YELLOW}Statusline script not properly linked, skipping settings.json update${NC}"
        return 0
    fi

    # Create settings.json if it doesn't exist
    if [[ ! -f "$settings_file" ]]; then
        echo '{}' > "$settings_file"
        echo -e "${GREEN}Created $settings_file${NC}"
    fi

    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${YELLOW}jq not found, skipping automatic settings.json configuration${NC}"
        echo "Manually add this to $settings_file:"
        echo '{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-custom.sh",
    "padding": 0
  }
}'
        return 0
    fi

    # Check if statusLine already exists in settings.json
    if jq -e '.statusLine' "$settings_file" >/dev/null 2>&1; then
        echo -e "${YELLOW}statusLine already configured in $settings_file, skipping${NC}"
        return 0
    fi

    # Update settings.json with statusline configuration
    local temp_file=$(mktemp)
    jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline-custom.sh", "padding": 0}}' "$settings_file" > "$temp_file" && mv "$temp_file" "$settings_file"

    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✓ Updated $settings_file with statusline configuration${NC}"
    else
        echo -e "${RED}Failed to update $settings_file${NC}"
        rm -f "$temp_file"
        return 1
    fi
}

if [[ $verification_failed -eq 0 ]]; then
    echo ""
    echo "Configuring Claude settings..."
    update_settings_json

    echo ""
    echo -e "${GREEN}Setup completed successfully.${NC}"
    echo ""
    echo "Statusline and global CLAUDE.md are linked."
    echo "For commands, agents, and hooks, install the plugins:"
    echo "  /plugin marketplace add andrewgross/claude_configs"
    echo "  /plugin install dev-workflow@claude-configs"
else
    echo ""
    echo -e "${RED}Setup completed with some issues. Please check the failed links above.${NC}"
    exit 1
fi
