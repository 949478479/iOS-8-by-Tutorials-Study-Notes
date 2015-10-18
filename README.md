# Transition Coordinators

## 被弃用的关于旋转的方法

`iOS 8`中弃用了`UIViewController`的所有关于旋转的方法.事实上,是旋转的概念被弃用了.在完全自适应的界面,旋转失去了意义,物理设备的屏幕必须旋转,以确保它在正确的方向,但界面内容本身只需要适当调整.

`iOS 8`中还增加了`UIContentContainer`协议,`UIViewController`和`UIPresentationController`遵循该协议并提供了默认实现.该协议中的方法能帮助开发者在`size`和`traitCollection`改变时,让视图控制器的内容更好地自适应.在重写这些协议方法时,一定要调用`super`的实现,从而让`UIKit`能执行一些默认的行为实现.

例如,从`iOS 8`开始,应该使用下面这个`UIContentContainer`协议中的方法处理设备的旋转:

```swift
override func willTransitionToTraitCollection(newCollection: UITraitCollection,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
    flowLayout.scrollDirection = (newCollection.verticalSizeClass == .Compact) ? .Vertical : .Horizontal
}
```

上述代码用于在设备旋转后改变`collection view`的滚动方向.`iPhone`设备在横屏下`verticalSizeClass`为`.Compact`,而`iPad`设备横竖屏都是`.Regular`.因此上述代码只会在`iPhone`设备横屏时将`collection view`的滚动方向改为垂直滚动,而竖屏时以及`iPad`设备在任意方向下总是保持水平滚动.

## transition coordinator

`iOS 7`中引入了`UIViewControllerTransitionCoordinator`协议,用来定制和控制视图控制器之间的过渡效果.`iOS 8`对其进一步扩展,使之可以处理同一视图控制器的`size`和`traitCollection`改变时的情况,例如实现一些动画效果:

```swift
override func willTransitionToTraitCollection(newCollection: UITraitCollection,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    
    coordinator.animateAlongsideTransition({ _ in
        // 动画内容...
    }, completion: { _ in
                
    })
}
```

## 旋转后调整 cell 的尺寸

例如,对于`UICollectionViewController`,设备旋转后,由于视图控制器的`view`尺寸发生变化,`cell`的`itemSize`可能需要随之调整,这时候可以在`viewWillLayoutSubviews()`方法中进行调整,因为此时视图控制器的`view`已是新尺寸:

```swift
override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
    let minDimension = min(view.bounds.width, view.bounds.height)
    let newItemSize = CGSize(width: minDimension, height: minDimension)
    if newItemSize != flowLayout.itemSize {
        flowLayout.itemSize = newItemSize
        flowLayout.invalidateLayout()
    }
}
```

## iPad 设备的旋转效果

如前所述,`iPhone`设备在横屏下`verticalSizeClass`为`.Compact`,竖屏下为`.Regular`.而`iPad`设备横竖屏都是`.Regular`.这意味着`iPad`设备旋转时不会更新布局,也不会调用`willTransitionToTraitCollection(_:withTransitionCoordinator:)`方法.

因此,如果还需要更新`iPad`设备的布局,就需要使用另一个方法来更新布局,即`viewWillTransitionToSize(_:withTransitionCoordinator:)`.只要视图控制器的`view`的`size`改变了就会调用此方法,因此无论什么设备,旋转后都会调用此方法.

通常,会在`IB`中根据不同`Size Classes`来设置布局约束,从而在设备旋转时自动更新布局.而对于`iPad`设备来说,无论横屏还是竖屏,都只有一种`Size Classes`,即`Regular Width,Regular Height`.这意味着无法在`IB`中为其针对横屏或者竖屏单独设置布局约束,也就是横竖屏只能共用一套布局约束.

解决方案是在不属于`iPad`的`Size Classes`下添加横屏下的布局约束,例如`Any Width,Compact Height`,然后将所有布局约束用`@IBOutlet`连出来,例如这样:

```swift
@IBOutlet var tallLayoutConstraints: [NSLayoutConstraint]!
@IBOutlet var wideLayoutConstraints: [NSLayoutConstraint]!
```

然后可以在`viewWillTransitionToSize(_:withTransitionCoordinator:)`方法中,根据宽高判断当前横竖屏状态,激活对应的布局约束,并移除不适用的布局约束:

```swift
override func viewWillTransitionToSize(size: CGSize,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    let transitionToWide = size.width > size.height
    let constraintsToUninstall = transitionToWide ? tallLayoutConstraints : wideLayoutConstraints
    let constraintsToInstall = transitionToWide ? wideLayoutConstraints : tallLayoutConstraints

    view.layoutIfNeeded()

    // 一定要先移除,再添加,否则会报警告提示约束有歧义.
    NSLayoutConstraint.deactivateConstraints(constraintsToUninstall)
    NSLayoutConstraint.activateConstraints(constraintsToInstall)

    coordinator.animateAlongsideTransition({ _ in
        self.view.layoutIfNeeded()
    }, completion: nil)
}
```

上述代码在设备旋转时,根据宽高进行比较,判断横竖屏情况,例如横屏下就激活横屏下的布局约束,而移除竖屏下的布局约束.通过在动画块中调用`layoutIfNeeded()`,让这些布局变化能以动画效果呈现.

对于同一个布局约束,即使激活多次,视图上依旧只会有一份.同样,反复移除同一布局约束也不会有问题.因此即使`iPhone`和`iPad`共用一套布局,`iPhone`设备会因为`IB`中设置的不同`Size Classes`而在设备旋转时自动更新一次布局约束,然后在上述方法中又会更新一次布局约束,也不会有什么问题.

当然,上述方案有个问题,只有设备旋转时才会更新到对应的布局约束,而程序启动时并不会调用该方法.因此,对于`iPad`设备,无论横屏还是竖屏状态启动,视图上的布局约束都将会是`IB`中针对`iPad`的`Size Classes`设置的布局约束.不过可以在`viewDidLayoutSubviews()`方法中更新一次布局约束,通过一个`Bool`属性标记下,只在启动时更新一次即可.

## UIView 的布局自适应

`UIView`并未遵循`UIContentContainer`协议,因此前面介绍的方法只适用于`UIViewController`和`UIPresentationController`.但是`UIView`遵循了`UITraitEnvironment`协议,该协议声明了`traitCollection`属性和`traitCollectionDidChange(_:)`方法,也可以用来响应布局变化.另外,`UIScreen`,`UIWindow`,`UIViewController`,`UIPresentationController`也都采纳了此协议,不过对于视图控制器来说,使用前面介绍的方法可能更为方便.

例如,下面的代码创建了一个能根据当前`verticalSizeClass`决定`padding`大小的`UILabel`子类:

```swift
class PaddedLabel: UILabel {

    var verticalPadding: CGFloat = 0.0

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            // iPhone 设备横屏时没有 padding, 竖屏以及 iPad 设备 padding 为 20.
            verticalPadding = (traitCollection.verticalSizeClass == .Compact) ? 0.0 : 20.0
            // 更新固有尺寸,自动布局系统会重新调用 intrinsicContentSize() 方法获取固有尺寸.
            invalidateIntrinsicContentSize() 
        }
    }

    override func intrinsicContentSize() -> CGSize {
        var intrinsicContentSize = super.intrinsicContentSize()
        intrinsicContentSize.height += verticalPadding // 在原有固有尺寸基础上将高度加上 padding.
        return intrinsicContentSize
    }
}
```
