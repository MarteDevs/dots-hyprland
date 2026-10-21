hl.bind("CTRL+SUPER+ALT+Slash", hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"), {description = "Edit user keybinds"} )

-- SAO: wallpaper aleatorio de ~/Imágenes/Wallpapers/SAO (regenera la paleta)
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd("~/.config/hypr/custom/scripts/sao-wallpaper.sh"), {description = "SAO: Random SAO wallpaper"} )
