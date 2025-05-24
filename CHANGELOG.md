# 更新日志、知识点和踩坑记录

## v0.0

### 预计任务
- 移植 python 版诗词、平仄检索工具。
- 制作字词的声、韵、平仄查询。

### 吹牛
- 折腾了大半天，终于能在手机上安装运行了，可喜可贺。正事拖着了。


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
