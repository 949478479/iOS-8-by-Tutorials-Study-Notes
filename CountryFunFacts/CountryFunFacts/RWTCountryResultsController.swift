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

import Foundation

import UIKit

@objc protocol RWTCountryResultsControllerDelegate {
    optional func searchCountrySelected()
}

class RWTCountryResultsController: UITableViewController
{

    var countries = RWTCountry.countries()
    var filteredCountries = NSMutableArray()
    var delegate:RWTCountryResultsControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = UITableViewCellSeparatorStyle.None

        let nib = UINib(nibName:"RWTCountryTableViewCell",
            bundle:nil)
        tableView.registerNib(nib, forCellReuseIdentifier:"Cell")

        tableView.rowHeight = 246
    }

    // #pragma mark – Table View
    override func numberOfSectionsInTableView(tableView:
        UITableView) -> Int {
            return 1
    }

    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {

            return filteredCountries.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {

            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell",
                forIndexPath: indexPath) as! RWTCountryTableViewCell

            let country = filteredCountries[indexPath.row] as! RWTCountry
            cell.configureCellForCountry(country)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
    }

    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {

            if (delegate?.searchCountrySelected != nil) {
                delegate?.searchCountrySelected!()
            }
    }

    // #pragma mark – Search Helper

    func filterContentForSearchText(searchText: String) {
        filteredCountries.removeAllObjects()

        let predicate = NSPredicate(format:
            "countryName contains[c] %@", searchText)
        
        let tempArray =
        self.countries.filteredArrayUsingPredicate(predicate)
        
        filteredCountries = NSMutableArray(array: tempArray)
        
        tableView.reloadData()
    }
}

extension RWTCountryResultsController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}