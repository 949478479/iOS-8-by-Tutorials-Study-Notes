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

    lazy var weatherData = WeatherData()

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationBarAppearance()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100

        let navigationController = splitViewController!.viewControllers.last as! UINavigationController
        let detailViewController = navigationController.topViewController as! DetailViewController
        detailViewController.cityWeather = weatherData.cities[0]
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let indexPath = tableView.indexPathForSelectedRow!
            let navController = segue.destinationViewController as! UINavigationController
            let detailController = navController.topViewController as! DetailViewController
            detailController.cityWeather = weatherData.cities[indexPath.row]
            /*
            对于 iPad 设备,竖屏时会在导航栏返回按钮位置显示一个按钮,用于显示和隐藏 master 控制器.
            对于 iPhone 设备,无论哪种型号,竖屏时都是以 push 的方式展示 detail 控制器的.因此该按钮不会显示,
            但是由于设置了 leftBarButtonItem, 将导致导航栏上的返回按钮消失,需要设置
            leftItemsSupplementBackButton 属性为 true 才能显示返回按钮. */
            detailController.navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
        }
    }

    private func prepareNavigationBarAppearance() {
        let font = UIFont(name: "HelveticaNeue-Light", size: 30)!
        let regularVertical = UITraitCollection(verticalSizeClass: .Regular)
        UINavigationBar.appearanceForTraitCollection(regularVertical)
            .titleTextAttributes = [NSFontAttributeName : font]
        let compactVertical = UITraitCollection(verticalSizeClass: .Compact)
        UINavigationBar.appearanceForTraitCollection(compactVertical)
            .titleTextAttributes = [NSFontAttributeName : font.fontWithSize(20)]
    }
}

// MARK: - Table View Data Source

extension MasterViewController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.cities.count
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("CityCell", forIndexPath: indexPath)
            as! CityTableViewCell
        let city = weatherData.cities[indexPath.row]
        cell.configureWithCityWeather(city)

        return cell
    }
}
