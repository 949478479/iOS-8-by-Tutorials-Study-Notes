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

class ViewController: UIViewController, ColorSwatchSelectionDelegate {

    @IBOutlet var tallLayoutConstraints: [NSLayoutConstraint]!
    @IBOutlet var wideLayoutConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Wire up any swatch selectors we can find as VC children
        childViewControllers.forEach {
            if let selector = $0 as? ColorSwatchSelector {
                selector.swatchSelectionDelegate = self
            }
        }
    }

    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        let transitionToWide = size.width > size.height
        let constraintsToUninstall = transitionToWide ? tallLayoutConstraints : wideLayoutConstraints
        let constraintsToInstall = transitionToWide ? wideLayoutConstraints : tallLayoutConstraints

        view.layoutIfNeeded()

        // 重复激活/反激活视图的约束没有效果,因此如果是 iPhone 设备,这些约束是使用 IB 激活的,这里再激活将没有效果.
        NSLayoutConstraint.deactivateConstraints(constraintsToUninstall)
        NSLayoutConstraint.activateConstraints(constraintsToInstall)

        coordinator.animateAlongsideTransition({ _ in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: - <ColorSwatchSelectionDelegate>

    func didSelect(swatch: ColorSwatch, sender: AnyObject?) {
        childViewControllers.forEach {
            if let selectable = $0 as? ColorSwatchSelectable {
                selectable.colorSwatch = swatch
            }
        }
    }
}

