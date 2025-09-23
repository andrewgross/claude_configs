#!/bin/bash

# Claude Configuration Setup Script
# Safely links configuration files from this repository to ~/.claude/

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the absolute path of this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Claude configurations from: $SCRIPT_DIR"

# Ensure ~/.claude directories exist
echo "Creating Claude configuration directories..."
mkdir -p ~/.claude/{agents,commands,configs}

# Function to safely create symbolic link
create_link() {
    local source="$1"
    local target="$2"
    local description="$3"

    if [[ ! -f "$source" ]]; then
        echo -e "${RED}Warning: Source file not found: $source${NC}"
        return 1
    fi

    # Remove existing link or file if it exists
    if [[ -L "$target" ]]; then
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
create_link "$SCRIPT_DIR/commands/commit.md" ~/.claude/commands/commit.md "commit command"
create_link "$SCRIPT_DIR/commands/fix-docs.md" ~/.claude/commands/fix-docs.md "fix-docs command"
create_link "$SCRIPT_DIR/commands/fix-tests.md" ~/.claude/commands/fix-tests.md "fix-tests command"
create_link "$SCRIPT_DIR/commands/update-changelog.md" ~/.claude/commands/update-changelog.md "update-changelog command"
create_link "$SCRIPT_DIR/agents/changelog-updater.md" ~/.claude/agents/changelog-updater.md "changelog-updater agent"
create_link "$SCRIPT_DIR/agents/repo-interface-analyzer.md" ~/.claude/agents/repo-interface-analyzer.md "repo-interface-analyzer agent"
create_link "$SCRIPT_DIR/statusline/statusline-custom.sh" ~/.claude/statusline-custom.sh "statusline script"

echo ""
echo "Verifying installation..."

# Verify all links are working
verification_failed=0
for file in ~/.claude/CLAUDE.md ~/.claude/commands/*.md ~/.claude/agents/*.md ~/.claude/statusline-custom.sh; do
    if [[ -L "$file" && -f "$file" ]]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo -e "${RED}✗ $file${NC}"
        verification_failed=1
    fi
done

if [[ $verification_failed -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}🎉 Claude configuration setup completed successfully!${NC}"
    echo ""
    echo "Your configurations are now linked and ready to use."
    echo "Claude will automatically discover these configurations in your next session."
else
    echo ""
    echo -e "${RED}❌ Setup completed with some issues. Please check the failed links above.${NC}"
    exit 1
fi