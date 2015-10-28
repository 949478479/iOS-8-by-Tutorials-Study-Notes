/*
* Copyright (c) 2015 Razeware LLC
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

class SettingsViewController: UIViewController {

    @IBOutlet private weak var watchView: WatchView!
    @IBOutlet private weak var timeZoneLabel: UILabel!
    @IBOutlet private weak var watchViewRadiusConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        timeZoneLabel.text = watchView.timeZone

        let screenSize = UIScreen.mainScreen().bounds.size
        if traitCollection.userInterfaceIdiom == .Phone {
            watchViewRadiusConstraint.constant = min(screenSize.width, screenSize.height) - 100
        } else {
            watchViewRadiusConstraint.constant = min(screenSize.width, screenSize.height) * 2/3
        }
    }

    // MARK: - Segue

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "showTimeZones" {
            let timeZoneViewController = segue.destinationViewController.childViewControllers[0] as! TimeZoneViewController
            timeZoneViewController.delegate = self
        }

        if segue.identifier == "showColorPicker" {
            let colorPickerViewController = segue.destinationViewController.childViewControllers[0] as! ColorPickerViewController
            colorPickerViewController.delegate = self;
            colorPickerViewController.color = watchView.backgroundLayerColor
        }
    }
}

// MARK: - IBAction
private extension SettingsViewController {

    @IBAction func selectClockSecondsType(sender: AnyObject) {
        watchView.enableClockSecondHand =
            sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) == "Hand"
    }

    // Select an image or a color for a background

    @IBAction func selectedClockBackground(sender: UISegmentedControl) {
        if sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) == "Image Face" {
            guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else {
                let alert = UIAlertController(
                    title: "Error",
                    message: "Cannot access Saved Photos on device...",
                    preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                showDetailViewController(alert, sender: nil)
                return
            }
            let photoPicker = UIImagePickerController()
            photoPicker.delegate = self
            photoPicker.allowsEditing = true
            photoPicker.sourceType = .PhotoLibrary
            photoPicker.navigationBar.tintColor = view.tintColor
            showDetailViewController(photoPicker, sender: nil)
        } else {
            performSegueWithIdentifier("showColorPicker", sender: nil)
        }
    }

    @IBAction func selectClockDesign(sender: AnyObject) {
        watchView.enableAnalogDesign =
            sender.titleForSegmentAtIndex(sender.selectedSegmentIndex) == "Analog"
    }

    @IBAction func unwindForSegue(unwindSegue: UIStoryboardSegue) { }
}

// MARK: - ColorPickerViewControllerDelegate
extension SettingsViewController: ColorPickerViewControllerDelegate {
    func didSelectColor(color: UIColor) {
        watchView.backgroundLayerColor = color
        watchView.enableColorBackground = true
    }
}

// MARK: - TimeZoneViewControllerDelegate
extension SettingsViewController: TimeZoneViewControllerDelegate {
    func didSelectATimeZone(timeZone: String) {
        watchView.timeZone = timeZone
        timeZoneLabel.text = timeZone
    }
}

// MARK: - UIImagePickerControllerDelegate
extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        watchView.backgroundImage = image
        watchView.enableColorBackground = false

        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
