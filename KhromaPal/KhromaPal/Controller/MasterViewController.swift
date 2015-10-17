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

class MasterViewController: UITableViewController {

    lazy var detailViewController: DetailViewController = {
        let navController = self.splitViewController!.viewControllers.last! as! UINavigationController
        let detailViewController = navController.topViewController as! DetailViewController
        return detailViewController
    }()

    var paletteCollection = ColorPaletterProvider().rootCollection

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "handleShowDetailViewControllerTargetChanged:",
            name: UIViewControllerShowDetailTargetDidChangeNotification,
            object: nil)
    }

    // splitViewController 在 expands 和 collapses 之间变化时会发出通知,在此改变 cell 的 accessoryType.
    func handleShowDetailViewControllerTargetChanged(sender: NSNotification) {
        tableView.indexPathsForVisibleRows?.forEach {
            tableView(tableView, willDisplayCell: tableView.cellForRowAtIndexPath($0)!, forRowAtIndexPath: $0)
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = tableView.indexPathForSelectedRow!
            let detailNav = segue.destinationViewController as! UINavigationController
            let detailVC  = detailNav.topViewController as! DetailViewController
            let palette   = paletteCollection.children[indexPath.row] as! ColorPalette
            detailVC.colorPalette = palette
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            return !rowHasChildrenAtIndex(selectedIndexPath)
        }
        return false
    }

    // MARK: - private

    private func rowHasChildrenAtIndex(indexPath: NSIndexPath) -> Bool {
        let item = paletteCollection.children[indexPath.row]
        return item is ColorPaletteCollection
    }
}

// MARK: - Table View Data Source

extension MasterViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paletteCollection.children.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let object = paletteCollection.children[indexPath.row]
        cell.textLabel?.text = object.name
        return cell
    }

    override func tableView(tableView: UITableView,
        willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        let segueWillPush: Bool
        if rowHasChildrenAtIndex(indexPath) {
            segueWillPush = showViewControllerWillResultInPush(self)
        } else {
            segueWillPush = showDetailViewControllerWillResultInPush(self)
        }
        cell.accessoryType = segueWillPush ? .DisclosureIndicator : .None
    }
}

// MARK: - Table View Data Delegate

extension MasterViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(rowHasChildrenAtIndex(indexPath)) {
            let childCollection = paletteCollection.children[indexPath.row] as! ColorPaletteCollection
            let newTable = storyboard!.instantiateViewControllerWithIdentifier("MasterVC") as! MasterViewController
            newTable.paletteCollection = childCollection
            newTable.title = childCollection.name
            navigationController!.showViewController(newTable, sender: self)
        }
    }
}

// MARK: - PaletteSelectionContainer

extension MasterViewController: PaletteSelectionContainer {
    func currentlySelectedPalette() -> ColorPalette? {
        // 选中行没有子菜单,说明它表示一个调色盘.否则,说明它是一个一级菜单.
        if let indexPath = tableView.indexPathForSelectedRow
            where !rowHasChildrenAtIndex(indexPath) {
            return paletteCollection.children[indexPath.row] as? ColorPalette
        }
        return nil
    }
}
