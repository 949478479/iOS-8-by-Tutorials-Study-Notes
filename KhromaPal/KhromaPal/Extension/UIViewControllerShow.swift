//
//  UIViewController.swift
//  KhromaPal
//
//  Created by 从今以后 on 15/10/17.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

extension UIViewController {

    func showViewControllerWillResultInPush(sender: UIViewController?) -> Bool {
        if let target = targetViewControllerForAction("showViewControllerWillResultInPush:", sender: sender) {
            return target.showViewControllerWillResultInPush(sender)
        }
        return false
    }

    func showDetailViewControllerWillResultInPush(sender: UIViewController?) -> Bool {
        if let target = targetViewControllerForAction("showDetailViewControllerWillResultInPush:", sender: self) {
            return target.showDetailViewControllerWillResultInPush(self)
        }
        return false
    }
}

extension UINavigationController {
    override func showViewControllerWillResultInPush(sender: UIViewController?) -> Bool {
        return true
    }
}

extension UISplitViewController {
    override func showDetailViewControllerWillResultInPush(sender: UIViewController?) -> Bool {
        return collapsed ? viewControllers.first!.showViewControllerWillResultInPush(sender) : false
    }
}
