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
*  PlaceManagerTests.swift
*  Places
*
*  Created by Soheil Azarpour on 7/4/14.
*/

import XCTest

class PlaceManagerTests: XCTestCase {

    let placeManager = PlaceManager.sharedManager()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_placeManager_initialization() {
        let optionalManager: PlaceManager? = PlaceManager.sharedManager()
        XCTAssertTrue(optionalManager != nil, "PlaceManager failed to return shared instance.")
    }

    func test_localResourceFileURL_getter() {
        let localResourceURL: NSURL? = placeManager.localResourceFileURL
        XCTAssertNotNil(localResourceURL, "PlaceManager failed to return default local resource URL.")
    }

    func test_async_fetchPlaces() {
        // 获取用于测试的本地 JSON 数据.
        let sampleURL = NSBundle.testBundle().URLForResource("SampleResponse", withExtension: "json")
        XCTAssertNotNil(sampleURL, "Failed to get a valid URL to sample response file in Test Bundle.")

        // 根据 PlaceManager 的用法,需要设置本地资源路径.
        placeManager.localResourceFileURL = sampleURL

        // 创建用于异步测试的 XCTestExpectation 实例.
        let expectation = expectationWithDescription("Async fetch")

        // 测试 fetchPlacesWithCompletion(:_) 方法.
        placeManager.fetchPlacesWithCompletion { (places) -> Void in
            XCTAssertTrue(places.count == 600, "Expected to get 600 results from the sample response.")
            // 标记异步测试完成.
            expectation.fulfill()
        }

        // 设置 1s 的超时时间.如果到达超时时间或者测试被标记完成,此闭包会被调用.
        waitForExpectationsWithTimeout(1.0) { (error) -> Void in
            XCTAssertNil(error, "PlaceManager failed to process fetch from ample response in a reasonable time.")
        }
    }

    func test_performance_processJSONRoot() {
        // 获取用于测试的本地 JSON 数据.
        let sampleURL = NSBundle.testBundle().URLForResource("SampleResponse", withExtension: "json")
        XCTAssertNotNil(sampleURL, "Failed to get a valid URL to sample response file in Test Bundle.")

        // 将 JSON 数据反序列化为字典.
        let data = NSData(contentsOfURL: sampleURL!)!
        let root = try! NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())

        // 测试 processJSONRoot 方法处理 JSON 的性能.
        measureBlock { () -> Void in
            let placeObjects = self.placeManager.processJSONRoot(root as! NSDictionary)
            XCTAssertFalse(placeObjects.isEmpty, "PlaceManager failed to process data.")
        }
    }
}