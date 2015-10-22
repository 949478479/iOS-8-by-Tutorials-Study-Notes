# Beginning Photos

在 iOS 8，开发者迎来了全新的`Photos`框架，它提供了与用户照片库交互的所有功能，用于取代`AssetsLibrary`框架，后者也在 iOS 9 正式弃用了。`Photos`框架包括大量简洁的特性，让开发者能访问并编辑图像，无论是单张图片还是整个相册。

- [概览](#overview)
- [获取相册权限](#requestAuthorization)
- [获取图像资源模型](#Fetching objects)
- [加载图像资源内容](#Loading content)

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
            // 获得权限，可执行获取模型之类的操作了。
        default:
            // 没有权限，提示用户去设置开启。
        }
    }
}
```

另外，iOS 8 中`UIApplication`新增了`UIApplicationOpenSettingsURLString`这个字符串，可以用来打开设置界面：

```swift
UIApplication.sharedApplication().openURL(
	NSURL(string: UIApplicationOpenSettingsURLString)!)
```

<a name="Fetching objects"></a>
## 获取图像资源模型

#### 获取用户设备全部图片资源

```swift
PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
```

还可以通过设置`PHFetchOptions`进行一些高级设置，例如：

```swift
let options = PHFetchOptions()
// 按创建日期排序.
options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)] 
options.predicate = /* 指定谓词进行过滤. */
options.fetchLimit = 233 // 限制返回结果最大数量.
options.includeHiddenAssets = true // 包含隐藏资源.
```

#### 获取相册

可通过下面的方式获取用户自己创建的相册：

```swift
// 获取所有用户创建的相册，其结果为 PHFetchResult 对象，该集合中的元素为 PHCollectionList 对象.
let userAlbums = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)

// 取出其中某个相册，它是个 PHAssetCollection 对象.
let userAlbum = userAlbums[233]

// 获取该相册下所有图像资源.
let assets = PHAsset.fetchAssetsInAssetCollection(userAlbum, options: nil)
```

可通过下面方式获取智能相册，例如“个人收藏”相册，也就是“Favorites”相册：

```swift
let favoritesAlbum = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, 
    subtype:.SmartAlbumFavorites, options: nil)
```

使用`localizedTitle`属性可获取相册名称。

使用`estimatedAssetCount`属性可提前获取相册中图像资源的估计数量，该值可能是`NSNotFound`，想获取确切数量可以通过` fetchAssetsInAssetCollection(_:options:)`方法获取全部模型然后查看返回结果的`count`属性。

<a name="Loading content"></a>
## 加载图像资源内容

如前所述，加载图像资源内容需通过`PHImageManager`或者其子类另行加载。

#### 加载图片

可以在 table view 或者 collection view 的数据源方法中类似下面这样加载图片，当然，还需根据需求设置`PHImageRequestOptions`参数对象：

```swift
PHImageManager.defaultManager().requestImageForAsset(asset, 
    targetSize: CGSize(width: 50, height: 50), 
    contentMode: .AspectFill, 
    options: nil) { image, info in
    // 设置图片...
}
```

这里需指定期望的图片尺寸，以及拉伸模式。如果想要原图，可以传入`PHImageManagerMaximumSize`常量，并将拉伸模式设置为`.Default`。但是最终生成的图片可能并不完全匹配指定的尺寸，这取决于`PHImageRequestOptions`参数对象的`deliveryMode`和`resizeMode`属性的设置。

在异步模式下（默认），如果不设置`PHImageRequestOptions`参数对象，或者其`deliveryMode`为`.Opportunistic`（默认），那么闭包可能会被多次调用。系统会先提供一个低质量的图片或者一张已存在的图片，待最终的高质量图片生成后再提供。可通过字典中的`PHImageResultIsDegradedKey`键取出`Bool`值来判断，若为`false`，则为高质量图片。

该方法会返回一个`PHImageRequestID`，配合`cancelImageRequest(_:)`方法可中途取消一个加载请求。

如果加载出错，或者中途取消，均会调用闭包。可通过字典中的`PHImageErrorKey`键获取`NSError`对象，通过`PHImageCancelledKey`获取`Bool`值判断是否被取消。

#### PHImageRequestOptions

`PHImageRequestOptions`对象用于进行一些高级的设置，它的一些属性如下：

`synchronous`属性，是否同步执行，默认为`false`。如果在后台线程调用方法，可以考虑同步模式。

`verson`属性，分为三种模式：

```swift
@available(iOS 8.0, *)
public enum PHImageRequestOptionsVersion : Int {
    /*  当前版本的图片，无论是否被编辑过。 */
    case Current 
    /*  未编辑过的原图。 */
    case Unadjusted // original version without any adjustments
    /*  高保真原图，例如存在 RAW 和 JPEG 两种格式，只会提供 RAW 格式的图片。 */
    case Original 
}
```

`deliveryMode`属性，分为三种模式：

```swift
@available(iOS 8.0, *)
public enum PHImageRequestOptionsDeliveryMode : Int {
    /*  此选项只能用于异步模式下，并且有可能导致闭包被多次调用。
        如果最终的高质量图片尚在处理，会先生成一张低质量的图片提供。
        如果低质量图片已存在，闭包会在方法返回前就被调用。
        如果最终的高质量图片已存在，闭包只会调用一次。
        可见，闭包调用次数取决于高质量图片是否存在，而闭包调用时机取决于能否立即提供图片。 */
    case Opportunistic 
    /*  只提供最终的高质量图片，不考虑耗时问题。这也是同步模式下的唯一选项。 */
    case HighQualityFormat 
    /*  尽可能地提高效率。因此闭包只调用一次，如果高质量图片不存在，就提供快速生成的低质量图片。*/
    case FastFormat 
}
```

`resizeMode`属性，分为三种模式：

```swift
@available(iOS 8.0, *)
public enum PHImageRequestOptionsResizeMode : Int {
    /*  不拉伸。 */
    case None 
    /*  追求执行效率的拉伸。最终图片尺寸可能和期望支持不太相符。 */
    case Fast
    /*  牺牲效率，最终图片尺寸完全符合期望值。如果设置了 normalizedCropRect 属性，则必须使用该选项。 */
    case Exact 
}
```

`normalizedCropRect`属性，设置裁剪区域，无论拉伸模式是什么，图片左上角为`{0,0}`，右下角为`{1,1}`。

`networkAccessAllowed`属性，是否加载 iCloud 上的图片，默认为`false`。开启后还可以设置`progressHandler`属性来通过闭包监听下载进度。如果未开启此属性就去加载 iCloud 上的图片资源，将无法获取图片，并且可以从字典中用`PHImageResultIsInCloudKey`键取出一个`true`值。

#### 其他加载方法

`PHImageManager`还可以直接获取图片的二进制数据。此方法会忽略`PHImageRequestOptions`参数的`deliveryMode`属性，闭包只会调用一次，并提供最大尺寸的图片的二进制数据。

```swift
public func requestImageDataForAsset(asset: PHAsset,
    options: PHImageRequestOptions?, 
    resultHandler: (NSData?, String?, UIImageOrientation, [NSObject : AnyObject]?) -> Void)
    -> PHImageRequestID
