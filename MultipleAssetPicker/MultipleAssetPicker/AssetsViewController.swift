/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import Photos

class AssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var assetsFetchResults: PHFetchResult?
    var selectedAssets = SelectedAssets()

    private let imageManager = PHCachingImageManager()
    private var cachingIndexes = [NSIndexPath]()
    private var lastCacheFrameCenter: CGFloat = 0

    private var assetThumbnailSize = CGSizeZero
    private let AssetCollectionViewCellReuseIdentifier = "AssetCell"
    @IBOutlet private weak var flowLayout: UICollectionViewFlowLayout!

    deinit {
        imageManager.stopCachingImagesForAllAssets()
    }

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let thumbsPerRow: CGFloat
        switch collectionView!.bounds.width {
        case 0..<400:
            thumbsPerRow = 4
        case 400..<600:
            thumbsPerRow = 5
        case 600..<800:
            thumbsPerRow = 6
        case 800..<1200:
            thumbsPerRow = 7
        default:
            thumbsPerRow = 4
        }
        let itemSize = collectionView!.bounds.width / thumbsPerRow
        flowLayout.itemSize = CGSize(width: itemSize, height: itemSize)

        // Calculate Thumbnail Size
        let scale = UIScreen.mainScreen().scale
        assetThumbnailSize = CGSize(width: itemSize * scale, height: itemSize * scale)

        collectionView!.allowsMultipleSelection = true
        updateSelectedItems()
    }
}

// MARK: - UICollectionViewDelegate

extension AssetsViewController {

    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
        let asset = currentAssetAtIndex(indexPath.row)
        selectedAssets.assets.append(asset)
    }

    override func collectionView(collectionView: UICollectionView,
        didDeselectItemAtIndexPath indexPath: NSIndexPath)  {
        // Update selected Assets
        let assetToDelete = currentAssetAtIndex(indexPath.item)
        selectedAssets.assets.removeAtIndex(selectedAssets.assets.indexOf(assetToDelete)!)

        // assetsFetchResults 为 nil 表示当前显示的是 selectedAssets, 需求是取消一个删除一个.
        if assetsFetchResults == nil {
            collectionView.deleteItemsAtIndexPaths([indexPath])
        }
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        updateCache()
    }
}

// MARK: - UICollectionViewDataSource

extension AssetsViewController {

    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {

        return assetsFetchResults?.count ?? selectedAssets.assets.count
    }

    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            AssetCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell

        // 用于标记 cell 被使用次数来判断是否是重用 cell.
        let reuseCount = ++cell.reuseCount
        let asset = currentAssetAtIndex(indexPath.item)
        // 允许加载 iCloud 上的图像资源.没有 iCloud ...
        let options = PHImageRequestOptions()
        options.resizeMode = .Exact
        options.deliveryMode = .HighQualityFormat

        imageManager.requestImageForAsset(asset,
            targetSize: assetThumbnailSize, contentMode: .AspectFill, options: options) {
            // 确定该 cell 没被重用.
            if reuseCount == cell.reuseCount {
                let image = $0
                if $1![PHImageResultIsDegradedKey] as! Bool == true {

                }
                cell.imageView.image = image
            }
        }
        return cell
    }
}

// MARK: - Private

private extension AssetsViewController {

    func currentAssetAtIndex(index: Int) -> PHAsset {
        if let fetchResult = assetsFetchResults {
            return fetchResult[index] as! PHAsset
        } else {
            return selectedAssets.assets[index]
        }
    }

    func updateSelectedItems() {
        // Select the selected items
        if let assetsFetchResults = assetsFetchResults {
            selectedAssets.assets.forEach {
                let index = assetsFetchResults.indexOfObject($0)
                if index != NSNotFound {
                    let indexPath = NSIndexPath(forItem: index, inSection: 0)
                    collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                }
            }
        } else {
            for index in 0..<selectedAssets.assets.count {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                collectionView!.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
            }
        }
    }

    func updateCache() {
        // 滚动超过三分之一才重新计算缓存.
        let currentBoundsCenter = collectionView!.bounds.midY
        guard abs(currentBoundsCenter - lastCacheFrameCenter) < collectionView!.bounds.height / 3
            else { return }
        lastCacheFrameCenter = currentBoundsCenter

        guard var visibleIndexes = collectionView?.indexPathsForVisibleItems() where visibleIndexes.count > 0
            else { return }
        visibleIndexes.sortInPlace { $0.item < $1.item }

        let totalItemCount = assetsFetchResults?.count ?? selectedAssets.assets.count

        // 沿屏幕上方向缓存 30 个,使用 max(_:_:), 限制索引越界.
        let firstItemToCache = max(0, visibleIndexes[0].item - 30)
        // 沿屏幕下方向缓存 30 个.
        let lastItemToCache  = min(totalItemCount - 1, visibleIndexes.last!.item + 30)

        // 将滚出缓存范围的 item 停止缓存.
        var indexexToStopCaching = [NSIndexPath]()
        cachingIndexes = cachingIndexes.filter {
            if $0.item < firstItemToCache || $0.item > lastItemToCache {
                indexexToStopCaching.append($0)
                return false
            }
            return true
        }
        let assetsToStopCaching = indexexToStopCaching.map { currentAssetAtIndex($0.item) }
        imageManager.stopCachingImagesForAssets(assetsToStopCaching, targetSize: assetThumbnailSize,
            contentMode: .AspectFill, options: nil)

        // 避免重复缓存.
        var indexesToStartCaching = [NSIndexPath]()
        for item in firstItemToCache..<lastItemToCache {
            if (cachingIndexes.contains { $0.item == item }) {
                let indexPath = NSIndexPath(forItem: item, inSection: 0)
                indexesToStartCaching.append(indexPath)
            }
        }
        cachingIndexes += indexesToStartCaching

        // 开始缓存.
        let assetsToStartCaching = indexesToStartCaching.map { currentAssetAtIndex($0.item) }
        imageManager.startCachingImagesForAssets(assetsToStartCaching, targetSize: assetThumbnailSize,
            contentMode: .AspectFill, options: nil)
    }
}
