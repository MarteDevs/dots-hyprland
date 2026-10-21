# SAO / Cardinal System — personalización sobre end-4

Tema inspirado en el Sistema Cardinal de *Sword Art Online* sobre los dotfiles
[end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (shell `ii`).

**Principios de diseño**

- **No se fuerza la paleta global.** end-4 genera los colores de toda la interfaz
  desde el wallpaper (matugen). Eso se mantiene; lo SAO se añade encima.
- **Se ve bien en tema claro y oscuro.** Los fondos y textos usan colores del tema;
  los acentos fijos son de tono medio y contrastan sobre ambos:
  cian `#0097b8`, magenta `#d61f8f`, verde `#2fa84f`, ámbar `#d49a00`, rojo `#d93b3b`.
- **Todo lo posible vive en archivos que end-4 no sobrescribe.** Lo que no, vive en este fork.

---

## Qué incluye

| Parte | Qué hace | Dónde se configura |
|---|---|---|
| Bordes | Degradado cian → magenta que gira despacio; esquinas de 10 px | `~/.config/hypr/custom/general.lua` |
| Animaciones | Ventanas y capas aparecen con un rebote rápido (curva `saoPop`, `popin 70%`) y se cierran encogiéndose | `~/.config/hypr/custom/general.lua` |
| Bloqueo | Panel "LINK DISCONNECTED", tarjeta de personaje con imágenes rotativas, fondo opcional, animación de despliegue SAO | `config.json` → `sao.lock` |
| Menú de sesión | Marco HUD, título "SYSTEM MENU", mensaje, botones circulares, misma animación | `config.json` → `sao.session` |
| Barra | Icono SAO (espada en rombo) arriba a la izquierda | `config.json` → `bar.topLeftIcon` |
| Wallpapers | `Super + Alt + W`: wallpaper aleatorio de `~/Imágenes/Wallpapers/SAO` + paleta regenerada | `~/.config/hypr/custom/keybinds.lua` |
| Prompt | `◢ FLOOR ~/dir ◇ QUEST rama · LINK TIME 3s` / `▸` (rojo si falla) | `~/.config/starship.toml` |
| fastfetch | Logo de Sinon en texto (chafa) + panel PLAYER / WORLD / HP… | `~/.config/fastfetch/` |
| fastfetch al abrir | Primera terminal de cada sesión | `~/.config/fish/conf.d/sao-fastfetch.fish` |
| btop / cava | Temas SAO con fondo transparente | `~/.config/btop/themes/sao.theme`, `~/.config/cava/` |

### Animación SAO compartida

`SaoUnfold.qml`: una línea cian se extiende horizontalmente desde el centro y luego
el panel se despliega verticalmente con un pequeño rebote. La usan el bloqueo y el
menú de sesión. `SaoHudFrame.qml` es el panel con esquinas cian/magenta.

---

## Configurar el bloqueo y el menú de sesión

En `~/.config/illogical-impulse/config.json` (quickshell lo recarga al guardar):

```jsonc
"sao": {
  "enable": true,                 // false = bloqueo y menú originales de end-4
  "lock": {
    "showCharacter": true,
    "imagesFolder": "",           // vacío = ~/Imágenes/SAO/lock
    "rotateInterval": 20,         // segundos entre imágenes (0 = fija)
    "shuffle": true,
    "backgroundImage": "",        // vacío = wallpaper actual; con ruta se muestra un reloj propio
    "title": "LINK DISCONNECTED",
    "subtitle": "Cardinal System · sesión en espera"
  },
  "session": {
    "title": "SYSTEM MENU",
    "message": "¿Qué deseas hacer, jugador?"
  }
}
```

- **Imágenes del personaje:** copia `png/jpg/webp` a `~/Imágenes/SAO/lock/`. Mejor con
  fondo transparente. Se leen al bloquear; no hace falta reiniciar nada.
- Las rutas aceptan `~/`.

## Configurar el resto

- **Logo de fastfetch con otra imagen:**
  `~/.config/fastfetch/tools/make-logo.sh imagen.png ~/.config/fastfetch/sinon.ans 46 24`
  (si cambias el tamaño, ajusta `width`/`height` en `config.jsonc`).
- **fastfetch en todas las terminales:** `set -U sao_fastfetch_always 1`
  · **desactivarlo:** `set -U sao_fastfetch_off 1`
- **Borde que gira:** consume algo de GPU/batería. Para pararlo pon `enabled = false`
  en el bloque `borderangle` de `custom/general.lua`.

---

## Cómo sobrevive a las actualizaciones

El instalador de end-4 (`./setup install`) trata los archivos de dos formas:

| Tipo | Ejemplos | Qué pasa al actualizar |
|---|---|---|
| **Sincronizados** (se sobrescriben) | `quickshell/`, `starship.toml`, `matugen/`, `hypr/hyprland/`, `hyprland.lua` | Se reemplazan por los de `dots/` del repo desde el que instales |
| **Del usuario** (no se tocan) | `hypr/custom/` (si ya existe), `fish/conf.d/`, `btop/`, `cava/`, `fastfetch/`, `illogical-impulse/config.json` | Se conservan |

Por eso:

- Los archivos de end-4 modificados están **en `dots/` de este fork** (rama
  `sao-cardinal-theme`). Mientras instales desde este fork, se mantienen.
- Los archivos propios están **copiados en `dots-extra/sao/files/`** como respaldo
  versionado, y `install.sh` los restaura.

### Archivos de end-4 modificados (posibles conflictos al fusionar)

| Archivo | Cambio |
|---|---|
| `quickshell/ii/modules/common/Config.qml` | Bloque `property JsonObject sao` tras `lock` |
| `quickshell/ii/modules/ii/lock/LockSurface.qml` | `Loader` con `SaoLockOverlay` antes de las barras |
| `quickshell/ii/modules/ii/sessionScreen/SessionScreen.qml` | `SaoUnfold` + `SaoHudFrame`, título y mensaje SAO |
| `quickshell/ii/modules/ii/sessionScreen/SessionActionButton.qml` | Radio circular si `sao.enable` |
| `starship.toml` | Reemplazado por el prompt SAO |

Archivos nuevos (no generan conflictos): `SaoUnfold.qml`, `SaoHudFrame.qml`,
`SaoLockOverlay.qml`, `assets/icons/sao-symbolic.svg`.

### Procedimiento para actualizar

```bash
cd ~/developer-workstation
git checkout sao-cardinal-theme

# 1. Traer los cambios de end-4 (solo la primera vez: añadir el remoto)
git remote add upstream https://github.com/end-4/dots-hyprland.git
git fetch upstream
git merge upstream/main
#    Si hay conflictos, solo pueden estar en los 5 archivos de la tabla anterior:
#    conserva el cambio de end-4 y vuelve a aplicar el bloque SAO descrito.

# 2. Instalar end-4 normalmente
./setup install

# 3. Restaurar/verificar la capa SAO
dots-extra/sao/install.sh          # instala (respalda lo que reemplace)
dots-extra/sao/install.sh --check  # solo verifica; código 1 si algo falta
```

Si algo se rompe tras una actualización, `--check` indica qué archivo falta o
difiere. Si quickshell no arranca, pon `"sao": { "enable": false }` en `config.json`
para volver al comportamiento original mientras se corrige.

### Volver al tema original

1. `"sao": { "enable": false }` en `config.json` (bloqueo y menú originales).
2. Vaciar `~/.config/hypr/custom/general.lua` y quitar la línea SAO de `custom/keybinds.lua`.
3. `rm ~/.config/fish/conf.d/sao-fastfetch.fish`; en `btop.conf` volver a tu tema anterior.
4. `git checkout main -- dots/` y `./setup install` para los archivos de end-4.

Cada `install.sh` deja un respaldo en `~/.config/sao-backup-<fecha>/`.
