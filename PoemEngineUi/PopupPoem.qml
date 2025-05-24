import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: root
    width: 200
    height: 300

    // 数据属性
    property string author: ""
    property string chulv: ""
    property string jushu: ""
    property string yan: ""
    property string title: ""
    property string ticai: ""
    property string ju: ""
    property string juind: ""
    property string pz: ""
    property var poem: null

    // 富文本内容：将 ju 加粗
    property string richContent: {
        const lines = []
        const regex = /[^，。？！；]+[，。？！；]/g
        const matches = poem["內容"].match(regex) || []
        const maxGroup = 5

        let i = 0
        while (i < matches.length) {
            let current = matches[i]
            const endChar = current.slice(-1)

            // Case A: 当前是逗号，下一句不是逗号结尾 → 合并 i 和 i+1
            if (endChar === "，" && i + 1 < matches.length && matches[i + 1].slice(-1) !== "，") {
                current += matches[i + 1]
                i += 2
            }
            // Case B: 连续句非句号结尾，最多合并5句，直到句号
            else {
                let group = current
                let j = i + 1
                while (j < matches.length && j - i < maxGroup && matches[j - 1].slice(-1) !== "。" && matches[j].slice(-1) !== "。") {
                    group += matches[j]
                    j += 1
                }
                // 检查是否最后一句是句号结尾
                if (j < matches.length && matches[j].slice(-1) === "。") {
                    group += matches[j]
                    j += 1
                }
                current = group
                i = j
            }

            lines.push(current)
        }
        let joined = lines.join("<br/>")
        if (ju.length === 0) return joined
        return joined.replace(ju, "<b>" + ju + "</b>")
    }

    // 自动高度（由 Layout 自动决定）
    contentItem: ColumnLayout {
        width: root.availableWidth
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // 第一部分：标题，居中显示
        Text {
            text: author + " 《" + title + "》"
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        ScrollView {
            id: v_poem
            ScrollBar.vertical.interactive: true
            Layout.fillHeight: true
            Layout.maximumHeight: 400
            Layout.alignment: Qt.AlignHCenter

            // ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            // 第二部分：富文本，自动换行，限制宽度
            TextEdit {
                anchors.fill: parent
                readOnly: true
                textFormat: Text.RichText
                text: richContent
                wrapMode: Text.Wrap
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
            }
        }

        RowLayout {
            Text {
                text: qsTr("体裁：") + yan + qsTr("言 ")
                      + jushu + qsTr("句 ")
                      + ticai
                rightPadding: 10
                font.pixelSize: 14
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            Text {
                text: qsTr("　出律度：") + parseFloat(poem["出律度"]).toFixed(2)
                rightPadding: 10
                font.pixelSize: 14
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }


    }
}
