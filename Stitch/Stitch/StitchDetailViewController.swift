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

let StitchEditSegueID = "StitchEditSegue"

class StitchDetailViewController: UIViewController, PHPhotoLibraryChangeObserver, AssetPickerDelegate {
  
  var asset: PHAsset!
  
  @IBOutlet private var imageView: UIImageView!
  
  @IBOutlet private var editButton: UIBarButtonItem!
  @IBOutlet private var favoriteButton: UIBarButtonItem!
  @IBOutlet private var deleteButton: UIBarButtonItem!
  
  private var stitchAssets:[PHAsset]?
  
  deinit {
    PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(
      self)
  }
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(
      self)
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    
    displayImage()
    
    // Update the interface buttons
    editButton.enabled = asset.canPerformEditOperation(.Content)
    favoriteButton.enabled =
      asset.canPerformEditOperation(.Properties)
    deleteButton.enabled = asset.canPerformEditOperation(.Delete)
    updateFavoriteButton()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    if segue.identifier == StitchEditSegueID {
      let nav = segue.destinationViewController as! UINavigationController
      let dest = nav.viewControllers[0] as! AssetCollectionsViewController
      dest.delegate = self
      
      // Set up AssetCollectionsViewController
      if let assets = stitchAssets {
        dest.selectedAssets = SelectedAssets(assets: assets)
      } else {
        dest.selectedAssets = nil
      }
    }
  }
  
  // MARK: Private
  private func displayImage() {
    // Load a high quality image to display
    // 1
    let scale = UIScreen.mainScreen().scale
    let targetSize = CGSize(
      width: CGRectGetWidth(imageView.bounds) * scale,
      height: CGRectGetHeight(imageView.bounds) * scale)
    
    // 2
    let options = PHImageRequestOptions()
    options.deliveryMode = .HighQualityFormat
    options.networkAccessAllowed = true;
    
    // 3
    PHImageManager.defaultManager().requestImageForAsset(asset,
      targetSize: targetSize,
      contentMode: .AspectFill,
      options: options)
      { result, info in
        if (result != nil) {
          self.imageView.image = result
        }
      }
  }
  
  private func updateFavoriteButton() {
    if asset.favorite {
      favoriteButton.title = "Unfavorite"
    } else {
      favoriteButton.title = "Favorite"
    }
  }
  
  // MARK: Actions
  @IBAction func favoritePressed(sender:AnyObject!) {
    PHPhotoLibrary.sharedPhotoLibrary().performChanges ({
      let request = PHAssetChangeRequest(forAsset: self.asset)
      request.favorite = !self.asset.favorite
    }, completionHandler: nil)
  }
  
  @IBAction func deletePressed(sender:AnyObject!) {
    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
      PHAssetChangeRequest.deleteAssets([self.asset])
    }, completionHandler: nil)
  }
  
  @IBAction func editPressed(sender:AnyObject!) {
    // Load the selected stitches then perform the segue to the picker
    StitchHelper.loadAssetsInStitch(asset) { stitchAssets in
      self.stitchAssets = stitchAssets
      dispatch_async(dispatch_get_main_queue()) {
      self.performSegueWithIdentifier(StitchEditSegueID,
      sender: self)
      }
    }
  }
  
  // MARK: AssetPickerDelegate
  
  func assetPickerDidCancel() {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])  {
    dismissViewControllerAnimated(true, completion: nil)
      // Update stitch with new assets
    let stitchImage =
      StitchHelper.createStitchImageWithAssets(selectedAssets)
    StitchHelper.editStitchContentWith(self.asset,
      image: stitchImage, assets: selectedAssets)
  }
  
  
  // MARK: PHPhotoLibraryChangeObserver
  func photoLibraryDidChange(changeInstance: PHChange)  {
    // Respond to changes
    // 1
    dispatch_async(dispatch_get_main_queue()) {
      // 2
      if let changeDetails = changeInstance.changeDetailsForObject(self.asset) {
        // 3
        if changeDetails.objectWasDeleted {
          self.navigationController?.popViewControllerAnimated(true)
          return
        }
        // 4
        self.asset = changeDetails.objectAfterChanges as! PHAsset
        if changeDetails.assetContentChanged {
          self.displayImage()
        }
        self.updateFavoriteButton()
      }
    }
  }
}
