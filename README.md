# Custom Presentations

- [presentingViewController 和 presentedViewController](#Presented and presenting controllers)
- [UIPresentationController 基本使用](#UIPresentationController Basic)

<a name="Presented and presenting controllers"></a>
## presentingViewController 和 presentedViewController

`presentingViewController`和`presentedViewController`并非新概念,它们在`iOS 5`正式引入,作为`UIViewController`的两个属性.前者表示被呈现的视图控制器, 后者表示持有被呈现的视图控制器的视图控制器.

`iOS 8`新引入了`UIPresentationController`类,它也有上述两个属性,这样操作视图控制器会更为方便,注意该类继承自`NSObject`,而并非`UIViewController`.

下图展示了`presentingViewController`和`presentedViewController`的关系:

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Custom-Presentations/Screenshot/Presented%26PresentingControllers.png)

Presenting 即背后的设置界面的视图控制器, Chrome 是介于`presentingViewController`和`presentedViewController`之间的视图,通常是这种半透明的样子,当然也可以自定义.

<a name="UIPresentationController Basic"></a>
## UIPresentationController 基本使用

通过子类化`UIPresentationController`,可以轻松实现下图这样的效果:

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Custom-Presentations/Screenshot/UIPresentationControllerBasic.png)

#### 核心方法

主要需要实现下面四个方法:

```swift
public func presentationTransitionWillBegin()
public func presentationTransitionDidEnd(completed: Bool)
public func dismissalTransitionWillBegin()
public func dismissalTransitionDidEnd(completed: Bool)
```

首先,通常会在`presentationTransitionWillBegin()`方法中将自定义的视图添加到`UIPresentationController`的`containerView`上.`containerView`是`presentingViewController`和`presentedViewController`的`view`的共同父视图.它不是`UIPresentationController`的`view`,`UIPresentationController`继承自`NSObject`,不是一个视图控制器.

然后利用`presentedViewController`的`transitionCoordinator`为自定义视图添加动画效果,这些动画会和`UIKit`的 presentation 动画一起执行,例如一个 modal 动画.

```swift
override func presentationTransitionWillBegin() {
    // 添加自定义的 dimmingView 到视图层级底层,确保在 presentedViewController 的 view 之下.
    dimmingView.frame = containerView!.bounds
    containerView!.insertSubview(dimmingView, atIndex: 0)

    // 获取 presentedViewController 的 transitionCoordinator, 用于执行自定义视图的动画.
    dimmingView.alpha = 0
    presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ _ in
        self.dimmingView.alpha = 1
    }, completion: nil)
}
```

在 presentation 动画结束后,可以选择在`presentationTransitionDidEnd(_:)`方法中进行一些清理工作.这主要针对手势驱动的 presentation 动画,因为用户可能会中途取消,那么这时候就将自定义视图从视图层级移除.

```swift
override func presentationTransitionDidEnd(completed: Bool) {
    // 如果是手势驱动的,那么用户可能会中途终止,此时 completed 会为 false, 此时应该将自定义视图移除.
    if !completed {
        dimmingView.removeFromSuperview()
    }
}
```

针对 dismissal 过程,需要实现下面这个方法.和 presentation 过程类似,在这里添加对自定义视图的动画.

```swift
override func dismissalTransitionWillBegin() {
    presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ _ in
        self.dimmingView.alpha = 0
    }, completion: nil)
}
```

同样,可以选择在 dismissal 过程结束后进行一些清理工作.

```swift
override func dismissalTransitionDidEnd(completed: Bool) {
    // completed 为 true 表示完全 dismiss 而没有中途取消之类的,移除自定义视图.
    if completed {
        dimmingView.removeFromSuperview()
    }
}
```

如果过渡动画不是手势驱动的,只实现`presentationTransitionWillBegin()`和`dismissalTransitionWillBegin()`就可以了.

#### 布局调整

设备旋转时,`viewWillTransitionToSize(_:withTransitionCoordinator:)`方法就会调用,因为`UIPresentationController`是符合`UIContentContainer`协议的.可以在此方法中对自定义视图进行布局调整,也可以在`containerViewWillLayoutSubviews()`方法中处理,此方法和`UIViewController`的`viewWillLayoutSubviews`类似.

```swift
override func containerViewWillLayoutSubviews() {
    // 设备旋转时,重新调整添加的自定义视图的布局.
    dimmingView.frame = containerView!.bounds
}
```

如果想改变`presentedViewController`的`view`的`frame`,可以实现如下方法.默认情况下该方法会返回`containerView`的`frame`.此方法会多次调用,因此一定要返回同一个`frame`,也不要在此方法中执行一次性任务.

```swift
override func frameOfPresentedViewInContainerView() -> CGRect {
    return /* 返回需要的 frame. */
}
```

还可以通过`overrideTraitCollection`属性来覆盖`presentedViewController`的`traitCollection`,这只会覆盖指定的值,例如通过`init(horizontalSizeClass:)`创建了一个`UITraitCollection`,那么`presentedViewController`的`traitCollection`只会被覆盖掉`horizontalSizeClass`.

#### 其他

可以实现`shouldRemovePresentersView()`方法决定是否移除`presentingViewController`,默认为`false`.对于上图中那种半透明的背景,如果移除了`presentingViewController`,后面就会变成黑色了.

#### 使用方法

使用方法如下:

```swift
let presentedViewController = /* ... */
presentedViewController.modalPresentationStyle = .Custom
presentedViewController.transitioningDelegate = self
presentViewController(presentedViewController, animated: true, completion: nil)
```

代理需符合`UIViewControllerTransitioningDelegate`协议,并在下面的代理方法中返回自定义的`UIPresentationController`:

```swift
func presentationControllerForPresentedViewController(presented: UIViewController,
    presentingViewController presenting: UIViewController,
    sourceViewController source: UIViewController) -> UIPresentationController? {
    return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
}
```

更复杂的用法是配合`UIViewControllerTransitioningDelegate`协议中的其他代理方法,提供实现`UIViewControllerAnimatedTransitioning`协议的动画对象,对动画过程进行自定义,还可支持手势交互.这些是`iOS 7`引入的,和`UIPresentationController`并无直接联系.
