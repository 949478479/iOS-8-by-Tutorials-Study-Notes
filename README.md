# Photos Framework

在 iOS 8，开发者迎来了全新的`Photos`框架，它提供了与用户照片库交互的所有功能，用于取代`AssetsLibrary`框架，后者也在 iOS 9 正式弃用了。

- [Photo 框架的主要功能](#overview)
- [概览：获取图像资源模型与加载图像内容](#Fetching_objects_and_loading_content)
- [概览：修改图像资源模型与编辑图像内容](#Requesting_changes_and_editing_content)
- [概览：监听改变](#Observing_changes)
- [获取相册权限](#requestAuthorization)
- [获取图像资源模型](#Fetching_objects)
- [加载图像资源内容](#Loading_content)
- [修改图像资源模型](#changes_objects)
- [修改图像资源内容](#editing_content)
- [监听改变](#observing_changes)

<a name="overview"></a>
## Photo 框架的主要功能

- 获取资源模型：可以轻松获取代表图像资源、集合或者集合列表的模型对象，同时保证性能和隐私。
- 加载以及缓存图像资源内容：`Photo`框架能处理图像资源内容的下载和缓存任务，并提供预加载的功能，能很好地配合 table view 或者 collection view。
- 请求变更：可以请求修改图像资源、集合或集合列表,并且这将会立即反映在用户的照片库中。
- 编辑图像资源内容：可以编辑图像资源内容，并提交到照片库。还可以允许用户撤销更改，恢复到先前的数据。
- 监听改变：可以注册通知，当照片库发生变化时，会得到通知，从而更新界面。无论改变是由自己的应用还是其他应用造成的。
- 使用系统相册的高级功能：可以访问系统相册中的所有东西，包括智能专辑，时刻，iCloud 照片流，并能识别 burst shots，全景图像，和慢动作视频。

<a name="Fetching_objects_and_loading_content"></a>
## 概览：获取图像资源模型与加载图像内容

下面这些类可用于获取图像资源模型和加载图像资源内容：

#### PHObject

`Photos`框架中的图像资源模型都用继承自抽象基类`PHObject`的模型类表示。它们是轻量的模型对象，只包含描述性的元数据，而不包括图像资源内容，具体的图像数据必须另行加载。所有的模型都是不可变的，想要修改必须创建对应的修改请求。这些模型类提供了一些类方法，用于获取资源模型对象。

其子类如下：

- `PHAsset`：代表单一的图像资源，例如一张图片或者一部视频，可以是本地的，也可以是 iCloud 上的。
- `PHCollection`：该类也是个抽象类，应该使用其子类`PHAssetCollection`和`PHCollectionList`。
- `PHAssetCollection`：代表有序的图像资源模型集合，类似相册，其内容是`PHAsset`。
- `PHCollectionList`：代表有序的集合的集合，类似相册文件夹，其内容是`PHAssetCollection`或其他`PHCollectionList`。
- `PHObjectPlaceholder`：代表一个占位模型，用于创建新模型时。

`PHAssetCollection`和`PHCollectionList`还可以创建临时的集合来方便地记录一些模型。

上面的两个集合类型的模型不持有其模型元素，都是通过类方法来获取模型对象。获取一个`PHAssetCollection`对象中的所有`PHAsset`对象，可使用`PHAsset`的类方法`fetchAssetsInAssetCollection(_:options:)`获取；获取一个`PHCollectionList`对象中的所有`PHAssetCollection`对象，可使用`PHAssetCollection`的类方法`fetchCollectionsInCollectionList(_:options:)`获取；获取`PHAsset`对象对应的图像资源，必须使用`PHImageManager`另行加载图像内容。

#### PHFetchResult

使用`PHObject`子类的类方法来获取图像资源模型对象时，其结果会用一个`PHFetchResult`对象表示。它是对应模型对象的有序集合，例如，使用`PHAsset`类获取模型对象时，该集合中元素为`PHAsset`对象，而使用`PHAssetCollection`类获取模型对象时，集合中的元素则是`PHAssetCollection`。该类有一些非常类似`NSArray`的方法。但和普通数组不同，它会智能管理内存以及懒加载，这意味着抓取并遍历大量模型对象也不会大量消耗内存。另外，它是线程安全的。

#### PHFetchOptions

可以通过设置`PHFetchOptions`选项来指定要抓取哪些模型对象，抓取结果如何排序，数量限制，以及结果变化时是否通知之类的设定。

#### PHImageManager

`PHImageManager`的单例负责加载图像资源模型对应的图像内容，还可指明目标图像尺寸，缩放模式，以及其他一些高级设置。它异步处理加载、缓存、加工图像以及重用图像的任务。另外，还有个子类`PHCachingImageManager`，可以预加载图像内容到内存，对于提高 table view 或者 collection view 的流畅性十分有用。

#### PHImageRequestOptions 和 PHVideoRequestOptions

可以通过`PHImageRequestOptions`和`PHVideoRequestOptions`对象来设置加载图像时的高级设定，例如是否同步执行、图像版本、图像质量、缩放模式、裁剪区域、是否加载 iCloud 端数据，甚至还可以传入闭包来监听下载进度。

<a name="Requesting_changes_and_editing_content"></a>
## 概览：修改图像资源模型与编辑图像内容

下面这些类可用于改变照片库和编辑图像：

#### PHPhotoLibrary

`PHPhotoLibrary`是代表用户照片库的全局共享对象，通过该对象来改变照片库，可对图像或者相册进行添加、删除以及编辑。还可以注册改变通知，从而在照片库发生改变时得到通知，无论这改变是应用程序本身造成的还是其他应用造成的。所有的修改都是异步执行的（也可以使用同步），而且必须在其闭包中执行。

#### PHAssetChangeRequest

可通过`PHAssetChangeRequest`的类方法创建一个针对`PHAsset`的请求，通过该请求来创建、编辑、删除一个`PHAsset`对象。该请求有一些和`PHAsset`对象的属性对应的属性，通过这些属性来修改`PHAsset`对象。例如，可以通过`favorite`属性修改一个`PHAsset`对象的`favorite`属性。

#### PHAssetCollectionChangeRequest 和 PHCollectionListChangeRequest

分别用来创建相应的请求来创建、编辑、删除`PHAssetCollection`和`PHCollectionList`，以及移动合并等操作。

#### PHContentEditingInput

可以通过`PHAsset`对象的`requestContentEditingInputWithOptions(_:completionHandler:)`方法获取该对象，它提供了被编辑的`PHAsset`对象的一些信息和元数据，以及用于预览的图片等。使用该对象实例化一个`PHContentEditingOutput`对象。

#### PHContentEditingOutput

该对象用来表示编辑的结果。将记录编辑信息的数据提供给其`adjustmentData`属性，然后将编辑过的图像数据写入到`renderedContentURL`属性指定的 URL，最后将该对象赋值给`PHAssetChangeRequest`对象的`contentEditingOutput`属性。

#### PHAdjustmentData

该对象表示对图像进行编辑的记录数据。例如，使用其`formatIdentifier`属性记录应用标识，如“com.example.myApp”；使用其`formatVersion`属性记录此次编辑的版本号，如“1.0”；使用其`data`参数记录此次编辑的一些参数信息，例如通过将各种滤镜参数信息保存为一个字典赋值给该属性。在编辑图像时，可以通过检索`PHContentEditingInput`对象的`adjustmentData`属性来判断应用程序是否可以重现该图像上次的编辑状态，如果可以支持，那么用户就可以恢复或者修改上次的编辑状态。

<a name="Observing_changes"></a>
## 概览：监听改变

下面这些类提供了照片库的改变详情：

#### PHChange

通过`PHPhotoLibrary`注册改变通知后，就可以在通知回调方法中得到`PHChange`对象。可以通过该对象的`changeDetailsForObject(_:)`和`changeDetailsForFetchResult(_:)`方法进一步获取改变详情。

#### PHObjectChangeDetails

利用`PHChange`对象的`changeDetailsForObject(_:)`方法，可以获取先前获取到的`PHAsset`、`PHAssetCollection`、`PHCollectionList`对象的改变详情，其返回值即是`PHObjectChangeDetails`对象。如果没有任何改变，那么返回值会为`nil`。可通过该对象获取改变前后的模型对象，判断该模型对象是否已被从照片库移除等。如果模型对象是`PHAsset`，还可以通过`assetContentChanged`属性判断其图像内容是否发生改变，从而加载新图像。

`PHObjectChangeDetails`仅仅体现模型本身属性的变化，例如`PHAsset`对象的各种元数据属性，`PHAssetCollection`的标题之类。若想获取`PHAssetCollection`或`PHCollectionList`这种集合模型中元素的添加移除移动等改变，需要使用`PHChange`对象的`changeDetailsForFetchResult(_:)`方法。

#### PHFetchResultChangeDetails

利用`PHChange`对象的`changeDetailsForFetchResult(_:)`方法，可获取到`PHFetchResult`对象的改变详情，其返回值即是`PHFetchResultChangeDetails`对象。如果没有任何改变，那么返回值会为`nil`。

可通过该对象获取改变前后的`PHFetchResult`对象。如果其`hasIncrementalChanges`属性为`true`，还可获取到发生移除、插入、改变的索引以及涉及到的模型对象。该属性与用`PHAsset`、`PHAssetCollection`、`PHCollectionList`的类方法获取模型时传入的`PHFetchOptions`参数对象有关，若该参数对象的属性`wantsIncrementalChangeDetails`为`true`（默认为`true`），则该属性即为`true`，也就是说默认情况下该属性会为`true`。如果该属性为`true`，更新 table view 或者 collection view 时就可以针对变化的索引进行操作，否则，就只能用改变后的`PHFetchResult`对象重新 reloadData。

配合 table view 或者 collection view 时，若针对变化索引进行操作，应符合一定顺序。一定要先移除单元格，再插入单元格，然后更新内容变化的单元格，最后通过判断`hasMoves`属性来判断是否有索引发生了移动，若是则使用`enumerateMovesWithBlock(_:)`方法遍历发生移动的索引并对相应单元格进行移动。

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

<a name="Fetching_objects"></a>
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
// 获取所有用户创建的相册，其结果为 PHFetchResult 对象，该集合中的元素为 PHAssetCollection 对象.
let userAlbums = PHAssetCollection.fetchTopLevelUserCollectionsWithOptions(nil)

// 也可以这样
// PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .AlbumRegular, options: nil)

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
                        
<a name="Loading_content"></a>
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
    /*  追求效率的拉伸。最终图片尺寸可能和期望支持不太相符。 */
    case Fast
    /*  牺牲效率，最终图片尺寸完全符合期望值。如果设置了 normalizedCropRect，则必须使用该选项。 */
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

<a name="changes_objects"></a>
## 修改图像资源模型

#### 创建相册

```swift
var assetPlaceholder: PHObjectPlaceholder!
PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
    let changeRequset = PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle("相册名字")
    assetPlaceholder = changeRequset.placeholderForCreatedAssetCollection // 用占位对象引用新创建的相册.
}, completionHandler: { success, error in
    guard success else {
        print("Failed to create album.\n", error)
        return
    }
    dispatch_async(dispatch_get_main_queue()) { // 闭包会在任意线程调用.
    	// 使用占位对象的 localIdentifier 获取创建好的对应相册.
    	let collections = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers(
    	[assetPlaceholder.localIdentifier], options: nil)
    	// 更新 UI...
    }
})
```

#### 添加图像资源模型

```swift
var assetPlaceholder: PHObjectPlaceholder!
PHPhotoLibrary.sharedPhotoLibrary().performChanges({
    // 利用一张图片创建 PHAssetChangeRequest.
    let createAssetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(anImage)
    // 获取该请求的占位对象.
    assetPlaceholder = createAssetRequest.placeholderForCreatedAsset
    // 针对一个相册创建 PHAssetCollectionChangeRequest.
    let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: anAlbum)!
    // 通过占位对象添加到相册.
    albumChangeRequest.addAssets([assetPlaceholder])
}, completionHandler: { _ in
    // 完成后可根据占位对象的 localIdentifier 获取到刚刚添加的 PHAsset 对象,此处即是 fetchResult[0].
    let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers([assetPlaceholder.localIdentifier], options: nil)
})
```

#### 编辑图像资源模型元数据

```swift
PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
    let request = PHAssetChangeRequest(forAsset: anAsset) // 创建请求.
    request.favorite = !anAsset.favorite // 修改请求对应的属性.
}, completionHandler: nil)
```

#### 删除图像资源模型

```swift
PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
    PHAssetChangeRequest.deleteAssets([anAsset])
}, completionHandler: nil)
```

另外，进行修改前最好通过`canPerformEditOperation(_:)`方法判断下能否支持该操作。操作分为以下三种：

```swift
@available(iOS 8.0, *)
public enum PHAssetEditOperation : Int {
    case Delete 	// 删除操作.
    case Content 	// 编辑内容.
    case Properties // 编辑元数据.
}
```

<a name="editing_content"></a>
## 修改图像资源内容

可使用`PHAsset`对象的如下方法。调用此方法时，`Photo`框架会加载图像内容，加载完成会调用`completionHandler` 闭包。

```swift
public func requestContentEditingInputWithOptions(options: PHContentEditingInputRequestOptions?, 		
	completionHandler: (PHContentEditingInput?, [NSObject : AnyObject]) -> Void) 
	-> PHContentEditingInputRequestID
```

闭包的字典参数可获取一些信息，支持如下键：

- `PHContentEditingInputResultIsInCloudKey`：如果取出的`Bool`值为`true`，说明图像资源在 iCloud 端，而且`PHContentEditingInputRequestOptions`参数对象的`networkAccessAllowed`属性未开启。
- `PHContentEditingInputCancelledKey`：如果加载请求被中途取消，取出的`Bool`值为`true`。
- `PHContentEditingInputErrorKey`：如果发生错误可以用该键取出`NSError`对象进行查看。

该方法会返回一个`PHContentEditingInputRequestID`，可配合`cancelContentEditingInputRequest(:_)`方法取消一个加载中的编辑请求。

#### PHContentEditingInputRequestOptions

可通过该参数对象设置`canHandleAdjustmentData`闭包来针对`PHAdjustmentData`对象进行判断，通常可以比较其`formatIdentifier`和`formatVersion`属性，如果应用能够重现上次的编辑状态，返回`true`，系统就会提供原图。如果返回`false`，系统就会提供上次编辑过后的图片。

```swift
let options = PHContentEditingInputRequestOptions()
options.canHandleAdjustmentData = {
    $0.formatIdentifier == "com.cjyh.xxx" && $0.formatVersion == "1.0"
}
```

还可以设置`networkAccessAllowed`属性决定是否加载 iCloud 端的图片，默认是`true`。

另外还可以利用`progressHandler`闭包处理下载进度。

#### PHContentEditingInput

可通过该对象的`displaySizeImage`属性获取供编辑展示用的图片，通过`fullSizeImageURL`获取完全尺寸的原图，待编辑结束后，将编辑信息应用于原图，然后创建`PHContentEditingOutput`并于`PHPhotoLibrary`的闭包中提交。

#### PHContentEditingOutput

该对象一般会利用`PHContentEditingInput`对象创建，只有`adjustmentData`和`renderedContentURL`两个属性。

`adjustmentData`用于设置此次编辑信息。`renderedContentURL`用于提供 URL，供写入编辑后的二进制图像数据。

#### 用法示例

```swift
// 用 PHAsset 对象创建请求.
anAsset.requestContentEditingInputWithOptions(nil) { input, _ in

    /*	用于记录此次编辑信息的对象,主要为了之后能识别此次编辑情况,从而恢复操作之类的.
        一般会使用应用标识,版本号,以及一个字典之类的对象的二进制数据.
        例如对图像进行了滤镜处理后,可用字典记录滤镜处理的各项参数设置.  */
    let adjustmentData = PHAdjustmentData(formatIdentifier: "com.cjyh.xxx", formatVersion: "1.0", data: aData)
    
    // 利用 PHContentEditingInput 对象创建 PHContentEditingOutput 对象.
    let contentEditingOutput = PHContentEditingOutput(contentEditingInput: input!)
    contentEditingOutput.adjustmentData = adjustmentData
    
    // 将编辑后的图像序列化为二进制数据,写入 PHContentEditingOutput 对象的 renderedContentURL 属性指定的 URL.
    UIImageJPEGRepresentation(anImage, 1.0)!.writeToURL(contentEditingOutput.renderedContentURL, atomically: true)

    // 提交更改.
    PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
        let request = PHAssetChangeRequest(forAsset: stitch)
        request.contentEditingOutput = contentEditingOutput
    }, completionHandler: nil)
}
```

<a name="observing_changes"></a>
## 监听改变

可以通过`PHPhotoLibrary`注册通知监听照片库的变化，无论是应用内造成的改变还是其他应用造成的改变，都会得到通知。

```swift
PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)   // 注册改变通知.
PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self) // 注销改变通知.
```

作为观察者需采纳`PHPhotoLibraryChangeObserver`协议，实现如下方法：

```swift
func photoLibraryDidChange(changeInstance: PHChange) {
    dispatch_async(dispatch_get_main_queue()) {
        // 注意，此方法会在任意线程调用.
    }
}
```

#### PHChange

`PHChange`提供了两个实例方法：

```swift
/*	若无任何改变，此方法会返回 nil。
	此方法只能体现 PHObject 对象自身的改变，例如元数据、标题之类的改变，
	无法反映出 PHAssetCollection 或 PHCollectionList 这种集合模型中元素数量、顺序以及元素本身的变化。*/
public func changeDetailsForObject(object: PHObject) -> PHObjectChangeDetails?

/*	若无任何改变，此方法会返回 nil。
	此方法只能体现 PHFetchResult 对象中元素数量、顺序的变化，无法反映出元素本身的变化。*/
public func changeDetailsForFetchResult(object: PHFetchResult) -> PHFetchResultChangeDetails?
```

#### PHObjectChangeDetails

可以分别通过其`objectBeforeChanges`和`objectAfterChanges`属性获得改变前后的`PHObject`对象。

通过`objectWasDeleted`属性判断该模型是否已从照片库删除。

如果`PHObject`对象是`PHAsset`对象，还可以通过`assetContentChanged`属性判断模型对应的图像内容是否发生改变。

#### PHFetchResultChangeDetails

可以分别通过`fetchResultBeforeChanges`和`fetchResultAfterChanges`属性获取改变前后的`PHFetchResult`对象。

如果其`hasIncrementalChanges`属性为`true`，那么下面的属性都将可用：

- `removedIndexes`
- `removedObjects`
- `insertedIndexes`
- `insertedObjects`
- `changedIndexes`
- `changedObjects`

如果获取模型时传入的`PHFetchOptions`参数对象的`wantsIncrementalChangeDetails`属性为`false`（默认为`true`），那么`hasIncrementalChanges`属性就会为`false`。

配合 table view 或者 collection view 时，若`hasIncrementalChanges`属性为`false`，那么此时只能根据`fetchResultAfterChanges`获取改变后的`PHFetchResult`，然后 reloadData。

若`hasIncrementalChanges`属性为`true`，那么可利用上述六个属性针对特定的索引和单元格更新 UI。更新 UI 的操作顺序必须是先移除被移除的单元格，再插入新插入的单元格，然后更新内容变化的单元格，最后再通过`hasMoves`属性判断是否有移动的情况，若是则进一步利用`enumerateMovesWithBlock(_:)`方法遍历发生移动的索引，并移动对应的单元格。
