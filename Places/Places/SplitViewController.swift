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
 *  SplitViewController.swift
 *  Places
 *
 *  Created by Soheil Azarpour on 7/2/14.
 */

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  
  // MARK: View Life Cycle
  
  override func awakeFromNib()  {
    self.delegate = self
    self.preferredDisplayMode = .AllVisible
    super.awakeFromNib()
  }
  
  override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    if traitCollection.horizontalSizeClass == .Regular {
      if let mapViewController = self.viewControllers.last as? MapViewController {
        if let navController = self.viewControllers.first as? UINavigationController {
          if let masterViewController = navController.viewControllers.first as? MasterViewController {
            if let selectedPlace = masterViewController.selectedPlace() {
              mapViewController.place = selectedPlace
            }
          }
        }
      }
    }
    super.traitCollectionDidChange(previousTraitCollection)
  }
  
  // MARK: UISplitViewControllerDelegate
  
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    
    // If the secondary view controller is Map View Controller and it is displaying a place, return NO for default behavior.
    if secondaryViewController.isKindOfClass(MapViewController.self) {
      let viewController = secondaryViewController as! MapViewController
      return !(viewController.isDisplayingPlace)
    }
    
    // Otherwise, pop any view controller in the navigation stack of the primary view controller before collapse.
    if primaryViewController.isKindOfClass(UINavigationController.self) {
      let navController = primaryViewController as! UINavigationController
      navController.popToRootViewControllerAnimated(true)
    }
    
    // Return true because we handled the collapse.
    return true
  }
}