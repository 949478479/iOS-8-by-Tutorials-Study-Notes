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
 *
 *  MasterViewController.swift
 *  Places
 *
 *  Created by Soheil Azarpour on 7/2/14.
 */

import UIKit
import CoreLocation

class MasterViewController: UITableViewController {
  
  let ShowDetailSegueIdentifier = "ShowDetailSegueIdentifier"
  let MasterTableViewCellIdentifier = "MasterTableViewCellIdentifier"
  
  var places = [Place]()
  var selectedIndexPath: NSIndexPath?
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    title = "Places"
    weak var weakSelf = self
    PlaceManager.sharedManager().fetchPlacesWithCompletion({ (places: [Place]) in
      if let unwrapped = weakSelf {
        unwrapped.places = places
        unwrapped.tableView.reloadData()
        unwrapped.autoSelectFirstPlace()
        unwrapped.autoDisplaySelectedPlaceIfApplicable()
      }
    })
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
    let viewController: AnyObject = segue.destinationViewController
    if viewController.isKindOfClass(MapViewController) {
      let place: Place? = selectedPlace()
      (viewController as! MapViewController).displayPlace(place)
    }
  }
  
  // MARK: Pubic 
  
  /** Returns the selected place or nil. */
  func selectedPlace() -> Place? {
    var place: Place?
    if let indexPath = selectedIndexPath {
      place = places[indexPath.row]
    }
    return place 
  }
  
  /** Auto select the 1st place in array of places, if none is selected. */
  func autoSelectFirstPlace() {
    if selectedIndexPath == nil {
      selectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    }
  }
  
  /** Auto dispaly the selected Place if split view controller is expanded. */
  func autoDisplaySelectedPlaceIfApplicable() {
    // If split view controller is expanded, displayed the selected item in Map View.
    if let splitViewController = self.splitViewController {
      if !splitViewController.collapsed {
        self.performSegueWithIdentifier(ShowDetailSegueIdentifier, sender: selectedPlace())
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
    return places.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(MasterTableViewCellIdentifier) as! TableViewCell
    let place = places[indexPath.row]
    cell.imageTitleLabel!.text = place.title
    cell.imageDateLabel!.text = place.subtitle
    cell.backgroundImageView!.image = place.image
    return cell
  }
  
  override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath {
    // This delegate method is called before the cell is selected and its associated segue is invoked. Keep a reference to this index path and update the destination view controller (Map View Controller) appropriately.
    selectedIndexPath = indexPath
    return indexPath
  }
}