```

还可以加载视频资源：

```swift
public func requestPlayerItemForVideo(asset: PHAsset, 
    options: PHVideoRequestOptions?, 
    resultHandler: (AVPlayerItem?, [NSObject : AnyObject]?) -> Void)
     -> PHImageRequestID
    
public func requestExportSessionForVideo(asset: PHAsset, 
    options: PHVideoRequestOptions?, exportPreset: String, 
    resultHandler: (AVAssetExportSession?, [NSObject : AnyObject]?) -> Void)
     -> PHImageRequestID
    
public func requestAVAssetForVideo(asset: PHAsset, 
    options: PHVideoRequestOptions?, 
    resultHandler: (AVAsset?, AVAudioMix?, [NSObject : AnyObject]?) -> Void)
     -> PHImageRequestID
```

#### PHCachingImageManager

`PHCachingImageManager`是`PHImageManager`的子类，可用于预加载图片资源，能很好的配合 table view 或者 collection view，提高滚动的流畅性。

使用该子类需要单独创建实例，而不要使用单例。可以使用下面的方法开启一个预加载。获取图片依旧是使用父类方法`requestImageForAsset(_:targetSize:contentMode:options:resultHandler:)`。如果图片已经预加载完毕，就可以立即获取到图片。注意两次传入的各参数一定要一样，否则将无法获取到预加载的图片而只能重新加载图片。

```swift
public func startCachingImagesForAssets(assets: [PHAsset], 
    targetSize: CGSize, 
    contentMode: PHImageContentMode, 
    options: PHImageRequestOptions?)
```

上面的方法并未返回`PHImageRequestID`，因此若想取消预加载需要使用下面两个方法，同样，需要注意参数：

```swift
public func stopCachingImagesForAssets(assets: [PHAsset], 
    targetSize: CGSize,
    contentMode: PHImageContentMode, 
    options: PHImageRequestOptions?)
    
public func stopCachingImagesForAllAssets()
```

该类还有个`allowsCachingHighQualityImages`属性，默认为`true`。缓存高质量的图片也意味着更高的性能耗费，根据官方文档的建议，类似使用 collection view 展示图片缩略图这种情况，应该关闭此属性，提升性能。
