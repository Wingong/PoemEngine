import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import PoemEngine 1.0

Dialog {
    id: root
    width: 336
    height: 400
    property var appInterf: null
    // spacing: 0
    // title: qsTr("设置")

    property var appTrDict: null
    property var appColDict: null
    // property var  AppSettings: null

    property int numSortFields: 3
    property var sortFieldModels: []

    property var sortOptionsModel: [
        { text: qsTr("诗题"), value: 0 },
        { text: qsTr("作者"), value: 1 },
        { text: qsTr("言数"), value: 2 },
        { text: qsTr("句数"), value: 3 },
        { text: qsTr("体裁"), value: 4 },
        { text: qsTr("韵脚"), value: 4 },
        { text: qsTr("诗句"), value: 7 },
        { text: qsTr("句序"), value: 8 },
        { text: qsTr("平仄"), value: 9 },
    ]

    // 通过 value 查找 index
    function findIndexByValue(index, value) {
        if (index >= sortFieldModels.length) {
            return -1
        }

        let model_i = sortFieldModels[index];
        for (var i = 0; i < model_i.length; ++i) {
            if (model_i[i].value === value) {
                // console.error("QML DEBUG: findIndexByValue: ", value, i)
                return i;
            }
        }
        return -1;
    }

    // 更新排序模型
    function getFilteredModels() {
        if ( AppSettings.sortFields === null) {
             AppSettings.sortFields = []
        }
        for (var i= AppSettings.sortFields.length; i < numSortFields; i ++) {
             AppSettings.sortFields.push({col:-1, asc:true});
        }

        let newModels = []
        let excluded = new Set()
        for (var i=0; i < numSortFields; i ++) {
            newModels.push(sortOptionsModel.filter(item => !excluded.has(item.value)))

            excluded.add( AppSettings.sortFields[i].col )
        }

        return newModels
    }

    // 部件完成
    Component.onCompleted: {
        // console.error(" AppSettings.sortFields: ",  AppSettings.sortFields)

        sortFieldModels = getFilteredModels()

        interf.sort(AppSettings.sortFields)

        let s = ""
        for (var field of AppSettings.sortFields) {
            s += JSON.stringify(field) + ","
        }
        s += "\n"
        for (var mod of sortFieldModels) {
            s += JSON.stringify(mod) + ','
        }
        // console.error(" AppSettings.sortFields: ", s/*, sortOptionsModel, sortFieldModels*/)
    }

    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        // anchors.margins: 16

        // 排序标题
        Label {
            text: qsTr("排序")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        // 排序控件 ComboBox 和 CheckBox
        RowLayout {
            spacing: 10
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 使用 Repeater 重复 numSortFields 次
            Repeater {
                model: root.numSortFields

                delegate: ColumnLayout {
                    id: dele
                    property int i: index
                    ComboBox {
                        font.pointSize: 14
                        leftPadding: 0
                        rightPadding: 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        textRole: "text"
                        valueRole: "value"
                        model: dele.i < sortFieldModels.length ? sortFieldModels[dele.i] : null
                        currentIndex: findIndexByValue(index, AppSettings.sortFields[index].col)
                        onActivated: {
                            let updated = AppSettings.sortFields.map(item => ({ col: item.col, asc: item.asc }))
                            updated[dele.i]["col"] = currentValue
                            AppSettings.sortFields = updated
                            sortFieldModels = getFilteredModels()
                            interf.sort(updated)
                            console.error("sortFields index: ", dele.i, currentValue, updated[dele.i]["col"], JSON.stringify(updated), JSON.stringify(AppSettings.sortFields[dele.i]))
                        }

                    }

                    CheckBox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: qsTr("升序")
                        font.pixelSize: 16
                        checked: AppSettings.sortFields[dele.i].asc
                        onCheckedChanged: {
                            let updated = AppSettings.sortFields.slice();
                            updated[dele.i].asc = checked
                            AppSettings.sortFields = updated
                            sortFieldModels = getFilteredModels()
                            interf.sort(updated)
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444" // 分隔线颜色
        }

        // 搜索模式
        Label {
            text: qsTr("搜索模式")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        RowLayout{
            Layout.bottomMargin: 10
            ComboBox {
                Layout.fillHeight: true
                id: cbxSearchMode
                model: [qsTr("诗句模式"), qsTr("全诗模式")]
                currentIndex:  AppSettings.searchMode
                onCurrentIndexChanged: {
                    AppSettings.searchMode = currentIndex
                    // Material.theme = currentIndex
                }
            }
            CheckBox {
                Layout.fillHeight: true
                id: optVarSearch
                text: qsTr("繁简、异体通搜")
                checked:  AppSettings.variantSearch
                onCheckedChanged: {
                    AppSettings.variantSearch = checked
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444" // 分隔线颜色
        }


        // 精确搜索标题
        Label {
            text: qsTr("精确搜索")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        // 诗题、诗句、平仄
        RowLayout {
            spacing: 0
            CheckBox {
                id: cbxTitle
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("诗题")
                checked:  AppSettings.strictTitle
                onCheckedChanged:  AppSettings.strictTitle = checked
            }
            CheckBox {
                id: cbxJu
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("诗句")
                checked:  AppSettings.strictJu
                onCheckedChanged:  AppSettings.strictJu = checked
            }
            CheckBox {
                id: cbxPz
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("平仄")
                checked:  AppSettings.strictPz
                onCheckedChanged:  AppSettings.strictPz = checked
            }
        }

        // 作者、体裁
        RowLayout{
            spacing: 0
            CheckBox {
                id: cbxAuthor
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("作者")
                checked:  AppSettings.strictAuthor
                onCheckedChanged:  AppSettings.strictAuthor = checked
            }
            CheckBox {
                id: cbxTicai
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: qsTr("体裁")
                checked:  AppSettings.strictTicai
                onCheckedChanged:  AppSettings.strictTicai = checked
            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Material.theme === Material.Light ? "#ccc" : "#444"
        }

        // 语言和提示
        Label {
            text: qsTr("语言和显示")
            topPadding: 15
            bottomPadding: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 16
        }

        // 示例字
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
                        dispPz:  AppSettings.dispPz
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

        // 其他设置
        RowLayout {
            spacing: 5
            Layout.fillWidth: true
            Layout.bottomMargin: 10

            CheckBox {
                Layout.fillHeight: true
                id: optPz
                text: qsTr("平仄分色")
                checked:  AppSettings.dispPz
                onCheckedChanged:  AppSettings.dispPz = checked
            }
        }


        RowLayout {
            spacing: 5
            Layout.fillWidth: true

            ComboBox {
                Layout.fillHeight: true
                id: languageSelector
                model: [qsTr("简体"), qsTr("繁體")]
                currentIndex: ( AppSettings.languageCode === "zh_CN") ? 0 : 1
                onCurrentIndexChanged: {
                    if(currentIndex === 0)
                    {
                        AppSettings.languageCode = "zh_CN"
                        appInterf.setLanguage("zh_CN")
                    }
                    else
                    {
                        AppSettings.languageCode = "zh_MO"
                        appInterf.setLanguage("zh_MO")
                    }
                }
            }

            ComboBox {
                Layout.fillHeight: true
                id: themeSelector
                model: [qsTr("浅色"), qsTr("暗色"), qsTr("跟随系统")]
                currentIndex:  AppSettings.theme
                onCurrentIndexChanged: {
                    AppSettings.theme = currentIndex
                    Material.theme = currentIndex
                }
            }
        }
    }
}
