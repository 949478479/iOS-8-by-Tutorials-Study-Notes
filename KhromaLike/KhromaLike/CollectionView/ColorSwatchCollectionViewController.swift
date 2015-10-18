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

private let reuseIdentifier = "ColorSwatchCell"

class ColorSwatchCollectionViewController: UICollectionViewController, ColorSwatchSelector {

    var swatchList: ColorSwatchList?
    var swatchSelectionDelegate: ColorSwatchSelectionDelegate?
    var currentCellContentTransform = CGAffineTransformIdentity

    override func viewWillAppear(animated: Bool) {
        if swatchList == nil {
            swatchList = ColorSwatchList()
            collectionView(collectionView!, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
        }
    }

    // 设备旋转时调整布局.
    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

        let targetTransform = coordinator.targetTransform()
        let inverseTransform = CGAffineTransformInvert(targetTransform)

        coordinator.animateAlongsideTransition({ _ in
            // 空实现,因为当前需求是使用自动布局系统更新后的视图做动画.
        }, completion: { _ in
            // 由于使用了自动布局,不要直接将放射变换应用于视图,但是可应用于视图的图层.
            self.view.layer.transform = CATransform3DConcat(self.view.layer.transform,
                CATransform3DMakeAffineTransform(inverseTransform))
            // 设备旋转 90° 时,交换宽度和高度.
            if abs(atan2(Double(targetTransform.b), Double(targetTransform.a)) / M_PI) < 0.9 {
                self.view.bounds = CGRect(origin: CGPointZero,
                    size: CGSize(width: self.view.bounds.height, height: self.view.bounds.width))
            }
            self.currentCellContentTransform = CGAffineTransformConcat(self.currentCellContentTransform, targetTransform)

            UIView.animateWithDuration(0.5,
                delay: 0,
                usingSpringWithDamping: 0.6,
                initialSpringVelocity: 0,
                options: UIViewAnimationOptions(),
                animations: {
                    self.collectionView?.visibleCells().forEach {
                        $0.contentView.transform = self.currentCellContentTransform
                    }
                }, completion: nil)
        })
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let minDimension = min(view.bounds.width, view.bounds.height)
        let newItemSize = CGSize(width: minDimension, height: minDimension)
        if newItemSize != flowLayout.itemSize {
            flowLayout.itemSize = newItemSize
            flowLayout.invalidateLayout()
        }
    }
}

// MARK: - <UICollectionViewDelegate>

extension ColorSwatchCollectionViewController {

    override func collectionView(collectionView: UICollectionView,
        numberOfItemsInSection section: Int) -> Int {
        return swatchList?.colorSwatches.count ?? 0
    }

    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)

        if let swatchCell = cell as? ColorSwatchCollectionViewCell,
            let swatch = swatchList?.colorSwatches[indexPath.item] {
                swatchCell.resetCell(swatch)
        }
        return cell
    }

    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let swatch = swatchList?.colorSwatches[indexPath.item] {
            swatchSelectionDelegate?.didSelect(swatch, sender: self)
        }
    }

    override func collectionView(collectionView: UICollectionView,
        willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        cell.contentView.transform = currentCellContentTransform
    }
}
