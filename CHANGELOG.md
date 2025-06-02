# 更新日志、知识点和踩坑记录

## v0.0.7 - 实现诗平仄显示、选中字标记

### 更新数据源：平水韵字表、韵部，修复诗歌韵码 bug

#### 更新平水韵字表、韵部文件

- 为 `D:/诗词格律` 创建 `git`。

- 修改平水韵读写方式。现在文件分为`psy-map.json`和`psy-yunbu.json`。

    - 前者将每个字映射到对应韵名，如`"空":"東董送"`。

    - 后者按顺序存放韵名到韵目的映射，如`"東":{"聲調":"平聲","序號":"上一","韻名":"東","韻碼":1}`。

#### 修复诗歌韵码 bug

- 之前上声和入声，同意序号的韵目混淆，如`上声五蟹`和`入声五物`。

- 之前`wasp_psy_local.py`中写：

    ```python
    elif m[6] == '入聲':
        n += 300
    ```

- 现在改成`300`就解决了。

### 接口更新

#### 更改平水韵读写接口

- 现在`psy-yunbu.json`读入`QmlInterface`中，`QML`直接用`interf.psy`读取韵部。

- 子进程、接口和`QML`之间传递的信息不再使用完整韵目。

- 现在这样等于忽视了单字各韵的注释，之后再说。

#### 更改`PoemManager`和`QmlInterface`的接口

- `PoemManager::dataHeader`新增`韵脚`字段，`dataHeaderVar`增加`yun`。

- `searchEnd()`和对应槽函数的参数从`const QMap<QString, QString> &poem`改成`const QVariantMap &poem`。

    - 其中包括`韵脚`和`韵目`字段。

- 删除`searchYunsByZi`相关功能。现在各字韵名都通过`ret["韻目"]`传递到`searchEnd()`的参数中，不再需要二次搜索。

### 界面更新

#### 更新`PzTextItem.qml`文件

- 新增`fontBold`、`textHorizontalAlignment`、`textVerticalAlignment`（未使用）、`verticalMargin`属性。

- 现在支持加粗、水平各方向对齐、垂直偏移等功能。

#### 重整`get_zi_pz()`函数 `PopupPoem.qml`

- 现在输入一个字，输出它对应的平仄。

#### 实现选中字高亮 `PopupPoem.qml`

- 现在使用`lineSelected`、`lineSelected`记录选中字的行、列，实现选中字高亮。

    - 在第一层`delegate`中使用`property int lineIndex: index`记录当前编号（行号）。

    - 在第二层中使用`i: lineIndex`、`j: index`记录行列号。

- 设置`visible`之后，一个字一个矩形也不卡。

- 限制`ScrollView`的左右`margin`宽度。

#### 韵脚显示 `PopupPoem.qml`

- 使用`PzTextItem`显示韵脚。设置其垂直偏置=0（默认为-2），可以有效对齐其他`Label`。

- 单字显示部分成功设置默认高度。

    - 之前如果行数少，这一块就会很高。

    - 应该设置`Flow`的`Layout.preferredHeight: implicitHeight`。

- 微调体裁、出律度文本。

#### 增加一道分界线

### 坑

