#!/usr/bin/env bash

set -euo pipefail

# ---------------------------------------------------------------------------
# init-new-project.sh
# Copies the claude-code-blueprint config into a target project directory.
# All files land inside <project>/.claude/ so they are project-scoped only.
# ---------------------------------------------------------------------------

BLUEPRINT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 0. Prompt for the target project directory ────────────────────────────
if [[ $# -ge 1 ]]; then
    INPUT_DIR="$1"
else
    read -rp "Enter the path to the new project (relative or absolute): " INPUT_DIR
fi

if [[ -z "$INPUT_DIR" ]]; then
    echo "Error: no directory specified." >&2
    exit 1
fi

# Resolve to absolute path
if [[ "$INPUT_DIR" = /* ]]; then
    PROJECT_DIR="$INPUT_DIR"
else
    PROJECT_DIR="$(cd "$(pwd)" && cd "$INPUT_DIR" 2>/dev/null && pwd)" || {
        # Directory doesn't exist yet — resolve parent then append
        PARENT="$(cd "$(dirname "$INPUT_DIR")" && pwd)"
        PROJECT_DIR="$PARENT/$(basename "$INPUT_DIR")"
    }
fi

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: directory does not exist: $PROJECT_DIR" >&2
    exit 1
fi

CLAUDE_DIR="$PROJECT_DIR/.claude"
echo "Target project : $PROJECT_DIR"
echo "Config location: $CLAUDE_DIR"
echo

# ── 1. Install jq if not present ──────────────────────────────────────────
if ! command -v jq &>/dev/null; then
    echo "Installing jq …"
    if command -v brew &>/dev/null; then
        brew install jq
    elif command -v apt-get &>/dev/null; then
        sudo apt-get update -qq && sudo apt-get install -y -qq jq
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y jq
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm jq
    else
        echo "Error: cannot auto-install jq. Install it manually and re-run." >&2
        exit 1
    fi
fi
echo "jq: $(command -v jq)"

# ── 2. Create directory structure ─────────────────────────────────────────
mkdir -p "$CLAUDE_DIR"/{rules,skills,agents,hooks/scripts,commands,memory}

# ── 3. Copy blueprint files ──────────────────────────────────────────────
cp "$BLUEPRINT_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

cp -r "$BLUEPRINT_DIR/rules/"*    "$CLAUDE_DIR/rules/"
cp -r "$BLUEPRINT_DIR/skills/"*   "$CLAUDE_DIR/skills/"
cp -r "$BLUEPRINT_DIR/agents/"*   "$CLAUDE_DIR/agents/"
cp -r "$BLUEPRINT_DIR/hooks/"*    "$CLAUDE_DIR/hooks/"
cp -r "$BLUEPRINT_DIR/commands/"* "$CLAUDE_DIR/commands/"

# Ensure .gitkeep exists in memory dir
touch "$CLAUDE_DIR/memory/.gitkeep"

# Make hook scripts executable
chmod +x "$CLAUDE_DIR/hooks/scripts/"*.sh 2>/dev/null || true

echo "Copied: CLAUDE.md, rules, skills, agents, hooks, commands, memory"

# ── 4. Generate project-level settings.json ───────────────────────────────
#    Hook paths point to the project-local .claude/hooks/scripts/ directory.
#    MCP servers (context7, fetch, git) are configured here.
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

if [[ -f "$SETTINGS_FILE" ]]; then
    echo "settings.json already exists — skipping (review manually)."
else
    # Read the template and rewrite hook paths from ~/.claude/ to .claude/
    # (project-relative paths used by Claude Code when found inside a project)
    sed 's|~/.claude/hooks/scripts/|.claude/hooks/scripts/|g' \
        "$BLUEPRINT_DIR/settings.template.json" > "$SETTINGS_FILE"

    # Inject mcpServers block into the settings file
    # We add it as the first key after the opening brace
    jq '. + {
        "mcpServers": {
            "context7": {
                "command": "npx",
                "args": ["-y", "@upstash/context7-mcp@latest"]
            },
            "fetch": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-fetch"]
            },
            "git": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-git", "--repository", "."]
            }
        }
    }' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

    echo "Created: settings.json (with MCP servers: context7, fetch, git)"
fi

# ── 5. Summary ────────────────────────────────────────────────────────────
echo
echo "Done. Project-level Claude Code config installed at:"
echo "  $CLAUDE_DIR"
echo
echo "Next steps:"
echo "  1. Review $CLAUDE_DIR/settings.json — adapt permissions to your needs"
echo "  2. Edit $CLAUDE_DIR/CLAUDE.md — customize for your project"
echo "  3. Install optional formatters: prettier (JS/TS), ruff (Python)"
