//
//  SimpleTransitioner.swift
//  CustomPresentation
//
//  Created by 从今以后 on 15/10/21.
//  Copyright © 2015年 Fresh App Factory. All rights reserved.
//

import UIKit

class SimpleTransitioner: NSObject, UIViewControllerAnimatedTransitioning {

    var isPresentation = false // 由于统一用 SimpleTransitioner 实现,因此需要区分是 present 还是 dismiss.

    // 在此提供过渡动画时间, UIKit 会用此时间同步过渡过程中的其他动画,例如导航控制器会用此时间同步导航栏的动画.
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)
        -> NSTimeInterval {
        return 0.5
    }

    // 在此配置具体的动画内容.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let fromView = fromViewController.view
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let toView = toViewController.view

        let containerView = transitionContext.containerView()!
        if isPresentation {
            containerView.addSubview(toView) // presentation 过程需要手动将 toView 添加到视图层级上.
        }

        // 根据 present 还是 dismiss 决定做动画的 view controller 和 view.
        let animatingView = isPresentation ? toView : fromView
        let animatingViewController = isPresentation ? toViewController : fromViewController

        // dismissedFrame 表示让 animatingView 从屏幕下方消失.
        let appearedFrame  = transitionContext.finalFrameForViewController(animatingViewController)
        let dismissedFrame = appearedFrame.offsetBy(dx: 0, dy: appearedFrame.height)

        // 确定 animatingView 的初始和结束时的 frame.
        let initialFrame = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame   = isPresentation ? appearedFrame : dismissedFrame

        animatingView.frame = initialFrame
        UIView.animateWithDuration(transitionDuration(nil), animations: {
            animatingView.frame = finalFrame
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}
