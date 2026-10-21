-- SAO / Cardinal System
-- Se carga después de hyprland/general.lua y hyprland/colors.lua, así que estos
-- valores tienen prioridad y sobreviven al cambio de wallpaper y a las actualizaciones.
-- Los acentos son de tono medio (cian #0097b8, magenta #d61f8f) para que se vean
-- bien tanto en tema claro como oscuro. El borde inactivo sigue siendo el de matugen.

hl.config({
    general = {
        border_size = 2,
        col = {
            active_border = {
                colors = { "rgba(0097b8ee)", "rgba(d61f8fee)" },
                angle = 45,
            },
        },
    },
    decoration = {
        -- Esquinas algo más rectas, estilo HUD
        rounding = 10,
    },
})

-- Animaciones tipo ventana emergente de SAO: aparece rápido con un pequeño
-- rebote de escala y se cierra encogiéndose.
hl.curve("saoPop", {
    type = "bezier",
    points = {{0.22, 1.25}, {0.36, 1}}
})
hl.curve("saoClose", {
    type = "bezier",
    points = {{0.55, 0}, {0.9, 0.4}}
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 3.2,
    bezier = "saoPop",
    style = "popin 70%"
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 2.2,
    bezier = "saoClose",
    style = "popin 85%"
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 3,
    bezier = "saoPop",
    style = "popin 85%"
})
-- El degradado del borde gira lentamente en la ventana activa
hl.animation({
    leaf = "borderangle",
    enabled = true,
    speed = 60,
    bezier = "linear",
    style = "loop"
})
