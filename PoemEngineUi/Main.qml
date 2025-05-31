import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import PoemEngine 1.0


Window {
    id: root
    width: 480
    height: 640

    property int text_default_height: 32

    Material.theme: AppSettings.theme
    Material.accent: Material.LightBlue

    color: Material.background

    visible: true
    title: qsTr("诗句检索")

    // property string c_title : model.col0
    // property string c_author: model.col1
    // property string c_ju    : model.col2
    // property string c_yan   : model.col3
    // property string c_jushu : model.col4
    // property string c_ticai : model.col5
    // property string c_juind : model.col6
    // property string c_pz    : model.col7
    // property string c_id    : model.col8

    property var trDict: {
        "诗句": qsTr("诗句"),
        "平仄": qsTr("平仄"),
        "诗题": qsTr("诗题"),
        "作者": qsTr("作者"),
        "言数": qsTr("言数"),
        "句数": qsTr("句数"),
        "体裁": qsTr("体裁"),
        "句序": qsTr("句序")
    }

    property var colDict: {
        "诗句": 2,
        "平仄": 7,
        "诗题": 0,
        "作者": 1,
        "言数": 3,
        "句数": 4,
        "体裁": 5,
        "句序": 6
    }

    Component.onCompleted: {
        const keys = Object.keys(AppSettings);

        interf.setLanguage(AppSettings.languageCode)
    }

    Connections {
        target: interf
        function onPoemResultReceived(poem) {
            popup_Poem.poem = poem
            popup_Poem.yuns = null
            popup_Poem.zi_disp = ""
            popup_Poem.open()
        }

        function onYunsResultReceived(yuns) {
            popup_Poem.yuns = yuns
            // console.error("QML DEBUG: Yuns: ", yuns)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: trDict["诗题"]
            }

            TextField {
                id: inputTitle
                topPadding: 0
                bottomPadding: 0
                Layout.fillWidth: true
                placeholderText: qsTr("送杜少府之任蜀州")
                Layout.preferredHeight: root.text_default_height
                onAccepted: {
                    btnQuery.click()
                }
            }

            Label {
                text: trDict["言数"]
            }

            TextField {
                id: inputYan
                topPadding: 0
                bottomPadding: 0
                leftPadding: 10
                rightPadding: 10
                placeholderText: "5,7"
                Layout.preferredHeight: root.text_default_height
                Layout.preferredWidth: 60
            }

            Label {
                text: trDict["句数"]
                horizontalAlignment: Text.AlignRight
            }

            TextField {
                id: inputJushu
                topPadding: 0
                bottomPadding: 0
                leftPadding: 10
                rightPadding: 10
                placeholderText: "8-9"
                Layout.preferredHeight: root.text_default_height
                Layout.preferredWidth: 60
                onAccepted: {
                    btnQuery.click()
                }
            }
        }
        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: trDict["作者"]
            }

            TextField {
                id: inputAuthor
                topPadding: 0
                bottomPadding: 0
                Layout.fillWidth: true
                placeholderText: qsTr("白居易")
                Layout.preferredHeight: root.text_default_height
                onAccepted: {
                    btnQuery.click()
                }
            }

            Label {
                text: trDict["体裁"]
            }

            TextField {
                id: inputTicai
                topPadding: 0
                bottomPadding: 0
                leftPadding: 10
                rightPadding: 10
                placeholderText: qsTr("律诗")
                Layout.preferredHeight: root.text_default_height
                Layout.preferredWidth: 60
                onAccepted: {
                    btnQuery.click()
                }
            }

            Label {
                text: trDict["句序"]
            }

            TextField {
                id: inputJuind
                topPadding: 0
                bottomPadding: 0
                leftPadding: 10
                rightPadding: 10
                placeholderText: "1,3,5"
                Layout.preferredHeight: root.text_default_height
                Layout.preferredWidth: 60
                onAccepted: {
                    btnQuery.click()
                }
            }

        }

        // 顶部搜索栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label {
                text: trDict["诗句"]
            }

            TextField {
                id: inputJu
                topPadding: 0
                bottomPadding: 0
                Layout.fillWidth: true
                placeholderText: qsTr("山隨平野盡")
                Layout.preferredHeight: root.text_default_height
                onAccepted: {
                    btnQuery.click()
                }
            }

            Label {
                text: trDict["平仄"]
            }

            TextField {
                id: inputPz
                topPadding: 0
                bottomPadding: 0
                Layout.fillWidth: true
                placeholderText: qsTr("仄平平仄仄")
                Layout.preferredHeight: root.text_default_height
                onAccepted: {
                    btnQuery.click()
                }
            }

            Button {
                id: btnQuery
                flat: true
                text: "🔍"
                font.family: "Noto Emoji"
                font.pixelSize: 23
                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0
                Layout.preferredWidth: root.text_default_height+12
                Layout.preferredHeight: root.text_default_height
                onClicked: {
                    // 调用 C++ 搜索逻辑
                    interf.query([inputJu.text,
                                 inputPz.text,
                                 inputTitle.text,
                                 inputAuthor.text,
                                 inputYan.text,
                                 inputJushu.text,
                                 inputTicai.text,
                                 inputJuind.text],
                                 [AppSettings.strictJu,
                                 AppSettings.strictPz,
                                 AppSettings.strictTitle,
                                 AppSettings.strictAuthor,
                                 false,
                                 false,
                                 AppSettings.strictTicai,
                                 false])
                }
                // Layout.preferredWidth: 60
            }
        }

        // 滚动视图区域
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            // ScrollBar.vertical.policy: ScrollBar.AlwaysOn  // 确保始终显示滚动条            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            ScrollBar.vertical.interactive: true

            ListView {
                id: listView
                anchors.fill: parent
                model: interf.proxyModel
                spacing: 2
                clip: true

                delegate: Rectangle {
                    id: delegateItem
                    width: listView.width
                    height: 60
                    color: mouseArea.pressed ? (Material.theme === Material.Light ? "#e0e0e0" : "#202020") : Material.background

                    // 点击效果
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            interf.searchById(model.id)
                            popup_Poem.title    = model.title
                            popup_Poem.author   = model.author
                            popup_Poem.ju       = model.ju
                            popup_Poem.yan      = model.yan
                            popup_Poem.jushu    = model.jushu
                            popup_Poem.ticai    = model.ticai
                            popup_Poem.juind    = model.juind
                            popup_Poem.pz       = model.pz
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        // 左侧大字体
                        PzTextItem {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 140

                            ju: model.ju
                            pz: model.pz
                            dispPz: AppSettings.dispPz

                        }

                        // 右侧上下布局
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    text: model.author + " 《" + model.title + "》"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: Material.theme === Material.Light ? "#444444" : "#CCCCCC"
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.fillHeight: true
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    text: qsTr("体裁：") + model.ticai
                                    font.pixelSize: 14
                                    color: Material.theme === Material.Light ? "#444444" : "#CCCCCC"
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.preferredWidth: 80
                                    Layout.fillHeight: true
                                }
                                Text {
                                    text: "第" + model.juind + "/" + model.jushu + "句"
                                    font.pixelSize: 14
                                    color: Material.theme === Material.Light ? "#444444" : "#CCCCCC"
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
                        color: Material.theme === Material.Light ? "#eee" : "#222"
                        anchors.bottom: parent.bottom
                    }
                }
            }

        }

        // 进度条与状态标签
        RowLayout {
            Layout.fillWidth: true
            // visible: bar.visible

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

            Item {
                Layout.fillWidth: true
            }

            Button {
                flat: true
                text: "ℹ️"
                font.family: "Noto Emoji"
                font.pixelSize: 23
                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0
                Layout.preferredWidth: root.text_default_height+12
                Layout.preferredHeight: root.text_default_height
                onClicked: {
                    popup_Info.open()
                }
            }

            Button {
                flat: true
                text: "⚙"
                font.family: "Noto Emoji"
                font.pixelSize: 25
                topPadding: 0
                bottomPadding: 0
                leftPadding: 0
                rightPadding: 0
                Layout.preferredWidth: text_default_height+12
                Layout.preferredHeight: text_default_height
                onClicked: {
                    dialog_Settings.open()
                }
            }
        }
    }

    PopupPoem {
        id: popup_Poem
        modal: true
        focus: true

        width: parent.width * 4 / 5
        height: parent.height / 2
        anchors.centerIn: Overlay.overlay  // ✅ 始终居中
    }

    PopupInfo {
        id: popup_Info
        modal: true
        focus: true

        width: root.width * 4 / 5
        anchors.centerIn: Overlay.overlay  // ✅ 始终居中
    }

    SettingsDialog {
        id: dialog_Settings
        modal: true
        focus: true

        appInterf: interf
        appTrDict: trDict
        appColDict: colDict

        width: parent.width * 4 / 5
        height: parent.height * 2 / 3
        anchors.centerIn: Overlay.overlay

        // appSettings: settings

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

