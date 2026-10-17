# Installation

## Prerequisites

- [Omarchy](https://github.com/omarchy/omarchy) installed and running
- Git
- For `chmonya.fans`: `nitro-fan` and `nbfc` packages

## Install

### Option 1: One-liner (recommended)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/rLeeKen/chmonya-omarchy-plugins/main/install.sh)"
```

### Option 2: Manual

```bash
git clone https://github.com/rLeeKen/chmonya-omarchy-plugins.git
cd chmonya-omarchy-plugins
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
rm -rf ~/.config/omarchy/plugins/chmonya.fans
rm -rf ~/.config/omarchy/plugins/chmonya.network
omarchy restart shell
```
