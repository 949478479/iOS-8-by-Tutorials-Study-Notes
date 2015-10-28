/*
* Copyright (c) 2015 Razeware LLC
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

protocol TimeZoneViewControllerDelegate: class {
    func didSelectATimeZone(timeZone: String)
}

class TimeZoneViewController: UIViewController {

    weak var delegate: TimeZoneViewControllerDelegate?
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!

    private let timeZoneNames = NSArray(contentsOfFile:
        NSBundle.mainBundle().pathForResource("TimeZoneNames", ofType: "plist")!)
        as! [ [String : AnyObject] ]

    private lazy var allTimeZoneName: [String] = {
        var allTimeZoneName = [String]()
        self.timeZoneNames.forEach {
            allTimeZoneName.appendContentsOf($0["subTimeZones"] as! [String])
        }
        return allTimeZoneName
    }()

    private var searchResult: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UITableViewDataSource
extension TimeZoneViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return searchResult != nil ? 1 : timeZoneNames.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult?.count ?? (timeZoneNames[section]["subTimeZones"]?.count)!
    }

    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("timeZoneCell", forIndexPath: indexPath)

        let timeZoneName = searchResult?[indexPath.row] ??
            (timeZoneNames[indexPath.section]["subTimeZones"] as! [String])[indexPath.row]

        cell.textLabel!.text = timeZoneName

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectATimeZone(tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text!)
        dismissViewControllerAnimated(true, completion: nil)
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchResult != nil ? nil : timeZoneNames[section]["timeZone"] as? String
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return searchResult != nil ? nil : timeZoneNames.map { $0["timeZoneAbbr"] as! String }
    }
}

// MARK: - UISearchResultsUpdating
extension TimeZoneViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResult = nil
        } else {
            searchResult = allTimeZoneName.filter { $0.rangeOfString(searchText) != nil }
        }
        tableView.reloadData()
    }
}
