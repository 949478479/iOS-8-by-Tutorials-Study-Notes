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

class RWTCountryDetailViewController: UIViewController, UISplitViewControllerDelegate {

    @IBOutlet var flagImageView: UIImageView!
    @IBOutlet var quizQuestionLabel: UILabel!
    @IBOutlet var answer1Button: UIButton!
    @IBOutlet var answer2Button: UIButton!
    @IBOutlet var answer3Button: UIButton!
    @IBOutlet var answer4Button: UIButton!

    var country: RWTCountry? {
        didSet {
            if isViewLoaded() {
                configureView()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        quizQuestionLabel.preferredMaxLayoutWidth = view.bounds.size.width - 40

        if splitViewController!.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
            addCountryListButton()
        }

        configureView()
    }

    func addCountryListButton() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let countriesButton: UIBarButtonItem =
            UIBarButtonItem(title: "Countries",
                style: UIBarButtonItemStyle.Plain,
                target: self.splitViewController,
                action: "toggleMasterVisible:")

            navigationItem.leftBarButtonItem = countriesButton
        }
    }

    func configureView() {
        if let country = country {
            self.title = country.countryName;
            let image = UIImage(named: country.imageName)!;
            flagImageView.image = image;
            quizQuestionLabel.text = country.quizQuestion;
            answer1Button.setTitle(country.quizAnswers[0],forState:UIControlState.Normal)
            answer2Button.setTitle(country.quizAnswers[1], forState:UIControlState.Normal)
            answer3Button.setTitle(country.quizAnswers[2], forState:UIControlState.Normal)
            answer4Button.setTitle(country.quizAnswers[3],forState:UIControlState.Normal)
        }
    }

    @IBAction func quizAnswerButtonPressed(sender: UIButton) {
        let buttonTitle = sender.currentTitle
        let message: String
        if buttonTitle == country!.correctAnswer {
            message = "You answered correctly!"
        } else {
            message = "That answer is incorrect, please try again."
        }

        let action = UIAlertAction(title: "OK", style: .Default) { _ in
            print("You tapped OK.")
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .ActionSheet)
        alert.addAction(action)
        alert.popoverPresentationController?.sourceView = view
        alert.popoverPresentationController?.sourceRect = sender.frame
        presentViewController(alert, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PopCountryVC" {
            let contentVC = segue.destinationViewController as! RWTCountryPopoverViewController
            contentVC.country = country
            contentVC.popoverPresentationController?.delegate = self
        }
    }

    // #pragma mark - Split view

    func splitViewController(svc: UISplitViewController,
        willChangeToDisplayMode displayMode:
        UISplitViewControllerDisplayMode) {
            if displayMode == UISplitViewControllerDisplayMode.AllVisible {
                    navigationItem.leftBarButtonItem = nil;
            } else {
                let barButtonItem = svc.displayModeButtonItem()
                navigationItem.leftBarButtonItem = barButtonItem
            }
    }

    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool  {
        return true
    }
}

extension RWTCountryDetailViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController,
        traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }

    // 由于上面方法返回 .None, 此方法不会被调用了.
    func presentationController(controller: UIPresentationController,
        viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
}
