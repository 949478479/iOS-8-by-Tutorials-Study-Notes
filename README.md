# Transition Coordinators

- [有关旋转的弃用方法](#Deprecated rotation methods)
- [过渡协调员](#transition coordinator)
- [旋转后调整集合视图单元格的尺寸](#Resizing Cells on Rotation)
- [iPad 设备旋转处理](#iPad rotation effects)
- [UIView 布局自适应](#adaptive view)

<a name="Deprecated rotation methods"></a>
## 有关旋转的弃用方法

`iOS 8` 中弃用了 `UIViewController` 的所有有关旋转的方法。事实上，是旋转的概念被弃用了。在完全自适应的界面，旋转失去了意义，物理设备的屏幕必须旋转，以确保它在正确的方向，但界面内容本身只需要适当调整。

`iOS 8` 中还引入了 `UIContentContainer` 协议，`UIViewController` 和 `UIPresentationController` 均实现了此协议。此协议中的方法能帮助开发者在 `size` 和 `traitCollection` 改变时，让视图控制器的内容更好地自适应。在重写这些协议方法时，一定要调用 `super` 实现，从而让 `UIKit` 能执行一些默认的行为实现。

例如，从 `iOS 8` 开始，应该使用下面这个 `UIContentContainer` 协议中的方法处理设备的旋转：

```swift
override func willTransitionToTraitCollection(newCollection: UITraitCollection,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
    flowLayout.scrollDirection = (newCollection.verticalSizeClass == .Compact) ? .Vertical : .Horizontal
}
```

上述代码用于在设备旋转后改变集合视图的滚动方向。`iPhone` 设备在横屏下 `verticalSizeClass` 为 `.Compact`，而 `iPad` 设备横竖屏都是`.Regular`。因此上述代码只会在 `iPhone` 设备横屏时将集合视图的滚动方向改为垂直滚动，而竖屏时以及 `iPad` 设备在任意方向下总是保持水平滚动。

<a name="transition coordinator"></a>
## 过渡协调员

`iOS 7` 中引入了 `UIViewControllerTransitionCoordinator` 协议，用来定制和控制视图控制器之间的转场效果。`iOS 8` 对其进一步扩展，使之可以处理同一视图控制器的 `size` 和 `traitCollection` 改变时的情况，例如实现一些动画效果：

```swift
override func willTransitionToTraitCollection(newCollection: UITraitCollection,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
    
    coordinator.animateAlongsideTransition({ _ in
        // 动画内容
    }, completion: { _ in
                
    })
}
```

<a name="Resizing Cells on Rotation"></a>
## 旋转后调整集合视图单元格的尺寸

例如，对于 `UICollectionViewController`，设备旋转后，由于视图控制器的视图尺寸发生变化，集合视图单元格的 `itemSize` 可能需要随之调整，这时候可以在 `viewWillLayoutSubviews()` 方法中进行调整，因为此时视图控制器的视图已是新尺寸：

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

<a name="iPad rotation effects"></a>
## iPad 设备旋转处理

如前所述，`iPhone` 设备在横屏下 `verticalSizeClass` 为 `.Compact`，竖屏下为 `.Regular`，而 `iPad` 设备横竖屏都是`.Regular`。这意味着 `iPad` 设备旋转时不会更新布局，也不会调用 `willTransitionToTraitCollection(_:withTransitionCoordinator:)` 方法。

因此，如果需要更新 `iPad` 设备的布局，就需要使用另一个方法来更新布局，即 `viewWillTransitionToSize(_:withTransitionCoordinator:)`。只要视图控制器的视图的 `size` 改变了就会调用此方法，因此无论什么设备，旋转后都会调用此方法。

通常，会在 `IB` 中根据不同 `Size Classes` 来设置布局约束，从而在设备旋转时自动更新布局。而对于 `iPad` 设备来说，无论横屏还是竖屏，都只有一种 `Size Classes`，即 `Regular Width,Regular Height`。这意味着无法在 `IB` 中为其针对横屏或者竖屏单独设置布局约束，也就是横竖屏只能共用一套布局约束。

解决方案是在不属于 `iPad` 的 `Size Classes` 下添加横屏下的布局约束，例如 `Any Width,Compact Height`，然后将所有布局约束用 `@IBOutlet` 连出来，例如这样：

```swift
@IBOutlet var tallLayoutConstraints: [NSLayoutConstraint]!
@IBOutlet var wideLayoutConstraints: [NSLayoutConstraint]!
```

然后可以在 `viewWillTransitionToSize(_:withTransitionCoordinator:)` 方法中，根据宽高判断当前横竖屏状态，激活对应的布局约束，并移除不适用的布局约束：

```swift
override func viewWillTransitionToSize(size: CGSize,
    withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    guard traitCollection.userInterfaceIdiom == .Pad else { return }
    
    let transitionToWide = size.width > size.height
    let constraintsToUninstall = transitionToWide ? tallLayoutConstraints : wideLayoutConstraints
    let constraintsToInstall = transitionToWide ? wideLayoutConstraints : tallLayoutConstraints

    // 先移除，再添加，否则会导致约束有歧义
    NSLayoutConstraint.deactivateConstraints(constraintsToUninstall)
    NSLayoutConstraint.activateConstraints(constraintsToInstall)
}
```

上述代码在设备旋转时，通过比较宽高来判断横竖屏，并激活和停用相应的布局约束。但是这种方案只会在设备旋转时更新到对应的布局约束，而程序启动时并不会调用该方法。为了修复这个问题，可以在 `viewDidLayoutSubviews()` 方法中更新一次布局约束，用一个属性标记下，保证只更新一次即可。

<a name="adaptive view"></a>
## UIView 布局自适应

`UIView` 并未实现 `UIContentContainer` 协议，因此前面介绍的方法只适用于 `UIViewController` 和 `UIPresentationController`。但是 `UIView` 实现了 `UITraitEnvironment` 协议，该协议声明了 `traitCollection` 属性和 `traitCollectionDidChange(_:)` 方法，利用此方法也可以响应布局变化。此外，`UIScreen`、`UIViewController` 和 `UIPresentationController` 也都实现了此协议，不过对于控制器来说，使用前面介绍的方法可能更为方便。

举个例子，下面的代码创建了一个能根据当前 `verticalSizeClass` 决定 `padding` 大小的 `UILabel` 子类：

```swift
class PaddedLabel: UILabel {

    var verticalPadding: CGFloat = 0.0

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            // iPhone 设备横屏时没有 padding，竖屏以及 iPad 设备 padding 为 20
            verticalPadding = (traitCollection.verticalSizeClass == .Compact) ? 0.0 : 20.0
            // 更新固有尺寸，自动布局系统会在下次布局时重新调用 intrinsicContentSize() 方法获取固有尺寸
            invalidateIntrinsicContentSize() 
        }
    }

    override func intrinsicContentSize() -> CGSize {
        // 在原有固有尺寸基础上将高度加上 padding
        var intrinsicContentSize = super.intrinsicContentSize()
        intrinsicContentSize.height += verticalPadding 
        return intrinsicContentSize
    }
}
```