- [实现选中字高亮](#实现选中字高亮)

    - 外部没有明确定义的属性穿不进来，比如`index`，需要在外层定义一个属性接一下。

- [韵脚显示](#韵脚显示)

    - `Flow`内部的排版设置不管用。最好整体设置整个`Flow`的。
# 吹牛

- 在国图！今天假期最后一天。下周去天津。


## v0.0.6 - 重做设置、排序功能

### 重做设置，用`QSettings`替代`Settings`，设置单例模式

#### 调试设置

- 在`main`函数中设置`setOrganizationName()、setApplicationName`确定项目名称，之后就不用再在设置中指定了。

- 使用`adb`成功进入项目文件夹。

    - 要先开`Debug`模式安装到手机上，再用`adb -s xxx shell`进入`adb`命令行。
    
    - 如果只连接了一个设备，可以不用`-s`。

    - 在命令行中`run-as xxx.xxxx.xxxx`进入文件夹，然后`ls、cd`什么的。

#### `QSettings`和单例模式

- 折腾了两天，老是有问题，`Settings`没法处理列表。最后发现官网上说，`QML`的`Settings`从`Qt 6.5`开始弃用了。tmd，早说啊，我直接用`QSettings`了。

    - 说废弃的：https://doc.qt.io/qt-6/qml-qt-labs-settings-settings.html

    - 刚刚发现，https://doc.qt.io/qt-6/qml-qtcore-settings.html 没废弃，废弃的是`Qt.labs.settings`。不过没`QSettings`好使，不改了。

- 设置单例模式，很方便，在头文件里像下面一样写就行。其他啥操作都不用。

    ```C++
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT
    ```

    - 官网例程：https://doc.qt.io/qt-6/qml-singleton.html

- 使用 GPT 给的宏`#define SETTING_ACCESSOR(TYPE, CATEGORY, NAME, NAMECAP, DEFAULT)`，批量生成设置。好用。

- 现在排序设置叫`sortFields`，是个`[{col: xxx, asc: xxx}, ...]`的结构。

- 设置现在统一采用驼峰命名法。

- `QmlInterface`和`PoemManager`的对应接口进行更改。

### 设置窗口更新排序部分 `SettingsDialog.qml`

- 删除之前的排序`ComboBox`和`CheckBox`，使用`Layout+Delegate`批量生成。

- 设计`getFilteredModels()`方法更新所有`ComboBox`的模型。

    - 现在通过从`index === 0`开始，逐个筛除选中项。

- `Component.onCompleted`中设置初始模型，并排序一次。

- 设计各处读写方法。修改因为驼峰命名法需要变动的名字。

### 坑

- `import Model`和直接使用属性时，报一大堆 Warning 。原因未知，但是首选项 - Qt Quick - QML/JS Editing - QML Language Server 关掉可以不显示。

- 控件可以读父对象`Repeater`的`index`和`modelData`，但`index`可能重名，搞个属性接一下可以避免问题。

### 吹牛

- 端午节！抄了湘夫人。


## v0.0.5 - 大范围更新，添加诗文文字点击、韵部显示，添加平水韵，统一平仄渲染组件，新增主题/查询设置，大幅修改查询逻辑

### 数据源更新

- 重写 `wash_psy.py` 、 `wash_qts.py` 、 `gen_qt_csv.py` 的大量逻辑，加入注释字段，清晰数据源。

- 现在 `psy.json` 中只包括基本文字的韵母，扩展查询使用 `unihan-extend.json` ，其中记录了大量异体字和繁简字。

- 合并了《全唐诗》中 `id` 相同、内容不同的诗文，重新清洗诗句。

- 使用更新的异体、繁简字库，重新匹配平仄声，大范围降低？率。

### 新增平水韵功能

- psy.json，结合unihan查询。

- 新增搜索声韵的系列方法：

    - `QmlInterface::searchById`, `searchYunsByZi`, `onYunsSearched`
    
    - `PoemManager::osSearchYunsByZi`

- 先搜`psy`，再搜异体字，再搜繁简字。

- 这样就可以在`PopupPoem`中正常显示。现在点击诗句中任何一个字，都可以显示平仄、韵部。

### 搜索诗句功能更新

- `PoemManager::onQuery`接口和实现改动。现在支持所有字段模糊/精确搜索和多项搜索。

- 修复之前体裁、作者搜索的问题，之前两者都写是搜索交集，现在改成了并集。`else if(!strict_ticai && !poem[qts_header["體裁"]].contains(ticai))`这一段。

- 现在数据模型中，`RoleName`不再是`col0..col8`，而是对应的`title`、`author`等，增加可读性。

### 封装平仄着色组件 `PzTextItem.qml`

- 使用`Item`包裹两个`Text`。

    - 第一个完整，第二个占上半段，这样显示多音字时，就可以上下分色。

- 替换原来的几个显示功能。

### 诗文显示功能更新 `PopupPoem.qml`

- 现在诗文显示部分使用一个`Repeater`，每行制作一个`Flow`。

    - 每个字是一个`Item`包裹`Text`+`MouseArea`，这样保证分字显示各种信息。

    - 支持单字点击。但是没在每个字下面加个`Rectangle`，加了就很卡。之后试试让他`visible: false`。

- 更改数据结构。现在每行不再是`string`，而是一个`list[list]`，每个字除了文字，还记录了加粗信息。之后还要记录平仄实际上是分字记录了加粗信息。

- 新增注释显示。没啥特殊的。

- 新增单字平仄、韵目显示。

- 注释显示和单字显示的`visible`绑定到对应文本是否为空上。第一次这样操作，好用。

### 其他`Qml`更新

- `Main.qml`，现在每个`TextField`设置了回车搜索功能。老婆提的。

- `SettingsDialog.qml`，新增主题风格切换、诗题精确搜索设置。调整排版。

- 统一替换大量`Text`为`Label`，适应主题切换。

### 学

- `visible`绑定好用。

- 大概整明白了`preferredWidth`、`anchors`等机制，之后用着顺手多了。

- 第一次用`Flow`，好用。现在很熟悉`Repeater`了。

### 接下来

- `PopupPoem`平仄显示；

- 诗自动滚动到加粗句；

- 选中字标记底纹；

- 诗句查询内容加粗；

- 增加诗歌搜索模式；

- 增加空格模糊搜索，或者加号模糊搜索；

- 解决设置排序初始化问题。

### 吹牛

- 这次正事慢步推进，还是这玩意太好玩了。

- 马上端午节。


## v0.0.4 - 写关于文本、修 Bug

### 添加“关于”中的开源声明、功能说明、更新日志文本。
- byd 写一下午。
- 富文本不好用，这玩意换行有问题。还是单个 Text 组合了。

### 增加精确匹配、非精确匹配功能。去除设置中无关选项。
- 不多说了。
- 修改 `PoemManager` 中的方法，现在避免[诗句]、[平仄]、[句序]三项全部匹配失败时，选择所有诗句的Bug。

### 优化界面。
    - 现在关于、诗歌查看界面的ScrollView禁止左右弹簧，只能上下滑动。必须要这样写：
    ```Qml
    ScrollView {
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignHCenter

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label  {
            Layout.fillWidth: true
        }
    ```
    - 现在进度条可以拖了。需要写`ScrollBar.vertical.interactive: true`
- 出律度保留两位小数。忘了这玩意是string了。。。

### 吹牛
- byd 之前 CHANGELOG 写反了，新版本在下面……
- 哎又写一下午，服了……老婆去清华了，干活干活。


## v0.0.3 - 增加设置、翻译等功能

### 增加繁简体支持、Qt本地化
- 这次玩明白了。
    1. 在需要翻译的地方，C++文件用`tr("")`，Qml文件用`qsTr("")`框柱要翻译的内容；
    2. 先用`lupdate`生成 .ts 文件，加入工程中；
    ```CMakeLists
    qt_add_translations(appPoemEngine
        TS_FILES
            translations/zh_CN.ts
            translations/zh_MO.ts
        RESOURCE_PREFIX "/translations"
    )
    ```
    3. 用Qt语言家打开，设置翻译；
    4. 编译的时候会自动编译到工程中，资源路径为`:/{$RESOURCE_PREFIX}/xxx.qm`。

### 增加设置功能
- 完成设置弹窗的大多数功能，显示如同预期，但是折腾了很久。最后用的方法是， SettingsDialog.qml 根节点为`Dialog`，在 Qt Design Studio 中制作时写成`Window`画图，编译的时候改成`Dialog`。
- 玩明白了响应式属性绑定。这种绑定是单向的，绑定对象更新的时候，被绑定对象也会更新，如：
    ```Qml
    // Set.qml
    Dialog {
        property var appSettings: null
        CheckBox {
            checked: appSettings.disp_pz
            onCheckedChanged: appSettings.disp_pz = checked
        }
    }
    // Main.qml
    Window {
        Settings {
            id: settings
            property bool disp_pz : true
        }
        Text {
            text: "123"
            color : settings.disp_pz ? "#666" : "#000"
        }
        Set {
            appSettings: settings
        }
    }
    ```
    - 这样主界面的`settings`是能成功传入子界面的，color也会自动更新，很好用。如果需要反向绑定，就要在比如`onClicked`事件中设置。这种`onSignal`是系统自动生成的，不用额外设计。
- GPT 帮我写了动态设置平仄颜色的函数，好用。现在在设置中点选平仄分色，可以设置主界面平仄是否同色显示。

### 重构数据加载和检索系统，实现排序功能
- 大幅修改各类中诗歌加载、检索、排序的接口。
- 现在诗歌加载时，就把所有诗的内容分块放到`QStandardItemModel`中，而不是每次搜索新建一个模型。
    - 分块（一次1000）是为了避免主界面一次写入过多数据卡顿。
- 筛选、排序功能通过自定义代理类`JuProxyModel`实现，实现`lessThan`和`filterAcceptsRow`方法，具体内容不赘述。代理类暴露给Qml，Qml不访问原模型。
    - 自定义模型要在`main`函数中注册才能暴露给Qml。
- 筛选时，向子线程要求筛选选项，现在分为`values`和`stricts`两个数组，分别代表键和是否精确搜索。
    - 子线程返回符合要求的行号，代理模型直接存入，加速筛选和显示。
    - 这部分还有问题，精确搜索部分尚未成功。
- 排序可以设置三种排序字段和升降序。后面的字段不能选前面的重复值。
    - 有Bug，第三个字段有时候点选会空。

### 诗歌展示界面调整
- 增加体裁、出律度信息。

### 增加平水韵文件
- `:/data/psy.csv`，以后得用。

### 吹牛
- 老婆答辩顺利！特别幸福。我写了假文化人诗。
- 正事没干，要死了。


## v0.0.2 - 重建Qt Quick工程

### 重建工程

- 实际上重建工程，.git 文件夹移动到新工程来。第一次做 Qt Quick 工程，一直在踩坑。

#### 迁移原因：QWidgets 工程在手机上刷新有问题。
- ProgressBar 不动画，窗口就锁住不动，必须切换选择或切 APP 才刷一下。
- 5 月 20 日 17:21:35 创建新工程。似乎自动生成的必须是 CMakeLists.txt 。

#### 坑：创建安卓模板失败。
- 如果用自动创建的模版，工程里显示有 Manifest 了，但实际上没作用。

- 解决：https://doc.qt.io/qtcreator/qtcreator-accelbubble-example.html#lock-device-orientation
    1. 必须手动在 qt_add_executable 下添加 MANUAL_FINALIZATION ，接着
    ```CMakeLists
    set_property(TARGET XXXXX APPEND PROPERTY
            QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
        )
    ```
    - 最后 `qt_finalize_executable(XXXXX)`
    -  `qt_add_executable` 不能添加两个，不然会报错：
        - `main.cpp:1: error: 'QGuiApplication' file not found` 

### 制作 Qml 界面

#### 总说
- 视觉效果在手机上确实比QWidgets好太多了。
- Qml 开头 import XXX 最好制定版本号，比如 2.15。感觉 Layout 还是好用。
- `Component.onCompleted: QtQuickControls2.style = "Material"` 这种语句无效，必须在 C++ 或者 qtquickcontrols2.conf 中设置。
- 在 Layout 中，如果一个设置了 fillWidth ，另一个啥都没写，就会被挤消失。需要设置 preferredWidth 。
- Qml 和外部连接，需要暴露一个 C++ 类给它。 Qml 中可以直接访问暴露类的 `Q_INVOKABLE` 方法和 `Q_PROPERTY` 属性。
- 尝试用 Qt Design Studio 制作 Qml 。这玩意生成的 Qml 必须手动复制到 Qt Quick 工程里……而且它默认的开头是 ApplicationWindow ，但新版 Qt Quick 只支持 Window 。
    - 界面用着倒还行。。。
- 刚开始文本框下方裁剪，上方超高，设啥都没用。最后发现要设`topPadding`和`bottomPadding`。
  
#### 表格
- 最后用的 ScrollView + ListView + 定制 Delegate 的方法。
- Delegate 中，访问 model 的列不现实，实际采用的方法是把 model 所有数据都存在一列里，访问它特定的 Role 。这需要：
    1. 在 C++ 中，用 `setItemRoleNames(QHash<int, QByteArray>)`设置 Role 和 RoleName 的对应关系。
    2. 用 `item->setData(数据, Role)` 添加。
    3. 在表格中用 model.RoleName 访问。 
- 平仄分组显示使用了富文本，并在 text 字段中直接插入函数。
    - text 字段可以用多个字符串加号连接，没试别的。
- 如下：
```Qml
Text {
    textFormat: Text.RichText
    text: {
        var str = ""
        for (var i = 0; i < model.col7.length; ++i) {
            var c = model.col7.charAt(i)
            var color = model.col9.charAt(i) === "仄" ? "#C55A11" : "#3B3838"
            str += "<span style='color:" + color + "'>" + c + "</span>"
        }
        return str
    }
}
```
- 最终显示效果倒还不错。

#### 弹窗
- 弹窗中的属性需要用`property string XXXXX: ""`初始化。假如 id 叫 `popup`，在其他地方，不管内部外部，都用`popup.XXXXX`访问。
- 诗句断行、加粗使用富文本，代码是 GPT 写的，太长不贴了。

### C++ 代码部分

#### QmlInterface
- Qml 和外部连接，需要暴露一个 C++ 类给它。这里创建了一个 `QmlInterface` 类，作为子线程和 Qml 的中转。定义 `Q_INVOKABLE` 方法和 `Q_PROPERTY` 属性。
    1. `Q_PROPERTY`在`Q_OBJECT`之后立刻声明。值不变的就写成`CONSTANT`，不用`NOTIFY`。
    ```C++
    Q_PROPERTY(QString labText READ labText NOTIFY labTextChanged)
    Q_PROPERTY(QStandardItemModel* model READ model CONSTANT)
    ```
    2. 需要回调的函数不用在`pulic slots`里声明，只需要在前面加`Q_INVOKABLE`。

- `model`相关的如[表格](#表格)部分所示。

#### PoemManager
- 数据存储方式：
    - 全唐诗：
    ```C++
    QMap<QString, QStringList> qts;
    QMap<QString, int> qts_header;
    ```
    - 句表：
    ```C++
    QList<QStringList> jubiao;
    QMap<QString, int>jubiao_header;
    QMap<QString, QMap<QString, QList<int>>> to_jubiao;
    ```
    - 看起来手机上跑得比电脑还快……不知道为啥。
- QSet 好用，用 python 的 set 之前还真没想到这个需求。
- QHash 没法转换成`std::unordered_map`，QMap 则可以`toStdMap()`。
- 其他好像没啥太多好说的，有空加个注释。

#### main.cpp
- 现在不用`MainWindow`，在主函数里面设置相关的东西。
    - 必须用`QObject::connect`，因为主函数没有`this`了。其他如常。
- 暴露给 Qml 的代码：
    ```C++
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("interf", interf);
    ```

### 接下来
- 添加繁简转换、排序、平仄显示等设置。
- 完善弹窗功能。
- 句数检索似乎有 bug ，调调。
- 加注释。

### 吹牛
- 老婆周五答辩，周四了。这次确实成就感拉满，但是正事耽误了，天天晚上一点多睡觉。呜呜呜。


## v0.0

### 预计任务
- 移植 python 版诗词、平仄检索工具。
- 制作字词的声、韵、平仄查询。

### 吹牛
- 折腾了大半天，终于能在手机上安装运行了，可喜可贺。正事拖着了。
