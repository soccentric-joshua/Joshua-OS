#!/usr/bin/env bash
# pin-layers.sh — verify every KAS layer is pinned to an immutable commit.
#
# Reproducible image builds require each layer in kas/repos/*.yaml to resolve
# to a fixed revision. A layer left on a moving branch (or with no pin at all)
# makes identical builds resolve different sources. This check FAILS before
# bitbake when any layer is unpinned, so a broken pin can never silently reach
# the build.
#
# Usage:
#   scripts/pin-layers.sh            # check (exit 1 on any unpinned layer)
#   scripts/pin-layers.sh --help
#
# Update workflow when you deliberately bump a layer:
#   1. Review the target commit in the upstream layer.
#   2. Set `commit: <40-hex>` in kas/repos/<layer>.yaml (replace any `branch:`).
#   3. Run this script; it must exit 0.
#   4. Commit the pin and the image together.
set -euo pipefail

REPOS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/kas/repos"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    sed -n '2,20p' "${BASH_SOURCE[0]}"
    exit 0
fi

fail=0
for yaml in "$REPOS_DIR"/*.yaml; do
    name="$(basename "$yaml")"
    # Parse the top-level repos.<repo>.commit / .branch with a tiny awk parser.
    repo="$(awk '/^repos:/{in_repos=1; next} in_repos && /^[[:space:]]+[A-Za-z0-9_.-]+:/{sub(":", ""); gsub(/^[ \t]+/, ""); if ($0 !~ /^[A-Za-z0-9_.-]+$/) exit; repo=$0} END{print repo}' "$yaml" 2>/dev/null || true)"
    commit="$(awk '/^    commit:/{print $2}' "$yaml" 2>/dev/null || true)"
    branch="$(awk '/^    branch:/{print $2}' "$yaml" 2>/dev/null || true)"
    # Local clone path for this repo (e.g. layers/meta-ti, meta/meta-joshua).
    # Only a format check here is not enough — a bogus hash (right shape, wrong
    # object) passes regex but fails the real checkout. Verify the pin actually
    # exists in the repo's object database so a broken pin fails fast here.
    path="$(awk '/^    path:/{print $2}' "$yaml" 2>/dev/null || true)"

    if [[ -z "$commit" ]]; then
        echo "FAIL: $name has no immutable 'commit:' pin" >&2
        if [[ -n "$branch" ]]; then
            echo "      it tracks a moving branch '${branch}' — pin it or the build is not reproducible" >&2
        fi
        fail=1
        continue
    fi
    if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
        echo "FAIL: $name has a malformed commit pin '$commit' (expected 40 hex chars)" >&2
        fail=1
        continue
    fi

    if [[ -z "$path" || ! -d "$path/.git" ]]; then
        echo "FAIL: $name: cannot verify pin — repo clone not found at '${path:-<missing path:>}'" >&2
        fail=1
        continue
    fi
    if ! git -C "$path" cat-file -e "$commit" 2>/dev/null; then
        echo "FAIL: $name @ $commit does not exist in the $path clone (bogus pin — run kas build to fetch, or fix the hash)" >&2
        fail=1
        continue
    fi

    if [[ -n "$branch" ]]; then
        echo "WARN: $name sets both 'branch' and 'commit'; kas resolves the commit, but drop 'branch:' to avoid confusion" >&2
    fi
    echo "OK  : $name @ $commit"
done

if [[ "$fail" -eq 1 ]]; then
    echo "" >&2
    echo "pin-layers: FAILED — at least one layer is not pinned to an immutable commit." >&2
    exit 1
fi
echo ""
echo "pin-layers: all layers pinned to immutable commits."
