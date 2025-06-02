import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15

Item {
    id: root
    implicitWidth: lower.implicitWidth
    implicitHeight: lower.implicitHeight

    property string ju: "休作狂歌老，回看不住心"
    property string pz: "平仄平平仄？？通通仄平"
    property bool dispPz: true
    property int fontSize: 20
    property bool fontBold: true
    property int textHorizontalAlignment: Text.AlignHCenter
    property int textVerticalAlignment: Text.AlignVCenter
    property int verticalMargin: -2

    property var colors: Material.theme === Material.Light ? {
                            "平": "#3B3838",
                            "仄": "#C55A11",
                            "通": "#5B5858",
                            "？": "#AABBC0",
                        } : {
                            "平": "#D5D8D8",
                            "仄": "#C55A11",
                            "通": "#A5A8A8",
                            "？": "#667780",
                        }

    Text {
        id: lower
        textFormat: Text.RichText
        horizontalAlignment: textHorizontalAlignment
        // verticalAlignment: textVerticalAlignment
        font.pixelSize: root.fontSize
        font.bold: fontBold
        text: {
            if (!root.dispPz)
            {
                return root.ju
            }

            var str = ""
            for (var i = 0; i < root.ju.length; ++i) {
                var c = root.ju.charAt(i)
                var pz_at = root.pz.charAt(i)

                str += "<span style='color:" + (pz_at in root.colors ? colors[pz_at]: colors["？"]) + "'>" + c + "</span>"
            }
            return str
        }
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: (root.height-implicitHeight) / 2 + verticalMargin
    }

    // 上半部分（红）
    Text {
        id: upper
        font.pixelSize: root.fontSize
        horizontalAlignment: textHorizontalAlignment
        // verticalAlignment: textVerticalAlignment
        font.bold: fontBold
        color: "#E57A31"
        clip: true
        height: implicitHeight/2
        text: {
            if (!root.dispPz)
            {
                return ""
            }

            var str = ""
            for (var i = 0; i < root.ju.length; ++i) {
                str += root.pz.charAt(i) === "通" ? root.ju.charAt(i) : "　";
            }
            return str
        }
        anchors.top: parent.top
        anchors.topMargin: (root.height-implicitHeight) / 2 + verticalMargin
    }
}
