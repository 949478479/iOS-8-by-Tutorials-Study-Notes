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
*  PlacesTests.swift
*  PlacesTests
*
*  Created by Soheil Azarpour on 7/2/14.
*/

import XCTest
import MapKit

class PlacesTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_place_initialization() {
        // Some test values.
        let title = "Title"
        let date = NSDate()
        let image = UIImage(named:"capecod")
        let coordinate = CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0)

        // Test initialization.
        let place = Place(title: title, date: date, image: image, coordinate: coordinate)

        // Test that the initializer properly set properties.
        XCTAssertEqual(place.title!, title, "Place class construstor failed to set title property.")
        XCTAssertEqual(place.date!, date, "Place class construstor failed to set date property.")
        XCTAssertEqual(place.image!, image!, "Place class construstor failed to set image property.")
        XCTAssertEqualWithAccuracy(place.coordinate.latitude, coordinate.latitude, accuracy: 0.0, "Place class construstor failed to set coordinate property.")
        XCTAssertEqualWithAccuracy(place.coordinate.longitude, coordinate.longitude, accuracy: 0.0, "Place class construstor failed to set coordinate property.")
    }
    
}
