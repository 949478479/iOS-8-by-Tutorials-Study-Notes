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

class ColorSwatchDetailViewController: UIViewController, ColorSwatchSelectable {
  
  // Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    colorSwatch = nil
  }
  
  // <ColorSwatchSelectable>
  var colorSwatch: ColorSwatch? {
    didSet {
      updateAppearance(colorSwatch)
    }
  }
  
  // IB Outlets
  @IBOutlet var allLabels: [UILabel]!
  @IBOutlet var swatchTiles: [UIView]?
  
  @IBOutlet weak var hexLabel: UILabel!
  @IBOutlet weak var cmykLabel: UILabel!
  @IBOutlet weak var rgbLabel: UILabel!
  @IBOutlet weak var hsbLabel: UILabel!
  @IBOutlet weak var labLabel: UILabel!
  
  // Utility methods
  private func updateAppearance(colorSwatch: ColorSwatch?) {
    if let swatch = colorSwatch {
      setSubviewsAsHidden(false)
      view.backgroundColor = swatch.color
      
      // Color labels
      hexLabel.text = "hex \(swatch.hexString)"
      rgbLabel.text = "rgb \(swatch.rgbString)"
      cmykLabel.text = "cmyk \(swatch.cmykString)"
      labLabel.text = "lab \(swatch.cielabString)"
      hsbLabel.text = "hsb \(swatch.hsbString)"
      
      // Update the swatch tiles
      if let tiles = swatchTiles {
        for (color, tile) in Zip2Sequence(swatch.relatedColors(), tiles) {
          tile.backgroundColor = color
        }
      }
      
      // Update the text color of the labels
      let textColor = swatch.color.blackOrWhiteContrastingColor()
      for label in allLabels {
        label.textColor = textColor
      }
    } else {
      setSubviewsAsHidden(true)
      view.backgroundColor = UIColor.whiteColor()
    }
  }
  
  private func setSubviewsAsHidden(hidden: Bool) {
    for subview in view.subviews {
      subview.hidden = hidden
    }
  }
  
}
