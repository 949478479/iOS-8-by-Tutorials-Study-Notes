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
*  PlaceManager.swift
*  Places
*
*  Created by Soheil Azarpour on 7/2/14.
*/

import UIKit
import CoreLocation

/** A manager to fetch data source and update asynchronously. */
class PlaceManager: NSObject {

    /** Designated class constructor. */
    class func sharedManager() -> PlaceManager! {
        let sharedInstance = PlaceManager()
        return sharedInstance
    }

    /** URL for the local resource JSON file. There is a default value for this, if not provided. */
    var localResourceFileURL = NSBundle.mainBundle().URLForResource("Places", withExtension: "json")

    /** Fetches places and returns an array of Place objects. */
    func fetchPlacesWithCompletion(completion: (places: [Place]) -> Void) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            if let URL = self.localResourceFileURL {
                if let data = try? NSData(contentsOfURL: URL, options: .UncachedRead) {
                    if let root: NSDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as? NSDictionary {
                        let processed: [Place] = self.processJSONRoot(root)
                        dispatch_async(dispatch_get_main_queue(), {
                            completion(places: processed)
                        })
                    }
                }
            }
        })
    }

    // MARK: Private

    private let dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        return dateFormatter
    }()

    private let subtitleFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        return formatter
    }()

    func processJSONRoot(root: NSDictionary) -> [Place] {
        var placesObjects = [Place]()
        if let places: NSArray = root["places"] as? NSArray {
            for aPlace: AnyObject in places {
                let placeDict: NSDictionary = aPlace as! NSDictionary
                let title: String = placeDict["title"] as! String
                let dateString: String = placeDict["date"] as! String
                let imageFile: String = placeDict["image"] as! String
                let location: NSDictionary = placeDict["location"] as! NSDictionary
                let latitude: NSNumber = location["latitude"] as! NSNumber
                let longitude: NSNumber = location["longitude"] as! NSNumber

                // Convert date string to date.
                let date: NSDate? = dateFormatter.dateFromString(dateString)

                // Create location coordinate.
                let lat: CLLocationDegrees = latitude.doubleValue
                let lon: CLLocationDegrees = longitude.doubleValue
                let locationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                // Load image from bundle.
                let image = UIImage(named: imageFile)

                // Create a Place object.
                let place = Place(title: title, date: date, image: image, coordinate: locationCoordinate)
                place.subtitle = subtitleFormatter.stringFromDate(date!)
                placesObjects.append(place)
            }
            placesObjects.sortInPlace({ (p1: Place, p2: Place) -> Bool in
                let result: NSComparisonResult = p1.date!.compare(p2.date!)
                return result == .OrderedDescending
            })
        }
        return placesObjects
    }
}
