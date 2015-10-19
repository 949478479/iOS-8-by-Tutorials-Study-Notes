# Introducing Presentation Controllers

## UIAlertController

在`iOS 8`之前,使用`UIAlertView`或者`UIActionSheet`来呈现一个弹窗展示一些信息并与用户进行交互.

在`iOS 8`,苹果引入了`UIAlertController`,用来取代上述两个类,相比之下,它有以下优势:

- 选择 alert 风格或 action sheet 风格十分方便,只需传入对应的枚举参数即可.
- API 非常简洁先进,以前使用一堆代理方法,现在可以优雅地使用闭包实现.
- `UIAlertController`是自适应的,在`iPad`设备上弹出一个 action sheet 时,它会自动以 popover 形式呈现.

下面的代码演示了如何在`iPhone`设备上弹出一个 alert:

```swift
let action = UIAlertAction(title: "OK", style: .Default) { _ in
    print("You tapped OK.")
}
let alert = UIAlertController(title: "My Alert", message: "This is an alert.", preferredStyle: .Alert)
alert.addAction(action)
presentViewController(alert, animated: true, completion: nil)
```

如果想使用 action sheet 风格,只需将枚举值`.Alert`换为`.ActionSheet`即可.

这里需要注意,在`iPad`设备上使用时, action sheet 会自动以 popover 形式呈现.这需要设置`sourceView`和`sourceRect`或者`barButtonItem`,否则会引发异常.可以像下面这样设置:

```swift
alert.popoverPresentationController?.sourceView = view
alert.popoverPresentationController?.sourceRect = sender.frame
```

`popoverPresentationController`是`UIPresentationController`的子类.在`iOS 8`中,在幕后都是`UIPresentationController`负责对视图控制器进行呈现.因为只有在`iPad`设备下 action sheet 才会以 popover 呈现,因此其他情况下`popoverPresentationController`属性均为`nil`,配合可选链语法,上述代码可适用所有设备.

## UIPopoverPresentationController

在`iOS 8`中,`UIPopoverController`被弃用,要呈现一个 popover,可以像下面这样.如果使用 IB, segue 选择 popover presentation 即可.

```swift
let myPopoverViewController = /* 要被弹出的视图控制器. */
// 指定呈现风格为 popover.
myPopoverViewController.modalPresentationStyle = .Popover 
// 由于指定为 .Popover 风格,访问 popoverPresentationController 属性将会自动创建 UIPopoverPresentationController.
let popover = myPopoverViewController.popoverPresentationController 
popover?.barButtonItem = /*...*/ 
presentViewController(myPopoverViewController, animated: true, completion: nil)
```

如果是`iPhone`设备,会自动以`UIModalPresentationFullScreen`也就是普通的 modal 形式呈现.但是在`iPhone plus`设备横屏下,则会以`UIModalPresentationPageSheet`形式呈现.后面会介绍如何在`iPhone`设备上以 popover 呈现.

如上所述,在`iPhone`设备下,视图控制器会以 modal 形式展示,而本来作为 popover 的视图控制器是没有导航栏的,这将造成此时没有导航栏按钮提供 dismiss 功能.

解决方法是实现`UIPresentationController`的代理方法,它们在`UIAdaptivePresentationControllerDelegate`协议中声明,可以在这两个方法中修改呈现风格以及被呈现的视图控制器.

```swift
func adaptivePresentationStyleForPresentationController(controller: UIPresentationController,
    traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    // 这样即使是 iPhone plus 横屏下,也会以普通 modal 形式呈现了.
    return .FullScreen
}

func presentationController(controller: UIPresentationController,
    viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
    // 导航栏按钮在 presentedViewController 中自行添加,这里只是演示包装导航栏.
    return UINavigationController(rootViewController: controller.presentedViewController)
}
```

这里有个问题,由于代理方法返回了`.FullScreen`,这将导致在`iPad`设备上也会变为全屏了.

上面的代理方法其实有`8.0`和`8.3`两个版本,文档是`8.0`的,`8.3`只在头文件里:

```swift
public protocol UIAdaptivePresentationControllerDelegate : NSObjectProtocol {
    
    /* For iOS8.0, the only supported adaptive presentation styles are UIModalPresentationFullScreen and UIModalPresentationOverFullScreen. */
    @available(iOS 8.0, *)
    optional public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle
    
    // Returning UIModalPresentationNone will indicate that an adaptation should not happen.
    @available(iOS 8.3, *)
    optional public func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle
    
    /* If this method is not implemented, or returns nil, then the originally presented view controller is used. */
    @available(iOS 8.0, *)
    optional public func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController?
    
    // If there is no adaptation happening and an original style is used UIModalPresentationNone will be passed as an argument.
    @available(iOS 8.3, *)
    optional public func presentationController(presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?)
}
```

对于老版本的`adaptivePresentationStyleForPresentationController(_:)`方法,在`iPad`设备下是不会调用的,但是如果实现此方法并返回`.FullScreen`,在`iPhone plus`设备横屏下将依旧是`UIModalPresentationPageSheet`风格,只有实现`8.3`版本的才可以,但是这又会导致`iPad`设备上也变成全屏的 modal 形式.

这里有个折中的解决方案,就是无论什么设备,都以 popover 形式呈现就好了,这样也不存在导航栏的问题了.非常简单,只实现下面这个代理方法返回`.None`即可:

```swift
func adaptivePresentationStyleForPresentationController(controller: UIPresentationController,
    traitCollection: UITraitCollection) -> UIModalPresentationStyle {
    return .None // 返回 .None 表示不要修改风格.
}
```

如此一来,无论是`iPad`设备还是`iPhone`设备,横屏还是竖屏,都会统一以 popover 形式呈现.
