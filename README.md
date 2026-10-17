# chmonya Omarchy Plugins

Custom Omarchy plugins for Acer Nitro AN515-44 and network enhancements.

## Plugins

| Plugin            | Description |
|-------------------|-------------|
| `chmonya.fans`    | Nitro fan control (nbfc + nitro-fan) with presets, speed slider,     keyboard navigation, and temperature warnings |
| `chmonya.network` | Wi-Fi network popup with "Forget network" support |

## Screenshots

![Fans popup](https://raw.githubusercontent.com/rLeeKen/chmonya-omarchy-plugins/main/screenshots/fans.png)
![Network popup](https://raw.githubusercontent.com/rLeeKen/chmonya-omarchy-plugins/main/screenshots/network.png)

## Requirements

- Omarchy installed and running
- For `chmonya.fans`: `nitro-fan` and `nbfc` packages installed
- Git (for installation)

## Installation

### One-liner

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rLeeKen/chmonya-omarchy-plugins/main/install.sh)"
```

### Manual

```bash
git clone https://github.com/rLeeKen/chmonya-omarchy-plugins.git
cd chmonya-omarchy-plugins
chmod +x install.sh
./install.sh
```

## Apply changes

After installation, restart the Omarchy shell:

```bash
omarchy restart shell
```

## Usage

### Fans plugin

Open the fan popup (default keybind: `SUPER+SPACE` or your configured key).

- `←` / `→` — switch between presets: Quiet → Balanced → Performance → Turbo
- `↓` from a preset — jump to Auto mode
- `↑` from a preset — jump to speed slider
- `↓` from slider — jump to Quiet preset
- `↑` from slider — jump to Auto mode
- `Enter` — apply selected preset or slider value

### Network plugin

Open the network popup from the bar widget.

- Click the forget icon (🗙) on a saved network to remove its profile and password.

## License

[MIT](LICENSE)
