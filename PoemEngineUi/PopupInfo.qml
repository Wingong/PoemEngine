import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Popup {
    id: root
    width: 300
    height: 500


    // 自动高度（由 Layout 自动决定）
    contentItem: ColumnLayout {
        id: rootLayout
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Label  {
            text: qsTr("ⓘ 关于")
            font.pixelSize: 24
            color: Material.accent
            horizontalAlignment: Text.AlignLeft
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            wrapMode: Text.Wrap
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#cccccc" // 分隔线颜色
        }

        //         Label {
        //             text: "输入各项参数，输出《全唐诗》中符合条件的所有诗句。"
        //             wrapMode: Text.Wrap
        //             width: 200
        //         }

        ScrollView {
            Layout.fillHeight: true
            // Layout.preferredWidth: rootLayout.width-10
            Layout.alignment: Qt.AlignHCenter

            // ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                Label  {
                    text: qsTr("诗句检索 v0.0.4")
                    textFormat: Text.RichText
                    font.pixelSize: 20
                    topPadding: 10
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                Label {
                    text: "Drail Ins.  2025.05.24"
                    font.pixelSize: 16
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("开源声明")
                    font.pixelSize: 18
                    font.bold: true
                    topPadding: 20
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 本应用依据 MIT License 许可发布，您可以自由使用、复制、修改和分发本软件，条件是保留原始版权声明和许可声明。")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("· 本应用动态链接 Qt 第三方库，其遵守LGPL v3协议。")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("本应用使用了以下开源组件：")
                    font.pixelSize: 16
                    font.bold: true
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("1. Qt 6.8.1 (LGPL v3)")
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("   https://www.qt.io/")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("   Copyright (C) 2020 The Qt Company Ltd.")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("2. chinese-poetry (MIT License)")
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("   https://github.com/chinese-poetry/chinese-poetry.git")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("   Copyright (C) 2016 JackeyGao")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("3. cc-visualize (MIT License)")
                    font.pixelSize: 14
                    font.bold: true
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("   https://github.com/garywill/cc-visualize.git")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("   Copyright (C) 2023 garywill")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("应用简介")
                    font.pixelSize: 18
                    font.bold: true
                    topPadding: 20
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 本应用可根据诗句、作者、平仄等关键词，快速检索符合条件的诗句，并按平仄声标注。")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("· 数据来源《全唐诗》，共 571568 句。部分数据存在污染、乱码等现象。")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("· 程序按照规则计算一首诗的出律度，自动标注体裁，所以肯定有错漏，见谅。")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("功能说明")
                    font.pixelSize: 18
                    font.bold: true
                    topPadding: 20
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("1. 显示功能")
                    font.pixelSize: 14
                    font.bold: true
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 进行检索后，主界面显示所有符合条件的诗句。左下角显示检索成功数目。")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("· [设置] 中，若为选中[平仄分色]，则否则，平、仄、多声字都显示为黑色。若选中，检索结果中仄声字显示为橙色，平声字显示为黑色，平仄多音字和平仄表以外的字显示为蓝灰色。如：")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    // text: qsTr("<span style='color:C55A11'>去</span>")
                    text: qsTr("<b><span style='color:#C55A11'>去</span><span style='color:#3B3838'>之</span><span style='color:#6666AA'>爲惡</span><span style='color:#C55A11'>草</span></b>")
                    textFormat: Text.RichText
                    font.pixelSize: 20
                    wrapMode: Text.Wrap
                    width: 200
                    topPadding: 0
                    bottomPadding: 5
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                }

                Label {
                    text: qsTr("· 其中，去、草为仄声，之为平声，爲字不在平仄表中，惡为平仄多音字。")
                    textFormat: Text.RichText
                    font.pixelSize: 12
                    leftPadding: 10
                    rightPadding: 10
                    bottomPadding: 5
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("2. 搜索功能")
                    font.pixelSize: 14
                    font.bold: true
                    topPadding: 10
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 输入各项参数，输出《全唐诗》中符合条件的所有诗句。")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 10
                }

                Label {
                    text: qsTr("· 搜索框中，可使用 , 或 - 分隔多个输入项，如：")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    bottomPadding: 5
                }

                Label {
                    text: qsTr("· [诗人] 字段：李白, 杜甫, 白居易")
                    font.pixelSize: 12
                    leftPadding: 10
                    rightPadding: 10
                    bottomPadding: 5
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 或 [句序] 字段：1, 3, 5-9")
                    font.pixelSize: 12
                    leftPadding: 10
                    rightPadding: 10
                    bottomPadding: 15
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 在设置中，可设置精确搜索模式。精确搜索的字段要求待搜索内容和搜索框完全相同，而非精确搜索中，只要字段包含于诗歌中，即可匹配。")
                    font.pixelSize: 14
                    bottomPadding: 5
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 如：精确搜索模式下，[诗句] 字段输入“春風急”无法检索到“仍憐一夜春風急”；")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    topPadding: 0
                    bottomPadding: 5
                    leftPadding: 20
                    rightPadding: 20
                }

                Label {
                    text: qsTr("· 非精确搜索模式下，[诗人] 字段输入“李”可以搜到李白、李贺、李商隐等人的诗。")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    topPadding: 0
                    bottomPadding: 15
                    leftPadding: 20
                    rightPadding: 20
                }

                Label {
                    text: qsTr("· 注意：[平仄] 字段较为特殊，输入内容只能由平、仄、通、？组合。无论是否设置精确搜索，都只匹配与输入字数相同的诗句。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· “通”字可匹配所有声调。若设置精确检索模式，则“平”只匹配平声字；若设置非精确检索模式，“平”可额外检索到平仄多音字。“仄”同理。")
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 如：精确匹配模式下，输入“平平通仄平”，只匹配符合“平平仄仄平”、“平平平仄平”，且长度为5个字的诗句。")
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                    topPadding: 0
                    bottomPadding: 10
                    leftPadding: 20
                    rightPadding: 20
                }

                Label {
                    text: qsTr("3. 排序功能")
                    font.pixelSize: 14
                    font.bold: true
                    topPadding: 10
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 最多能使用三种字段排序。每个字段可在搜索框中任意选择，并且可以设置升序或降序。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 三种字段不能重复选择。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("更新日志")
                    font.pixelSize: 18
                    font.bold: true
                    topPadding: 20
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("v0.0.4 2025.05.24")
                    font.pixelSize: 14
                    font.bold: true
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 添加“关于”中的开源声明、功能说明、更新日志文本。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 增加精确匹配、非精确匹配功能。去除设置中无关选项。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 修复[诗句]、[平仄]、[句序]三项全部匹配失败时，选择所有诗句的Bug。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 优化界面。现在关于、诗歌查看界面只能上下滑动。诗歌查看、检索结果显示可以拖动的进度条。出律度保留两位小数。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("v0.0.3 2025.05.23")
                    font.pixelSize: 14
                    font.bold: true
                    topPadding: 10
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 增加设置页面、关于页面，完成排序、繁简体切换、平仄分色功能。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 增加设置界面中平仄分色的展示功能。现在可实时切换是否平仄分色。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 增加本地化功能，现在界面可实时切换繁、简中文显示。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 重构数据加载和检索系统，优化搜索和排序速度。现在可实时切换排序规则。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 调整诗歌展示界面，现在显示体裁、出律度。增加平水韵数据库。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 修复诸多Bug。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("v0.0.2 2025.05.22")
                    font.pixelSize: 14
                    font.bold: true
                    topPadding: 10
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 使用Qt Quick重建工程。成功在安卓设备中运行。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 完成基本的搜索、诗歌显示、平仄分色显示功能。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("v0.0.1 2025.05.20")
                    font.pixelSize: 14
                    font.bold: true
                    topPadding: 10
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 使用Qt Widget构件界面。成功在安卓设备中运行。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 实现基本的诗句检索功能。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 存在严重Bug，页面无法自动刷新。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("v0.0 2025.05.19")
                    font.pixelSize: 14
                    font.bold: true
                    topPadding: 10
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

                Label {
                    text: qsTr("· 工程初始化，引入全唐诗表、诗句表。")
                    font.pixelSize: 14
                    bottomPadding: 10
                    wrapMode: Text.Wrap
                    Layout.maximumWidth: rootLayout.width - 20
                }

            }
        }
    }
}
