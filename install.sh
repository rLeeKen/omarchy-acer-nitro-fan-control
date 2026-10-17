#!/usr/bin/env bash
set -eo pipefail

###############################################################################
# Nitro Fans plugin installer for Omarchy
# Laptop: Acer Nitro AN515-44
#
# Installs the nitro.fans widget into ~/.config/omarchy/plugins,
# adds it to shell.json and asks where to place the popup on the panel:
# left / right / center — without replacing widgets of other plugins.
###############################################################################

OMARCHY_PLUGINS_DIR="$HOME/.config/omarchy/plugins"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
PLUGIN_ID="nitro.fans"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd) || true"
PLUGIN_SRC="$SCRIPT_DIR/plugins/$PLUGIN_ID"
REPO_URL="https://github.com/rLeeKen/omarchy-acer-nitro-fan-control.git"

echo "============================================================"
echo "  Installing Nitro Fans plugin for Omarchy"
echo "  Laptop: Acer Nitro AN515-44"
echo "============================================================"
echo

# -------- checks --------------------------------------------------------------
have_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! have_cmd omarchy; then
  echo "ERROR: omarchy not found in PATH. Install Omarchy first."
  exit 1
fi

if ! have_cmd jq; then
  echo "ERROR: jq not found. Install jq first."
  exit 1
fi

mkdir -p "$OMARCHY_PLUGINS_DIR"

# -------- required packages ----------------------------------------------------
echo "==> Checking required packages..."
MISSING=0

if ! pacman -Q nbfc >/dev/null 2>&1 && ! yay -Q nbfc >/dev/null 2>&1; then
  echo "   [missing] nbfc        (AUR: nbfc-linux — reads fan speeds)"
  MISSING=1
fi

if ! have_cmd nitro-fan && [ ! -x "$HOME/.local/bin/nitro-fan" ]; then
  echo "   [missing] nitro-fan   (PATH or ~/.local/bin/nitro-fan — switches fan modes)"
  MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
  echo
  read -rp "Install missing packages via yay? (y/N): " ans
  echo
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    if ! have_cmd yay; then
      echo "ERROR: yay is not installed. Install yay (AUR helper) first, then re-run this script."
      echo "See: https://github.com/Jguer/yay"
      exit 1
    fi
    echo "==> Installing nbfc-linux ..."
    yay -S --needed nbfc-linux || echo "WARNING: failed to install nbfc-linux via yay."
    echo
    if ! have_cmd nitro-fan && [ ! -x "$HOME/.local/bin/nitro-fan" ]; then
      echo "WARNING: nitro-fan was not installed automatically."
      echo "Install it manually (AUR: nitro-fan) or place the binary at ~/.local/bin/nitro-fan"
    fi
  else
    echo "==> Skipping package installation. The plugin may not work without nbfc and nitro-fan."
  fi
else
  echo "   All required packages are present."
fi
echo

# -------- copy plugin ----------------------------------------------------------
if [ -d "$PLUGIN_SRC" ]; then
  # running from cloned repository
  echo "==> Copying plugin to $OMARCHY_PLUGINS_DIR/$PLUGIN_ID ..."
  rm -rf "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
  cp -r "$PLUGIN_SRC" "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
else
  # one-liner via curl: plugin not next to script — clone the repository
  echo "==> Cloning repository $REPO_URL ..."
  TMP_DIR="$(mktemp -d)"
  git clone --depth=1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
  echo "==> Copying plugin to $OMARCHY_PLUGINS_DIR/$PLUGIN_ID ..."
  rm -rf "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
  cp -r "$TMP_DIR/plugins/$PLUGIN_ID" "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
  rm -rf "$TMP_DIR"
fi
echo "   Plugin installed."

# -------- backup shell.json ----------------------------------------------------
if [ -f "$SHELL_JSON" ]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  cp "$SHELL_JSON" "$SHELL_JSON.bak.$ts"
  echo "==> Backup: $SHELL_JSON.bak.$ts"
fi

# -------- add plugin to plugins array ------------------------------------------
if [ -f "$SHELL_JSON" ]; then
  echo "==> Adding plugin to omarchy shell.json ..."
  tmp="$(mktemp)"
  jq '
    .plugins = ([.plugins[] | select((.id // "") != "nitro.fans")] + [{"id":"nitro.fans"}])
  ' "$SHELL_JSON" > "$tmp" && mv "$tmp" "$SHELL_JSON"
  echo "   Plugin nitro.fans added to plugins array."
else
  echo "   WARNING: $SHELL_JSON not found. Add {\"id\":\"nitro.fans\"} to plugins manually."
fi

# -------- choose popup position on panel ---------------------------------------
echo
echo "============================================================"
echo "  Where to place the fan popup on the Omarchy panel?"
echo "  1) Left   (left)"
echo "  2) Right  (right)"
echo "  3) Center (center)"
echo "============================================================"
read -rp "Enter 1/2/3 [default: 2 - right]: " pos
case "$pos" in
  1) section="left" ;;
  3) section="center" ;;
  *) section="right" ;;
esac

if [ -f "$SHELL_JSON" ]; then
  echo "==> Placing widget nitro.fans in section '$section' of the panel ..."
  tmp="$(mktemp)"
  jq --arg sec "$section" '
    # do not touch widgets of other plugins, remove only possible nitro.fans duplicates
    .bar.layout.left  = ([.bar.layout.left  [] | select((.id // "") != "nitro.fans")]) |
    .bar.layout.center= ([.bar.layout.center[] | select((.id // "") != "nitro.fans")]) |
    .bar.layout.right = ([.bar.layout.right [] | select((.id // "") != "nitro.fans")]) |
    # add nitro.fans at the end of the chosen section
    .bar.layout[$sec] += [{"id":"nitro.fans"}]
  ' "$SHELL_JSON" > "$tmp" && mv "$tmp" "$SHELL_JSON"
  echo "   Widget nitro.fans added to section '$section' (end of section)."
else
  echo "   WARNING: add {\"id\":\"nitro.fans\"} to the desired bar.layout section manually."
fi

# -------- finish ---------------------------------------------------------------
echo
echo "============================================================"
echo "  Installation complete!"
echo "============================================================"
echo
echo "Restart the Omarchy shell to apply changes:"
echo "    omarchy restart shell"
echo
echo "After that, the Nitro Fans widget will appear on the panel (section: $section)."
echo "Open the popup by clicking the widget icon on the panel."
echo
echo "Uninstall:"
echo "    rm -rf $OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
echo "    omarchy restart shell"
