# Beginning Photos

在 iOS 8，开发者迎来了全新的`Photos`框架，它提供了与用户照片库交互的所有功能，用于取代`AssetsLibrary`框架，后者也在 iOS 9 正式弃用了。`Photos`框架包括大量简洁的特性，让开发者能访问并编辑图像，无论是单张图片还是整个相册。

- [抓取资源模型和加载图像内容](#Fetching objects and loading content)


<a name="Fetching objects and loading content"></a>
## 抓取资源模型和加载图像内容

#### 资源模型

`Photos`框架中的资源模型都继承自抽象基类`PHObject`。它们是轻量的对象，只包含描述性的元数据，而不包括图像资源内容。具体的模型类如下：

- `PHAsset`：代表一个单一的图像资源，例如一张图片或者一部视频。包含一些诸如”媒体类型“之类的元数据。
- `PHAssetCollection`：代表一个有序的资源模型集合。
- `PHCollectionList`：代表一个有序的集合的集合，其内容是`PHAssetCollection`或者其他`PHCollectionList`。
- `PHObjectPlaceholder`：代表一个占位模型。

#### 抓取

抓取是`Photos`框架的一个关键功能。通过使用资源模型的类方法来抓取资源模型对象。还可以在抓取时指定`PHFetchOptions`选项。该选项可以指定要抓取哪些资源模型对象，抓取结果如何排序，数量限制，以及结果变化时是否通知之类的设定。

抓取总是返回一个`PHFetchResult`。它是对应资源模型对象的有序集合，有一些非常类似`NSArray`的方法。它会管理内存并执行懒加载，这意味着抓取并遍历大量资源模型也不会大量消耗内存。另外，它是线程安全的。

记住，资源模型不持有其内容。如果想检索资源模型集合中的所有资源模型，必须抓取它们。类似的，如果想显示单一资源模型对应的图片，必须另行加载其图像内容。

#### 加载图像内容

要显示资源模型对应的图像时，需要使用`PHImageManager`的单例来加载。该单例异步处理加载、缓存以及重用图像资源的工作。另外，还有个子类`PHCachingImageManager`，可以预缓存资源模型的图像内容到内存，确保图像在使用时已存在。

