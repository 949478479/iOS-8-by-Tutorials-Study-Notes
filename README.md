<<<<<<< Updated upstream
# Adaptive View Controller Hierarchies

这一章讲解了如何在视图控制器层级中引入自适应布局,以及`UISplitViewController`的使用.

`UISplitViewController`现在支持所有设备,而不仅仅只是`iPad`设备.对于普通`iPhone`设备,无论横竖屏都是`compact width`状态,`detail view controller`会以`modal`或者`push`的方式呈现,而对于`iPhone plus`设备,横屏下将是`regular width`,因此`detail view controller`会像在`iPad`设备设备上一样呈现.

## iPhone 和 iPad 共用 UISplitViewController

例如可以像下图这样:

![]()

在普通`iPhone`设备上,`detail view controller`将会以`push`的方式呈现,而在`iPhone plus`设备横屏状态下,`detail view controller`会像`iPad`设备一样呈现:

![]()
![]()
![]()

可以看到截图中实际上是`iPhone 6s`模拟器而非`plus`,这用到了上篇笔记中提到的修改子控制器的`traitCollection`的方法.首先需要将`splitViewController`添加到一个普通控制器上作为子控制器,如图所示,这里使用了一个`Container View`来实现.

![]()

然后可以通过在该控制器中实现下面的方法来修改`splitViewController`的`traitCollection`:

```swift
override func viewWillTransitionToSize(size: CGSize,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    var traitOverride: UITraitCollection?
    if size.width > 414 {
        traitOverride = UITraitCollection(horizontalSizeClass: .Regular)
    }
    setOverrideTraitCollection(traitOverride, forChildViewController: childViewControllers[0])
}
```

`414`是`iPhone plus`的竖屏宽度,大于该宽度说明所有`iPhone`设备处于横屏状态下,这时候修改`traitCollection`的`horizontalSizeClass`为`regular`,即可让`splitViewController`在所有`iPhone`设备横屏状态下都像`iPad`设备那样呈现`detail view controller`.

在`iPhone`设备上以竖屏状态运行程序,会发现启动后直接就`push`到了`detail view controller`,这是因为`splitViewController`会根据当前`traitCollection`以适当的方式呈现`detail view controller`,由于当前是竖屏,因此`splitViewController`以`push`的方式呈现`detail view controller`.可以通过实现下面这个代理方法改变这种默认行为:

```swift
func splitViewController(splitViewController: UISplitViewController,
    collapseSecondaryViewController secondaryViewController: UIViewController,
    ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    return true
}
```

每当设备由`regular width`转换到`compact width`时,会调用此方法.这意味着`iPad`设备不会调用,因为总是处于`regular width`状态,`iPhone`设备只会一开始调用一次,而`iPhone plus`设备在此基础上每次横屏转换到竖屏时都会调用.

- 如果该方法返回`false`,`splitViewController`会调用`primary view controller`也就是左侧的`master view controller`的`collapseSecondaryViewController(_:forSplitViewController:)`方法,大多数`view controller`默认不会做任何操作,但是`UINavigationController`会对`secondary view controller`也就是右侧的`detail view controller`做`push`操作,也就是说切换到竖屏后右侧的控制器成了左侧导航控制器的`topViewController`.
- 如果该方法返回`true`,则表示已自行处理,`splitViewController`就不会去调用相关方法了.

此方法返回后,`splitViewController`会从`viewControllers`数组中移除`secondary view controller`,只保留`primary view controller`作为唯一的子控制器.

通过实现该代理方法并返回`true`,启动程序后就不会直接`push`到`detail view controller`了.在实际使用中,往往需要进行一些判断后再决定返回值,因为有时候可能想在横屏切换到竖屏后,将原先右侧的内容以导航控制器的`topViewController`呈现.

另外,在`iPhone`设备上竖屏状态下,如果左侧的导航控制器`push`到了一个控制器,例如左侧是个深层级的菜单,这时候切换到横屏状态,那么刚才`push`的控制器会被导航控制器`pop`,而变为右侧的`detail view controller`.如下图所示:

![]()
![]()

这可以利用下面这个代理方法解决.此方法用于在`splitViewController`由`compact width`状态进入`regular width`状态时,提供其右侧的`detail view controller`.和前面的代理方法一样,`iPad`设备不会调用此方法.

如果此方法返回`nil`,`splitViewController`会调用`primary view controller`的`separateSecondaryViewControllerForSplitViewController(_:)`方法.大多数`view controller`默认不做任何操作,但是`UINavigationController`会对`topViewController`做`pop`操作并返回它,也就意味着`splitViewController`会将之前的`topViewController`作为`detail view controller`.

此方法返回后,`splitViewController`会将`secondary view controller`添加到`viewControllers`数组.
        
因此,如果想将左侧导航控制器的`topViewController`作为右侧的`detail view controller`,就可以在此方法中返回`nil`,否则可以另外提供一个控制器.

```swift
func splitViewController(splitViewController: UISplitViewController,
    separateSecondaryViewControllerFromPrimaryViewController
    primaryViewController: UIViewController) -> UIViewController? {
    return nil
}
```

## 显示占位内容

如果`iPhone`设备横屏状态或者`iPad`运行程序,`detail view controller`会直接呈现出来,而这时往往还未提供数据给`detail view controller`呈现,因此其内容一般是空白的.为了更好的用户体验,最好显示一个占位内容.

