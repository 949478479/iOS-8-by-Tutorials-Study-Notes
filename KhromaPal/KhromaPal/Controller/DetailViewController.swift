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

class DetailViewController: UIViewController {

    @IBOutlet var colorLabels: [UILabel]!
    @IBOutlet weak var titleLabel: UILabel!

    var colorPalette: ColorPalette? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //  在 viewDidLoad() 中 splitViewController 还是 nil.
        navigationItem.leftBarButtonItem = splitViewController!.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    // Private methods

    private func makeAllContentHidden(hidden: Bool) {
        for subview in view.subviews {
            subview.hidden = hidden
        }
        if hidden {
            title = ""
        }
    }

    private func configureView() {
        // Update the user interface for the detail item.
        if let palette = colorPalette {
            makeAllContentHidden(false)
            if (colorLabels != nil) {
                // Update the color panels
                for (color, label) in Zip2Sequence(palette.colors, colorLabels!) {
                    label.backgroundColor = color
                    label.text = color.hexString()
                    label.textColor = color.blackOrWhiteContrastingColor().colorWithAlphaComponent(0.6)
                }

                // And the title label
                title = palette.name
                titleLabel.text = palette.name

                // Central color
                let middleIndex = Int(floor(Double(palette.colors.count - 1) / 2.0))
                let middleColor = palette.colors[middleIndex]
                titleLabel.textColor = middleColor.blackOrWhiteContrastingColor().colorWithAlphaComponent(0.6)
            }
        } else {
            performSegueWithIdentifier("showNoPaletteSelectedVC", sender: nil)
            makeAllContentHidden(true)
        }
    }
}

extension DetailViewController: PaletteDisplayContainer {
    func currentlyDisplayedPallette() -> ColorPalette? {
        return colorPalette
    }
}
