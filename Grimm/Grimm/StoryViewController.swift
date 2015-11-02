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

class StoryViewController: UIViewController, ThemeAdopting {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var storyView: StoryView!
    @IBOutlet private weak var optionsContainerView: UIView!
    @IBOutlet private weak var optionsContainerViewBottomConstraint: NSLayoutConstraint!

    var story: Story?

    private var showingOptions = false

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "themeDidChange:",
            name: ThemeDidChangeNotification, object: nil)

        navigationItem.titleView = UIImageView(image: UIImage(named: "Bull"))
        
        reloadTheme()
        storyView.story = story
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setOptionsHidden(true, animated: false)
    }

    @IBAction func optionsButtonTapped(_: AnyObject) {
        setOptionsHidden(showingOptions, animated: true)
    }

    func themeDidChange(notification: NSNotification!) {
        reloadTheme()
        storyView.reloadTheme()
    }
    
    func reloadTheme() {
        let theme = Theme.sharedInstance
        scrollView.backgroundColor = theme.textBackgroundColor
        childViewControllers.forEach { $0.view.tintColor = theme.tintColor }
    }
}

// MARK: - Private
private extension StoryViewController {

    func setOptionsHidden(hidden: Bool, animated: Bool) {
        showingOptions = !hidden;

        let height = optionsContainerView.bounds.height
        var constant = optionsContainerViewBottomConstraint.constant
        constant = hidden ? (constant - height) : (constant + height)

        if animated {
            UIView.animateWithDuration(0.2,
                delay: 0,
                usingSpringWithDamping: 0.95,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions(),
                animations: {
                    self.optionsContainerViewBottomConstraint.constant = constant
                    self.view.layoutIfNeeded()
                }, completion: nil)
        } else {
            optionsContainerViewBottomConstraint.constant = constant
        }
    }
}
