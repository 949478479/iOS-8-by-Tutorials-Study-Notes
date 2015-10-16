# Intermediate Adaptive Layout

## 使用 self-sizing cell 的要点

- `cell`的宽度由`table view`的宽度决定.
- `cell`的高度由布局约束决定,千万不要有任何歧义.
- `table view`的`rowHeight`属性需设置为`UITableViewAutomaticDimension`.
- `table view`的`estimatedRowHeight`属性必须设置为`非0值`.尽量让该值接近实际高度,若相差过大,`table view`滚动时会出现"跳跃".

## Installable View

不仅仅是布局约束和字体可以指定`Size Classes`,视图也可以.可以很灵活地指定一个视图在哪种`Size Classes`下显示,一般来说会在`Any Any`的`Size Classes`下设置通用的布局,然后切换不同的`Size Classes`,使用`cmd + delete`键从该`Size Classes`删除一个视图.或者像下图这样在`attributes inspector`窗格中添加不同`Size Classes`并设置勾选,从而决定该视图在哪些`Size Classes`下显示.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Intermediate-Adaptive-Layout/Screenshot/InstallableViews.png)

## UITraitCollection 以及修改子控制器的 traitCollection

`UITraitCollection`封装了一系列用来描述当前环境信息的特性,例如水平和垂直方向的`Size Classes`,屏幕`scale`,设备`idiom`等.`UITraitEnvironment`协议声明了一个类型为`UITraitCollection`的`traitCollection`属性,`UIViewController`和`UIView`都采纳了该协议,这意味着几乎可以随时随地地获取当前的`traitCollection`.

不同设备在不同方向都有固有的`traitCollection`,并且会沿着`view controller`和`view`层级向下传递.控制器可以通过`setOverrideTraitCollection(_:forChildViewController:)`方法来修改子控制器的`traitCollection`,从而改变一些默认的布局行为.

例如,像下面这样,指定高度不足`1000`时,也就是除了`iPad`设备竖屏的情况,都归为`compact height`.正常情况下,`iPhone`设备在竖屏时是`regular height`,横屏时是`compact height`.而`iPad`设备横竖屏都是`regular height`.通过这样的修改,就可以让设备在横屏下呈现和默认行为不同的布局.例如只在`iPad`设备竖屏下才显示某视图之类的.

注意这里只提供了`verticalSizeClass`的信息,因此这只会覆盖子控制器的`traitCollection`的`verticalSizeClass`.另外,一旦修改了`traitCollection`,每次设备旋转时都需要修改,否则只会沿用上次修改后的值.例如,这里指定当高度超过`1000`时,`traitOverride`为`nil`,这将会重置之前的修改,重新沿用原有的默认行为,即子控制器沿用父控制器的`traitCollection`,这时候`verticalSizeClass`将是`regular`.否则,即使高度超过`1000`,也就是`iPad`由横屏变为竖屏,子控制器的`verticalSizeClass`将依旧是之前设置的`compact`,而不会沿用父控制器的`regular`.

```swift
func configureTraitOverrideForSize(size: CGSize) {
    let traitOverride: UITraitCollection? = size.height < 1000 ?
        UITraitCollection(verticalSizeClass: .Compact) : nil
    childViewControllers.forEach {
        setOverrideTraitCollection(traitOverride, forChildViewController: $0)
    }
}
```

