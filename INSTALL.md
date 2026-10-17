# Install Nitro Fans plugin (Omarchy, Acer Nitro AN515-44)

## Prerequisites

- [Omarchy](https://github.com/omarchy/omarchy) installed and running
- `nbfc` (`nbfc-linux` from AUR) — reads fan speeds
- `nitro-fan` — switches fan modes
- `git`, `yay` (AUR helper), `curl`

## Installation

### One-liner

```bash
bash -c "$(curl -fsSL https://github.com/rLeeKen/omarchy-acer-nitro-fan-control/raw/main/install.sh)"
```

### Manual

```bash
git clone https://github.com/rLeeKen/omarchy-acer-nitro-fan-control.git
cd omarchy-acer-nitro-fan-control
chmod +x install.sh
./install.sh
```

## At the end of installation

The installer will ask where to place the fan popup on the Omarchy panel:

1. Left (`left`)
2. Right (`right`)
3. Center (`center`)

Choose an option — the widget will be added to the end of the chosen `bar.layout` section in `~/.config/omarchy/shell.json` **without replacing widgets of other plugins**.

### Apply changes

```bash
omarchy restart shell
```

## Uninstall

```bash
rm -rf ~/.config/omarchy/plugins/nitro.fans
omarchy restart shell
```
