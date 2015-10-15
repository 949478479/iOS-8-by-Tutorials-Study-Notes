# Beginning Adaptive Layout

这一篇主要大致介绍了下`Size Class`对布局带来的变化,没什么好记录的.

使用`Size Class`可以针对横竖屏分别布局,在不同`Size Class`下使用不同布局约束,字体效果等.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Adaptive-Layout/Screenshot/AdaptiveWeather.gif)

在`Size Inspector`窗格中,使用`delete`键可以将选中约束从当前`Size Class`移除.

在`Document Outline`窗格中,使用`delete`键可以完全移除选中约束,使用`cmd + delete`键可以从当前`Size Class`移除.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Adaptive-Layout/Screenshot/ConstraintSizeClass.png)

可以针对不同`Size Class`设置字体.

还可以开启`adjustsFontSizeToFitWidth`配合`minimumScaleFactor`,在空间有限时适当缩小字体从而完整地显示文字.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Adaptive-Layout/Screenshot/FontSizeClass.png)
