# SAO: muestra fastfetch en la primera terminal de cada sesión gráfica.
# Para verlo en todas las terminales: set -U sao_fastfetch_always 1
# Para desactivarlo:                  set -U sao_fastfetch_off 1
if status is-interactive; and test "$TERM" != linux; and not set -q sao_fastfetch_off
    and command -q fastfetch
    set -l marker "$XDG_RUNTIME_DIR/sao-fastfetch-$HYPRLAND_INSTANCE_SIGNATURE"
    if set -q sao_fastfetch_always; or not test -e "$marker"
        touch "$marker" 2>/dev/null
        fastfetch
    end
end
