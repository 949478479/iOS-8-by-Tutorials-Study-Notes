//
//  TraitOverrideViewController.swift
//  KhromaPal
//
//  Created by 从今以后 on 15/10/17.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

class TraitOverrideViewController: UIViewController {

    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        var traitOverride: UITraitCollection?
        if size.width > 414 {
            traitOverride = UITraitCollection(horizontalSizeClass: .Regular)
        }
        setOverrideTraitCollection(traitOverride, forChildViewController: childViewControllers[0])
    }
}
