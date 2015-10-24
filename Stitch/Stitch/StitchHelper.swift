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
import CoreGraphics

let StitchWidth = 900
let MaxPhotosPerStitch = 6

let StitchAdjustmentFormatIdentifier = "RW.stitch.adjustmentFormatID"

class StitchHelper: NSObject {
  
  // MARK: Stitch Creation
  class func createNewStitchWith(assets: [PHAsset], inCollection collection: PHAssetCollection) {
    // Create a new asset for the new stitch
    // 1
    let stitchImage = self.createStitchImageWithAssets(assets)
    
    // 2
    var stitchPlaceholder: PHObjectPlaceholder!
    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
      // 3
      let assetChangeRequest =
        PHAssetChangeRequest.creationRequestForAssetFromImage(
        stitchImage)
      stitchPlaceholder =
        assetChangeRequest.placeholderForCreatedAsset
      
      // 4
      let assetCollectionChangeRequest =
        PHAssetCollectionChangeRequest(forAssetCollection: collection)
      assetCollectionChangeRequest!.addAssets([stitchPlaceholder])
    }, completionHandler: { _, _ in
      // Fetch the asset and add modification data to it
      let fetchResult = PHAsset.fetchAssetsWithLocalIdentifiers(
        [stitchPlaceholder.localIdentifier], options: nil)
      let stitchAsset = fetchResult[0] as! PHAsset
      
      self.editStitchContentWith(stitchAsset,
        image: stitchImage, assets: assets)
    })
  }
  
  // MARK: Stitch Content
  class func editStitchContentWith(stitch: PHAsset, image: UIImage, assets: [PHAsset]) {
    // Update the stitch with the new assets
    //1
    let stitchJPEG = UIImageJPEGRepresentation(image, 0.9)
    let assetIDs = assets.map { asset in
      (asset as PHAsset).localIdentifier
    }
    let assetsData =
      NSKeyedArchiver.archivedDataWithRootObject(assetIDs)
    // 2
    stitch.requestContentEditingInputWithOptions(nil)
    {  contentEditingInput, _ in
      // 3
      let adjustmentData = PHAdjustmentData(formatIdentifier:
        StitchAdjustmentFormatIdentifier, formatVersion: "1.0",
        data: assetsData)
      // 4
      let contentEditingOutput = PHContentEditingOutput(
        contentEditingInput: contentEditingInput!)
      stitchJPEG?.writeToURL(
        contentEditingOutput.renderedContentURL, atomically: true)
      contentEditingOutput.adjustmentData = adjustmentData
      // 5
      PHPhotoLibrary.sharedPhotoLibrary().performChanges({
        let request = PHAssetChangeRequest(forAsset: stitch)
        request.contentEditingOutput = contentEditingOutput
      }, completionHandler: nil)
    }
  }
  
  class func loadAssetsInStitch(stitch: PHAsset, completion: [PHAsset] -> ()) {
    // 1
    let options = PHContentEditingInputRequestOptions()
    options.canHandleAdjustmentData = { adjustmentData in
      (adjustmentData.formatIdentifier == StitchAdjustmentFormatIdentifier) &&
      (adjustmentData.formatVersion == "1.0")
    }
    // 2
    stitch.requestContentEditingInputWithOptions(options)
    { contentEditingInput, _ in
      if let adjustmentData = contentEditingInput?.adjustmentData {
        // 3
        let stitchAssetsID =
        NSKeyedUnarchiver.unarchiveObjectWithData(
          adjustmentData.data) as! [String]
        let stitchAssetsFetchResult =
          PHAsset.fetchAssetsWithLocalIdentifiers(
          stitchAssetsID, options: nil)
        // 4
        var stitchAssets: [PHAsset] = []
        stitchAssetsFetchResult.enumerateObjectsUsingBlock
        { obj, _, _ in
          stitchAssets.append(obj as! PHAsset)
        }
        completion(stitchAssets)
      } else {
      // 5
      completion([])
      }
    }
  }
  
  // MARK: Stitch Image Creation
  class func createStitchImageWithAssets(assets: [PHAsset]) -> UIImage {
    var assetCount = assets.count
    
    // Cap to 6 max photos
    if (assetCount > MaxPhotosPerStitch) {
      assetCount = MaxPhotosPerStitch
    }
    
    // Calculate placement rects
    let placementRects = placementRectsForAssetCount(assetCount)
    
    // Create context to draw images
    let deviceScale = UIScreen.mainScreen().scale
    UIGraphicsBeginImageContextWithOptions(CGSize(width: StitchWidth, height: StitchWidth), true, deviceScale)
    
    let options = PHImageRequestOptions()
    options.synchronous = true
    options.resizeMode = .Exact
    options.deliveryMode = .HighQualityFormat
    
    // Draw each image into their rect
    for (i, asset): (Int, PHAsset) in assets.enumerate() {
      if (i >= assetCount) {
        break
      }
      let rect = placementRects[i]
      let targetSize = CGSize(width: CGRectGetWidth(rect)*deviceScale, height: CGRectGetHeight(rect)*deviceScale)
      PHImageManager.defaultManager().requestImageForAsset(asset, targetSize:targetSize, contentMode:.AspectFill, options:options) { result, _ in
        if result!.size != targetSize {
          let croppedResult = self.cropImageToCenterSquare(result!, size:targetSize)
          croppedResult.drawInRect(rect)
        } else {
          result!.drawInRect(rect)
        }
      }
    }
    
    // Grab results
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result
  }
  
  private class func placementRectsForAssetCount(count: Int) -> [CGRect] {
    var rects: [CGRect] = []
    
    var evenCount: Int
    var oddCount: Int
    if count % 2 == 0 {
      evenCount = count
      oddCount = 0
    } else {
      oddCount = 1
      evenCount = count - oddCount
    }
    
    let rectHeight = StitchWidth / (evenCount / 2 + oddCount)
    let evenWidth = StitchWidth / 2
    let oddWidth = StitchWidth
    
    for i in 0..<evenCount {
      let rect = CGRect(x: i%2 * evenWidth, y: i/2 * rectHeight, width: evenWidth, height: rectHeight)
      rects.append(rect)
    }
    
    if oddCount > 0 {
      let rect = CGRect(x: 0, y: evenCount/2 * rectHeight, width: oddWidth, height: rectHeight)
      rects.append(rect)
    }
    
    return rects
  }
  
  // Helper to crop Image if it wasn't properly cropped
  private class func cropImageToCenterSquare(image: UIImage, size: CGSize) -> UIImage {
    let ratio = min(image.size.width / size.width, image.size.height / size.height)
    
    let newSize = CGSize(width: image.size.width / ratio, height: image.size.height / ratio)
    let offset = CGPoint(x: 0.5 * (size.width - newSize.width), y: 0.5 * (size.height - newSize.height))
    let rect = CGRect(origin: offset, size: newSize)
    
    UIGraphicsBeginImageContext(size)
    image.drawInRect(rect)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return output
  }
  
}
