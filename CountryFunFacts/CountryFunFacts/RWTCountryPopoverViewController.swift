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

class RWTCountryPopoverViewController: UIViewController {
  
  @IBOutlet var countryNameLabel: UILabel!
  @IBOutlet var languageLabel: UILabel!
  @IBOutlet var populationLabel: UILabel!
  @IBOutlet var currencyLabel: UILabel!
  @IBOutlet var factsTextView: UITextView!
  
  var country: RWTCountry?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.addCloseButton()
  }
  
  override func viewWillAppear(animated: Bool)  {
    super.viewWillAppear(animated)
    
    self.configureView()
  }
  
  func addCloseButton() {
    let detailsButton: UIBarButtonItem =
    UIBarButtonItem(title: "Close",
      style: UIBarButtonItemStyle.Plain,
      target: self, action: "close:")
    
    self.navigationItem.rightBarButtonItem = detailsButton
  }
  
  func configureView() {
    if country != nil {
      countryNameLabel.text = country!.countryName
      languageLabel.text = country!.language
      populationLabel.text = country!.population
      currencyLabel.text = country!.currency
      factsTextView.text = country!.fact
    }
  }
  
  func close(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

