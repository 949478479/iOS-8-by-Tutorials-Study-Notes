//
//  SimplePresentationController.swift
//  CustomPresentation
//
//  Created by 从今以后 on 15/10/21.
//  Copyright © 2015年 Fresh App Factory. All rights reserved.
//

import UIKit

class SimplePresentationController: UIPresentationController {

    // MARK: - 背景 view

    lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.alpha = 0
        return dimmingView
    }()

    // MARK: - presentation

    // 此方法默认实现为空,子类可以在此添加自定义 view 到视图层级上并设置一些动画.
    override func presentationTransitionWillBegin() {

        // 添加自定义的 dimmingView 到视图层级底层,确保在 presented view controller 的 view 之下.
        dimmingView.frame = containerView!.bounds
        containerView!.insertSubview(dimmingView, atIndex: 0)

        // 获取 presented view controller 的 transition coordinator, 用于执行自定义的动画.
        dimmingView.alpha = 0
        presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    // 此方法默认实现为空,子类可以在此进行额外的清理工作.
    override func presentationTransitionDidEnd(completed: Bool) {
        // 如果是手势驱动的过程,那么用户可能会中途终止,此时 completed 会为 false, 此时应该将自定义视图移除.
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    // MARK: - dismissal

    // 此方法默认实现为空,子类可以在此执行 dismissal 过程的动画.
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    // 此方法默认实现为空,子类可以在此进行额外的清理工作.
    override func dismissalTransitionDidEnd(completed: Bool) {
        // completed 为 true 表示完全 dismiss 而没有中途取消之类的,移除自定义视图.
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    // MARK: - 调整布局

    // 类似于 UIViewController 的 viewWillLayoutSubviews() 方法.
    override func containerViewWillLayoutSubviews() {
        // 例如设备旋转时,重新调整添加的自定义视图的布局.
        dimmingView.frame = containerView!.bounds
    }
}
