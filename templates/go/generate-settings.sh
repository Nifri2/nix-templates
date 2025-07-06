#!/usr/bin/env bash
set -euo pipefail

# Resolve gopls path from nixpkgs
GOPLS_PATH=$(nix build --no-link --print-out-paths .#gopls)

# Write to .vscode/settings.json
mkdir -p .vscode
cat > .vscode/settings.json <<EOF
{
    "go.alternateTools": {
        "gopls": "$GOPLS_PATH/bin/gopls"
    }
}
EOF

echo "✅ VSCode settings created with gopls: $GOPLS_PATH"