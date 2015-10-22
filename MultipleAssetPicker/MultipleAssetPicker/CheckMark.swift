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
import CoreGraphics

class CheckMark: UIView {

    static let checkmarkBlue = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1.0).CGColor
    static let checkedOvalBorderWhite = UIColor.whiteColor().CGColor

    override func drawRect(rect: CGRect) {
        let width  = rect.width
        let height = rect.height

        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, CheckMark.checkmarkBlue)
        CGContextSetStrokeColorWithColor(context, CheckMark.checkedOvalBorderWhite)

        let path = CGPathCreateWithEllipseInRect(CGRect(x: 0.5, y: 0.5, width: width - 1, height: height - 1), nil)

        // 绘制圆形背景.
        CGContextAddPath(context, path)
        CGContextFillPath(context)

        // 圆形背景描边.
        CGContextAddPath(context, path)
        CGContextStrokePath(context)

        // 绘制对勾.
        CGContextMoveToPoint(context, 0.27083 * width, 0.54167 * height)
        CGContextAddLineToPoint(context, 0.41667 * width, 0.68750 * height)
        CGContextAddLineToPoint(context, 0.75000 * width, 0.35417 * height)
        CGContextStrokePath(context)
    }
}
