# Установка плагина Nitro Fans (Omarchy, Acer Nitro AN515-44)

## Предварительные требования

- [Omarchy](https://github.com/omarchy/omarchy) установлен и запущен
- `nbfc` (`nbfc-linux` из AUR) — чтение оборотов вентиляторов
- `nitro-fan` — переключение режимов вентилятора
- `git`, `yay` (AUR helper), `curl`

## Установка

### Одной командой

```bash
bash -c "$(curl -fsSL https://github.com/rLeeKen/omarchy-acer-nitro-fan-control/raw/main/install.sh)"
```

### Вручную

```bash
git clone https://github.com/rLeeKen/omarchy-acer-nitro-fan-control.git
cd omarchy-acer-nitro-fan-control
chmod +x install.sh
./install.sh
```

## На конце установки

Установщик спросит, куда разместить popup с вентиляторами на панели:
слева / справа / по центру.

Виджет добавляется в конец выбранной секции `bar.layout` в
`~/.config/omarchy/shell.json` без замены виджетов других плагинов.

## Применить

```bash
omarchy restart shell
```

## Удаление

```bash
rm -rf ~/.config/omarchy/plugins/nitro.fans
omarchy restart shell
```
