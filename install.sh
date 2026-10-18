#!/usr/bin/env bash
set -eo pipefail

###############################################################################
# Nitro Fans plugin installer for Omarchy
# Laptop: Acer Nitro AN515-44
#
# Installs:
#   - nitro-fan from this repository into ~/.local/bin/nitro-fan
#   - nitro.fans widget into ~/.config/omarchy/plugins
#
# Then adds the widget to shell.json and asks where to place the popup
# on the Omarchy panel: left / right / center — without replacing widgets
# of other plugins.
###############################################################################

OMARCHY_PLUGINS_DIR="$HOME/.config/omarchy/plugins"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
PLUGIN_ID="nitro.fans"
NITRO_FAN_DST="$HOME/.local/bin/nitro-fan"
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
mkdir -p "$HOME/.local/bin"

# -------- decide source directory --------------------------------------------
# When run from a cloned repo, files are next to this script.
# When run via curl | bash, there are no local files — clone to a temp dir.
# Determine directory of this installer script.
# When run via `curl | bash`, BASH_SOURCE[0] and $0 are empty —
# in that case we fall back to cloning the repository below.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
PLUGIN_SRC="$SCRIPT_DIR/plugins/$PLUGIN_ID"
NITRO_FAN_SRC="$SCRIPT_DIR/nitro-fan"

if [ -d "$PLUGIN_SRC" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
elif [ -f "$NITRO_FAN_SRC" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
else
  echo "==> Cloning repository $REPO_URL ..."
  SOURCE_DIR="$(mktemp -d)"
  git clone --depth=1 "$REPO_URL" "$SOURCE_DIR" >/dev/null 2>&1
  CLONED_TO_TEMP=1
fi

# -------- install nitro-fan from repository ----------------------------------
echo "==> Installing nitro-fan ..."
if [ -f "$SOURCE_DIR/nitro-fan" ]; then
  cp "$SOURCE_DIR/nitro-fan" "$NITRO_FAN_DST"
  chmod +x "$NITRO_FAN_DST"
  echo "   nitro-fan installed to $NITRO_FAN_DST"
else
  echo "WARNING: nitro-fan not found in repository."
  echo "Copy it manually to $NITRO_FAN_DST and make it executable."
fi

echo

# -------- copy plugin ----------------------------------------------------------
echo "==> Copying plugin to $OMARCHY_PLUGINS_DIR/$PLUGIN_ID ..."
rm -rf "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
cp -r "$SOURCE_DIR/plugins/$PLUGIN_ID" "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
echo "   Plugin installed."

# -------- clean up temp clone --------------------------------------------------
if [ "${CLONED_TO_TEMP:-0}" = "1" ]; then
  rm -rf "$SOURCE_DIR"
fi

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
echo "    rm -f $NITRO_FAN_DST"
echo "    omarchy restart shell"
