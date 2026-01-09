#!/bin/bash
# =============================================================================
# Dependency Validation Helper
# Checks for required commands before script execution
# =============================================================================

check_dependency() {
    local cmd="$1"
    local required="${2:-false}"

    if command -v "$cmd" &>/dev/null; then
        echo "✓ $cmd found"
        return 0
    else
        if [[ "$required" == "true" ]]; then
            echo "✗ ERROR: Required command '$cmd' not found"
            echo "  Please install $cmd and try again"
            return 1
        else
            echo "⚠ WARNING: Optional command '$cmd' not found"
            return 0
        fi
    fi
}

validate_basic_deps() {
    local all_ok=true

    echo "Checking required dependencies..."

    # Required for all scripts
    check_dependency "bash" "true" || all_ok=false
    check_dependency "grep" "true" || all_ok=false
    check_dependency "sed" "true" || all_ok=false
    check_dependency "cat" "true" || all_ok=false
    check_dependency "mkdir" "true" || all_ok=false
    check_dependency "chmod" "true" || all_ok=false

    if [[ "$all_ok" == "false" ]]; then
        echo ""
        echo "❌ Dependency check failed"
        return 1
    fi

    echo ""
    echo "✅ All required dependencies found"
    return 0
}

validate_git_deps() {
    echo "Checking Git dependencies..."
    check_dependency "git" "true" || return 1
    echo "✅ Git dependencies found"
    return 0
}

validate_optional_deps() {
    echo "Checking optional dependencies..."

    # Optional but recommended
    check_dependency "openspec" "false"
    check_dependency "npm" "false"
    check_dependency "npx" "false"
    check_dependency "python3" "false"
    check_dependency "sqlite3" "false"

    echo ""
}

# Platform detection
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Detect sed flavor
detect_sed_flavor() {
    if sed --version 2>&1 | grep -q GNU; then
        echo "gnu"
    else
        echo "bsd"
    fi
}

# Export functions if sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    export -f check_dependency
    export -f validate_basic_deps
    export -f validate_git_deps
    export -f validate_optional_deps
    export -f detect_platform
    export -f detect_sed_flavor
fi
