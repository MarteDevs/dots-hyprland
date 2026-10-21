import qs.modules.common
import qs.modules.common.functions
import QtQuick

// SAO: panel tipo HUD. El fondo sigue el tema (claro/oscuro) y las esquinas usan
// acentos de tono medio que contrastan sobre ambos.
Rectangle {
    id: root

    property color accentA: "#0097b8"   // cian
    property color accentB: "#d61f8f"   // magenta
    property real cornerLength: 18
    property real cornerWidth: 2
    property real backgroundOpacity: 0.78

    radius: 4
    color: ColorUtils.transparentize(Appearance.m3colors.m3surfaceContainerLow, 1 - backgroundOpacity)
    border.width: 1
    border.color: ColorUtils.transparentize(Appearance.m3colors.m3outlineVariant, 0.3)

    component Corner: Item {
        property color c
        property bool flipX: false
        property bool flipY: false
        width: root.cornerLength
        height: root.cornerLength
        Rectangle { color: parent.c; width: parent.width; height: root.cornerWidth; y: parent.flipY ? parent.height - height : 0 }
        Rectangle { color: parent.c; width: root.cornerWidth; height: parent.height; x: parent.flipX ? parent.width - width : 0 }
    }

    Corner { c: root.accentA; anchors { top: parent.top; left: parent.left; margins: -1 } }
    Corner { c: root.accentB; flipX: true; anchors { top: parent.top; right: parent.right; margins: -1 } }
    Corner { c: root.accentB; flipY: true; anchors { bottom: parent.bottom; left: parent.left; margins: -1 } }
    Corner { c: root.accentA; flipX: true; flipY: true; anchors { bottom: parent.bottom; right: parent.right; margins: -1 } }
}
