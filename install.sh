#!/usr/bin/env bash
set -euo pipefail

# chmonya Omarchy plugins installer
# Installs custom Omarchy plugins into ~/.config/omarchy/plugins

OMARCHY_PLUGINS_DIR="${HOME}/.config/omarchy/plugins"
REPO_URL="https://github.com/rLeeKen/chmonya-omarchy-plugins.git"
TMP_DIR="$(mktemp -d)"

echo "==> chmonya Omarchy plugins installer"
echo "==> Target: ${OMARCHY_PLUGINS_DIR}"

mkdir -p "${OMARCHY_PLUGINS_DIR}"

echo "==> Cloning plugins..."
git clone --depth=1 "${REPO_URL}" "${TMP_DIR}"

for plugin in "${TMP_DIR}/plugins"/*/; do
  plugin_name="$(basename "${plugin}")"
  echo "==> Installing ${plugin_name}..."
  rm -rf "${OMARCHY_PLUGINS_DIR}/${plugin_name}"
  cp -r "${plugin}" "${OMARCHY_PLUGINS_DIR}/${plugin_name}"
done

rm -rf "${TMP_DIR}"

echo "==> Done!"
echo "==> Restart Omarchy shell to apply changes:"
echo "    omarchy restart shell"
