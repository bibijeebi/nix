#!/usr/bin/env bash

# Common utilities for all hooks
HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

log_success() {
    echo -e "${GREEN}SUCCESS:${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/usr/bin/env bash

# 1. Check for Nix syntax errors
echo "Checking Nix syntax..."
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.nix$'); do
    if ! nix-instantiate --parse "$file" > /dev/null 2>&1; then
        log_error "Nix syntax error in $file"
        exit 1
    fi
done

# 2. Check for formatting consistency
echo "Checking Nix formatting..."
for file in $(git diff --cached --name-only --diff-filter=ACM | grep '\.nix$'); do
    if command -v nixfmt >/dev/null 2>&1; then
        if ! nixfmt --check "$file"; then
            log_error "Formatting issues in $file. Run 'nixfmt $file' to fix."
            exit 1
        fi
    else
        log_warning "nixfmt not found. Install it with 'nix-env -iA nixpkgs.nixfmt'"
    fi
done

# 3. Verify flake.nix inputs
if git diff --cached --name-only | grep -q "flake.nix"; then
    echo "Checking flake.nix..."
    if ! nix flake check; then
        log_error "Flake check failed"
        exit 1
    fi
fi

# 4. Check for NixOS system builds
for file in $(git diff --cached --name-only | grep -E "systems/.*/default.nix"); do
    system_name=$(basename $(dirname "$file"))
    echo "Checking NixOS configuration for $system_name..."
    if ! nix build .#nixosConfigurations.$system_name.config.system.build.toplevel --dry-run; then
        log_error "NixOS configuration check failed for $system_name"
        exit 1
    fi
done

exit 0
EOF

# pre-push hook
cat > .git/hooks/pre-push << 'EOF'
#!/usr/bin/env bash

# 1. Full flake check
echo "Performing complete flake check..."
if ! nix flake check; then
    log_error "Flake check failed"
    exit 1
fi

# 2. Check if all systems build
echo "Checking all system configurations..."
for system in $(nix eval --json .#nixosConfigurations --apply builtins.attrNames | jq -r '.[]'); do
    echo "Building configuration for $system..."
    if ! nix build .#nixosConfigurations.$system.config.system.build.toplevel --dry-run; then
        log_error "Build failed for system: $system"
        exit 1
    fi
done

# 3. Check home-manager configurations
if command -v home-manager >/dev/null 2>&1; then
    echo "Checking home-manager configurations..."
    for home in $(nix eval --json .#homeConfigurations --apply builtins.attrNames 2>/dev/null | jq -r '.[]' 2>/dev/null); do
        echo "Building home configuration for $home..."
        if ! nix build .#homeConfigurations.$home.activationPackage --dry-run; then
            log_error "Build failed for home configuration: $home"
            exit 1
        fi
    done
fi

# 4. Lock file validation
if git diff --name-only | grep -q "flake.lock"; then
    echo "Checking flake.lock consistency..."
    if ! nix flake metadata >/dev/null 2>&1; then
        log_error "Flake lock file is inconsistent"
        exit 1
    fi
fi

exit 0
EOF

# post-merge hook
cat > .git/hooks/post-merge << 'EOF'
#!/usr/bin/env bash

# 1. Check if flake.nix or flake.lock changed
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -q "flake\.(nix|lock)"; then
    echo "Flake files changed, updating lockfile..."
    nix flake update
fi

# 2. Remind about garbage collection
echo "Consider running 'nix-collect-garbage -d' to clean up old generations"

exit 0
EOF

# Install script
cat > install-hooks.sh << 'EOF'
#!/usr/bin/env bash

# Make all hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push
chmod +x .git/hooks/post-merge

log_success "Git hooks installed successfully!"
EOF

chmod +x install-hooks.sh