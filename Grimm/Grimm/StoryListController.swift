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

private let StoryListToStoryViewSegueIdentifier = "StoryListToStoryView";

class StoryListController: UITableViewController, ThemeAdopting {

    private var stories = [Story]()

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 145
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.titleView = UIImageView(image: UIImage(named: "Bull"))

        registerForNotifications()
        reloadTheme()

        Story.loadStories() { loadedStories, error in
            if let stories = loadedStories {
                self.stories = stories
                var indexPaths = [NSIndexPath]()
                for row in 0..<stories.count {
                    indexPaths.append(NSIndexPath(forRow: row, inSection: 0))
                }
                self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            }
        }
    }

    // MARK: - Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == StoryListToStoryViewSegueIdentifier {
            let storyViewController = segue.destinationViewController as! StoryViewController
            storyViewController.story = sender as? Story;
        }
    }

    // MARK: - 更新字体

    func preferredContentSizeCategoryDidChange(notification: NSNotification!) {
        tableView.reloadData()
    }

    // MARK: - Private

    private func registerForNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "preferredContentSizeCategoryDidChange:",
            name: UIContentSizeCategoryDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: "themeDidChange:",
            name: ThemeDidChangeNotification, object: nil)
    }

    func themeDidChange(notification: NSNotification!) {
        reloadTheme()
    }
    
    func reloadTheme() {
        let theme = Theme.sharedInstance
        tableView.separatorColor = theme.separatorColor
        
        if let indexPaths = tableView.indexPathsForVisibleRows {
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        }
    }
}

// MARK: - UITableViewDataSource
extension StoryListController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return stories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell  {
        let storyCell = tableView.dequeueReusableCellWithIdentifier("StoryCell") as! StoryCell
        storyCell.story = stories[indexPath.row]
        return storyCell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let story = stories[indexPath.row]
        performSegueWithIdentifier(StoryListToStoryViewSegueIdentifier, sender: story)
    }
}
