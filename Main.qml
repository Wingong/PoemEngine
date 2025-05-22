import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: root
    width: 480
    height: 640
    title: qsTr("诗句检索")

    visible: true
    Component.onCompleted: QtQuickControls2.style = "Material" // 设置全局样式为 Material

    // ToolBar {
    //     id: toolBar
    //     anchors.right: parent.right
    //     anchors.left: parent.left
    //     contentHeight: toolButton.implicitHeight

    //     ToolButton {
    //         id: toolButton
    //         text: stackView.depth > 1 ? "\u25C0" : "\u2630"
    //         font:  Constants.largeFont
    //         onClicked: {
    //             if (stackView.depth > 1) {
    //                 stackView.pop()
    //             } else {
    //                 drawer.open()
    //             }
    //         }
    //     }

    //     Label {
    //         text: stackView.currentItem.title
    //         anchors.centerIn: parent
    //     }
    // }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "詩題"
            }

            TextField {
                id: inputTitle
                padding: 4
                Layout.fillWidth: true
                placeholderText: "詩題..."
                Layout.preferredHeight: 32

            }

            Label {
                text: "言數"
            }

            TextField {
                id: inputYan
                padding: 4
                placeholderText: "示例: 5"
                Layout.preferredHeight: 32
                Layout.preferredWidth: 60
            }

            Label {
                text: "句數"
            }

            TextField {
                id: inputJushu
                padding: 4
                placeholderText: "示例: 8"
                Layout.preferredHeight: 32
                Layout.preferredWidth: 60

            }
        }
        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "作者"
            }

            TextField {
                id: inputAuthor
                padding: 4
                Layout.fillWidth: true
                placeholderText: "作者..."
                Layout.preferredHeight: 32

            }

            Label {
                text: "體裁"
            }

            TextField {
                id: inputTicai
                padding: 4
                placeholderText: "(律詩)"
                Layout.preferredHeight: 32
                Layout.preferredWidth: 60

            }

            Label {
                text: "句序"
            }

            TextField {
                id: inputJuind
                padding: 4
                placeholderText: "示例: 1"
                Layout.preferredHeight: 32
                Layout.preferredWidth: 60

            }

        }

        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: "詩句"
            }

            TextField {
                id: inputJu
                padding: 4
                Layout.fillWidth: true
                placeholderText: "輸入詩句..."
                Layout.preferredHeight: 32

            }

            Label {
                text: "平仄"
            }

            TextField {
                id: inputPz
                padding: 4
                Layout.fillWidth: true
                placeholderText: "輸入平仄格式..."
                Layout.preferredHeight: 32

            }

            Button {
                text: "🔍"
                onClicked: {
                    // 调用 C++ 搜索逻辑
                    interf.onQuery(inputJu.text,
                                 inputPz.text,
                                 inputTitle.text,
                                 inputAuthor.text,
                                 inputYan.text,
                                 inputJushu.text,
                                 inputTicai.text,
                                 inputJuind.text)
                    // poemManager.query(searchInput.text)
                }
                Layout.preferredHeight: 32
            }
        }

        // 模式 + 选项区
        // ColumnLayout {
        //     spacing: 6

        //     RowLayout {
        //         Label { text: "查詢模式：" }
        //         ComboBox {
        //             id: modeSelect
        //             model: ["全部", "詩句", "平仄"]
        //             Layout.preferredHeight: 32
        //         }
        //     }

        //     ColumnLayout {
        //         CheckBox { id: opt2; text: "簡繁、異體轉換"; checked: true }
        //     }
        // }

        // 滚动视图区域
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn  // 确保始终显示滚动条

            ListView {
                id: listView
                anchors.fill: parent
                model: interf.model
                spacing: 2
                clip: true

                delegate: Rectangle {
                    property string col7str: model.col7
                    property string col9str: model.col9
                    id: delegateItem
                    width: listView.width
                    height: 60
                    color: mouseArea.pressed ? "#e0e0e0" : "white"

                    // 点击效果
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            popup.author = model.col0
                            popup.content = model.col1
                            popup.chulv = model.col2
                            popup.jushu = model.col3
                            popup.yan = model.col4
                            popup.title = model.col5
                            popup.ticai = model.col6
                            popup.ju = model.col7
                            popup.juind = model.col8
                            popup.pz = model.col9
                            popup.open()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        // 左侧大字体
                        Text {
                            textFormat: Text.RichText
                            font.pixelSize: 20
                            font.bold: true
                            text: {
                                var str = ""
                                for (var i = 0; i < model.col7.length; ++i) {
                                    var c = model.col7.charAt(i)
                                    var color = model.col9.charAt(i) === "仄" ? "#C55A11" : "#3B3838"
                                    str += "<span style='color:" + color + "'>" + c + "</span>"
                                }
                                return str
                            }
                            Layout.fillHeight: true
                            Layout.preferredWidth: 140
                            verticalAlignment: Text.AlignVCenter
                        }

                        // Text {
                            // text: model.col7
                            // font.pixelSize: 20
                            // font.bold: true
                            // Layout.leftMargin: 10
                            // Layout.fillHeight: true
                            // Layout.preferredWidth: 140
                            // verticalAlignment: Text.AlignVCenter
                        // }

                        // 右侧上下布局
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    text: model.col0 + " 《" + model.col5 + "》"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#444444"
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillHeight: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    text: "體裁：" + model.col6
                                    font.pixelSize: 14
                                    color: "#444444"
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.preferredWidth: 80
                                    Layout.fillHeight: true
                                }
                                Text {
                                    text: "第" + model.col8 + "句"
                                    font.pixelSize: 14
                                    color: "#444444"
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                }
                            }
                        }
                    }

                    // 分割线
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: "#eee"
                        anchors.bottom: parent.bottom
                    }
                }
            }
        }
        // TableView {
        //     id: tableView
        //     Layout.fillWidth: true
        //     Layout.fillHeight: true
        //     // selectionBehavior: TableView.SelectRows
        //     // selectionMode: TableView.SingleSelection
        //     // horizontalScrollBarPolicy: ScrollBar.AlwaysOff
        //     // ScrollBar.horizontal.policy: ScrollBar.AlwaysOff  // 禁用水平滚动
        //     // ScrollBar.vertical.policy: ScrollBar.AlwaysOn     // 始终显示垂直滚动条
        //     // 自动列宽配置
        //     // columnWidthProvider: function(column) {
        //     //     return width / columnCount;
        //     // }
        //     delegate: Rectangle {
        //         required property bool selected
        //         // implicitWidth: 150
        //         // implicitWidth: textItem.implicitWidth + 20
        //         implicitHeight: 30
        //         border.width: 0.5
        //         border.color: "#bbbbbb"
        //         color: "transparent"

        //         Text {
        //             text: display
        //             anchors.centerIn: parent
        //         }
        //     }

        //     columnWidthProvider: function(column) {
        //         switch(column)
        //         {
        //         case 0:
        //             return 120;
        //         case 1:
        //             return 200;
        //         case 2:
        //             return 80;
        //         }
        //     }

        //     model: interf.model
        // }
        // 查询结果展示区
        // ScrollView {
        //     Layout.fillWidth: true
        //     Layout.fillHeight: true
        //     ScrollBar.horizontal.policy: ScrollBar.AlwaysOff  // 禁用水平滚动
        //     ScrollBar.vertical.policy: ScrollBar.AlwaysOn     // 始终显示垂直滚动条

        //     Rectangle {
        //         id: resultArea
        //         width: parent.width

        //         Column {
        //             spacing: 12
        //             Repeater {
        //                 model: resultModel
        //                 delegate: Rectangle {
        //                     width: parent.width
        //                     height: 100
        //                     radius: 8
        //                     color: "#ffffff"
        //                     border.color: "#cccccc"
        //                     border.width: 1

        //                     Text {
        //                         text: model.character + " - " + model.reading
        //                         font.pointSize: 16
        //                     }
        //                 }
        //             }
        //         }
        //     }
        // }

        // 进度条与状态标签
        RowLayout {
            Layout.fillWidth: true
            visible: bar.visible

            // ProgressBar {
            //     id: bar
            //     Layout.fillWidth: true
            //     value: 0.0
            // }

            Label {
                id: lab
                text: interf.labText
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    Popup {
        id: popup
        modal: true
        focus: true

        width: parent.width * 4 / 5
        anchors.centerIn: Overlay.overlay  // ✅ 始终居中

        // 数据属性
        property string author: ""
        property string content: ""
        property string chulv: ""
        property string jushu: ""
        property string yan: ""
        property string title: ""
        property string ticai: ""
        property string ju: ""
        property string juind: ""
        property string pz: ""

        // 富文本内容：将 ju 加粗
        property string richContent: {
            const lines = []
            const regex = /[^，。？！；]+[，。？！；]/g
            const matches = popup.content.match(regex) || []
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
            if (popup.ju.length === 0) return joined
            return joined.replace(popup.ju, "<b>" + popup.ju + "</b>")
            // return popup.content
        }

        // 自动高度（由 Layout 自动决定）
        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // 第一部分：标题，居中显示
            Text {
                text: popup.author + " 《" + popup.title + "》"
                font.pixelSize: 14
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: popup.width - 32
                wrapMode: Text.Wrap
            }

            // 第二部分：富文本，自动换行，限制宽度
            Text {
                textFormat: Text.RichText
                text: popup.richContent
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.Wrap
                font.pixelSize: 16
                Layout.preferredWidth: popup.width - 32
            }
        }
    }

    // Drawer {
    //     id: drawer
    //     width: root.width * 0.33
    //     height: root.height

    //     Column {
    //         anchors.fill: parent

    //         ItemDelegate {
    //             text: qsTr("Page 1")
    //             width: parent.width
    //             onClicked: {
    //                 stackView.push("Screen01.ui.qml")
    //                 drawer.close()
    //             }
    //         }
    //         ItemDelegate {
    //             text: qsTr("Page 2")
    //             width: parent.width
    //             onClicked: {
    //                 stackView.push("Screen02.ui.qml")
    //                 drawer.close()
    //             }
    //         }
    //     }
    // }
}

