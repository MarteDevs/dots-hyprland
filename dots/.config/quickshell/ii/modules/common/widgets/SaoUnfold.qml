import QtQuick

// SAO: animación de apertura de los menús del juego.
// 1) una línea fina se extiende horizontalmente desde el centro,
// 2) el contenido se despliega verticalmente desde esa línea con un pequeño rebote.
// Uso: SaoUnfold { shown: true; delay: 100; MiContenido {} }
Item {
    id: root

    property bool shown: false
    property int delay: 0
    property color lineColor: "#0097b8"
    default property alias content: holder.data

    property real lineProgress: 0
    property real openProgress: 0

    implicitWidth: holder.childrenRect.width
    implicitHeight: holder.childrenRect.height

    onShownChanged: shown ? openAnim.restart() : closeAnim.restart()
    Component.onCompleted: if (shown) openAnim.restart()

    SequentialAnimation {
        id: openAnim
        PauseAnimation { duration: root.delay }
        NumberAnimation { target: root; property: "lineProgress"; to: 1; duration: 180; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "openProgress"; to: 1; duration: 320; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
    }
    SequentialAnimation {
        id: closeAnim
        NumberAnimation { target: root; property: "openProgress"; to: 0; duration: 160; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "lineProgress"; to: 0; duration: 120; easing.type: Easing.InCubic }
    }

    Item {
        id: holder
        anchors.fill: parent
        opacity: Math.min(1, root.openProgress * 1.5)
        transform: Scale {
            origin.x: holder.width / 2
            origin.y: holder.height / 2
            yScale: Math.max(0.001, root.openProgress)
        }
    }

    // Línea de apertura: visible mientras el panel aún no se ha desplegado
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * root.lineProgress
        height: 2
        radius: 1
        color: root.lineColor
        opacity: root.lineProgress * Math.max(0, 1 - root.openProgress)
        visible: opacity > 0
    }
}
