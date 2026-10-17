# Installation

## Prerequisites

- [Omarchy](https://github.com/omarchy/omarchy) installed and running
- Git
- For `nitro.fans`: `nitro-fan` and `nbfc` packages

## Install

### Option 1: One-liner (recommended)

```bash
bash -c "$(curl -fsSL https://gitlab.com/rLeeKen/omarchy-acer-nitro-fan-control/-/raw/main/install.sh)"
```

### Option 2: Manual

```bash
git clone https://gitlab.com/rLeeKen/omarchy-acer-nitro-fan-control.git
cd omarchy-acer-nitro-fan-control
chmod +x install.sh
./install.sh
```

## After installation

Restart the Omarchy shell to load the new plugins:

```bash
omarchy restart shell
```

## Uninstall

```bash
rm -rf ~/.config/omarchy/plugins/nitro.fans
rm -rf ~/.config/omarchy/plugins/nitro.network
omarchy restart shell
```
