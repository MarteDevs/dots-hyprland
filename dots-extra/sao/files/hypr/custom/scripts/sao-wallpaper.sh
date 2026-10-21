#!/usr/bin/env bash
# SAO: pone un wallpaper aleatorio de la carpeta SAO y regenera la paleta de
# toda la interfaz (matugen) a partir de él. Sin repetir el actual.
dir="${1:-$(xdg-user-dir PICTURES)/Wallpapers/SAO}"
current="$(jq -r '.background.wallpaperPath // empty' ~/.config/illogical-impulse/config.json 2>/dev/null)"
mapfile -t imgs < <(find "$dir" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) ! -path "$current")
if [ "${#imgs[@]}" -eq 0 ]; then
    notify-send "SAO" "No hay wallpapers en $dir" 2>/dev/null
    exit 1
fi
exec ~/.config/quickshell/ii/scripts/colors/switchwall.sh "${imgs[RANDOM % ${#imgs[@]}]}"