例如,额外用一个控制器专门显示一些没有数据的提示信息,然后在`detail view controller`的`viewDidLoad()`之类的方法中进行判断,如果当前没有数据,就调用`showDetailViewController(_:sender:)`方法或者执行一个`show detail`的`segue`呈现出来.就像下图这样:

![]()
![]()

## 处理 disclosure indicators 

如下图所示,在横屏状态下,`cell`是不需要箭头标记的,切换到竖屏后,则应显示箭头标记.

![]()
![]()

是否显示箭头标记,意味着点击该`cell`是否会发生`push`操作.这里介绍下`iOS 8`新引入的两个方法:

- showViewController(_:sender:)
- showDetailViewController(_:sender:)

如文档所述,这两个方法主要用来解耦,以及更好地配合`Size Classes`.一个视图控制器不需要知道它当前属于`UINavigationController`还是`UISplitViewController`,只需调用方法即可.

这两个方法的默认实现会使用`targetViewControllerForAction(_:sender:)`方法沿视图控制器层级向上,即搜寻最近的提供了重写的父控制器,并调用其重写的方法呈现控制器.如果到最后也没找到,则会使用窗口的根控制器以`modal`形式呈现.

对于`showViewController(_:sender:)`方法,`nav controller`的实现是调用`pushViewController(_:animated:)`.`splitViewController`会先调用代理方法`splitViewController(_:showViewController:sender:)`,如果代理方法未实现或者返回了`false`,则会在`regular width`状态下以`primary view controller`呈现,但如果该控制器是当前`primary view controller`的子控制器,则会以`secondary view controller`呈现.而在`compact width`状态下,则会以`modal`呈现.

对于`showDetailViewController(_:sender:)`方法,`navigation controller`并未提供实现,`splitViewController`会先调用代理方法`splitViewController(_:showDetailViewController:sender:)`,如果代理方法未实现或者返回了`false`,则会在`regular width`状态下以`secondary view controller`呈现,在`compact width`状态下先尝试转发`showViewController(_:sender:)`给下级的`navigation controller`以`push`方式呈现,若无`navigation controller`,则以`modal`呈现.

也可以有选择地重写这两个方法,进行一些自定义的呈现效果,注意适应不同的`regular`和`compact`环境.

回到前面说的是否显示箭头标志的问题.对于处于导航控制器层级中的多级菜单,如果都是`push`操作,可以简单地判断是否还有子菜单来决定是否显示箭头.而对于`show detail`这种操作,则需判断`splitViewController`的`collapsed`属性,若为`true`,则是以`push`呈现,否则,说明`splitViewController`会以`secondary view controller`呈现,也就不需要剪头了.

另外,在`iOS 8`中`UIViewController`类中新增加了通知`UIViewControllerShowDetailTargetDidChangeNotification`.当`splitViewController`在`expands`和`collapses`两种状态之间转换时,或者说,在`iPad`那样左右分屏显示的状态和`iPhone`那样`push`或者`modal`方式显示的状态之间转换时,就会发出该通知.

例如在`iPhone`设备上由横屏过渡到竖屏后,原先在右侧呈现的控制器可能会以导航控制器的栈顶控制器呈现.这时候如果`pop`回上层控制器,应该为`cell`加上右侧的箭头标志以表明点击该`cell`可以跳转.例如可以在该代理方法`tableView(_:willDisplayCell:forRowAtIndexPath:)`中做出对应处理.

## UISplitViewController 的四种显示模式

`splitViewController`的显示模式有四种,可通过`displayMode`属性访问当前的模式.

- AllVisible `iPad`设备横屏下左右分屏的显示方式.

- PrimaryOverlay `iPad`设备竖屏下的显示方式.

- PrimaryHidden 隐藏`master view controller`.

- Automatic 不同于上面三种模式,访问`displayMode`不会获取到该模式.该模式常用于设置`preferredDisplayMode`属性,也是该属性的默认值.对于`iPad`设备,横屏下为`AllVisible`,竖屏下为`PrimaryOverlay`.

另外,如果`splitViewController`的`collapsed`属性为`true`,这些模式会被忽略,因为此时都是以`push`形式呈现的.

有个靠编码切换模式的小技巧,可在竖屏下手动隐藏`master view controller`,比如选中了一个`cell`后:

```swift
UIView.animateWithDuration(0.25, animations: {
    // 设置为该选项会隐藏 master view controller.
    splitViewController!.preferredDisplayMode = .PrimaryHidden 
}, completion: { _ in
    // 隐藏动画结束后要设置回默认的选项,否则切换到横屏也不显示了.
    splitViewController!.preferredDisplayMode = .Automatic 
})
```

## displayModeButtonItem 与返回按钮

`splitViewController`的`displayModeButtonItem()`方法会返回一个用于切换显示模式的`barButtonItem`,可以通过下面这样将其显示到`detail view controller`的导航栏上:

```swift
navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
```

需要注意的是,这样会将返回按钮顶掉,在`iPad`设备上`splitViewController`不会使用`push`的方式,因此也不存在返回按钮.而在`iPhone`设备上,由横屏切换到竖屏后,返回按钮就不见了.因此还需要设置`navigationItem.leftItemsSupplementBackButton`属性为`true`
=======
>>>>>>> Stashed changes
