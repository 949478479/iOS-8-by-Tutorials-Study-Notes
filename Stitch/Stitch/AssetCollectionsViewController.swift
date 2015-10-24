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

protocol AssetPickerDelegate {
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])
  func assetPickerDidCancel()
}

class AssetCollectionsViewController: UITableViewController, PHPhotoLibraryChangeObserver {
  let AssetCollectionCellReuseIdentifier = "AssetCollectionCell"
  
  // MARK: Variables
  var delegate: AssetPickerDelegate?
  var selectedAssets: SelectedAssets?
  
  private let sectionNames = ["","","Albums"]
  private var userAlbums: PHFetchResult!
  private var userFavorites: PHFetchResult!
  
  deinit {
    PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(
      self)
  }
  
  // MARK: UIViewController
  override func viewDidLoad() {
    super.viewDidLoad()
    PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
    if selectedAssets == nil {
      selectedAssets = SelectedAssets()
    }
    
    // Check for permissions and load assets
    // 1
    PHPhotoLibrary.requestAuthorization { status in
      dispatch_async(dispatch_get_main_queue()) {
        switch status {
        case .Authorized:
          // 2
          self.fetchCollections()
          self.tableView.reloadData()
        default:
          // 3
          self.showNoAccessAlertAndCancel()
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    let destination = segue.destinationViewController as! AssetsViewController
    // Set up AssetCollectionViewController
    // 1
    destination.selectedAssets = selectedAssets
    
    // 2
    let cell = sender as! UITableViewCell
    destination.title = cell.textLabel!.text
    
    // 3
    let options = PHFetchOptions()
    options.sortDescriptors =
      [NSSortDescriptor(key: "creationDate", ascending: true)]
    let indexPath = tableView.indexPathForCell(cell)!
    switch (indexPath.section) {
    case 0:
      // Selected
      destination.assetsFetchResults = nil
    case 1:
      if indexPath.row == 0 {
        // All Photos
        destination.assetsFetchResults  =
          PHAsset.fetchAssetsWithOptions(options)
      } else {
        // Favorites
        let favorites = userFavorites[indexPath.row - 1] as!
        PHAssetCollection
        destination.assetsFetchResults =
          PHAsset.fetchAssetsInAssetCollection(favorites,
            options: options)
      }
    case 2:
      // Albums
      let album = userAlbums[indexPath.row] as! PHAssetCollection
      destination.assetsFetchResults =
        PHAsset.fetchAssetsInAssetCollection(album,
          options: options)
    default:
      break
    }
  }
  
  // MARK: Private
  func fetchCollections() {
    userAlbums = PHCollectionList.fetchTopLevelUserCollectionsWithOptions(nil)
    userFavorites = PHAssetCollection.fetchAssetCollectionsWithType(
      .SmartAlbum,
      subtype: .SmartAlbumFavorites,
      options: nil)
  }
  
  func showNoAccessAlertAndCancel() {
    let alert = UIAlertController(title: "No Photo Permissions", message: "Please grant photo permissions in Settings", preferredStyle: .Alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in
      self.cancelPressed(self)
    }))
    alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { _ in
      UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
      return
    }))
    
    self.presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: Actions
  @IBAction func donePressed(sender: AnyObject) {
    delegate?.assetPickerDidFinishPickingAssets(selectedAssets!.assets)
  }
  
  @IBAction func cancelPressed(sender: AnyObject) {
    delegate?.assetPickerDidCancel()
  }
  
  // MARK: UITableViewDataSource
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return sectionNames.count
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch(section) {
    case 0: // Selected Section
      return 1
    case 1: // All Photos + Favorites
      return 1 + (userFavorites?.count ?? 0)
    case 2: // Albums
      return userAlbums?.count ?? 0
    default:
      return 0
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(AssetCollectionCellReuseIdentifier, forIndexPath: indexPath) 
    cell.detailTextLabel!.text = ""
    
    // Populate the table cell
    switch(indexPath.section) {
    case 0:
      // Selected
      cell.textLabel!.text = "Selected"
      cell.detailTextLabel!.text = "\(selectedAssets!.assets.count)"
    case 1:
      if (indexPath.row == 0) {
        // All Photos
        cell.textLabel!.text = "All Photos"
      } else {
        // Favorites
        let favorites = userFavorites[indexPath.row - 1] as! PHAssetCollection
        cell.textLabel!.text = favorites.localizedTitle
        if (favorites.estimatedAssetCount != NSNotFound) {
          cell.detailTextLabel!.text = "\(favorites.estimatedAssetCount)"
        }
      }
    case 2:
      // Albums
      let album = userAlbums[indexPath.row] as! PHAssetCollection
      cell.textLabel!.text = album.localizedTitle
      if (album.estimatedAssetCount != NSNotFound) {
        cell.detailTextLabel!.text = "\(album.estimatedAssetCount)"
      }
    default:
      break
    }
    return cell
  }
  
  // MARK: PHPhotoLibraryChangeObserver
  func photoLibraryDidChange(changeInstance: PHChange) {
    // Respond to changes
    dispatch_async(dispatch_get_main_queue()) {
      var updatedFetchResults = false
      // 1
      var changeDetails: PHFetchResultChangeDetails? =
        changeInstance.changeDetailsForFetchResult(self.userAlbums)
      if let changes = changeDetails {
        self.userAlbums = changes.fetchResultAfterChanges
        updatedFetchResults = true
      }
      
      changeDetails = changeInstance.changeDetailsForFetchResult(
      self.userFavorites)
      if let changes = changeDetails {
        self.userFavorites = changes.fetchResultAfterChanges
        updatedFetchResults = true
      }
      // 2
      if updatedFetchResults {
        self.tableView.reloadData()
      }
    }
  }
}
