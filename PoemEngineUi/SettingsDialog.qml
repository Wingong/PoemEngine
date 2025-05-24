import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings

Dialog {
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
            if (sortOptionsModel.get(i).value === value)
                return i;
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
        console.error(newModel, comboBox.currentText, comboBox.currentValue, values)
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
        ListElement { text: qsTr("诗句"); value: 2 }
        ListElement { text: qsTr("平仄"); value: 7 }
        ListElement { text: qsTr("诗题"); value: 0 }
        ListElement { text: qsTr("作者"); value: 1 }
        ListElement { text: qsTr("言数"); value: 3 }
        ListElement { text: qsTr("句数"); value: 4 }
        ListElement { text: qsTr("体裁"); value: 5 }
        ListElement { text: qsTr("句序"); value: 6 }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        // anchors.margins: 16

        Text {
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

                        appInterf.sort([comboBox1.currentValue, comboBox2.currentValue, comboBox3.currentValue],
                                    [appSettings.asc1, appSettings.asc2, appSettings.asc3])
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#cccccc" // 分隔线颜色
        }

        Text {
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
                id: cbx_title
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: appTrDict["诗题"]
                checked: appSettings.strict_title
                onCheckedChanged: appSettings.strict_title = checked
            }
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
            color: "#cccccc" // 分隔线颜色
        }

        Text {
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
            Layout.bottomMargin: 10
            spacing: 0
            ColumnLayout {
                spacing: 0
                Text { width: 16; height: 20;text: "休"; color: "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter; id: t0}
                Text { width: 14;text: "平"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { width: 16; height: 20;text: "作"; color: appSettings.disp_pz ? "#C55A11" : "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter; id: t1}
                Text { width: 14;text: "仄"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t2; width: 16; height: 20;text: "狂"; color: "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "平"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t3; width: 16; height: 20;text: "歌"; color: "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "平"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t4; width: 16; height: 20;text: "老"; color: appSettings.disp_pz ? "#C55A11" : "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "仄"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { width: 16; height: 20;text: ","; color: "#666"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "　"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t5; width: 16; height: 20;text: "迴"; color: appSettings.disp_pz ? "#6666AA" : "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "？"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t6; width: 16; height: 20;text: "看"; color: appSettings.disp_pz ? "#6666AA" : "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "通"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t7; width: 16; height: 20;text: "不"; color: appSettings.disp_pz ? "#6666AA" : "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "通"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t8; width: 16; height: 20;text: "住"; color: appSettings.disp_pz ? "#C55A11" : "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "仄"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
            }
            ColumnLayout {
                spacing: 0
                Text { id: t9; width: 16; height: 20;text: "心"; color: "#3B3838"; font.pixelSize: 22; font.bold: true; horizontalAlignment: Text.AlignHCenter}
                Text { width: 14;text: "平"; color: "#666"; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; Layout.alignment: Qt.AlignHCenter}
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

        // CheckBox {
        //     Layout.fillHeight: true
        //     id: darkMode
        //     text: qsTr("启用深色模式")
        //     checked: false
        // }
    }
}
