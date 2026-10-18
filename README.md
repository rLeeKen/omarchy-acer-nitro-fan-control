# Nitro Fans — Omarchy fan control plugin

Omarchy plugin for fan control on **Acer Nitro AN515-44** laptops.
Adds a panel widget with fan speed slider, presets, temperature readings, and a popup.

## Supported laptop

Tested and developed on **Acer Nitro AN515-44**.
Fan control is handled via `nitro-fan` (mode switching) and `nbfc`
(fan speed and CPU/GPU/NVIDIA temperature readings).

## Included plugins

| Plugin | Description |
|--------|-------------|
| `nitro.fans` | Panel widget (bar-widget): icon + popup with speed slider, Quiet/Balanced/Performance/Turbo presets, Auto mode, temperatures, and overheat warning |

## Required packages

Make sure the following are installed before running the installer:

| Component | Package / source | Purpose |
|-----------|------------------|---------|
| Omarchy | omarchy | Shell and panel |
| nbfc | `nbfc-linux` (AUR) | Read fan speeds |
| nitro-fan | `~/.local/bin/nitro-fan` or AUR `nitro-fan` | Switch fan modes |
| git | git | Clone the repository |
| yay | yay (AUR helper) | Install AUR packages |
| curl | curl | One-liner installation |

## Installation

### Option 1: One-liner (recommended)

```bash
bash -c "$(curl -fsSL https://github.com/rLeeKen/omarchy-acer-nitro-fan-control/raw/main/install.sh)"
```

### Option 2: Manual

```bash
git clone https://github.com/rLeeKen/omarchy-acer-nitro-fan-control.git
cd omarchy-acer-nitro-fan-control
chmod +x install.sh
./install.sh
```

## At the end of installation

The installer will ask where to place the fan popup on the Omarchy panel:

1. **Left** (`left`)
2. **Right** (`right`) — default
3. **Center** (`center`)

The widget `{"id": "nitro.fans"}` is added to the end of the chosen `bar.layout` section in `~/.config/omarchy/shell.json` without replacing widgets of other plugins.

### Apply changes

Restart the Omarchy shell after installation:

```bash
omarchy restart shell
```

Then the Nitro Fans widget will appear on the panel. Click its icon to open the popup.

## Controls

Popup opens by clicking the widget icon on the panel.

| Key | Action |
|-----|--------|
| `←` / `→` | Switch presets: Quiet → Balanced → Performance → Turbo |
| `↓` from a preset | Switch to Auto mode |
| `↑` from a preset | Switch to speed slider |
| `↓` from slider | Switch to Quiet preset |
| `↑` from slider | Switch to Auto mode |
| `Enter` | Apply selected preset or slider value |

The icon color changes to "urgent" if CPU or GPU temperature exceeds 85 °C.

## Uninstall

```bash
rm -rf ~/.config/omarchy/plugins/nitro.fans
omarchy restart shell
```

You can also restore `~/.config/omarchy/shell.json` from the backup created by the installer
(`shell.json.bak.YYYYMMDD-HHMMSS`) to return the panel to its previous state.

## License

[MIT](LICENSE)
