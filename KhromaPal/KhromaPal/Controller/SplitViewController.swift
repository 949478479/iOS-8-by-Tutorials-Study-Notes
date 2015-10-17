//
//  SplitViewController.swift
//  KhromaPal
//
//  Created by 从今以后 on 15/10/17.
//  Copyright © 2015年 RayWenderlich. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    func splitViewController(splitViewController: UISplitViewController,
        collapseSecondaryViewController secondaryViewController: UIViewController,
        ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {

        /*  regular width 转换到 compact width 时,会调用此方法.
            这意味着 iPad 设备不会调用, iPhone 设备只会一开始调用一次, iPhone plus 设备每次横屏到竖屏时都会调用.
            如果返回 false, splitViewController 会调用 primary view controller 的
            collapseSecondaryViewController(_:forSplitViewController:) 方法,大多数控制器默认不做任何操作,
            但是 UINavigationController 会 push secondary view controller.
            如果返回 true, 则表示已自行处理, splitViewController 就不会去调用相关方法了.
            此方法返回后, splitViewController 会从 viewControllers 数组中移除 secondary view controller,
            只保留 primary view controller 作为唯一的子控制器. */

        /*  横屏 -> 竖屏 时,只有左侧当前选中的调色盘和右侧展示的调色盘相同时,才返回 false. 
            这样切换到竖屏后,系统会将右侧的控制器 push 到导航控制器层级的顶部.
            如果不相同,例如右侧控制器展示的是"NoPaletteSelected"控制器,或者展示着某调色盘,但是左侧菜单切换了,
            只是还没选颜色,这时候返回 true. 
            这样切换到竖屏后,右侧控制器会被丢弃,导航控制器层级最顶层依旧是刚才的左侧菜单. */
        if let
            secondaryViewController = secondaryViewController as? PaletteDisplayContainer,
            displayedPalette = secondaryViewController.currentlyDisplayedPallette(),
            primaryViewController = primaryViewController as? PaletteSelectionContainer,
            selectedPalette = primaryViewController.currentlySelectedPalette()
            where selectedPalette == displayedPalette {
                return false
        }
        return true
    }

    func splitViewController(splitViewController: UISplitViewController,
        separateSecondaryViewControllerFromPrimaryViewController
        primaryViewController: UIViewController) -> UIViewController? {

        /*  此方法用于提供 splitViewController 右侧的 detail view controller.
            如果返回 nil, splitViewController 会调用 primary view controller 的
            separateSecondaryViewControllerForSplitViewController(_:) 方法.大多数控制器默认不做任何操作,
            但是 UINavigationController 会将 topViewController pop 并返回,也就意味着 splitViewController
            会将之前的 topViewController 作为 detail view controller.
            此方法返回后, splitViewController 会将 secondary view controller 添加到 viewControllers 数组.*/

        /*  竖屏 -> 横屏 时,如果当前导航层级顶部展示的是调色盘控制器,那么返回 nil, 系统会将该控制器作为右侧控制器.
            否则,返回嵌入导航控制器的自定义的 "NoPaletteSelected" 控制器,导航控制器的 topViewController pop
            后就直接被丢弃了. */
        if let primaryViewController = primaryViewController as? PaletteDisplayContainer
            where primaryViewController.currentlyDisplayedPallette() != nil {
            return nil
        }

        let vc = storyboard!.instantiateViewControllerWithIdentifier("NoPaletteSelected")
        return NavigationController(rootViewController: vc)
    }
}
