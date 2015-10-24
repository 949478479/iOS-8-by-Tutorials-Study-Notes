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

class AssetsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {
  let AssetCollectionViewCellReuseIdentifier = "AssetCell"
  
  var assetsFetchResults: PHFetchResult?
  var selectedAssets: SelectedAssets!
  
  private var assetThumbnailSize = CGSizeZero
  private let imageManager: PHCachingImageManager =
  PHCachingImageManager()
  private var cachingIndexes: [NSIndexPath] = []
  private var lastCacheFrameCenter: CGFloat = 0
  private var cacheQueue =
  dispatch_queue_create("cache_queue", DISPATCH_QUEUE_SERIAL)
  
  deinit {
    // Unregister observer
  }
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView!.allowsMultipleSelection = true
    resetCache()
    
    // Register observer
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    
    // Calculate Thumbnail Size
    let scale = UIScreen.mainScreen().scale
    let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    
    collectionView!.reloadData()
    updateSelectedItems()
    updateCache()
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView!.reloadData()
    updateSelectedItems()
  }
  
  // MARK: Private
  func currentAssetAtIndex(index:NSInteger) -> PHAsset {
    if let fetchResult = assetsFetchResults {
      return fetchResult[index] as! PHAsset
    } else {
      return selectedAssets.assets[index]
    }
  }
  
  func updateSelectedItems() {
    // Select the selected items
    if let fetchResult = assetsFetchResults {
      // 1
      for asset in selectedAssets.assets {
        let index = fetchResult.indexOfObject(asset)
        if index != NSNotFound {
          let indexPath = NSIndexPath(forItem: index, inSection: 0)
          collectionView!.selectItemAtIndexPath(indexPath,
            animated: false, scrollPosition: .None)
        }
      }
    } else {
      // 2
      for i in 0..<selectedAssets.assets.count {
        let indexPath = NSIndexPath(forItem: i, inSection: 0)
        collectionView!.selectItemAtIndexPath(indexPath,
          animated: false, scrollPosition: .None)
      }
    }
  }
  
  // MARK: UICollectionViewDelegate
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // Update selected Assets
    let asset = currentAssetAtIndex(indexPath.item)
    selectedAssets.assets.append(asset)
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    // Update selected Assets
    // 1
    let assetToDelete = currentAssetAtIndex(indexPath.item)
    selectedAssets.assets = selectedAssets.assets.filter { asset in
      !(asset == assetToDelete)
    }
    // 2
    if assetsFetchResults == nil {
      collectionView.deleteItemsAtIndexPaths([indexPath])
    }
  }
  
  
  // MARK: UICollectionViewDataSource
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
    if let fetchResult = assetsFetchResults {
      return fetchResult.count
    } else if selectedAssets != nil {
      return selectedAssets.assets.count
    }
    return 0
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AssetCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell
    
    // Populate Cell
    // 1
    let reuseCount = ++cell.reuseCount
    let asset = currentAssetAtIndex(indexPath.item)
    
    // 2
    let options = PHImageRequestOptions()
    options.networkAccessAllowed = true
    
    // 3
    imageManager.requestImageForAsset(asset,
      targetSize: assetThumbnailSize,
      contentMode: .AspectFill, options: options)
      { result, info in
        if reuseCount == cell.reuseCount {
          cell.imageView.image = result
        }
    }
    
    return cell
  }
  
  // MARK: UICollectionViewDelegateFlowLayout
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var thumbsPerRow: Int
    switch collectionView.bounds.size.width {
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
    let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
    return CGSize(width: width,height: width)
  }
  
  // MARK: Caching
  func resetCache() {
    imageManager.stopCachingImagesForAllAssets()
    cachingIndexes.removeAll(keepCapacity: true)
    lastCacheFrameCenter = 0
  }
  
  func updateCache() {
    let currentFrameCenter = CGRectGetMidY(collectionView!.bounds)
    if abs(currentFrameCenter - lastCacheFrameCenter) <
      CGRectGetHeight(collectionView!.bounds) / 3 {
        return
    }
    lastCacheFrameCenter = currentFrameCenter
    let numOffscreenAssetsToCache = 60
    
    var visibleIndexes = collectionView!.indexPathsForVisibleItems()
      
    visibleIndexes.sortInPlace { a, b in
      a.item < b.item
    }
    if visibleIndexes.count == 0 {
      return
    }
    
    var totalItemCount = selectedAssets.assets.count
    if let fetchResults = assetsFetchResults {
      totalItemCount = fetchResults.count
    }
    let lastItemToCache = min(totalItemCount,visibleIndexes[visibleIndexes.count-1].item + numOffscreenAssetsToCache/2)
    let firstItemToCache = max(0, visibleIndexes[0].item - numOffscreenAssetsToCache/2)
    
    let options = PHImageRequestOptions()
    options.networkAccessAllowed = true
    options.resizeMode = .Fast
    
    // 1
    var indexesToStopCaching: [NSIndexPath] = []
    cachingIndexes = cachingIndexes.filter { index in
      if index.item < firstItemToCache || index.item > lastItemToCache {
        indexesToStopCaching.append(index)
        return false
      }
      return true
    }
    // 2
    imageManager.stopCachingImagesForAssets(assetsAtIndexPaths(indexesToStopCaching),
      targetSize: assetThumbnailSize,
      contentMode: .AspectFill,
      options: options)
    
    // 1
    var indexesToStartCaching: [NSIndexPath] = []
    for i in firstItemToCache..<lastItemToCache {
      let indexPath = NSIndexPath(forItem: i, inSection: 0)
      if !cachingIndexes.contains(indexPath) {
        indexesToStartCaching.append(indexPath)
      }
    }
    cachingIndexes += indexesToStartCaching
    // 2
    imageManager.startCachingImagesForAssets(
      assetsAtIndexPaths(indexesToStartCaching),
      targetSize: assetThumbnailSize, contentMode: .AspectFill,
      options: options)
  }
  
  func assetsAtIndexPaths(indexPaths:[NSIndexPath]) -> [PHAsset] {
    return indexPaths.map { indexPath in
      return self.currentAssetAtIndex(indexPath.item)
    }
  }
  
  // MARK: UIScrollViewDelegate
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    dispatch_async(cacheQueue) {
      self.updateCache()
    }
  }
  
  // MARK: PHPhotoLibraryChangeObserver
  func photoLibraryDidChange(changeInstance: PHChange)  {
    // Respond to changes
    dispatch_async(dispatch_get_main_queue()) {
      if let collectionChanges =
      changeInstance.changeDetailsForFetchResult(self.assetsFetchResults!)
      {
        self.assetsFetchResults = collectionChanges.fetchResultAfterChanges
        if collectionChanges.hasMoves ||
          !collectionChanges.hasIncrementalChanges {
          self.collectionView!.reloadData()
        } else {
          // perform incremental updates
          self.collectionView!.performBatchUpdates({
            let removedIndexes = collectionChanges.removedIndexes
            if removedIndexes?.count > 0 {
              self.collectionView!.deleteItemsAtIndexPaths(
              self.indexPathsFromIndexSet(removedIndexes!, section: 0))
            }
            let insertedIndexes = collectionChanges.insertedIndexes
            if insertedIndexes?.count > 0 {
              self.collectionView!.insertItemsAtIndexPaths(
              self.indexPathsFromIndexSet(insertedIndexes!, section: 0))
            }
            let changedIndexes = collectionChanges.changedIndexes
            if changedIndexes?.count > 0 {
              self.collectionView!.reloadItemsAtIndexPaths(
              self.indexPathsFromIndexSet(changedIndexes!, section: 0))
            }
          }, completion: nil)
        }
      }
    }
  }
  
  func indexPathsFromIndexSet(indexSet:NSIndexSet, section:Int) -> [NSIndexPath] {
    var indexPaths: [NSIndexPath] = []
    indexSet.enumerateIndexesUsingBlock { i, stop in
      indexPaths.append(NSIndexPath(forItem: i, inSection: section))
    }
    return indexPaths
  }
}
