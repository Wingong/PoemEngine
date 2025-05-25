import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.settings


Window {
    id: root
    width: 480
    height: 640

    property int text_default_height: 32

    Material.theme: Material.System
    Material.accent: Material.LightBlue

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

    Settings {
        id: settings
        category: "UserPreferences"
        property string languageCode    : ""
        property int    theme           : 0
        property bool   strict_ju       : false
        property bool   strict_pz       : false
        property bool   strict_title    : true
        property bool   strict_author   : true
        property bool   strict_ticai    : true
        property int    sort1           : 3
        property bool   asc1            : true
        property int    sort2           : 2
        property bool   asc2            : true
        property int    sort3           : 7
        property bool   asc3            : true
        property bool   disp_pz         : true
        property bool   general_search  : true
        // property
    }

    Component.onCompleted: {
        console.error(settings.languageCode)
        interf.setLanguage(settings.languageCode)
    }

    Connections {
        target: interf
        onPoemResultReceived: (poem) => {
            popup_Poem.poem  = poem
            popup_Poem.open()
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

            }

            Button {
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
                                 [settings.strict_ju,
                                 settings.strict_pz,
                                 false,
                                 settings.strict_author,
                                 false,
                                 false,
                                 settings.strict_ticai,
                                 false])
                    // poemManager.query(searchInput.text)
                }
                // Layout.preferredWidth: 60
            }
        }

        // 模式 + 选项区
        // ColumnLayout {
        //     spacing: 6

        //     RowLayout {
        //         Label { text: qsTr("查询模式") }
        //         ComboBox {
        //             id: modeSelect
        //             model: [qsTr("全部"), trDict["诗句"], trDict["平仄"]]
        //             Layout.preferredHeight: root.text_default_height
        //         }
        //     }

        //     ColumnLayout {
        //         CheckBox { id: opt2; text: qsTr("繁简、异体转换"); checked: true }
        //     }
        // }


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
                    color: mouseArea.pressed ? "#e0e0e0" : "white"

                    // 点击效果
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            interf.searchById(model.col8)
                            popup_Poem.title    = model.col0
                            popup_Poem.author   = model.col1
                            popup_Poem.ju       = model.col2
                            popup_Poem.yan      = model.col3
                            popup_Poem.jushu    = model.col4
                            popup_Poem.ticai    = model.col5
                            popup_Poem.juind    = model.col6
                            popup_Poem.pz       = model.col7
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 10

                        // 左侧大字体
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 140

                            Text {
                                textFormat: Text.RichText
                                font.pixelSize: 20
                                font.bold: true
                                text: {
                                    if (!settings.disp_pz)
                                    {
                                        return model.col2
                                    }

                                    var str = ""
                                    for (var i = 0; i < model.col2.length; ++i) {
                                        var c = model.col2.charAt(i)
                                        var color = model.col7.charAt(i) === "仄"
                                                ? "#C55A11"
                                                : (model.col7.charAt(i) === "？"
                                                   ? "#AAAAAA"
                                                   : (model.col7.charAt(i) === "通"
                                                      ? "#6666AA"
                                                      : "#3B3838")
                                                   )
                                        str += "<span style='color:" + color + "'>" + c + "</span>"
                                    }
                                    return str
                                }
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            // 上半部分（红）
                            Text {
                                font.pixelSize: 20
                                font.bold: true
                                color: "#C55A11"
                                clip: true
                                height: 15
                                text: {
                                    if (!settings.disp_pz)
                                    {
                                        return ""
                                    }

                                    var str = ""
                                    for (var i = 0; i < model.col2.length; ++i) {
                                        str += model.col7.charAt(i) === "通" ? model.col2.charAt(i) : "　";
                                    }
                                    return str
                                }
                                // anchors.top: {console.error(parent.top); return parent.top;}
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        // Text {
                        //     textFormat: Text.RichText
                        //     font.pixelSize: 20
                        //     font.bold: true
                        //     text: {
                        //         if (!settings.disp_pz)
                        //         {
                        //             return model.col2
                        //         }

                        //         var str = ""
                        //         for (var i = 0; i < model.col2.length; ++i) {
                        //             var c = model.col2.charAt(i)
                        //             var color = model.col7.charAt(i) === "仄"
                        //                     ? "#C55A11"
                        //                     : (model.col7.charAt(i) === "平"
                        //                        ? "#3B3838"
                        //                        : "#6666AA")
                        //             str += "<span style='color:" + color + "'>" + c + "</span>"
                        //         }
                        //         return str
                        //     }
                        //     // text: listView.c_ju
                        // }

                        // Text {
                            // text: c_ju
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
                                    text: model.col1 + " 《" + model.col0 + "》"
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
                                    text: qsTr("体裁：") + model.col5
                                    font.pixelSize: 14
                                    color: "#444444"
                                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                                    Layout.preferredWidth: 80
                                    Layout.fillHeight: true
                                }
                                Text {
                                    text: "第" + model.col6 + "/" + model.col4 + "句"
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
        height: parent.height / 2
        anchors.centerIn: Overlay.overlay

        appSettings: settings

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

