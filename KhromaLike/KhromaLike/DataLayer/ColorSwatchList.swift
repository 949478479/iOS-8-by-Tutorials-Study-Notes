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

class ColorSwatchList {
  
  var colorSwatches: [ColorSwatch]
  
  init(plistNamed: String) {
    colorSwatches = []
    colorSwatches = loadSwatchesFromPlist(plistNamed)
  }
  
  convenience init () {
    self.init(plistNamed: "ColorList")
  }
  
  
  private func loadSwatchesFromPlist(name: String) -> [ColorSwatch] {
    /*
    We expect the plist to be a dictionary with the color names as the keys and
    hex strings representing the colors to be the values. Very little error checking
    is performed in this code.
    */

    let plistPath = NSBundle.mainBundle().pathForResource(name, ofType: "plist")
    let colorList = NSDictionary(contentsOfFile: plistPath!)

    var swatchList = [ColorSwatch]()
    
    for (colorName, hexString) in colorList as! [String : String] {
      let color = UIColor(fromHexString: hexString)
      let swatch = ColorSwatch(name: colorName, color: color)
      swatchList.append(swatch)
    }
    
    return swatchList
  }
}
