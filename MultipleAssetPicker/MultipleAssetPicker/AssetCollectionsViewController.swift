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

protocol AssetPickerDelegate: class {
    func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])
    func assetPickerDidCancel()
}

class AssetCollectionsViewController: UITableViewController {

    // MARK: -

    weak var delegate: AssetPickerDelegate?
    let selectedAssets = SelectedAssets()

    private let AssetCollectionCellReuseIdentifier = "AssetCollectionCell"
    private let sectionNames = ["","","Albums"]
    private var userAlbums: PHFetchResult!
    private var userFavorites: PHFetchResult!

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        // Check for permissions and load assets
        requestAuthorization()
    }

    override func viewWillAppear(animated: Bool)  {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Set up AssetCollectionViewController
        let destination = segue.destinationViewController as! AssetsViewController
        destination.selectedAssets = selectedAssets

        let cell = sender as! UITableViewCell
        destination.title = cell.textLabel!.text

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let indexPath = tableView.indexPathForCell(cell)!
        switch indexPath.section {
        case 0: // Selected
            destination.assetsFetchResults = nil
        case 1:
            if indexPath.row == 0 { // All Photos
                destination.assetsFetchResults = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
            } else { // Favorites
                let favorites = userFavorites[indexPath.row - 1] as! PHAssetCollection
                destination.assetsFetchResults = PHAsset.fetchAssetsInAssetCollection(favorites, options: options)
            }
        case 2: // Albums
            let album = userAlbums[indexPath.row] as! PHAssetCollection
            destination.assetsFetchResults = PHAsset.fetchAssetsInAssetCollection(album, options: options)
        default: break
        }
    }
}

// MARK: - Actions

private extension AssetCollectionsViewController {

    @IBAction func donePressed(sender: AnyObject) {
        delegate?.assetPickerDidFinishPickingAssets(selectedAssets.assets)
    }

    @IBAction func cancelPressed(sender: AnyObject) {
        delegate?.assetPickerDidCancel()
    }
}

// MARK: - Private

private extension AssetCollectionsViewController {

    /*  异步获取相册权限。
        如果用户尚未做出过选择，调用此方法会弹窗询问，在用户做出选择后，闭包会被调用。
        如果用户已经做出过选择，调用此方法会直接执行闭包。*/
    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization { state in
            dispatch_async(dispatch_get_main_queue()) {
                switch state {
                case .Authorized:
                    self.fetchCollections()
                    self.tableView.reloadData()
                default:
                    self.showNoAccessAlertAndCancel()
                }
            }
        }
    }

    func fetchCollections() {
        // 获取用户相册根节点包含的所有图像资源。
        userAlbums = PHAssetCollection.fetchTopLevelUserCollectionsWithOptions(nil)
        // 获取 Favorites 图像资源。
        userFavorites = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum,
            subtype: .SmartAlbumFavorites, options: nil)
    }

    func showNoAccessAlertAndCancel() {
        let alert = UIAlertController(
            title: "No Photo Permissions",
            message: "Please grant Stitch photo access in Settings -> Privacy",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            self.cancelPressed(self)
        }))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            return
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension AssetCollectionsViewController {

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

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(AssetCollectionCellReuseIdentifier,
            forIndexPath: indexPath)

        cell.detailTextLabel!.text = nil

        // Populate the table cell
        switch indexPath.section {
        case 0: // Selected
            cell.textLabel!.text = "Selected"
            cell.detailTextLabel!.text = "\(selectedAssets.assets.count)"
        case 1:
            if indexPath.row == 0 { // All Photos
                cell.textLabel!.text = "All Photos"
            } else { // Favorites
                let favorites = userFavorites[indexPath.row - 1] // 第一行是 “All Photos”，因此需要 -1。
                cell.textLabel!.text = favorites.localizedTitle
                if favorites.estimatedAssetCount != NSNotFound {
                    cell.detailTextLabel!.text = "\(favorites.estimatedAssetCount)"
                }
            }
        case 2: // Albums
            let album = userAlbums[indexPath.row] as! PHAssetCollection
            cell.textLabel!.text = album.localizedTitle
            if album.estimatedAssetCount != NSNotFound {
                cell.detailTextLabel!.text = "\(album.estimatedAssetCount)"
            }
        default: break
        }

        return cell
    }
}
