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

                delegate: Rectangle {
                    id: delegateItem
                    width: listView.width
                    height: 80
                    color: mouseArea.pressed ? "#e0e0e0" : "white"

                    // 点击效果
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            popup.contentText = modelData[7]
                            popup.open()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        // 左侧大字体
                        Text {
                            text: modelData[7]
                            font.pixelSize: 24
                            Layout.leftMargin: 10
                            Layout.fillHeight: true
                            verticalAlignment: Text.AlignVCenter
                        }

                        // 右侧上下布局
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 2

                            Text {
                                text: modelData[0]
                                font.pixelSize: 14
                                color: "#666"
                                Layout.alignment: Qt.AlignRight
                            }

                            Text {
                                text: modelData[1]
                                font.pixelSize: 12
                                color: "#999"
                                Layout.alignment: Qt.AlignRight
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

