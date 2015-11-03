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
 *  MapViewController.swift
 *  Places
 *
 *  Created by Soheil Azarpour on 7/2/14.
 */

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  
  let MapAnnotationViewIdentifier = "MapAnnotationViewIdentifier"
  let ZoomFactorRegularLayout: CLLocationDegrees = 0.02
  let ZoomFactorCompactLayout: CLLocationDegrees = 0.05
  
  @IBOutlet var mapView: MKMapView?
  var place: Place? {
    didSet {
      updateMapViewWithPlace(place)
    }
  }
  
  // MARK: View Life Cycle
  
  override func viewDidAppear(animated: Bool) {
    updateMapViewWithPlace(place)
    super.viewDidAppear(animated)
  }
  
  // MARK: Public
  
  /** Returns YES if receiver is currently displaying a place on the map. */
  var isDisplayingPlace: Bool {
    get {
      return (place != nil)
    }
  }
  
  /** Displays a Place object on the map. */
  func displayPlace(place: Place?) {
    self.place = place
    title = place?.title
    updateMapViewWithPlace(place)
  }
  
  /** Removes all Place objects from the map. */
  func clearMap()->() {
    place = nil
    self.updateMapViewWithPlace(nil)
  }
  
  // MARK: Private
  
  /** A helper method to update the map view with a given Place. */
  func updateMapViewWithPlace(place: Place?) {
    
    // Remove any old places that is being displayed.
    let annotations = mapView?.annotations
    mapView?.removeAnnotations(annotations!)
    
    // If the new place is not nil, display it.
    if let aPlace = place {
      mapView?.addAnnotation(aPlace)
      
      // Zoom in to the new place. Zoom in more if layout class is Regular.
      let delta = (traitCollection.horizontalSizeClass == .Compact) ? ZoomFactorCompactLayout : ZoomFactorRegularLayout
      let region = MKCoordinateRegion(center: aPlace.coordinate, span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta))
      mapView?.setRegion(region, animated: true)
      
      // Make it selected.
      mapView?.selectAnnotation(aPlace, animated: false)
    }
  }
  
  // MARK: MKMapViewDelegate
  
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    var annotationView: MKAnnotationView?
    if annotation.isKindOfClass(Place.self) {
      annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(MapAnnotationViewIdentifier)
      if let unwrappedAnnotationView = annotationView {
        unwrappedAnnotationView.annotation = annotation
      } else {
        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: MapAnnotationViewIdentifier)
        annotationView!.enabled = true
        annotationView!.canShowCallout = true
        annotationView!.image = (annotation as! Place).image
      }
    }
    return annotationView
  }
  
}
