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

class OptionsController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var readingModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleAlignmentSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        let theme = Theme.sharedInstance
        pageControl.currentPage = theme.font.rawValue
        readingModeSegmentedControl.selectedSegmentIndex = theme.readingMode.rawValue
        titleAlignmentSegmentedControl.selectedSegmentIndex = theme.titleAlignment.rawValue

        synchronizeViews()
    }

    private func synchronizeViews() {
        let page      = pageControl.currentPage
        let pageWidth = scrollView.bounds.width
        let offset    = CGFloat(page) * pageWidth
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
    }
}

// MARK: - IBAction
private extension OptionsController {
    @IBAction func pageControlPageDidChange() {
        synchronizeViews()
    }

    @IBAction func readingModeDidChange(segmentedControl: UISegmentedControl!) {
        Theme.sharedInstance.readingMode = ReadingMode(rawValue: segmentedControl.selectedSegmentIndex)!
    }

    @IBAction func titleAlignmentDidChange(segmentedControl: UISegmentedControl!) {
        Theme.sharedInstance.titleAlignment = TitleAlignment(rawValue: segmentedControl.selectedSegmentIndex)!
    }
}

// MARK: - UIScrollViewDelegate
extension OptionsController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPage = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
        if pageControl.currentPage != currentPage {
            pageControl.currentPage = currentPage
            Theme.sharedInstance.font = Font(rawValue: currentPage)!
        }
    }
}
