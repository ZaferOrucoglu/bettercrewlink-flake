#!/usr/bin/env bash
set -euo pipefail

REPO="OhMyGuus/BetterCrewLink"
PACKAGE_FILE="package.nix"

AUTH_HEADER=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  AUTH_HEADER=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

echo "Checking latest release from $REPO..."
RESPONSE=$(curl -sL "${AUTH_HEADER[@]}" "https://api.github.com/repos/$REPO/releases/latest")
LATEST_TAG=$(echo "$RESPONSE" | grep -oP '"tag_name":\s*"\K[^"]+' || true)

if [[ -z "$LATEST_TAG" ]]; then
  API_MSG=$(echo "$RESPONSE" | grep -oP '"message":\s*"\K[^"]+' || true)
  if [[ -n "$API_MSG" ]]; then
    echo "Error from GitHub API: $API_MSG"
  else
    echo "Error: Failed to fetch latest release tag."
  fi
  exit 1
fi

LATEST_VERSION="${LATEST_TAG#v}"
CURRENT_VERSION=$(grep -oP 'version = "\K[^"]+' "$PACKAGE_FILE")

echo "Current version: $CURRENT_VERSION"
echo "Latest version:  $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
  echo "Already up-to-date."
  exit 0
fi

echo "New version available: $LATEST_VERSION. Prefetching hash..."
URL="https://github.com/$REPO/releases/download/v${LATEST_VERSION}/Better-CrewLink-${LATEST_VERSION}.AppImage"
NEW_HASH=$(nix store prefetch-file "$URL" --json | grep -oP '"hash":\s*"\K[^"]+' || true)

if [[ -z "$NEW_HASH" ]]; then
  echo "Error: Failed to prefetch hash for $URL"
  exit 1
fi

echo "Fetched hash: $NEW_HASH"
echo "Updating $PACKAGE_FILE..."

# Update version
sed -i -E "s/version = \"[^\"]+\";/version = \"$LATEST_VERSION\";/" "$PACKAGE_FILE"
# Update hash
sed -i -E "s|hash = \"[^\"]+\";|hash = \"$NEW_HASH\";|" "$PACKAGE_FILE"

echo "Testing build..."
if nix build --no-link .#bettercrewlink; then
  echo "Build succeeded! Updated to $LATEST_VERSION."
else
  echo "Build failed! Reverting $PACKAGE_FILE..."
  git checkout -- "$PACKAGE_FILE"
  exit 1
fi
