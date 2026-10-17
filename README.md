# Nitro Omarchy Plugins

Custom Omarchy plugins for Acer Nitro AN515-44 and network enhancements.

## Plugins

| Plugin            | Description |
|-------------------|-------------|
| `nitro.fans`      | Nitro fan control (nbfc + nitro-fan) with presets, speed slider,     keyboard navigation, and temperature warnings |

## Screenshots

![Fans popup](https://raw.githubusercontent.com/rLeeKen/omarchy-acer-nitro-fan-control/main/screenshots/fans.png)

## Requirements

- Omarchy installed and running
- For `nitro.fans`: `nitro-fan` and `nbfc` packages installed
- Git (for installation)

## Installation

### One-liner

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rLeeKen/omarchy-acer-nitro-fan-control/main/install.sh)"
```

### Manual

```bash
git clone https://github.com/rLeeKen/omarchy-acer-nitro-fan-control.git
cd omarchy-acer-nitro-fan-control
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


## License

[MIT](LICENSE)
