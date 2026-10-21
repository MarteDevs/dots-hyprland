#!/usr/bin/env bash
# SAO / Cardinal System — instala o verifica las personalizaciones sobre end-4.
#
#   ./install.sh           copia todo a ~/.config (respalda lo que vaya a cambiar)
#   ./install.sh --check   solo verifica que todo siga en su sitio (p. ej. tras actualizar)
#
# Ver README.md para saber qué hace cada archivo y cómo actualizar sin romper nada.
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FILES="$REPO/dots-extra/sao/files"
CONF="${XDG_CONFIG_HOME:-$HOME/.config}"
PICS="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
BACKUP="$CONF/sao-backup-$(date +%Y%m%d-%H%M%S)"

# Archivos de end-4 modificados para SAO. Viven en dots/ del fork y el instalador
# de end-4 los sobrescribe, por eso también se pueden restaurar desde aquí.
SHELL_FILES=(
    quickshell/ii/modules/common/Config.qml
    quickshell/ii/modules/common/widgets/SaoUnfold.qml
    quickshell/ii/modules/common/widgets/SaoHudFrame.qml
    quickshell/ii/modules/ii/lock/SaoLockOverlay.qml
    quickshell/ii/modules/ii/lock/LockSurface.qml
    quickshell/ii/modules/ii/sessionScreen/SessionScreen.qml
    quickshell/ii/modules/ii/sessionScreen/SessionActionButton.qml
    quickshell/ii/assets/icons/sao-symbolic.svg
    starship.toml
)
# Archivos propios (no existen en end-4): origen relativo a files/ -> destino en ~/.config
USER_FILES=(
    hypr/custom/general.lua
    hypr/custom/keybinds.lua
    hypr/custom/scripts/sao-wallpaper.sh
    fish/conf.d/sao-fastfetch.fish
    btop/themes/sao.theme
    cava/config
    cava/themes/sao
    fastfetch/config.jsonc
    fastfetch/sinon.ans
    fastfetch/sinon.png
    fastfetch/tools/make-logo.sh
)

ok=0; bad=0
pass() { printf '  \e[32m✔\e[0m %s\n' "$1"; ok=$((ok + 1)); }
fail() { printf '  \e[31m✘\e[0m %s\n' "$1"; bad=$((bad + 1)); }
has()  { grep -q -- "$2" "$1" 2>/dev/null; }

check() {
    echo "◢ SAO: verificando instalación"
    for f in "${SHELL_FILES[@]}"; do
        if cmp -s "$REPO/dots/.config/$f" "$CONF/$f"; then pass "$f"
        else fail "$f (distinto al del fork o ausente)"; fi
    done
    for f in "${USER_FILES[@]}"; do
        if [ -e "$CONF/$f" ]; then pass "$f"; else fail "$f (falta)"; fi
    done
    has "$CONF/hypr/hyprland.lua" 'require("custom.general")' \
        && pass "hyprland.lua carga custom/general.lua" || fail "hyprland.lua ya no carga custom/general.lua"
    has "$CONF/btop/btop.conf" 'color_theme = "sao"' && pass "btop usa el tema sao" || fail "btop no usa el tema sao"
    [ "$(jq -r '.sao.enable // empty' "$CONF/illogical-impulse/config.json" 2>/dev/null)" = "true" ] \
        && pass "config.json tiene la sección sao" || fail "config.json sin sección sao"
    [ -d "$PICS/SAO/lock" ] && pass "carpeta de imágenes del bloqueo: $PICS/SAO/lock" || fail "falta $PICS/SAO/lock"
    if command -v hyprctl >/dev/null && hyprctl version >/dev/null 2>&1; then
        errs="$(hyprctl configerrors 2>/dev/null | tr -d '[:space:]')"
        [ -z "$errs" ] && pass "Hyprland sin errores de configuración" || fail "Hyprland reporta errores: hyprctl configerrors"
    fi
    echo "◥ $ok correctos, $bad con problemas"
    [ "$bad" -eq 0 ]
}

backup_copy() { # origen destino
    local src="$1" dst="$2"
    if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
        mkdir -p "$BACKUP/$(dirname "${dst#"$CONF"/}")"
        cp -a "$dst" "$BACKUP/${dst#"$CONF"/}"
    fi
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
}

install() {
    echo "◢ SAO: instalando (respaldo de lo reemplazado en $BACKUP)"
    for f in "${SHELL_FILES[@]}"; do backup_copy "$REPO/dots/.config/$f" "$CONF/$f"; done
    for f in "${USER_FILES[@]}"; do backup_copy "$FILES/$f" "$CONF/$f"; done
    chmod +x "$CONF/hypr/custom/scripts/sao-wallpaper.sh" "$CONF/fastfetch/tools/make-logo.sh"

    # btop: activar el tema y usar el fondo de la terminal
    if [ -f "$CONF/btop/btop.conf" ]; then
        sed -i 's/^color_theme = .*/color_theme = "sao"/; s/^theme_background = .*/theme_background = false/' "$CONF/btop/btop.conf"
    fi

    # quickshell: fusionar la sección sao (y el icono de la barra) sin tocar el resto
    local cfg="$CONF/illogical-impulse/config.json"
    if [ -f "$cfg" ]; then
        mkdir -p "$BACKUP/illogical-impulse"; cp "$cfg" "$BACKUP/illogical-impulse/config.json"
        jq -s '.[0] * .[1]' "$cfg" "$FILES/illogical-impulse.sao.json" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
    fi

    # Imágenes del bloqueo y carpeta de wallpapers
    mkdir -p "$PICS/SAO/lock" "$PICS/Wallpapers/SAO"
    [ -n "$(ls -A "$PICS/SAO/lock" 2>/dev/null)" ] || cp "$FILES/pictures/SAO/lock/"* "$PICS/SAO/lock/"

    command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1
    rmdir "$BACKUP" 2>/dev/null || true
    echo
    check
}

case "${1:-}" in
    --check) check ;;
    "") install ;;
    *) echo "Uso: $0 [--check]"; exit 2 ;;
esac
