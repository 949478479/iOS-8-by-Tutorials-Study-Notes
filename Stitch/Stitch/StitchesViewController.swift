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

let StitchesAlbumTitle = "Stitches"

let StitchCellReuseIdentifier = "StitchCell"
let CreateNewStitchSegueID = "CreateNewStitchSegue"
let StitchDetailSegueID = "StitchDetailSegue"

class StitchesViewController: UIViewController, PHPhotoLibraryChangeObserver, AssetPickerDelegate , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var noStitchView: UILabel!
  @IBOutlet private var newStitchButton: UIBarButtonItem!
  
  private var assetThumbnailSize = CGSizeZero
  private var stitches: PHFetchResult!
  private var stitchesCollection: PHAssetCollection!
  
  deinit {
    // Unregister observer
    PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(
      self)
  }
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    PHPhotoLibrary.requestAuthorization { status in
      dispatch_async(dispatch_get_main_queue()) {
        switch status {
          case .Authorized:
            // Register observer
            PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(
              self)
            // Fetch stitches album
            // 1
            let options = PHFetchOptions()
            options.predicate = NSPredicate(format: "title = %@", StitchesAlbumTitle)
            let collections = PHAssetCollection.fetchAssetCollectionsWithType(.Album,
              subtype: .AlbumRegular, options: options)
            // 2
            if collections.count > 0 {
              // Album exists
              self.stitchesCollection = collections[0] as! PHAssetCollection
              // 3
              self.stitches =
              PHAsset.fetchAssetsInAssetCollection(self.stitchesCollection,
                options: nil)
              self.collectionView.reloadData()
              // Hide or Show the label to the user.
              self.updateNoStitchView()
            } else {
              // Create the album
              // 1
              var assetPlaceholder: PHObjectPlaceholder?
              // 2
              PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                // 3
                let changeRequest =
                  PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(StitchesAlbumTitle)
                assetPlaceholder =
                  changeRequest.placeholderForCreatedAssetCollection
              }, completionHandler: { success, error in
                // 4
                if !success {
                  print("Failed to create album")
                  print(error)
                  return
                }
                // 5
                let collections = PHAssetCollection.fetchAssetCollectionsWithLocalIdentifiers(
                  [assetPlaceholder!.localIdentifier], options: nil)
                if collections.count > 0 {
                  self.stitchesCollection =
                    collections[0] as! PHAssetCollection
                  self.stitches = PHAsset.fetchAssetsInAssetCollection(
                    self.stitchesCollection, options: nil)
                }
              })
            }
            // Register observer
          default:
            self.noStitchView.text = "Please grant Stitch photo access in Settings -> Privacy"
            self.noStitchView.hidden = false
            self.newStitchButton.enabled = false
          
            self.showNoAccessAlert()
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Calculate Thumbnail Size
    let scale = UIScreen.mainScreen().scale
    let cellSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
    assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    collectionView.reloadData()
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    collectionView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)  {
    if segue.identifier == CreateNewStitchSegueID {
      let nav = segue.destinationViewController as! UINavigationController
      let dest = nav.viewControllers[0] as! AssetCollectionsViewController
      dest.delegate = self
      dest.selectedAssets = nil
    } else if segue.identifier == StitchDetailSegueID {
      let dest = segue.destinationViewController as! StitchDetailViewController
      let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)!
      dest.asset = stitches[indexPath.item] as! PHAsset
    }
  }
  
  // MARK: Private
  private func updateNoStitchView() {
    noStitchView.hidden = (stitches == nil || (stitches.count > 0))
  }
  
  private func showNoAccessAlert() {
    let alert = UIAlertController(title: "No Photo Access", message: "Please grant Stitch photo access in Settings -> Privacy", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { _ in
      UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
      return
    }))
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: AssetPickerDelegate
  func assetPickerDidCancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])  {
    dismissViewControllerAnimated(true, completion: nil)
    
    if (selectedAssets.count > 0) {
      // Create new Stitch
      StitchHelper.createNewStitchWith(selectedAssets,
        inCollection: stitchesCollection)
    }
  }
  
  // MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return stitches?.count ?? 0
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StitchCellReuseIdentifier, forIndexPath: indexPath) as! AssetCell
    
    // Configure the Cell
    let reuseCount = ++cell.reuseCount
    
    let options = PHImageRequestOptions()
    options.networkAccessAllowed = true
    
    let asset = stitches[indexPath.item] as! PHAsset
    PHImageManager.defaultManager().requestImageForAsset(asset,
      targetSize: assetThumbnailSize,
      contentMode: .AspectFill,
      options: options) { result, info in
        if reuseCount == cell.reuseCount {
          cell.imageView.image = result
        }
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var thumbsPerRow: Int
    switch collectionView.bounds.size.width {
    case 0..<400:
      thumbsPerRow = 2
    case 400..<800:
      thumbsPerRow = 4
    case 800..<1200:
      thumbsPerRow = 5
    default:
      thumbsPerRow = 3
    }
    let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
    return CGSize(width: width,height: width)
  }
  
  // MARK: PHPhotoLibraryChangeObserver
  func photoLibraryDidChange(changeInstance: PHChange)  {
    // Respond to changes
    dispatch_async(dispatch_get_main_queue()) {
      if let collectionChanges =
      changeInstance.changeDetailsForFetchResult(self.stitches)
      {
        self.stitches = collectionChanges.fetchResultAfterChanges
        if collectionChanges.hasMoves ||
          !collectionChanges.hasIncrementalChanges {
          self.collectionView.reloadData()
        } else {
          // perform incremental updates
          self.collectionView.performBatchUpdates({
            let removedIndexes = collectionChanges.removedIndexes
            if removedIndexes?.count > 0 {
              self.collectionView.deleteItemsAtIndexPaths(
              self.indexPathsFromIndexSet(removedIndexes!, section: 0))
            }
            let insertedIndexes = collectionChanges.insertedIndexes
            if insertedIndexes?.count > 0 {
              self.collectionView.insertItemsAtIndexPaths(
              self.indexPathsFromIndexSet(insertedIndexes!, section: 0))
            }
            let changedIndexes = collectionChanges.changedIndexes
            if changedIndexes?.count > 0 {
              self.collectionView.reloadItemsAtIndexPaths(
              self.indexPathsFromIndexSet(changedIndexes!, section: 0))
            }
          }, completion: nil)
        }
      }
    }
  }
  
  // Create an array of index paths from an index set
  func indexPathsFromIndexSet(indexSet:NSIndexSet, section:Int) -> [NSIndexPath] {
    var indexPaths: [NSIndexPath] = []
    indexSet.enumerateIndexesUsingBlock { i, _ in
      indexPaths.append(NSIndexPath(forItem: i, inSection: section))
    }
    return indexPaths
  }
}
