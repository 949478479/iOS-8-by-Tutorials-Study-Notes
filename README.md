# Beginning Photos

在 iOS 8，开发者迎来了全新的`Photos`框架，它提供了与用户照片库交互的所有功能，用于取代`AssetsLibrary`框架，后者也在 iOS 9 正式弃用了。`Photos`框架包括大量简洁的特性，让开发者能访问并编辑图像，无论是单张图片还是整个相册。

- [概览](#overview)
- [获取相册权限](#requestAuthorization)

<a name="overview"></a>
## 概览

#### Photo 框架的主要功能

- 获取资源模型：可以轻松获取代表图像资源、集合或者集合列表的模型对象，同时保证性能和隐私。
- 加载以及缓存图像资源内容：`Photo`框架能处理图像资源内容的下载和缓存任务，并提供预加载的功能，能很好地配合 table view 或者 collection view。
- 请求变更：可以请求修改图像资源、集合或集合列表,并且这将会立即反映在用户的照片库中。
- 编辑图像资源内容：可以编辑图像资源内容，并提交到照片库。还可以允许用户撤销更改，恢复到先前的数据。
- 监听改变：可以注册通知，当照片库发生变化时，会得到通知，从而更新界面。无论改变是由自己的应用还是其他应用造成的。
- 使用系统相册的高级功能：可以访问系统相册中的所有东西，包括智能专辑，时刻，iCloud 照片流，并能识别 burst shots，全景图像，和慢动作视频。

#### PHObject

`Photos`框架中的图像资源模型都用继承自抽象基类`PHObject`的模型类表示。它们是轻量的模型对象，只包含描述性的元数据，而不包括图像资源内容，具体的图像数据必须另行加载。所有的模型都是不可变的，想要修改必须创建对应的修改请求。这些模型类提供了一些类方法，用于获取资源模型对象。

其子类如下：

- `PHAsset`：代表一个单一的图像资源，例如一张图片或者一部视频，可以是本地的，也可以是 iCloud 上的。
- `PHCollection`：该类也是个抽象类，应该使用其子类`PHAssetCollection`和`PHCollectionList`。
- `PHAssetCollection`：代表一个有序的图像资源模型集合，其内容是`PHAsset`。
- `PHCollectionList`：代表一个有序的集合的集合，其内容是`PHAssetCollection`或者其他`PHCollectionList`。
- `PHObjectPlaceholder`：代表一个占位模型。

上面的两个集合类型的模型不持有其模型元素，都是通过类方法来获取模型对象。获取一个`PHAssetCollection`对象中的所有`PHAsset`对象，可使用`PHAsset`的类方法`fetchAssetsInAssetCollection(_:options:)`获取；获取一个`PHCollectionList`对象中的所有`PHAssetCollection`对象，可使用`PHAssetCollection`的类方法`fetchCollectionsInCollectionList(_:options:)`获取；获取`PHAsset`对象对应的图像资源，必须使用`PHImageManager`另行加载图像内容。

还可以通过设置`PHFetchOptions`选项来指定要抓取哪些模型对象，抓取结果如何排序，数量限制，以及结果变化时是否通知之类的设定。

#### PHFetchResult

使用`PHObject`子类的类方法来获取图像资源模型对象时，其结果会用一个`PHFetchResult`对象表示。它是对应模型对象的有序集合，例如，使用`PHAsset`类获取模型对象时，该集合中元素为`PHAsset`对象，而使用`PHAssetCollection`类获取模型对象时，集合中的元素则是`PHAssetCollection`。该类有一些非常类似`NSArray`的方法。但和普通数组不同，它会智能管理内存以及懒加载，这意味着抓取并遍历大量模型对象也不会大量消耗内存。另外，它是线程安全的。

#### PHImageManager

`PHImageManager`的单例负责加载图像资源模型对应的图像内容，还可指明目标图像尺寸，缩放模式，以及其他一些高级设置。它异步处理加载、缓存、加工图像以及重用图像的任务。另外，还有个子类`PHCachingImageManager`，可以预加载图像内容到内存，对于提高 table view 或者 collection view 的流畅性十分有用。

可以通过`PHImageRequestOptions`和`PHVideoRequestOptions`对象来设置加载图像时的高级设定，例如是否同步执行、图像版本、图像质量、缩放模式、裁剪区域、是否加载 iCloud 端数据，甚至还可以传入闭包来监听下载进度。

<a name="requestAuthorization"></a>
## 获取相册权限

在访问相册前，必须先获取权限，使用如下方法获取权限。该方法异步获取相册权限。如果用户尚未做出过选择，调用此方法会弹窗询问，在用户做出选择后，闭包会被调用。如果用户已经做出过选择，调用此方法会直接执行闭包。

```swift
PHPhotoLibrary.requestAuthorization { state in
    dispatch_async(dispatch_get_main_queue()) {
        switch state {
        case .Authorized:
            // 获得权限，可执行抓取之类的操作了。
        default:
            // 没有权限，提示用户曲设置开启。
        }
    }
}
```

另外，iOS 8 中`UIApplication`新增了`UIApplicationOpenSettingsURLString`这个字符串，可以用来打开设置界面：

```swift
UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
```
