//
//  NSBundle+TestAdditions.swift
//  Places
//
//  Created by 从今以后 on 15/11/3.
//  Copyright © 2015年 Razeware LLC. All rights reserved.
//

import Foundation

class Dummy {}

extension NSBundle {
    class func testBundle() -> NSBundle {
        // 此方法返回类所在的 farmwork 的 bundle, 由于 Dummy 定义在 Test Target, 因此会返回 Test Target 的 bundle.
        return NSBundle(forClass: Dummy.self)
    }
}