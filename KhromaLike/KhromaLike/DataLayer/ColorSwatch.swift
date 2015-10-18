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

import Foundation


class ColorSwatch {
  
  var name: String
  var color: UIColor
  private let formatString = "0.2"
  
  init(name: String, color: UIColor) {
    self.name = name
    self.color = color
  }
  
  // Color string properties
  var hexString: String {
    return color.hexString()
  }
  
  var rgbString: String {
    let rgbArray = color.rgbaArray() as! [Double]
    return "(\(rgbArray[0].rw_format(formatString)), \(rgbArray[1].rw_format(formatString)), " +
      "\(rgbArray[2].rw_format(formatString)))"
  }
  
  var cmykString: String {
    let cmykArray = color.cmykArray() as! [Double]
    return "(\(cmykArray[0].rw_format(formatString)), \(cmykArray[1].rw_format(formatString)), " +
      "\(cmykArray[2].rw_format(formatString)), \(cmykArray[3].rw_format(formatString)))"
  }
  
  var hsbString: String {
    let hsbArray = color.hsbaArray() as! [Double]
    return "(\(hsbArray[0].rw_format(formatString)), \(hsbArray[1].rw_format(formatString)), " +
      "\(hsbArray[2].rw_format(formatString)))"
  }
  
  var cielabString: String {
    let cielabArray = color.CIE_LabArray() as! [Double]
    return "(\(cielabArray[0].rw_format(formatString)), \(cielabArray[1].rw_format(formatString)), " +
      "\(cielabArray[2].rw_format(formatString)))"
  }
  
  // Color scheme array function
  func relatedColors() -> [UIColor] {
    return self.color.colorSchemeOfType(ColorScheme.Analagous) as! [UIColor]
  }
  
}