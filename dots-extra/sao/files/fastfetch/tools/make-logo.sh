#!/usr/bin/env bash
# Genera el logo de fastfetch en texto (bloques a color real) con chafa.
# Uso: make-logo.sh imagen.png [salida.ans] [ancho] [alto]
# La imagen debe tener fondo transparente para que se adapte a tema claro/oscuro.
set -euo pipefail
src="$1"; out="${2:-$HOME/.config/fastfetch/logo.ans}"; w="${3:-38}"; h="${4:-23}"
chafa -f symbols -c full --work 9 -t 0.5 --font-ratio 1/2 -s "${w}x${h}" \
    --symbols "block+sextant+quad+half+wedge+space" "$src" \
  | sed -e 's/\x1b\[?25[lh]//g' | sed -e '/^$/d' > "$out"
echo "$out: $(wc -l < "$out") líneas"
