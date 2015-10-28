# Beginning Live Rendering

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Live-Rendering/Screenshot/WatchControl.gif)

## 开启实时渲染

iOS 8 开始，Xcode 提供了实时渲染功能，可以在 IB 中实时渲染自定义的 UI 视图，无需运行程序。

要对一个自定义的`UIView`子类开启实时渲染，像下面这样，在类声明前标记`@IBDesignable`属性：

```swift
@IBDesignable
class WatchView: UIView { 
    // ...
}
```

在 IB 的 Identity Inspector 窗格设置好 Class 后，就会如下所示：

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Live-Rendering/Screenshot/UpToDate.png)

Up to date 说明实时渲染已经正常工作了。如果像下图这样提示 Build failed，那么可以点击 Show 按钮显示一些提示信息帮助检查是哪里出了问题。

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Live-Rendering/Screenshot/BuildFailed.png)

有时候需要在实时渲染时提供一些假数据，那么可以实现`prepareForInterfaceBuilder()`方法：

```swift
override func prepareForInterfaceBuilder() {
    // 此方法只会用于编译期的实时渲染，运行期不会调用。可以在这里为实时渲染提供必要的假数据。
}
```

或者，可以使用这个预编译指令：

```swift
#if !TARGET_INTERFACE_BUILDER 
    // 此处的代码只会在运行时执行。
#else 
    // 此处的代码只会用于实时渲染。
#endif
```

## 让类中属性支持实时渲染

在属性声明前标记`@IBInspectable`属性，就可以将该属性暴露给 IB 的 Attributes Inspector：

```swift
@IBInspectable var name: Type = value // 注意一定要加上变量类型，不能使用类型推断。
```

然后就可以在 IB 的 Attributes Inspector 窗格中像设置系统原生控件的属性一样进行设置：

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Live-Rendering/Screenshot/IBInspectable.png)

注意，`@IBInspectable`仅支持这些类型：

Boolean，Number，String，Localized String，Point，Size，Rect，Range，Color，Image 和 Nil。

也就是用户定义运行时属性所支持的类型，可以在 Identity Inspector 窗格中进行查看。