可以在`viewDidLoad()`方法中进行该项修改:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    configureTraitOverrideForSize(view.bounds.size)
}
```

如上所述,如果需要响应屏幕旋转,还可以在下面这个方法中进一步做出修改.每当设备旋转造成`view`的`bounds`改变时,此方法就会调用,可以在这里修改子控制器的`traitCollection`.

```swift
override func viewWillTransitionToSize(size: CGSize,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    configureTraitOverrideForSize(size)
}
```

## iPhone 和 iPad 共用 UISplitViewController 

`UISplitViewController`会根据当前环境是`compact width`还是`regular width`决定`detail view controller`的显示方式.对于所有`iPhone`设备,竖屏下都是`compact width`,因此`detail view controller`将会以`modal`或者`push`的方式呈现,这取决于`master view controller`是否嵌套了导航控制器.而对于`iPhone plus`设备,横屏下则是`regular width`,因此`detail view controller`会像`iPad`设备一样显示.

`splitViewController`首次呈现时,`iPhone`设备在竖屏下默认会直接`modal`或者`push`到`detail view controller`.若想显示`master view controller`,则可以实现下面这个`UISplitViewController`的代理方法,返回`true`.该代理方法会在`compact width`和`regular width`过渡时调用,这意味着`iPad`设备不会调用此方法,普通`iPhone`设备只会在一开始调用一次,而`iPhone plus`设备每次旋转屏幕都会调用.

```swift
func splitViewController(splitViewController: UISplitViewController,
    collapseSecondaryViewController secondaryViewController:UIViewController,
    ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    return true
}
```

另外,使用`UISplitViewController`时,可以通过下面代码在导航栏返回按钮处放置一个用于显示和隐藏`detail view controller`的按钮.

```swift
navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
```

对于`iPhone`设备,`detail view controller`以`modal`或者`push`方式呈现时,设置该按钮不会有效果,但是这却会导致返回按钮消失.因此还需要设置下面的属性,从而能在普通`iPhone`设备横竖屏以及`iPhone plus`设备竖屏下正确显示返回按钮.

```swift
navigationItem.leftItemsSupplementBackButton = true
```

## Size Classes 和图片资源

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Intermediate-Adaptive-Layout/Screenshot/SizeClasses%E5%92%8C%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%900.png)
![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Intermediate-Adaptive-Layout/Screenshot/SizeClasses%E5%92%8C%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%901.png)
![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Intermediate-Adaptive-Layout/Screenshot/SizeClasses%E5%92%8C%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%902.png)

如图,可以根据不同的`Size Classes`显示不同的图片.中括号中的符号含义如下:

- * Any
- - Compact 
- + Regular

利用前面提到的修改子控制器的`traitCollection`的方法,就可以实现父控制器和子控制器分别显示不同的图片.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Intermediate-Adaptive-Layout/Screenshot/SizeClasses%E5%92%8C%E5%9B%BE%E7%89%87%E8%B5%84%E6%BA%903.png)

如图,最上面的大云彩和中间的小云彩是同名图片资源,但是中间的小云彩属于子控制器部分,通过修改子控制器的`traitCollection`,从而显示了不同的图片.

## 显示和隐藏导航栏

`iOS 8`中`UINavigationController`新增了几个关于导航栏的属性,可以在`iPhone`设备横屏,轻击,向上滑动或者键盘弹出时隐藏导航栏.

注意,`iPhone`设备使用`UISplitViewController`且以`push`方式呈现`detail view controller`时,导航控制器的`hidesBarsWhenVerticallyCompact`属性以`master view controller`的导航控制器的设置为准.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Intermediate-Adaptive-Layout/Screenshot/%E6%98%BE%E7%A4%BA%E5%92%8C%E9%9A%90%E8%97%8F%E5%AF%BC%E8%88%AA%E6%A0%8F.png)

## Size Classes 和 UIAppearance

`iOS 8`中`UIAppearance`也增加了对`Size Classes`的支持,例如像下面这样根据`verticalSizeClass`设置字体.这在`iPhone`设备上会根据横竖屏显示不同大小的导航栏标题字体.而对于`iPad`设备,由于横竖屏都是`regular height`,只会显示大号的字体.

```swift
func prepareNavigationBarAppearance() {
    let font = UIFont(name: "HelveticaNeue-Light", size: 30)!
    
    let regularVertical = UITraitCollection(verticalSizeClass: .Regular)
    UINavigationBar.appearanceForTraitCollection(regularVertical)
        .titleTextAttributes = [NSFontAttributeName : font]
        
    let compactVertical = UITraitCollection(verticalSizeClass: .Compact)
    UINavigationBar.appearanceForTraitCollection(compactVertical)
        .titleTextAttributes = [NSFontAttributeName : font.fontWithSize(20)]
}
```
