#!/usr/bin/env bash
# Generate stats.svg locally. Requires a GitHub token (PAT) for API access.
# Create one at https://github.com/settings/tokens with "read:user" scope.
#
# Usage: ./scripts/generate-stats.sh
# Reads PAT_1 from .env in the repo root (or pass PAT_1=ghp_xxx to override).

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$REPO_ROOT/.env" ]]; then
  set -a
  source "$REPO_ROOT/.env"
  set +a
fi

if [[ -z "${PAT_1}" ]]; then
  echo "Error: PAT_1 (GitHub token) is required. Create one at https://github.com/settings/tokens"
  echo "Add PAT_1=ghp_xxx to .env in the repo root, or run: PAT_1=ghp_xxx ./scripts/generate-stats.sh"
  exit 1
fi

if [[ -z "${GITHUB_USERNAME}" ]]; then
  echo "Error: GITHUB_USERNAME is required."
  echo "Add GITHUB_USERNAME=your-username to .env in the repo root."
  exit 1
fi

STATS_PATH="${STATS_PATH:-profile/stats.svg}"
STATS_THEME="${STATS_THEME:-radical}"
STATS_SHOW_ICONS="${STATS_SHOW_ICONS:-true}"

ACTION_DIR="/tmp/github-readme-stats-action"

git clone --depth 1 https://github.com/stats-organization/github-readme-stats-action "$ACTION_DIR" 2>/dev/null || true
cd "$ACTION_DIR" && npm ci --omit=dev --ignore-scripts

cd "$REPO_ROOT"
INPUT_CARD=stats \
INPUT_OPTIONS="username=${GITHUB_USERNAME}&theme=${STATS_THEME}&show_icons=${STATS_SHOW_ICONS}" \
INPUT_PATH="$STATS_PATH" \
GITHUB_REPOSITORY_OWNER="$GITHUB_USERNAME" \
node "$ACTION_DIR/index.js"

echo "Generated $STATS_PATH"
