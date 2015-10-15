# Beginning Adaptive Layout

这一篇主要大致介绍了下`Size Class`对布局带来的变化,没什么好记录的.

使用`Size Class`可以针对横竖屏分别布局,在不同`Size Class`下使用不同布局约束,字体效果等.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Adaptive-Layout/Screenshot/AdaptiveWeather.gif)

可以使用`delete`键从当前`Size Class`移除一个布局约束,使用`cmd`键 + `delete`键完全移除一个布局约束.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Adaptive-Layout/Screenshot/ConstraintSizeClass.png)

可以针对不同`Size Class`设置字体.

还可以开启`adjustsFontSizeToFitWidth`配合`minimumScaleFactor`,在空间有限时适当缩小字体从而完整地显示文字.

![](https://github.com/949478479/iOS-8-by-Tutorials-Study-Notes/blob/Beginning-Adaptive-Layout/Screenshot/FontSizeClass.png)
