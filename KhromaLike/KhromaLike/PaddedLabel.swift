//
//  PaddedLabel.swift
//  KhromaLike
//
//  Created by 从今以后 on 15/10/18.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {

    var verticalPadding: CGFloat = 0.0

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass {
            verticalPadding = (traitCollection.verticalSizeClass == .Compact) ? 0.0 : 20.0
            invalidateIntrinsicContentSize()
        }
    }

    override func intrinsicContentSize() -> CGSize {
        var intrinsicContentSize = super.intrinsicContentSize()
        intrinsicContentSize.height += verticalPadding
        return intrinsicContentSize
    }
}
