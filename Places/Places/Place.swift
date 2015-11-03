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
*  Place.swift
*  Places
*
*  Created by Soheil Azarpour on 7/2/14.
*/

import UIKit
import MapKit

class Place: NSObject, MKAnnotation {

    /** Title of the receiver, as user enters. */
    var title: String?

    /** Subtitle; it is a formatted string from date property of the receiver. */
    var subtitle: String?

    /** Date representing when it was visited. */
    var date: NSDate?

    /** An image. */
    var image: UIImage?

    /** Location coordinate of the receiver. */
    var _coordinate: CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        get {
            return _coordinate
        }
        set(newCoordinate) {
            _coordinate = newCoordinate
        }
    }

    // MARK: Life Cycle

    init(title aTitle: String, date aDate: NSDate?, image anImage: UIImage?, coordinate aCoordinate: CLLocationCoordinate2D) {
        title = aTitle
        date = aDate
        image = anImage
        _coordinate = aCoordinate
        /*
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        if let date = aDate {
        subtitle = dateFormatter.stringFromDate(date)
        }
        */
        super.init()
    }
}