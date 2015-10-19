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

class RWTCountryTableViewCell: UITableViewCell {
  @IBOutlet var flagImageView: UIImageView!
  @IBOutlet var countryNameLabel: UILabel!
  @IBOutlet var containerView: UIView!
  
  func configureCellForCountry(country: RWTCountry) {
    countryNameLabel.text = country.countryName
    
    let image: UIImage = UIImage(named: country.imageName)!
    flagImageView.image = image
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // When selected the label background is set to
    // white by default, this overrides that setting.
    countryNameLabel.backgroundColor =
      UIColor(white: 0.0, alpha: 0.7)
  }
  
  override func awakeFromNib() {
    // Round the corners of the container view.
    containerView.layer.cornerRadius = 5.0;
    containerView.layer.borderWidth = 1.0;
    containerView.layer.borderColor =
      UIColor(white: 0.0, alpha: 0.7).CGColor
  }
}
