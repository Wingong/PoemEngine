import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

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
    property string yun: ""
    property string ju: ""
    property string juind: ""
    property string pz: ""
    property var poem: null
    property var psy: interf.psy
    property string zi_disp: ""
    property int lineSelected : -1
    property int ziSelected : -1
    property var zi_yuns: {
        let ret = []
        for(let yunname of poem["韻目"][root.zi_disp]) {
            ret.push(root.psy[yunname])
        }
        return ret
    }

    function get_zi_pz(zi) {
        let pz_ret = "？"
        for(let yunname of poem["韻目"][zi]) {
            let yun = root.psy[yunname]
            // console.error("韵", yunname, JSON.stringify(yun), poem["韻目"][zi])
            if(pz_ret === "？")
                pz_ret = get_pz(yun);
            else if(pz_ret !== "通" && pz_ret !== get_pz(yun)){
                return "通"
            }
        }
        return pz_ret
    }

    property var ju_list: {
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

            // if (ju.length !== 0)
            //     current = current.replace(ju, "<b>" + ju + "</b>")


            let start = current.indexOf(ju)
            let end = start >= 0 ? start + ju.length : -1

            const line = []
            for (var j=0; j<current.length; j++)
                line.push([current[j], j >= start && j < end ? true : false])


            lines.push(line)
        }

        return lines
    }

    function get_pz(yun) {
        return yun["聲調"][0] === "平" ? "平" : "仄";
    }

    // 自动高度（由 Layout 自动决定）
    contentItem: ColumnLayout {
        id: rootLayout
        width: root.availableWidth
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // 第一部分：标题，居中显示
        Label {
            text: root.author + " 《" + root.title + "》"
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
            // Layout.maximumHeight: 400
            Layout.alignment: Qt.AlignHCenter

            // ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ColumnLayout {
                anchors.fill: parent
                width: 80

                Repeater {
                    model: root.ju_list

                    delegate: Flow {
                        id: lineItem
                        property int lineIndex: index
                        spacing: 0
                        Layout.maximumWidth: root.availableWidth - 10
                        Layout.alignment: Qt.AlignHCenter
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10

                        Repeater {
                            model: modelData

                            delegate: Item {
                                property int i: lineIndex
                                property int j: index
                                implicitWidth: textItem.implicitWidth
                                implicitHeight: textItem.implicitHeight
                                Layout.alignment: Qt.AlignHCenter

                                // Text {
                                //     id: textItem
                                //     anchors.fill: parent
                                //     font.pixelSize: 16
                                //     color: Material.foreground
                                //     horizontalAlignment: Text.AlignHCenter
                                //     text: modelData[0]
                                //     font.bold: modelData[1]
                                // }

                                PzTextItem {
                                    id: textItem
                                    anchors.fill: parent
                                    fontSize: 16
                                    fontBold: modelData[1]
                                    ju: modelData[0]
                                    pz: get_zi_pz(modelData[0])
                                }

                                Rectangle {
                                    z: -1
                                    color: "#DDDDDD"
                                    anchors.fill: parent
                                    radius: 10
                                    visible: root.lineSelected === i && root.ziSelected === j
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    onClicked:{
                                        const code = modelData[0].codePointAt(0)

                                        if(
                                            (code >= 0x4E00 && code <= 0x9FFF)   || // 基本汉字
                                            (code >= 0x3400 && code <= 0x4DBF)   || // 扩展 A
                                            (code >= 0x20000 && code <= 0x2A6DF) || // 扩展 B
                                            (code >= 0x2A700 && code <= 0x2B73F) || // 扩展 C
                                            (code >= 0x2B740 && code <= 0x2B81F) || // 扩展 D
                                            (code >= 0x2B820 && code <= 0x2CEAF) || // 扩展 E
                                            (code >= 0x2CEB0 && code <= 0x2EBEF) || // 扩展 F
                                            (code >= 0x30000 && code <= 0x3134F) || // 扩展 G
                                            (code >= 0xF900 && code <= 0xFAFF)   || // 兼容汉字
                                            (code >= 0x2F00 && code <= 0x2FDF)      // 康熙部首
                                        )
                                            root.zi_disp = modelData[0]
                                        else
                                            root.zi_disp = ""

                                        // interf.searchYunsByZi(modelData[0])

                                        root.lineSelected = i
                                        root.ziSelected = j
                                        console.error("Selected:", i, j)
                                    }
                                }
                            }
                        }
                    }

                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444"
            visible: poem["注釋"] !== ""
        }

        RowLayout {
            Label {
                Component.onCompleted: {console.error("体裁", implicitHeight, implicitWidth) }
                text: /*qsTr("体裁：") +*/ (root.yan !== "-1" ? root.yan : qsTr("杂")) + qsTr("言 ")
                      + root.jushu + qsTr("句 ")
                      + root.ticai
                font.pixelSize: 14
                horizontalAlignment: Text.AlignLeft
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }

            PzTextItem {
                Component.onCompleted: {console.error("韵脚", implicitHeight, implicitWidth) }
                property var yunbu: root.psy[root.yun]
                ju: {
                    if (root.yun === "")
                        return qsTr("无")

                    return yunbu["聲調"] + yunbu["序號"] + yunbu["韻名"]
                }
                pz: {
                    let pz = get_pz(yunbu)
                    let len = ju.length
                    if (len < 3) return pz.repeat(len)
                    return pz.repeat(2) + "平".repeat(len - 3) + pz
                }

                fontBold: false
                fontSize: 14
                textHorizontalAlignment: Text.AlignHCenter
                verticalMargin: 0
            }

            Label {
                Component.onCompleted: {console.error("出律", implicitHeight, implicitWidth) }
                text: qsTr("出律度") + parseFloat(root.poem["出律度"]).toFixed(2)
                font.pixelSize: 14
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignRight
                Layout.fillWidth: true
                wrapMode: Text.Wrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444"
            visible: poem["注釋"] !== ""
        }

        Label {
            text: qsTr("注释")
            rightPadding: 10
            font.bold: true
            font.pixelSize: 14
            horizontalAlignment: Text.AlignLeft
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            visible: poem["注釋"] !== ""
        }

        ScrollView {
            id: v_note
            ScrollBar.vertical.interactive: true
            Layout.fillHeight: true
            // Layout.maximumHeight: 100
            Layout.alignment: Qt.AlignHCenter
            visible: poem["注釋"] !== ""

            // ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ColumnLayout {
                anchors.fill: parent
                width: 80

                Repeater {
                    model: {
                        return poem["注釋"].split(/\s*;\s*/).filter(str => str.length > 0);
                    }

                    delegate: Text {
                        Layout.maximumWidth: root.availableWidth
                        Layout.alignment: Qt.AlignLeft
                        wrapMode: Text.Wrap
                        font.weight: 14
                        text: "· " + modelData
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444"
            visible: root.zi_disp !== ""
        }

        RowLayout {
            Layout.preferredHeight: 30
            Layout.minimumHeight: yunsFlow.implicitHeight
            visible: root.zi_disp !== ""
            // Layout.preferredHeight: 60
            PzTextItem {
                // DebugOutline {}
                id: item_zi
                // Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                Layout.minimumWidth: implicitWidth
                Layout.maximumWidth: 40
                Layout.preferredWidth: implicitWidth
                Layout.preferredHeight: 30
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                fontSize: 24
                ju: root.zi_disp
                pz: get_zi_pz(root.zi_disp)
                // {
                //     // console.error("QML DEBUG:", "item_zi:", root.zi_disp == "")
                //     return root.zi_disp !== ""
                // }
            }

            Flow {
                // DebugOutline {}
                id: yunsFlow
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                // Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                spacing: 10

                Repeater {
                    model: zi_yuns
                    delegate: Item {
                        implicitWidth: yunText.implicitWidth + 10
                        implicitHeight: yunText.implicitHeight + 5
                        // Layout.topMargin: 2
                        // Layout.bottomMargin: 2
                        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                        Text {
                            id: yunText
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 0
                            font.weight: 16
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: {
                                let ret = [modelData["聲調"], modelData["序號"], modelData["韻名"]].join(" ")
                                return ret
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: modelData["聲調"][0] == "平" ? "#D0D6D8" :"#DDC8B0"
                            z: -1
                            radius: 10
                        }
                    }
                }
            }
        }
    }
}
