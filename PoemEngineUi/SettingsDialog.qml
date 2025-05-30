import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Qt.labs.settings

Dialog {
    id: root
    width: 336
    height: 400
    property var appInterf: null
    // spacing: 0
    // title: qsTr("设置")

    property var appTrDict: null
    property var appColDict: null
    property var appSettings: null

    function findIndexByValue(value) {
        for (var i = 0; i < sortOptionsModel.count; ++i) {
            if (sortOptionsModel.get(i).value === value) {
                console.error("QML DEBUG: findIndexByValue: ", value, i)
                return i;
            }
        }
        return 0;
    }

    function getFilteredModel(excludedValues) {
        var filtered = [];
        for (var i = 0; i < sortOptionsModel.count; ++i) {
            var item = sortOptionsModel.get(i);
            if (excludedValues.indexOf(item.value) === -1) {
                filtered.push({ text: item.text, value: item.value });
            }
        }
        return filtered;
    }

    function updateComboBoxModel(comboBox, values) {
        var newModel = getFilteredModel(values);
        console.error("QML DEBUG:", "updateComboBoxModel:", newModel, comboBox.currentText, comboBox.currentValue, values)
        comboBox.model = newModel

        // 检查当前文本是否仍存在于新模型中
        if (newModel.indexOf(comboBox.currentText) === -1) {
            // 如果不在，则选择第一项
            if (newModel.length > 0) {
                comboBox.currentIndex = 0;
            } else {
                comboBox.currentIndex = -1;  // 空模型时清空选择
            }
        }
    }

    ListModel {
        id: sortOptionsModel
        ListElement { text: qsTr("诗题"); value: 0 }
        ListElement { text: qsTr("作者"); value: 1 }
        ListElement { text: qsTr("诗句"); value: 2 }
        ListElement { text: qsTr("平仄"); value: 7 }
        ListElement { text: qsTr("言数"); value: 3 }
        ListElement { text: qsTr("句数"); value: 4 }
        ListElement { text: qsTr("体裁"); value: 5 }
        ListElement { text: qsTr("句序"); value: 6 }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        // anchors.margins: 16

        Label {
            text: qsTr("排序")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 第1排序项
            ColumnLayout {
                spacing: 5
                Layout.fillWidth: true
                Layout.fillHeight: true

                ComboBox {
                    id: comboBox1
                    font.pointSize: 14
                    leftPadding: 0
                    rightPadding: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textRole: "text"
                    valueRole: "value"
                    model: sortOptionsModel
                    currentIndex: findIndexByValue(appSettings.sort1)

                    onActivated: {
                        updateComboBoxModel(comboBox2, [comboBox1.currentValue]);
                        updateComboBoxModel(comboBox3, [comboBox1.currentValue, comboBox2.currentValue]);

                        appSettings.sort1 = comboBox1.currentValue
                        appSettings.sort2 = comboBox2.currentValue
                        appSettings.sort3 = comboBox3.currentValue

                        console.error("QML DEBUG: comboBox1: sort value: ", comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue)
                        console.error("QML DEBUG: comboBox1: sort text: ", comboBox1.currentText, comboBox2.currentText, comboBox3.currentText)
                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }

                CheckBox {
                    id: checkBox1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("升序")
                    font.pixelSize: 16
                    checked: appSettings.asc1
                    onCheckedChanged: {
                        appSettings.asc1 = checked

                        console.error("QML DEBUG: checkBox1: sort value: ", comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue)
                        console.error("QML DEBUG: checkBox1: sort text: ", comboBox1.currentText, comboBox2.currentText, comboBox3.currentText)
                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }
            }

            // 第2排序项
            ColumnLayout {
                spacing: 5

                ComboBox {
                    id: comboBox2
                    font.pointSize: 14
                    leftPadding: 0
                    rightPadding: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textRole: "text"
                    valueRole: "value"
                    model: getFilteredModel([comboBox1.currentValue])
                    currentIndex: findIndexByValue(appSettings.sort2)

                    onActivated: {
                        updateComboBoxModel(comboBox3, [comboBox1.currentValue, comboBox2.currentValue]);

                        appSettings.sort2 = comboBox2.currentValue
                        appSettings.sort3 = comboBox3.currentValue

                        console.error("QML DEBUG: comboBox2: sort value: ", comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue)
                        console.error("QML DEBUG: comboBox2: sort text: ", comboBox1.currentText, comboBox2.currentText, comboBox3.currentText)
                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }

                CheckBox {
                    id: checkBox2
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("升序")
                    font.pixelSize: 16
                    checked: appSettings.asc2
                    onCheckedChanged: {
                        appSettings.asc2 = checked

                        console.error("QML DEBUG: checkBox2: sort value: ", comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue)
                        console.error("QML DEBUG: checkBox2: sort text: ", comboBox1.currentText, comboBox2.currentText, comboBox3.currentText)
                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }
            }

            // 第3排序项
            ColumnLayout {
                spacing: 5

                ComboBox {
                    id: comboBox3
                    font.pointSize: 14
                    leftPadding: 0
                    rightPadding: 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    textRole: "text"
                    valueRole: "value"
                    model: getFilteredModel([comboBox1.currentValue, comboBox2.currentValue])
                    currentIndex: findIndexByValue(appSettings.sort3)

                    onActivated: {
                        appSettings.sort3 = comboBox3.currentValue

                        console.error("QML DEBUG: comboBox3: sort value: ", comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue)
                        console.error("QML DEBUG: comboBox3: sort text: ", comboBox1.currentText, comboBox2.currentText, comboBox3.currentText)
                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }

                CheckBox {
                    id: checkBox3
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("升序")
                    font.pixelSize: 16
                    checked: appSettings.asc3
                    onCheckedChanged: {
                        appSettings.asc3 = checked

                        console.error("QML DEBUG: checkBox3: sort value: ", comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue)
                        console.error("QML DEBUG: checkBox3: sort text: ", comboBox1.currentText, comboBox2.currentText, comboBox3.currentText)
                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444" // 分隔线颜色
        }

        Label {
            text: qsTr("精确搜索")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        RowLayout {
            spacing: 0
            CheckBox {
                id: cbx_title
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: appTrDict["诗题"]
                checked: appSettings.strict_title
                onCheckedChanged: appSettings.strict_title = checked
            }
            CheckBox {
                id: cbx_ju
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: appTrDict["诗句"]
                checked: appSettings.strict_ju
                onCheckedChanged: appSettings.strict_ju = checked
            }
            CheckBox {
                id: cbx_pz
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: appTrDict["平仄"]
                checked: appSettings.strict_pz
                onCheckedChanged: appSettings.strict_pz = checked
            }
        }

        RowLayout{
            spacing: 0
            CheckBox {
                id: cbx_author
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: appTrDict["作者"]
                checked: appSettings.strict_author
                onCheckedChanged: appSettings.strict_author = checked
            }
            CheckBox {
                id: cbx_ticai
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: appTrDict["体裁"]
                checked: appSettings.strict_ticai
                onCheckedChanged: appSettings.strict_ticai = checked
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444"
        }

        Label {
            text: qsTr("语言和显示")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 0
            spacing: 0

            Repeater
            {
                id: rep
                property string ju: "休作狂歌老,回看不住心"
                property string pz: "平仄平平仄 ？通通仄平"
                model: ju.length

                ColumnLayout {
                    spacing: -10
                    PzTextItem {
                        fontSize: 22
                        ju: rep.ju[index]
                        pz: rep.pz[index]
                        dispPz: appSettings.disp_pz
                    }

                    Label {
                        text: rep.pz[index];
                        color: "#666";
                        font.pixelSize: 14;
                        horizontalAlignment: Text.AlignHCenter;
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            CheckBox {
                Layout.fillHeight: true
                id: optPz
                text: qsTr("平仄分色")
                checked: appSettings.disp_pz
                onCheckedChanged: appSettings.disp_pz = checked
            }

            CheckBox {
                Layout.fillHeight: true
                id: opt2
                text: qsTr("繁简、异体通搜")
                checked: appSettings.general_search
                onCheckedChanged: appSettings.general_search = checked
            }
        }


        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            ComboBox {
                Layout.fillHeight: true
                id: languageSelector
                model: [qsTr("简体"), qsTr("繁體")]
                currentIndex: (appSettings.languageCode === "zh_CN") ? 0 : 1
                onCurrentIndexChanged: {
                    if(currentIndex === 0)
                    {
                        appSettings.languageCode = "zh_CN"
                        appInterf.setLanguage("zh_CN")
                    }
                    else
                    {
                        appSettings.languageCode = "zh_MO"
                        appInterf.setLanguage("zh_MO")
                    }
                }
            }

            ComboBox {
                Layout.fillHeight: true
                id: themeSelector
                model: [qsTr("浅色"), qsTr("暗色"), qsTr("跟随系统")]
                currentIndex: appSettings.theme
                onCurrentIndexChanged: {
                    appSettings.theme = currentIndex
                    Material.theme = currentIndex
                }
            }
        }

        // CheckBox {
        //     Layout.fillHeight: true
        //     id: darkMode
        //     text: qsTr("启用深色模式")
        //     checked: false
        // }
    }
}
