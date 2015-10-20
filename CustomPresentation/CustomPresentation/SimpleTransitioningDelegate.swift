//
//  SimpleTransitioningDelegate.swift
//  CustomPresentation
//
//  Created by 从今以后 on 15/10/21.
//  Copyright © 2015年 Fresh App Factory. All rights reserved.
//

import UIKit

class SimpleTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    func presentationControllerForPresentedViewController(presented: UIViewController,
        presentingViewController presenting: UIViewController,
        sourceViewController source: UIViewController) -> UIPresentationController? {
        return SimplePresentationController(presentedViewController: presented,
            presentingViewController: presenting)
    }

/* 这些是自定义过渡动画的内容. UIPresentationController并不依赖于这些.
    func animationControllerForPresentedController(presented: UIViewController,
        presentingController presenting: UIViewController,
        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = SimpleTransitioner()
        animationController.isPresentation = true
        return animationController
    }

    func animationControllerForDismissedController(dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        return SimpleTransitioner()
    }
*/
}
