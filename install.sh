#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Установщик плагина Nitro Fans для Omarchy
# Ноутбук: Acer Nitro AN515-44
#
# Устанавливает виджет nitro.fans в ~/.config/omarchy/plugins,
# добавляет его в shell.json и спрашивает, куда разместить popup на панели:
# слева / справа / по центру — не заменяя виджеты других плагинов.
###############################################################################

OMARCHY_PLUGINS_DIR="$HOME/.config/omarchy/plugins"
SHELL_JSON="$HOME/.config/omarchy/shell.json"
PLUGIN_ID="nitro.fans"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_SRC="$SCRIPT_DIR/plugins/$PLUGIN_ID"
REPO_URL="https://github.com/rLeeKen/omarchy-acer-nitro-fan-control.git"

echo "============================================================"
echo "  Установка плагина Nitro Fans для Omarchy"
echo "  Ноутбук: Acer Nitro AN515-44"
echo "============================================================"
echo

# -------- проверки -------------------------------------------------------------
need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd omarchy; then
  echo "ОШИБКА: omarchy не найден в PATH. Установите Omarchy сначала."
  exit 1
fi

if ! need_cmd jq; then
  echo "ОШИБКА: jq не найден. Установите jq."
  exit 1
fi

mkdir -p "$OMARCHY_PLUGINS_DIR"

# -------- пакеты ---------------------------------------------------------------
echo "==> Проверка необходимых пакетов..."
MISSING=0
if ! pacman -Q nbfc >/dev/null 2>&1 && ! yay -Q nbfc >/dev/null 2>&1; then
  echo "   [отсутствует] nbfc  (AUR: nbfc-linux — чтение оборотов вентиляторов)"
  MISSING=1
fi
if ! need_cmd nitro-fan && [ ! -x "$HOME/.local/bin/nitro-fan" ]; then
  echo "   [отсутствует] nitro-fan  (PATH или ~/.local/bin/nitro-fan — переключение режимов)"
  MISSING=1
fi

if [ "$MISSING" -eq 1 ]; then
  echo
  read -rp "Установить недостающие пакеты через yay? (y/N): " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    yay -S --needed nbfc-linux || true
    if ! need_cmd nitro-fan && [ ! -x "$HOME/.local/bin/nitro-fan" ]; then
      echo
      echo "Внимание: nitro-fan не установлен автоматически."
      echo "Установите его вручную (AUR: nitro-fan) или положите бинарник в ~/.local/bin/nitro-fan"
    fi
  fi
fi
echo

# -------- копирование плагина --------------------------------------------------
if [ -d "$PLUGIN_SRC" ]; then
  # запуск из клонированного репозитория
  echo "==> Копирование плагина в $OMARCHY_PLUGINS_DIR/$PLUGIN_ID ..."
  rm -rf "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
  cp -r "$PLUGIN_SRC" "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
else
  # однострочник через curl: плагина рядом нет — клонируем репозиторий
  echo "==> Клонирование репозитория $REPO_URL ..."
  TMP_DIR="$(mktemp -d)"
  git clone --depth=1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
  echo "==> Копирование плагина в $OMARCHY_PLUGINS_DIR/$PLUGIN_ID ..."
  rm -rf "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
  cp -r "$TMP_DIR/plugins/$PLUGIN_ID" "$OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
  rm -rf "$TMP_DIR"
fi
echo "   Плагин установлен."

# -------- бэкап shell.json -----------------------------------------------------
if [ -f "$SHELL_JSON" ]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  cp "$SHELL_JSON" "$SHELL_JSON.bak.$ts"
  echo "==> Бэкап: $SHELL_JSON.bak.$ts"
fi

# -------- добавить плагин в массив plugins -------------------------------------
if [ -f "$SHELL_JSON" ]; then
  echo "==> Добавление плагина в omarchy shell.json ..."
  tmp="$(mktemp)"
  jq '
    .plugins = ([.plugins[] | select((.id // "") != "nitro.fans")] + [{"id":"nitro.fans"}])
  ' "$SHELL_JSON" > "$tmp" && mv "$tmp" "$SHELL_JSON"
  echo "   Плагин nitro.fans добавлен в массив plugins."
else
  echo "   ВНИМАНИЕ: $SHELL_JSON не найден. Добавьте {\"id\":\"nitro.fans\"} в массив plugins вручную."
fi

# -------- выбор позиции popup на панели ----------------------------------------
echo
echo "============================================================"
echo "  Куда разместить popup с вентиляторами на панели Omarchy?"
echo "  1) Слева   (left)"
echo "  2) Справа  (right)"
echo "  3) По центру (center)"
echo "============================================================"
read -rp "Введите 1/2/3 [по умолчанию 2 - справа]: " pos
case "$pos" in
  1) section="left" ;;
  3) section="center" ;;
  *) section="right" ;;
esac

if [ -f "$SHELL_JSON" ]; then
  echo "==> Размещение виджета nitro.fans в секции '$section' панели ..."
  tmp="$(mktemp)"
  jq --arg sec "$section" '
    # не трогаем виджеты других плагинов, убираем только возможные дубли nitro.fans
    .bar.layout.left  = ([.bar.layout.left  [] | select((.id // "") != "nitro.fans")]) |
    .bar.layout.center= ([.bar.layout.center[] | select((.id // "") != "nitro.fans")]) |
    .bar.layout.right = ([.bar.layout.right [] | select((.id // "") != "nitro.fans")]) |
    # добавляем нитро-фана в конец выбранной секции
    .bar.layout[$sec] += [{"id":"nitro.fans"}]
  ' "$SHELL_JSON" > "$tmp" && mv "$tmp" "$SHELL_JSON"
  echo "   Виджет nitro.fans добавлен в секцию '$section' (конец секции)."
else
  echo "   ВНИМАНИЕ: добавьте {\"id\":\"nitro.fans\"} в нужную секцию bar.layout вручную."
fi

# -------- завершение -----------------------------------------------------------
echo
echo "============================================================"
echo "  Установка завершена!"
echo "============================================================"
echo
echo "Перезапустите оболочку Omarchy, чтобы применить изменения:"
echo "    omarchy restart shell"
echo
echo "После этого виджет Nitro Fans появится на панели (секция: $section)."
echo "Открыть popup — кликом по иконке виджета на панели."
echo
echo "Удаление:"
echo "    rm -rf $OMARCHY_PLUGINS_DIR/$PLUGIN_ID"
echo "    omarchy restart shell"
