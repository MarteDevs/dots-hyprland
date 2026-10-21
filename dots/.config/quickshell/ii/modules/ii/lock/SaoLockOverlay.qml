import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

// SAO: capa del bloqueo de pantalla. Todo se configura en config.json -> sao.lock
//   imagesFolder     carpeta con imágenes del personaje (rota entre ellas)
//   backgroundImage  fondo propio para el bloqueo (vacío = wallpaper actual)
//   rotateInterval   segundos entre imágenes, shuffle para orden aleatorio
//   title/subtitle   textos del panel superior
Item {
    id: root
    anchors.fill: parent

    readonly property var cfg: Config.options.sao.lock
    readonly property color cyan: "#0097b8"
    readonly property color magenta: "#d61f8f"
    property bool shown: false

    function expandPath(p) {
        if (!p || p.length === 0) return "";
        if (p.startsWith("~/")) return FileUtils.trimFileProtocol(Directories.home) + p.slice(1);
        return FileUtils.trimFileProtocol(p);
    }
    readonly property string imagesFolder: expandPath(cfg.imagesFolder) || `${FileUtils.trimFileProtocol(Directories.pictures)}/SAO/lock`
    readonly property string backgroundPath: expandPath(cfg.backgroundImage)

    // Arranca la animación cuando la superficie ya es visible (si no, ocurre mientras carga)
    Timer { interval: 220; running: true; onTriggered: root.shown = true }

    // Fondo opcional (por encima del wallpaper, por debajo de todo lo demás)
    Image {
        anchors.fill: parent
        visible: root.backgroundPath.length > 0
        source: visible ? `file://${root.backgroundPath}` : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // Con fondo propio el reloj del wallpaper queda tapado: mostramos uno aquí
    SaoUnfold {
        id: clockUnfold
        visible: root.backgroundPath.length > 0
        shown: root.shown
        delay: 250
        anchors.centerIn: parent
        width: clockColumn.implicitWidth + 80
        height: clockColumn.implicitHeight + 36

        SaoHudFrame {
            width: clockUnfold.width
            height: clockUnfold.height
            ColumnLayout {
                id: clockColumn
                anchors.centerIn: parent
                spacing: 0
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: DateTime.time
                    color: Appearance.colors.colOnLayer1
                    font { pixelSize: 72; weight: Font.Light; family: Appearance.font.family.title }
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: DateTime.longDate
                    color: root.cyan
                    font { pixelSize: Appearance.font.pixelSize.normal; letterSpacing: 2 }
                }
            }
        }
    }

    // Panel superior: título del sistema
    SaoUnfold {
        id: titleUnfold
        shown: root.shown
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: parent.height * 0.06 }
        width: titleRow.implicitWidth + 64
        height: titleRow.implicitHeight + 28

        SaoHudFrame {
            width: titleUnfold.width
            height: titleUnfold.height
            ColumnLayout {
                id: titleRow
                anchors.centerIn: parent
                spacing: 2
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: `◢  ${root.cfg.title}  ◣`
                    color: root.magenta
                    font { pixelSize: Appearance.font.pixelSize.huge; weight: Font.DemiBold; letterSpacing: 3 }
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.cfg.subtitle
                    color: Appearance.colors.colOnLayer1
                    font { pixelSize: Appearance.font.pixelSize.small; letterSpacing: 1 }
                }
            }
        }
    }

    // Imágenes del personaje
    FolderListModel {
        id: images
        folder: `file://${root.imagesFolder}`
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.PNG", "*.JPG", "*.JPEG", "*.WEBP"]
        showDirs: false
        sortField: FolderListModel.Name
        onStatusChanged: if (status === FolderListModel.Ready) root.pickImage()
    }
    property int imageIndex: -1
    function pickImage() {
        if (images.count === 0) { imageIndex = -1; return; }
        if (cfg.shuffle && images.count > 1) {
            let next = imageIndex;
            while (next === imageIndex) next = Math.floor(Math.random() * images.count);
            imageIndex = next;
        } else {
            imageIndex = (imageIndex + 1) % images.count;
        }
    }
    readonly property string currentImage: imageIndex >= 0 ? images.get(imageIndex, "filePath") : ""

    Timer {
        running: root.cfg.rotateInterval > 0 && images.count > 1 && GlobalStates.screenLocked
        interval: Math.max(3, root.cfg.rotateInterval) * 1000
        repeat: true
        onTriggered: swapAnim.restart()
    }

    SaoUnfold {
        id: characterUnfold
        visible: root.cfg.showCharacter && images.count > 0
        shown: root.shown
        delay: 150
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: parent.width * 0.06 }
        width: Math.min(parent.width * 0.26, 440)
        height: Math.min(parent.height * 0.62, 620)

        SaoHudFrame {
            width: characterUnfold.width
            height: characterUnfold.height

            Image {
                id: characterImage
                anchors { fill: parent; margins: 14; bottomMargin: 46 }
                source: root.currentImage ? `file://${root.currentImage}` : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                mipmap: true
                sourceSize.height: height * 2
            }

            SequentialAnimation {
                id: swapAnim
                NumberAnimation { target: characterImage; property: "opacity"; to: 0; duration: 350; easing.type: Easing.InCubic }
                ScriptAction { script: root.pickImage() }
                NumberAnimation { target: characterImage; property: "opacity"; to: 1; duration: 450; easing.type: Easing.OutCubic }
            }

            // Placa con el nombre del jugador
            RowLayout {
                anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 14 }
                spacing: 8
                Rectangle { implicitWidth: 8; implicitHeight: 8; rotation: 45; color: root.cyan }
                StyledText {
                    text: "PLAYER"
                    color: root.cyan
                    font { pixelSize: Appearance.font.pixelSize.smaller; weight: Font.DemiBold; letterSpacing: 2 }
                }
                StyledText {
                    Layout.fillWidth: true
                    text: SystemInfo.username
                    color: Appearance.colors.colOnLayer1
                    elide: Text.ElideRight
                    font { pixelSize: Appearance.font.pixelSize.normal; weight: Font.DemiBold }
                }
            }
        }
    }
}
